from sqlmodel import SQLModel, Field

class Club(SQLModel, table=True):
    __tablename__ = "club" # type: ignore
    id: int = Field(primary_key=True, index=True)
    owner_id: int = Field(foreign_key="auth_user.id")
    name: str = Field(max_length=100)
    address: str
    city: str
    description: str | None = None