from enums import Status, TimeLimit


class Seat:
    def __init__(self, seat_number: int, coordinates: tuple, status=Status.AVAILABLE, user_id=-1):
        """
        seat_number (int): 
        고유한 자리 식별 번호 

        coordinates (tuple): 
        카메라 상에서 보이는 정규화된 좌표 (x1, y1, x2, y2, x3, y3, x4, y4) 
        0과 1 사이의 정규화된 값을 가져야함.
        Top left: (x1,y1) / Top right: (x2,y2) / Bottom right: (x3,y3) / Bottom left: (x4,y4)

        status_id (Status):
        현재 자리의 상태를 나타냅니다.
        AVAILABLE : 예약 가능
        IN_USE : 사용 중
        UNAUTHORIZED_USE : 무단 이용 중
        RESERVED_WAITING_ENTRY : 예약 됨, 입실 대기
        CHECKING_OUT : 퇴실 예정
        TEMPORARILY_EMPTY : 자리 비움
                    
        user_id (int): 
        만약 자리를 사용하고 있다면, 사용중인 사람의 user id
        사용중이지 않다면, -1
        """
        self.seat_number = seat_number
        self.coordinates = coordinates
        self.status = status
        self.user_id = user_id

        self.is_person = False
        self.is_luggage = False
        self.waited_time = 0

    def status_update(self):
        """
        분당 반복되야하는 함수. status를 업데이트 한다.
        """
        if self.status == Status.TEMPORARILY_EMPTY:
            self.waited_time += 1
            if self.waited_time > TimeLimit.TEMPORARILY_EMPTY:
                self.waited_time = 0
                # 관리자 연락
                # 이용자 경고, 벌점
                self.status = Status.CHECKING_OUT
                return
        elif self.status == Status.CHECKING_OUT:
            self.waited_time += 1
            if self.waited_time > TimeLimit.CHECKING_OUT:
                self.waited_time = 0
                # 퇴실 처리
                self.status = Status.AVAILABLE
                self.user_id = -1
                return

        if self.is_person:  # 사람이 있는가?
            if self.status in (Status.RESERVED_WAITING_ENTRY, Status.IN_USE, Status.CHECKING_OUT):
                self.status = Status.IN_USE
                return
            else:
                # 관리자 연락
                self.status = Status.UNAUTHORIZED_USE
                return
        else:
            if self.status == Status.RESERVED_WAITING_ENTRY:
                self.waited_time += 1
                if self.waited_time > TimeLimit.RESERVED_WAITING_ENTRY:
                    self.waited_time = 0
                    # 퇴실 처리
                    self.status = Status.AVAILABLE
                    self.user_id = -1
                    return
                else:
                    self.status = Status.RESERVED_WAITING_ENTRY
                    return
            elif self.status == Status.IN_USE or self.status == Status.TEMPORARILY_EMPTY:
                if self.is_luggage:  # 짐이 있는가?
                    self.status = Status.TEMPORARILY_EMPTY
                    return
                else:
                    # 퇴실 처리
                    self.status = Status.AVAILABLE
                    self.user_id = -1
                    return
            elif self.status == Status.CHECKING_OUT:
                if self.is_luggage:  # 짐이 있는가?
                    self.status = Status.CHECKING_OUT
                    return
                else:
                    # 퇴실 처리
                    self.status = Status.AVAILABLE
                    self.user_id = -1
                    return
            elif self.is_luggage:  # 짐이 있는가?
                # 관리자 연락
                self.status = Status.UNAUTHORIZED_USE
                return
            else:
                # 퇴실 처리
                self.status = Status.AVAILABLE
                self.user_id = -1
                return
