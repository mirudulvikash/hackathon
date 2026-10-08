from pydantic import BaseModel, EmailStr, ConfigDict
from typing import List, Optional

class UserProfileBase(BaseModel):
    institution: Optional[str] = None
    location: Optional[str] = None
    preferences: Optional[List[str]] = []

class UserProfileCreate(UserProfileBase):
    pass

class UserProfileResponse(UserProfileBase):
    profile_id: int
    user_id: int
    model_config = ConfigDict(from_attributes=True)


class UserBase(BaseModel):
    name: str
    email: EmailStr
    role: str

class UserCreate(UserBase):
    password: str

class UserResponse(UserBase):
    user_id: int
    profile: Optional[UserProfileResponse] = None
    model_config = ConfigDict(from_attributes=True)
    
class AuthLogin(BaseModel):
    email: EmailStr
    password: str

class UserRegisterRequest(BaseModel):
    name: str
    email: EmailStr
    password: str
    role: str
    institution: Optional[str] = None
    location: Optional[str] = None


class SafetyGuidelineResponse(BaseModel):
    phase: str
    content: str
    model_config = ConfigDict(from_attributes=True)


class QuizResponse(BaseModel):
    quiz_id: int
    question: str
    options: List[str]
    correct_answer: int
    explanation: str
    model_config = ConfigDict(from_attributes=True)


class DisasterResponse(BaseModel):
    disaster_id: str
    disaster_name: str
    category: str
    short_description: str
    description: str
    causes: List[str]
    warning_signs: List[str]
    relevant_locations: List[str]
    guidelines: List[SafetyGuidelineResponse] = []
    
    recommendation_reason: Optional[str] = None
    priority_score: Optional[int] = None
    model_config = ConfigDict(from_attributes=True)


class ProgressSubmit(BaseModel):
    user_id: int
    disaster_id: str
    score: int
    total_questions: int


class ProgressResponse(BaseModel):
    disaster_id: str
    completion_percentage: float
    completed_status: bool
    model_config = ConfigDict(from_attributes=True)


class UserProgressResponse(BaseModel):
    overall_completion_percentage: float
    topics: List[ProgressResponse]
    weak_areas: List[str]
    recommended_next_topic: Optional[str] = None
    model_config = ConfigDict(from_attributes=True)
