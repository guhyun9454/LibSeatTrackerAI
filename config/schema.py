from pydantic import BaseModel


class SeatBase(BaseModel):
    seat_number: int
    seat_status: int


class SeatWithoutUserID(SeatBase):
    class Config:
        orm_mode = True
        fields = {
            "user_id": None
        }


class SeatWithUserID(SeatBase):
    user_id: int

    class Config:
        orm_mode = True
