from sqlmodel import SQLModel, Field

class UserRole(SQLModel, table=True):  
    user_id: int = Field(foreign_key="user.id", primary_key=True)
    user_type_id: int = Field(foreign_key="user_type.id", primary_key=True)