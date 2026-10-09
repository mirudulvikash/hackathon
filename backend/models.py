from sqlalchemy import Column, Integer, String, Float, Boolean, ForeignKey, Text, JSON
from sqlalchemy.orm import relationship
from database import Base

class User(Base):
    __tablename__ = "users"

    user_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    name = Column(String(100), nullable=False)
    email = Column(String(150), unique=True, index=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    role = Column(String(50), nullable=False) # e.g., 'Student', 'Staff'

    profile = relationship("UserProfile", back_populates="user", uselist=False)
    progress_records = relationship("Progress", back_populates="user")
    quiz_results = relationship("QuizResult", back_populates="user")
    activity_logs = relationship("ActivityLog", back_populates="user")
    achievements = relationship("Achievement", back_populates="user")


class UserProfile(Base):
    __tablename__ = "user_profiles"

    profile_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("users.user_id"), unique=True, nullable=False)
    institution = Column(String(200))
    location = Column(String(100))
    preferences = Column(JSON) # JSON/Text

    user = relationship("User", back_populates="profile")


class Disaster(Base):
    __tablename__ = "disasters"

    disaster_id = Column(String(50), primary_key=True, index=True) # E.g., 'd1'
    disaster_name = Column(String(150), nullable=False)
    category = Column(String(50), nullable=False) # 'Natural' or 'Man-Made'
    short_description = Column(Text, nullable=False)
    description = Column(Text, nullable=False)
    causes = Column(JSON, nullable=False)
    warning_signs = Column(JSON, nullable=False)
    relevant_locations = Column(JSON, nullable=False)

    guidelines = relationship("SafetyGuideline", back_populates="disaster")
    quizzes = relationship("Quiz", back_populates="disaster")
    progress_records = relationship("Progress", back_populates="disaster")
    quiz_results = relationship("QuizResult", back_populates="disaster")


class SafetyGuideline(Base):
    __tablename__ = "safety_guidelines"

    guideline_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    disaster_id = Column(String(50), ForeignKey("disasters.disaster_id"), nullable=False)
    phase = Column(String(50), nullable=False) # 'before', 'during', 'after', 'precautions', 'avoid'
    content = Column(Text, nullable=False)

    disaster = relationship("Disaster", back_populates="guidelines")


class Quiz(Base):
    __tablename__ = "quizzes"

    quiz_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    disaster_id = Column(String(50), ForeignKey("disasters.disaster_id"), nullable=False)
    question = Column(Text, nullable=False)
    options = Column(JSON, nullable=False) # JSON list of strings
    correct_answer = Column(Integer, nullable=False) # int index
    explanation = Column(Text, nullable=False)

    disaster = relationship("Disaster", back_populates="quizzes")


class Progress(Base):
    __tablename__ = "progress"

    progress_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("users.user_id"), nullable=False)
    disaster_id = Column(String(50), ForeignKey("disasters.disaster_id"), nullable=False)
    completion_percentage = Column(Float, default=0.0)
    completed_status = Column(Boolean, default=False)

    user = relationship("User", back_populates="progress_records")
    disaster = relationship("Disaster", back_populates="progress_records")


class QuizResult(Base):
    __tablename__ = "quiz_results"

    result_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("users.user_id"), nullable=False)
    disaster_id = Column(String(50), ForeignKey("disasters.disaster_id"), nullable=False)
    score = Column(Integer, nullable=False)
    total_questions = Column(Integer, nullable=False)

    user = relationship("User", back_populates="quiz_results")
    disaster = relationship("Disaster", back_populates="quiz_results")


class ActivityLog(Base):
    __tablename__ = "activity_logs"

    log_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("users.user_id"), nullable=False)
    activity_date = Column(String(10), nullable=False, index=True) # "YYYY-MM-DD"
    disaster_id = Column(String(50), nullable=True)
    activity_type = Column(String(50), default="lesson") # "lesson", "quiz"

    user = relationship("User", back_populates="activity_logs")


class Achievement(Base):
    __tablename__ = "achievements"

    achievement_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("users.user_id"), nullable=False)
    badge_key = Column(String(50), nullable=False) # "first_step", "silver_badge", "safety_champion", "champion_100"
    title = Column(String(150), nullable=False)
    unlocked_at = Column(String(30), nullable=False)
    certificate_id = Column(String(100), nullable=True)

    user = relationship("User", back_populates="achievements")

