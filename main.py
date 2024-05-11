from fastapi import FastAPI, HTTPException
from fastapi.responses import RedirectResponse
import asyncio
import uvicorn

from Seat import Seat

number_of_seats = 10
seats = []

app = FastAPI()

@app.get("/")
async def root():
    return RedirectResponse(url="/seats/")

@app.get("/seats/")
async def get_seats():
    return [seat.status for seat in seats]

@app.put("/seats/")
async def reserve_seats(seat_number: int, user_id: int):
    seat = seats[seat_number]
    if seat.check_in(user_id):
        return {"message": "Seat reserved successfully"}
    else:
        raise HTTPException(status_code=404, detail="Seat isn't available")

def initialize_seats():
    for i in range(number_of_seats):
        _seat = Seat(seat_number=i, coordinates=()) # 초기 설정
        seats.append(_seat)

async def seat_loop_task(): # status 및 사람과 짐 유무 업데이트
    while True:
        for seat in seats:
            seat.status_update()
        await asyncio.sleep(60) # 60초마다 반복

def start_uvicorn(loop):
    config = uvicorn.Config(app, loop=loop, host="localhost", port=8000)
    server = uvicorn.Server(config)
    loop.run_until_complete(server.serve())

def start_seat_app(loop):
    loop.create_task(seat_loop_task())

if __name__ == "__main__":
    initialize_seats()

    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    start_seat_app(loop)
    start_uvicorn(loop)