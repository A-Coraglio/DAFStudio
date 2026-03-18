from sqlmodel import SQLModel, Field

class Court(SQLModel, table=True):
    id: int = Field(primary_key=True, index=True)
    club_id: int = Field(foreign_key="club.id")
    sport_id: int = Field(foreign_key="sports.id")
    name: str = Field(max_length=50)
    price_per_hour: float
    is_indoor: bool = False
    is_active: bool = True