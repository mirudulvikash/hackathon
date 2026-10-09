from sqlalchemy.orm import Session
from models import Disaster, SafetyGuideline, Quiz, User, UserProfile, Progress, QuizResult
from database import engine, Base
import bcrypt

def get_password_hash(password: str) -> str:
    salt = bcrypt.gensalt()
    return bcrypt.hashpw(password.encode('utf-8'), salt).decode('utf-8')

def seed_data(db: Session):
    Base.metadata.create_all(bind=engine)

    if db.query(Disaster).first():
        return # Database already seeded

    print("Seeding database...")

    disasters_data = [
        {
            "id": "d1",
            "name": "Flood",
            "category": "Natural",
            "short_desc": "Prepare for floods and learn how to stay safe during heavy rains.",
            "desc": "Floods are the most frequent type of natural disaster and occur when an overflow of water submerging land that is usually dry.",
            "causes": ["Heavy rainfall", "River overflow", "Dam failures"],
            "warning_signs": ["Continuous heavy rain", "Rising river levels"],
            "locations": ["Coimbatore", "Chennai", "Nilgiris"]
        },
        {
            "id": "d2",
            "name": "Earthquake",
            "category": "Natural",
            "short_desc": "Learn how to stay safe before, during and after an earthquake.",
            "desc": "An earthquake is a sudden release of energy in the Earth's crust that creates seismic waves.",
            "causes": ["Tectonic plate movements", "Volcanic activity"],
            "warning_signs": ["Ground shaking", "Unusual animal behavior"],
            "locations": ["Coimbatore", "Salem"]
        },
        {
            "id": "d3",
            "name": "Cyclone",
            "category": "Natural",
            "short_desc": "Be prepared for cyclones and follow safety guidelines during storms.",
            "desc": "Cyclones are characterized by inward spiraling winds that rotate counterclockwise.",
            "causes": ["Warm ocean waters", "Atmospheric instability"],
            "warning_signs": ["High winds", "Dark heavy sky", "Sudden drop in pressure"],
            "locations": ["Chennai", "Kanyakumari", "Coimbatore"]
        },
        {
            "id": "d4",
            "name": "Landslide",
            "category": "Natural",
            "short_desc": "Understand landslide risks and learn how to stay safe in hilly areas.",
            "desc": "Landslides include rock falls, deep failure of slopes, and shallow debris flows.",
            "causes": ["Heavy rain", "Earthquakes", "Deforestation"],
            "warning_signs": ["Cracks on slopes", "Tilting trees"],
            "locations": ["Nilgiris", "Coimbatore"]
        },
        {
            "id": "d5",
            "name": "Fire Accidents",
            "category": "Man-Made",
            "short_desc": "Understand fire safety measures and learn how to respond in case of fire.",
            "desc": "Fire accidents can happen due to negligence, electrical faults, or accidents.",
            "causes": ["Short circuits", "Gas leaks", "Carelessness"],
            "warning_signs": ["Smoke", "Burning smell", "Sparks"],
            "locations": ["Coimbatore", "Chennai", "Madurai"]
        },
        {
            "id": "d6",
            "name": "Electrical/Lab Accidents",
            "category": "Man-Made",
            "short_desc": "Stay safe around electricity and learn lab safety procedures.",
            "desc": "Laboratory or electrical accidents often involve chemical spills or electrocution.",
            "causes": ["Chemical mishandling", "Faulty wiring"],
            "warning_signs": ["Chemical smell", "Flickering lights", "Frayed wires"],
            "locations": ["Coimbatore", "Chennai", "Tiruchirappalli"]
        }
    ]

    for d_data in disasters_data:
        disaster = Disaster(
            disaster_id=d_data["id"],
            disaster_name=d_data["name"],
            category=d_data["category"],
            short_description=d_data["short_desc"],
            description=d_data["desc"],
            causes=d_data["causes"],
            warning_signs=d_data["warning_signs"],
            relevant_locations=d_data["locations"]
        )
        db.add(disaster)
        db.commit()
        db.refresh(disaster)

        # Basic guidelines
        guidelines = [
            {"phase": "before", "content": "Prepare an emergency kit. Know your evacuation routes."},
            {"phase": "during", "content": "Stay calm and follow official protocols. Move to a safe location."},
            {"phase": "after", "content": "Wait for official clearance before returning. Check for injuries."},
            {"phase": "precautions", "content": "Keep important documents safe and accessible."},
            {"phase": "avoid", "content": "Do not panic or spread unverified rumors."}
        ]
        for g in guidelines:
            guide = SafetyGuideline(disaster_id=disaster.disaster_id, phase=g["phase"], content=g["content"])
            db.add(guide)
        
        # Quizzes
        quizzes = [
            {"q": f"What is a common cause of {disaster.disaster_name}?", "opts": d_data["causes"] + ["None of the above"], "ans": 0, "exp": f"{d_data['causes'][0]} is a primary cause."},
            {"q": f"Which location is prone to {disaster.disaster_name}?", "opts": d_data["locations"] + ["Moon"], "ans": 0, "exp": f"{d_data['locations'][0]} is prone to this."},
            {"q": f"What should you avoid during a {disaster.disaster_name}?", "opts": ["Panicking", "Staying quiet", "Listening to radio", "Helping others"], "ans": 0, "exp": "Panicking leads to poor decisions."},
            {"q": f"What is a warning sign of {disaster.disaster_name}?", "opts": ["Clear skies"] + d_data["warning_signs"] + ["Loud music"], "ans": 1, "exp": "Always watch out for warning signs."}
        ]
        for q in quizzes:
            quiz = Quiz(disaster_id=disaster.disaster_id, question=q["q"], options=q["opts"], correct_answer=q["ans"], explanation=q["exp"])
            db.add(quiz)
        
        db.commit()

    # Seed Demo User
    demo_user = User(
        name="Demo Learner",
        email="demo@munnarivu.com",
        password_hash=get_password_hash("demo123"),
        role="College Student"
    )
    db.add(demo_user)
    db.commit()
    db.refresh(demo_user)

    profile = UserProfile(
        user_id=demo_user.user_id,
        institution="Coimbatore Tech",
        location="Coimbatore",
        preferences=["Natural", "Man-Made"]
    )
    db.add(profile)
    
    # Progress
    p1 = Progress(user_id=demo_user.user_id, disaster_id="d1", completion_percentage=100.0, completed_status=True)
    p2 = Progress(user_id=demo_user.user_id, disaster_id="d2", completion_percentage=50.0, completed_status=False)
    p3 = Progress(user_id=demo_user.user_id, disaster_id="d5", completion_percentage=100.0, completed_status=True)
    db.add_all([p1, p2, p3])

    qr1 = QuizResult(user_id=demo_user.user_id, disaster_id="d1", score=4, total_questions=4)
    qr2 = QuizResult(user_id=demo_user.user_id, disaster_id="d5", score=4, total_questions=4)
    db.add_all([qr1, qr2])

    db.commit()
    print("Database seeded successfully with disasters, guidelines, quizzes, and demo user!")
