from sqlmodel import SQLModel, Field

class TeacherSport(SQLModel, table=True):
    __tablename__ = "teacher_sport"
    teacher_id: int = Field(foreign_key="teacher.id", primary_key=True)
    sport_id: int = Field(foreign_key="sports.id", primary_key=True)