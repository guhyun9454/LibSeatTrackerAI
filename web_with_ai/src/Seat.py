from .SeatStatus import Status, TimeLimit
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
    def __init__(self, seat_number: int, coordinates: tuple, status=Status.AVAILABLE, user_id=-1):
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
        self.seat_number = seat_number
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
                self.report_to_admin() # 관리자 연락
                self.penalize_user() # 이용자 경고, 벌점
                self.status = Status.CHECKING_OUT
                return
        elif self.status == Status.CHECKING_OUT:
            self.waited_time += 1
            if self.waited_time > TimeLimit.CHECKING_OUT:
                self.waited_time = 0
                self.check_out() # 퇴실 처리
                self.status = Status.AVAILABLE
                return

        if self.is_person:  # 사람이 있는가?
            if self.status in (Status.RESERVED_WAITING_ENTRY, Status.IN_USE, Status.CHECKING_OUT):
                self.status = Status.IN_USE
                return
            else:
                self.report_to_admin() # 관리자 연락
                self.status = Status.UNAUTHORIZED_USE
                return
        else:
            if self.status == Status.RESERVED_WAITING_ENTRY:
                self.waited_time += 1
                if self.waited_time > TimeLimit.RESERVED_WAITING_ENTRY:
                    self.waited_time = 0
                    self.check_out() # 퇴실 처리
                    self.status = Status.AVAILABLE
                    return
                else:
                    self.status = Status.RESERVED_WAITING_ENTRY
                    return
            elif self.status in (Status.IN_USE, Status.TEMPORARILY_EMPTY):
                if self.is_luggage: # 짐이 있는가?
                    self.status = Status.TEMPORARILY_EMPTY
                    return
                else:
                    self.check_out() # 퇴실 처리
                    self.status = Status.AVAILABLE
                    return
            elif self.status == Status.CHECKING_OUT:
                if self.is_luggage: # 짐이 있는가?
                    self.status = Status.CHECKING_OUT
                    return
                else:
                    self.check_out() # 퇴실 처리
                    self.status = Status.AVAILABLE
                    return
            elif self.is_luggage: # 짐이 있는가?
                self.report_to_admin() # 관리자 연락
                self.status = Status.UNAUTHORIZED_USE
                return
            else:
                self.check_out() # 퇴실 처리
                self.status = Status.AVAILABLE
                return

    def check_in(self, user_id : int): # 입실 처리 과정
        if self.status == Status.AVAILABLE:
            self.status = Status.RESERVED_WAITING_ENTRY
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
