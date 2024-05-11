from fastapi import FastAPI, HTTPException, Depends
from sqlalchemy.orm import Session
from fastapi.responses import RedirectResponse
from config import crud, database, models, schema

app = FastAPI()

def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.on_event("startup")
def startup_event():
    database.create_tables()

@app.get("/")
async def root():
    return RedirectResponse(url="/seats/")

@app.get("/seats/")
async def get_seats(db: Session = Depends(get_db)):
    seats = crud.get_seats(db)
    return seats

@app.get("/seats/{seat_id}")
async def get_seat(seat_number: int, db: Session = Depends(get_db)):
    seat = crud.get_seat(db, seat_number)
    if seat is None:
        raise HTTPException(status_code=404, detail="Seat not found")
    return seat

def create_seat(item: schema.SeatWithUserID, db: Session = Depends(get_db)):
    db_seat = crud.create_seat(db, item)
    return db_seat

def update_seat(updated_item: schema.SeatWithUserID, db: Session = Depends(get_db)):
    db_seat = crud.get_seat(db, updated_item.seat_number, is_put=True)
    if db_seat is None:
        raise HTTPException(status_code=404, detail="Item not found")
    updated_item = crud.update_seat(db, db_seat, updated_item)
    return updated_item

def delete_seat(seat_id: int, db: Session = Depends(get_db)):
    db_seat = crud.get_seat(db, seat_id)
    if db_seat is None:
        raise HTTPException(status_code=404, detail="Item not found")
    crud.delete_seat(db, db_seat)
    return {"message": "Item deleted successfully"}