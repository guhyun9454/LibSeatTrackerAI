from .SeatStatus import SeatStatus
import numpy as np
import cv2
from .Colors import get_color

class DetectArea:
    def __init__(self,coordinates):
        self.polygon = np.array(coordinates, np.int32).reshape((-1, 1, 2))
    
    def draw(self, img, color_name, alpha = 0.5):
        """
        원본 이미지에 구역을 그림

        img (np.ndarray):
        구역을 그릴 원본 이미지

        color_name (str):
        구역을 칠할 색상

        aplha (int): 
        투명도
        """
        overlay = img.copy()
        color = get_color(color_name)

        cv2.fillPoly(overlay, [self.polygon], color)
        cv2.addWeighted(overlay, alpha, img, 1 - alpha, 0, img)

class Seat:
    def __init__(self, seat_id: int, coordinates: tuple, status=SeatStatus.AVAILABLE, user_id=-1):
        """
        DetectArea (DetectArea객체):
        자리의 카메라상의 구역을 나타내는 객체

        seat_number (int): 
        고유한 자리 식별 번호 

        coordinates (tuple): 
        ((x1, y1), (x2, y2), (x3, y3), (x4, y4)) 
        Top left: (x1,y1) / Top right: (x2,y2) / Bottom right: (x3,y3) / Bottom left: (x4,y4)

        status_id (Status):
        현재 자리의 상태를 나타냅니다. SeatStatus.py 참조
                    
        user_id (int): 
        만약 자리를 사용하고 있다면, 사용중인 사람의 user id
        사용중이지 않다면, -1
        """
        self.DetectArea = DetectArea(coordinates)
        self.seat_id = seat_id
        self.status = status
        self.user_id = user_id

        self.is_person = False
        self.is_luggage = False
        self.waited_time = 0
        self.luggage_waited_time = 0

    def check_in(self, user_id : int): # 입실 처리 과정
        if self.status == SeatStatus.AVAILABLE:
            self.status = SeatStatus.RESERVED_WAITING_ENTRY
            self.user_id = user_id
            return True
        return False

    def check_out(self): # 퇴실 처리 과정
        self.user_id = -1
        # 관리자 페이지에 update
        return

    def report_to_admin(self): # 관리자 연락 처리 과정
        # 관리자 페이지에 update
        return

    def penalize_user(self): # 이용자 경고, 벌점 처리 과정
        return
