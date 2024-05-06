class Seat:
    def __init__(self, seat_number, coordinates, status=0, user_id=None):
        """
        seat_number (int): 
        고유한 자리 식별 번호 

        coordinates (tuple): 
        카메라 상에서 보이는 정규화된 좌표 (x1, y1, x2, y2, x3, y3, x4, y4) 
        0과 1 사이의 정규화된 값을 가져야함.
        Top left: (x1,y1) / Top right: (x2,y2) / Bottom right: (x3,y3) / Bottom left: (x4,y4)

        status_id (int): 
        현재 자리의 상태를 나타냅니다.
        0: 예약 가능
        1: 사용 중
        2: 무단 이용 중
        3: 예약 됨, 입실 대기
        4: 퇴실 예정
        5: 자리 비움
                    
        user_id (int): 
        만약 자리를 사용하고 있다면, 사용중인 사람의 user id
        사용중이지 않다면, None
        """
        self.seat_number = seat_number
        self.coordinates = coordinates
        self.status = status
        self.user_id = user_id
