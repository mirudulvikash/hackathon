from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import List, Optional
from passlib.context import CryptContext

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
    db = next(get_db())
    seed.seed_data(db)

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

@app.post("/api/auth/register", response_model=schemas.UserResponse)
def register(user_req: schemas.UserRegisterRequest, db: Session = Depends(get_db)):
    db_user = db.query(models.User).filter(models.User.email == user_req.email).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
        
    new_user = models.User(
        name=user_req.name,
        email=user_req.email,
        password_hash=pwd_context.hash(user_req.password),
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
    if not db_user or not pwd_context.verify(auth.password, db_user.password_hash):
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
    result = models.QuizResult(
        user_id=submit.user_id,
        disaster_id=submit.disaster_id,
        score=submit.score,
        total_questions=submit.total_questions
    )
    db.add(result)
    
    score_percent = (submit.score / submit.total_questions) * 100
    
    progress = db.query(models.Progress).filter_by(user_id=submit.user_id, disaster_id=submit.disaster_id).first()
    if not progress:
        progress = models.Progress(user_id=submit.user_id, disaster_id=submit.disaster_id)
        db.add(progress)
    
    if score_percent >= 60:
        progress.completion_percentage = 100.0
        progress.completed_status = True
    elif progress.completion_percentage < 75.0:
        progress.completion_percentage = max(progress.completion_percentage, 75.0)
        
    db.commit()
    db.refresh(progress)
    
    return progress

@app.get("/api/progress/{user_id}", response_model=schemas.UserProgressResponse)
def get_analytics(user_id: int, db: Session = Depends(get_db)):
    progress_records = db.query(models.Progress).filter(models.Progress.user_id == user_id).all()
    
    all_disasters = db.query(models.Disaster).all()
    total_disasters = len(all_disasters)
    
    overall = sum([p.completion_percentage for p in progress_records]) / total_disasters if total_disasters > 0 else 0
    
    weak_areas = []
    results = db.query(models.QuizResult).filter(models.QuizResult.user_id == user_id).all()
    for r in results:
        if (r.score / r.total_questions) * 100 < 60:
            if r.disaster_id not in weak_areas:
                weak_areas.append(r.disaster_id)

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
        topics=progress_records,
        weak_areas=weak_areas,
        recommended_next_topic=recommended_next_topic
    )
