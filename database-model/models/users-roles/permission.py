from sqlmodel import SQLModel, Field

class Permission(SQLModel, table=True):
    id: int = Field(primary_key=True)
    name: str = Field(max_length=100)  # "create_tournament", "manage_court", etc.
    user_type_id: int = Field(foreign_key="user_type.id")