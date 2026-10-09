from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import List, Optional
import bcrypt
import os
from datetime import datetime, date, timedelta
try:
    import google.generativeai as genai
except Exception as e:
    genai = None

from database import get_db, engine, Base
import models, schemas, seed

app = FastAPI(title="Munnarivu API", description="Disaster Awareness & Preparedness Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
def on_startup():
    Base.metadata.create_all(bind=engine)
    db = next(get_db())
    seed.seed_data(db)

def get_password_hash(password: str) -> str:
    salt = bcrypt.gensalt()
    return bcrypt.hashpw(password.encode('utf-8'), salt).decode('utf-8')

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return bcrypt.checkpw(plain_password.encode('utf-8'), hashed_password.encode('utf-8'))

@app.post("/api/auth/register", response_model=schemas.UserResponse)
def register(user_req: schemas.UserRegisterRequest, db: Session = Depends(get_db)):
    db_user = db.query(models.User).filter(models.User.email == user_req.email).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
        
    new_user = models.User(
        name=user_req.name,
        email=user_req.email,
        password_hash=get_password_hash(user_req.password),
        role=user_req.role
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    new_profile = models.UserProfile(
        user_id=new_user.user_id,
        institution=user_req.institution,
        location=user_req.location,
        preferences=[]
    )
    db.add(new_profile)
    
    # Initialize progress
    all_disasters = db.query(models.Disaster).all()
    for d in all_disasters:
        prog = models.Progress(
            user_id=new_user.user_id,
            disaster_id=d.disaster_id,
            completion_percentage=0.0,
            completed_status=False
        )
        db.add(prog)
        
    db.commit()
    db.refresh(new_user)
    
    return new_user

@app.post("/api/auth/login", response_model=schemas.UserResponse)
def login(auth: schemas.AuthLogin, db: Session = Depends(get_db)):
    db_user = db.query(models.User).filter(models.User.email == auth.email).first()
    if not db_user or not verify_password(auth.password, db_user.password_hash):
        raise HTTPException(status_code=401, detail="Invalid email or password")
    return db_user

@app.post("/api/users/profile", response_model=schemas.UserProfileResponse)
def create_or_update_profile(profile_data: schemas.UserProfileBase, user_id: int = 1, db: Session = Depends(get_db)):
    # Default to user_id 1 since auth isn't fully implemented
    profile = db.query(models.UserProfile).filter(models.UserProfile.user_id == user_id).first()
    if profile:
        for var, value in vars(profile_data).items():
            if value is not None:
                setattr(profile, var, value)
    else:
        profile = models.UserProfile(
            user_id=user_id,
            **profile_data.dict()
        )
        db.add(profile)
    db.commit()
    db.refresh(profile)
    return profile

@app.get("/api/users/{user_id}/profile", response_model=schemas.UserProfileResponse)
def get_profile(user_id: int, db: Session = Depends(get_db)):
    profile = db.query(models.UserProfile).filter(models.UserProfile.user_id == user_id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")
    return profile

@app.get("/api/disasters", response_model=List[schemas.DisasterResponse])
def get_disasters(category: Optional[str] = None, location: Optional[str] = None, db: Session = Depends(get_db)):
    query = db.query(models.Disaster)
    if category:
        query = query.filter(models.Disaster.category == category)
    disasters = query.all()
    
    if location:
        disasters = [d for d in disasters if location in d.relevant_locations]
        
    return disasters

@app.get("/api/recommendations/{location}", response_model=List[schemas.DisasterResponse])
def get_recommendations(location: str, user_id: Optional[int] = 1, db: Session = Depends(get_db)):
    disasters = db.query(models.Disaster).all()
    
    progress_map = {}
    quiz_map = {}
    if user_id:
        for p in db.query(models.Progress).filter(models.Progress.user_id == user_id).all():
            progress_map[p.disaster_id] = p.completed_status
            
        for r in db.query(models.QuizResult).filter(models.QuizResult.user_id == user_id).all():
            score_percent = (r.score / r.total_questions) * 100
            if r.disaster_id not in quiz_map or score_percent > quiz_map[r.disaster_id]:
                quiz_map[r.disaster_id] = score_percent

    response_list = []
    
    for d in disasters:
        score = 0
        is_location = location in d.relevant_locations
        is_incomplete = False
        is_weak = False
        
        if is_location:
            score += 50
            
        if user_id:
            if not progress_map.get(d.disaster_id, False):
                score += 30
                is_incomplete = True
                
            best_score = quiz_map.get(d.disaster_id)
            if best_score is not None and best_score < 60:
                score += 40
                is_weak = True
                
        d_dict = schemas.DisasterResponse.model_validate(d).model_dump()
        d_dict['priority_score'] = score
        
        if is_location and is_weak:
            d_dict['recommendation_reason'] = f"High priority for {location} & needs quiz review"
        elif is_weak:
            d_dict['recommendation_reason'] = "Retake recommended: Quiz score below 60%"
        elif is_location:
            d_dict['recommendation_reason'] = f"Recommended for {location} region"
        elif is_incomplete:
            d_dict['recommendation_reason'] = "Next incomplete topic in your learning path"
        else:
            d_dict['recommendation_reason'] = None
            
        # Only recommend if score > 0
        if score > 0:
            response_list.append(d_dict)
            
    response_list.sort(key=lambda x: x['priority_score'], reverse=True)
    return response_list

@app.get("/api/quizzes/{disaster_id}", response_model=List[schemas.QuizResponse])
def get_quizzes(disaster_id: str, db: Session = Depends(get_db)):
    quizzes = db.query(models.Quiz).filter(models.Quiz.disaster_id == disaster_id).all()
    return quizzes

@app.post("/api/quizzes/submit", response_model=schemas.ProgressResponse)
def submit_quiz(submit: schemas.ProgressSubmit, db: Session = Depends(get_db)):
    # Validate target user_id to prevent foreign key errors
    db_user = db.query(models.User).filter(models.User.user_id == submit.user_id).first()
    if not db_user:
        db_user = db.query(models.User).first()
        target_user_id = db_user.user_id if db_user else submit.user_id
    else:
        target_user_id = submit.user_id

    result = models.QuizResult(
        user_id=target_user_id,
        disaster_id=submit.disaster_id,
        score=submit.score,
        total_questions=submit.total_questions
    )
    db.add(result)
    score_percent = (submit.score / submit.total_questions) * 100 if submit.total_questions > 0 else 0.0
    progress = db.query(models.Progress).filter_by(user_id=target_user_id, disaster_id=submit.disaster_id).first()
    if not progress:
        progress = models.Progress(
            user_id=target_user_id, 
            disaster_id=submit.disaster_id,
            completion_percentage=0.0,
            completed_status=False
        )
        db.add(progress)
    
    if score_percent >= 60:
        progress.completion_percentage = 100.0
        progress.completed_status = True
    elif progress.completion_percentage < 75.0:
        progress.completion_percentage = max(progress.completion_percentage, 75.0)
        
    db.commit()
    db.refresh(progress)
    
    # Log active learning day for user
    today_str = date.today().strftime("%Y-%m-%d")
    existing_act = db.query(models.ActivityLog).filter_by(user_id=target_user_id, activity_date=today_str).first()
    if not existing_act:
        act_log = models.ActivityLog(user_id=target_user_id, activity_date=today_str, disaster_id=submit.disaster_id, activity_type="quiz")
        db.add(act_log)
        db.commit()
        
    calculate_user_streaks_and_achievements(target_user_id, db)
    
    return progress

@app.get("/api/progress/{user_id}", response_model=schemas.UserProgressResponse)
def get_analytics(user_id: int, db: Session = Depends(get_db)):
    progress_records = db.query(models.Progress).filter(models.Progress.user_id == user_id).all()
    
    all_disasters = db.query(models.Disaster).all()
    total_disasters = len(all_disasters)
    
    overall = sum([p.completion_percentage for p in progress_records]) / total_disasters if total_disasters > 0 else 0
    
    weak_areas = []
    quiz_best = {}
    results = db.query(models.QuizResult).filter(models.QuizResult.user_id == user_id).all()
    for r in results:
        score_percent = (r.score / r.total_questions) * 100
        if r.disaster_id not in quiz_best or score_percent > quiz_best[r.disaster_id]:
           quiz_best[r.disaster_id] = score_percent
        if score_percent < 60 and r.disaster_id not in weak_areas:
            weak_areas.append(r.disaster_id)

    topics_assessed = len(quiz_best)
    avg_score = sum(quiz_best.values()) / topics_assessed if topics_assessed > 0 else 0.0

    profile = db.query(models.UserProfile).filter(models.UserProfile.user_id == user_id).first()
    user_location = profile.location if profile else ""
    
    recommended_next_topic = None
    completed_ids = [p.disaster_id for p in progress_records if p.completion_percentage == 100.0]
    for d in all_disasters:
        if d.disaster_id not in completed_ids and user_location in d.relevant_locations:
            recommended_next_topic = d.disaster_id
            break

    return schemas.UserProgressResponse(
        overall_completion_percentage=overall,
        topics_assessed_count=topics_assessed,
        average_quiz_score=avg_score,
        topics=progress_records,
        weak_areas=weak_areas,
        recommended_next_topic=recommended_next_topic
    )

# --- CHATBOT INTELLIGENCE ---

# Configure Gemini AI using environment variable
GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY", "")
if GEMINI_API_KEY and genai:
    genai.configure(api_key=GEMINI_API_KEY)

# Generation config to ensure concise, safety-first, student-friendly responses
generation_config = {
  "temperature": 0.2,
  "top_p": 0.95,
  "top_k": 40,
  "max_output_tokens": 1024,
  "response_mime_type": "text/plain",
}

SYS_PROMPT = """You are MUNNARIVU AI Assistant, a specialized disaster preparedness and safety assistant designed for students in Tamil Nadu, India.
Your objective is to help students with disaster awareness, preparedness, emergency response, evacuation, and safety precautions.
You MUST follow these rules:
1. Understand and reply in the language the student uses: English, Simple English, Tamil, or Tanglish (Tamil written in English).
2. Answer questions accurately about disasters (Flood, Cyclone, Earthquake, Fire, Tsunami, Landslides, Lightning, Heavy Rain, etc).
3. Be concise and practical. Use bullet points and numbered lists.
4. PRIORITIZE SAFETY. For dangerous scenarios, provide immediate safe actions. Do not recommend risky behavior.
5. NEVER invent emergency numbers.
6. DO NOT claim to know live disaster conditions; guide students to official alerts if they ask for live data.
7. If the user asks non-disaster related questions, politely decline and steer them back to disaster safety.
8. Retain context of the disaster and situation being discussed."""

@app.post("/api/chat", response_model=schemas.ChatResponse)
def handle_chat(request: schemas.ChatRequest):
    if not GEMINI_API_KEY:
        # Fallback if the user hasn't set up the API key to prevent crashing during demo without env vars
        return schemas.ChatResponse(reply="API Key not configured on the backend. Please set GEMINI_API_KEY in the environment to activate the live AI.")
    
    try:
        model = genai.GenerativeModel(
            model_name="gemini-1.5-flash",
            generation_config=generation_config,
            system_instruction=SYS_PROMPT,
        )
        
        # Convert incoming chat messages to the format expected by google-generativeai
        history = []
        for msg in request.messages[:-1]:
            # incoming roles are "user" or "model"
            history.append({"role": msg.role, "parts": [msg.content]})
            
        chat_session = model.start_chat(history=history)
        
        latest_message = request.messages[-1].content
        response = chat_session.send_message(latest_message)
        
        return schemas.ChatResponse(reply=response.text)
    except Exception as e:
        print("Chatbot Error:", e)
        raise HTTPException(status_code=500, detail="Failed to generate AI response. Please check backend connection and API quota.")


# --- 100-DAY ACHIEVEMENT SYSTEM ---

BADGE_DEFINITIONS = [
    {
        "key": "first_step",
        "title": "First Step",
        "required_days": 1,
        "type": "active_days"
    },
    {
        "key": "silver_badge",
        "title": "Silver Badge",
        "required_days": 7,
        "type": "streak"
    },
    {
        "key": "safety_champion",
        "title": "Safety Champion",
        "required_days": 30,
        "type": "streak"
    },
    {
        "key": "champion_100",
        "title": "MUNNARIVU Disaster Preparedness Champion",
        "required_days": 100,
        "type": "streak"
    },
]

def calculate_user_streaks_and_achievements(user_id: int, db: Session, custom_today: Optional[date] = None):
    logs = db.query(models.ActivityLog).filter(models.ActivityLog.user_id == user_id).order_by(models.ActivityLog.activity_date.asc()).all()
    
    unique_dates = sorted(list(set([datetime.strptime(log.activity_date, "%Y-%m-%d").date() for log in logs])))
    
    total_active_days = len(unique_dates)
    first_lesson_date = unique_dates[0].strftime("%Y-%m-%d") if unique_dates else None
    last_activity_date = unique_dates[-1].strftime("%Y-%m-%d") if unique_dates else None
    
    today_dt = custom_today or date.today()
    
    current_streak = 0
    longest_streak = 0
    
    if unique_dates:
        temp_streak = 1
        longest_streak = 1
        for i in range(1, len(unique_dates)):
            if (unique_dates[i] - unique_dates[i-1]).days == 1:
                temp_streak += 1
            else:
                temp_streak = 1
            if temp_streak > longest_streak:
                longest_streak = temp_streak
                
        latest_date = unique_dates[-1]
        if latest_date == today_dt or latest_date == (today_dt - timedelta(days=1)):
            c_streak = 1
            idx = len(unique_dates) - 1
            while idx > 0 and (unique_dates[idx] - unique_dates[idx-1]).days == 1:
                c_streak += 1
                idx -= 1
            current_streak = c_streak
        else:
            current_streak = 0
            
    existing_achievements = db.query(models.Achievement).filter(models.Achievement.user_id == user_id).all()
    unlocked_map = {ach.badge_key: ach for ach in existing_achievements}
    
    newly_unlocked = []
    now_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    for b in BADGE_DEFINITIONS:
        key = b["key"]
        req = b["required_days"]
        b_type = b["type"]
        
        is_eligible = False
        if b_type == "active_days" and total_active_days >= req:
            is_eligible = True
        elif b_type == "streak" and (current_streak >= req or longest_streak >= req):
            is_eligible = True
            
        if is_eligible and key not in unlocked_map:
            cert_id = None
            if key == "champion_100":
                cert_id = f"MUN-CHAMP-{user_id}-{int(datetime.now().timestamp())}"
                
            new_ach = models.Achievement(
                user_id=user_id,
                badge_key=key,
                title=b["title"],
                unlocked_at=now_str,
                certificate_id=cert_id
            )
            db.add(new_ach)
            db.commit()
            db.refresh(new_ach)
            unlocked_map[key] = new_ach
            newly_unlocked.append(new_ach)
            
    achievements_resp = []
    certificate_id = None
    certificate_unlocked = False
    
    for b in BADGE_DEFINITIONS:
        key = b["key"]
        if key in unlocked_map:
            ach_item = unlocked_map[key]
            achievements_resp.append(schemas.AchievementResponse(
                badge_key=key,
                title=b["title"],
                unlocked=True,
                unlocked_at=ach_item.unlocked_at,
                certificate_id=ach_item.certificate_id
            ))
            if key == "champion_100":
                certificate_id = ach_item.certificate_id
                certificate_unlocked = True
        else:
            achievements_resp.append(schemas.AchievementResponse(
                badge_key=key,
                title=b["title"],
                unlocked=False,
                unlocked_at=None,
                certificate_id=None
            ))
            
    newly_unlocked_resp = [
        schemas.AchievementResponse(
            badge_key=a.badge_key,
            title=a.title,
            unlocked=True,
            unlocked_at=a.unlocked_at,
            certificate_id=a.certificate_id
        ) for a in newly_unlocked
    ]
    
    return schemas.UserAchievementsResponse(
        user_id=user_id,
        current_streak=current_streak,
        longest_streak=longest_streak,
        total_active_days=total_active_days,
        first_lesson_date=first_lesson_date,
        last_activity_date=last_activity_date,
        achievements=achievements_resp,
        newly_unlocked=newly_unlocked_resp,
        certificate_id=certificate_id,
        certificate_unlocked=certificate_unlocked
    )

@app.post("/api/achievements/log-activity", response_model=schemas.UserAchievementsResponse)
def log_activity(req: schemas.ActivityLogSubmit, db: Session = Depends(get_db)):
    db_user = db.query(models.User).filter(models.User.user_id == req.user_id).first()
    if not db_user:
        db_user = db.query(models.User).first()
        target_user_id = db_user.user_id if db_user else req.user_id
    else:
        target_user_id = req.user_id

    act_date = req.custom_date or date.today().strftime("%Y-%m-%d")
    
    existing = db.query(models.ActivityLog).filter_by(
        user_id=target_user_id,
        activity_date=act_date
    ).first()
    
    if not existing:
        log = models.ActivityLog(
            user_id=target_user_id,
            activity_date=act_date,
            disaster_id=req.disaster_id,
            activity_type=req.activity_type or "lesson"
        )
        db.add(log)
        db.commit()
        
    custom_dt = datetime.strptime(act_date, "%Y-%m-%d").date() if req.custom_date else None
    return calculate_user_streaks_and_achievements(target_user_id, db, custom_today=custom_dt)

@app.get("/api/achievements/{user_id}", response_model=schemas.UserAchievementsResponse)
def get_user_achievements(user_id: int, db: Session = Depends(get_db)):
    db_user = db.query(models.User).filter(models.User.user_id == user_id).first()
    if not db_user:
        db_user = db.query(models.User).first()
        target_user_id = db_user.user_id if db_user else user_id
    else:
        target_user_id = user_id
    return calculate_user_streaks_and_achievements(target_user_id, db)

@app.get("/api/achievements/{user_id}/certificate", response_model=schemas.CertificateResponse)
def get_certificate(user_id: int, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.user_id == user_id).first()
    if not user:
        user = db.query(models.User).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
    ach = db.query(models.Achievement).filter_by(user_id=user.user_id, badge_key="champion_100").first()
    if not ach or not ach.certificate_id:
        raise HTTPException(status_code=400, detail="100-Day Champion achievement not yet unlocked")
        
    return schemas.CertificateResponse(
        certificate_id=ach.certificate_id,
        student_name=user.name,
        title="MUNNARIVU DISASTER PREPAREDNESS CHAMPION",
        subtitle="Awarded in recognition of completing the 100-Day Disaster Preparedness Learning Challenge.",
        issue_date=ach.unlocked_at[:10] if ach.unlocked_at else date.today().strftime("%Y-%m-%d"),
        total_days=100
    )

