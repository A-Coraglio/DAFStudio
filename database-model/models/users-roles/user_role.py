from sqlmodel import SQLModel, Field

class UserRole(SQLModel, table=True):
    __tablename__ = "user_role"
    user_id: int = Field(foreign_key="auth_user.id", primary_key=True)
    user_type_id: int = Field(foreign_key="user_type.id", primary_key=True)