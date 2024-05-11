from sqlalchemy import Column, Integer, String
from config.database import Base


class Seat(Base):
    __tablename__ = "seat"
    seat_number = Column(Integer, primary_key=True, nullable=False)
    seat_status = Column(Integer, nullable=False)
    user_id = Column(Integer, nullable=False)