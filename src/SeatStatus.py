from enum import IntEnum


class Status(IntEnum):
    AVAILABLE = 0  # 예약 가능
    IN_USE = 1  # 사용 중
    UNAUTHORIZED_USE = 2  # 무단 이용 중
    RESERVED_WAITING_ENTRY = 3  # 예약 됨, 입실 대기
    CHECKING_OUT = 4  # 퇴실 예정
    TEMPORARILY_EMPTY = 5  # 자리 비움

state_colors = {
    Status.AVAILABLE: "green",
    Status.IN_USE: "blue",
    Status.UNAUTHORIZED_USE: "red",
    Status.RESERVED_WAITING_ENTRY: "yellow",
    Status.CHECKING_OUT: "orange",
    Status.TEMPORARILY_EMPTY: "purple"
}

class TimeLimit(IntEnum):
    RESERVED_WAITING_ENTRY = 5  # k분 제한
    TEMPORARILY_EMPTY = 5  # n분 제한
    CHECKING_OUT = 5  # m분 제한
