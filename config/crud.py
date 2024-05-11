from sqlalchemy.orm import Session
from config.models import Seat
from config.schema import SeatWithoutUserID, SeatWithUserID


def get_seats(db: Session):
    seats = db.query(Seat).all()
    return [SeatWithoutUserID(seat_number=seat.seat_number, seat_status=seat.seat_status) for seat in seats]


def get_seat(db: Session, seat_number: int, is_put: bool = False):
    seat = db.query(Seat).filter(Seat.seat_number == seat_number).first()
    if is_put:
        return seat
    if seat:
        return SeatWithoutUserID(seat_number=seat.seat_number, seat_status=seat.seat_status)
    return None


def create_seat(db: Session, seat: SeatWithUserID):
    db_seat = Seat(**seat.dict())
    db.add(db_seat)
    db.commit()
    db.refresh(db_seat)
    return db_seat


def update_seat(db: Session, seat: Seat, updated_seat: SeatWithUserID):
    for key, value in updated_seat.dict().items():
        if value is not None:
            setattr(seat, key, value)
    db.commit()
    db.refresh(seat)
    return seat


def delete_seat(db: Session, item: Seat):
    db.delete(item)
    db.commit()
