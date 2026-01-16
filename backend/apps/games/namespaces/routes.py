

from fastapi import APIRouter

router : APIRouter = APIRouter(prefix="/api")



#example route
@router.get("/get-sports/",responses={
        200: {
            "model": dict,
            "description": "Successful response"
        }
    })
async def get_sports():
    
    return [{}]
    