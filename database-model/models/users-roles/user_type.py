from sqlmodel import SQLModel, Field

class UserType(SQLModel, table=True):
    __tablename__ :str = "user_type" # type: ignore
    id: int = Field(primary_key=True)
    name: str = Field(max_length=50)