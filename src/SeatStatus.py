from enum import IntEnum


class SeatStatus(IntEnum):
    AVAILABLE = 0  # 예약 가능
    IN_USE = 1  # 사용 중
    UNAUTHORIZED_USE = 2  # 무단 이용 중
    RESERVED_WAITING_ENTRY = 3  # 예약 됨, 입실 대기
    CHECKING_OUT = 4  # 퇴실 예정
    TEMPORARILY_EMPTY = 5  # 자리 비움
