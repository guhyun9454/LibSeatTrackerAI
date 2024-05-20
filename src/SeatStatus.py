from enum import IntEnum


class SeatStatus(IntEnum):
    AVAILABLE = 0  # 예약 가능
    IN_USE = 1  # 사용 중
    UNAUTHORIZED_USE = 2  # 무단 이용 중
    RESERVED_WAITING_ENTRY = 3  # 예약 됨, 입실 대기
    CHECKING_OUT = 4  # 퇴실 예정
    TEMPORARILY_EMPTY = 5  # 자리 비움

state_colors = {
    SeatStatus.AVAILABLE: "green",
    SeatStatus.IN_USE: "blue",
    SeatStatus.UNAUTHORIZED_USE: "red",
    SeatStatus.RESERVED_WAITING_ENTRY: "yellow",
    SeatStatus.CHECKING_OUT: "orange",
    SeatStatus.TEMPORARILY_EMPTY: "purple"
}

class TimeLimit(IntEnum):
    RESERVED_WAITING_ENTRY = 5  # k분 제한
    TEMPORARILY_EMPTY = 5  # n분 제한
    CHECKING_OUT = 5  # m분 제한