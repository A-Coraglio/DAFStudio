from sqlmodel import SQLModel, Field

class Admin(SQLModel, table=True):
    id: int = Field(primary_key=True)
    user_id: int = Field(foreign_key="user.id", unique=True)