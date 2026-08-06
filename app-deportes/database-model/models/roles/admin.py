from sqlmodel import SQLModel, Field

class Admin(SQLModel, table=True):
    __tablename__ = "admin" # type: ignore
    id: int = Field(primary_key=True)
    user_id: int = Field(foreign_key="auth_user.id", unique=True)