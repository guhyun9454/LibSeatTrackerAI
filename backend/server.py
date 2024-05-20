from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.responses import RedirectResponse
from fastapi.security import APIKeyHeader
from pydantic import BaseModel
from typing import List

from src.SeatStatus import Status as SeatStatus

API_TOKEN = "SECRET_API_TOKEN"

app = FastAPI()
api_key_header = APIKeyHeader(name="Token")

class Seat(BaseModel):
    seat_number: int
    status: SeatStatus
    user_id: int

seats: List[Seat] = []

@app.get("/")
async def root():
    return RedirectResponse(url="/seats/")

@app.get("/seats/")
async def get_seats():
    return [seat.status for seat in seats]

@app.get("/seat/")
async def get_my_seat(user_id: int):
    for seat in seats:
        if seat.user_id == user_id:
            return {"my_seat" : seat.seat_number}
    raise HTTPException(status_code=404, detail="There are no seat you reserved.")

@app.put("/seats/")
async def reserve_seat(seat_number: int, user_id: int):
    if seat_number < 0 or seat_number >= len(seats):
        raise HTTPException(status_code=404, detail="Seat number isn't available")
    if seats[seat_number].status == SeatStatus.AVAILABLE:
        seats[seat_number].user_id = user_id
        seats[seat_number].status = SeatStatus.RESERVED_WAITING_ENTRY
        return {"message": "Seat reserved successfully"}
    else:
        raise HTTPException(status_code=404, detail="Seat isn't available")

async def api_token(token: str = Depends(APIKeyHeader(name="Token"))):
    if token != API_TOKEN:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN)

@app.get("/seats/admin", dependencies=[Depends(api_token)])
async def get_seats_with_id():
    return [[seat.status, seat.user_id] for seat in seats]

@app.post("/seats/admin", dependencies=[Depends(api_token)])
async def init_seat(seat_number: int):
    seats.append(Seat(seat_number=seat_number, status=SeatStatus.AVAILABLE, user_id=-1))

@app.put("/seats/admin", dependencies=[Depends(api_token)])
async def update_seat(seat_number: int, seat_status: int, user_id: int):
    if seat_number < 0 or seat_number >= len(seats):
        raise HTTPException(status_code=404, detail="Seat number isn't available")
    seats[seat_number].status = seat_status
    seats[seat_number].user_id = user_id

@app.delete("/seats/admin", dependencies=[Depends(api_token)])
async def delete_all_seat():
    seats.clear()