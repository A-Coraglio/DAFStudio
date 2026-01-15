

class User(SQLModel):
    __tablename__ = "user"
    
    id: int
    user_type_id : int