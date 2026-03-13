from sqlmodel import SQLModel, Field

class UserType(SQLModel, table=True):
    id: int = Field(primary_key=True)
    name: str = Field(max_length=50)