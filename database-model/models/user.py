from sqlmodel import SQLModel, Field

class User(SQLModel, table=True):
    __tablename__ :str= "users" # type: ignore
    id: int = Field(primary_key=True, index=True)
    name : str = Field(nullable=False,max_length=30)
        