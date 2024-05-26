import cv2
import numpy as np
from typing import List
from .Seat import Seat
from .SeatStatus import SeatStatus
from .Colors import get_color, state_colors
from .IoU import calculate_iou
from .UsersManager import UsersManager

class SeatsManager:
    """
    여러 자리를 관리하는 객체
    도식화한 diagram도 가짐.
    """
    seats: List[Seat]
    def __init__(self, diagram_sz, users_manager: UsersManager, background_color= "white"):
        self.seats = []
        self.width ,self.height = diagram_sz
        self.background_color = get_color(background_color)
        self.plot = None
        self.image = np.full((self.height, self.width, 3), self.background_color, dtype=np.uint8)
        self.users_manager = users_manager
    
    def add_seat(self, seat: Seat):
        """
        관리할 Seat 객체를 추가함
        """
        self.seats.append(seat)
    
    def draw_seats(self):
        """
        관리중인 Seats를 image에 도식화하여 그림.
        """
        self.image = np.full((self.height, self.width, 3), self.background_color, dtype=np.uint8)
        for seat in self.seats:
            color_name = state_colors.get(seat.status)
            color = get_color(color_name)
            cv2.fillPoly(self.image, [seat.DetectArea.polygon], color)
            
            # 사각형의 중심을 계산
            moments = cv2.moments(seat.DetectArea.polygon)
            if moments['m00'] != 0:
                cx = int(moments['m10'] / moments['m00'])
                cy = int(moments['m01'] / moments['m00'])
            else:
                cx, cy = 0, 0

            # seat number와 상태, 사람 유무 및 짐 유무를 표시
            seat_text = f"Seat {seat.seat_id}"
            status_text = f"Status: {seat.status.name}"
            person_text = "Person: Yes" if seat.is_person else "Person: No"
            luggage_text = "Luggage: Yes" if seat.is_luggage else "Luggage: No"
            user_text = f"User: {seat.user_id}"

            cv2.putText(self.image, seat_text, (cx - 100, cy - 50), cv2.FONT_HERSHEY_SIMPLEX, 0.8, get_color("black"), 2)
            cv2.putText(self.image, status_text, (cx - 100, cy - 15), cv2.FONT_HERSHEY_SIMPLEX, 0.8, get_color("black"), 2)
            cv2.putText(self.image, person_text, (cx - 100, cy + 15), cv2.FONT_HERSHEY_SIMPLEX, 0.8, get_color("black"), 2)
            cv2.putText(self.image, luggage_text, (cx - 100, cy + 50), cv2.FONT_HERSHEY_SIMPLEX, 0.8, get_color("black"), 2)
            cv2.putText(self.image, user_text, (cx - 100, cy + 85), cv2.FONT_HERSHEY_SIMPLEX, 0.8, get_color("black"), 2)


    def update_all_seats(self,model_result,iou_threshold,MAX_WAITING4ENTRY,MAX_TEMPORARILY_EMPTY,MAX_CHECKING_OUT,MAX_WITHOUT_LUGGAGE):
        for seat in self.seats :
            seat.is_person = False
            seat.is_luggage = False
            for result in model_result[0].boxes:
                cls = int(result.cls[0])
                iou = calculate_iou(seat.DetectArea.polygon.reshape(-1)[[0, 1, 4, 5]], result.xyxy[0])
                if cls == 0 and iou > iou_threshold:  # 사람
                    seat.is_person = True
                elif cls != 0 and iou > iou_threshold:  # 짐
                    seat.is_luggage = True
            self.status_update(seat,MAX_WAITING4ENTRY,MAX_TEMPORARILY_EMPTY, MAX_CHECKING_OUT, MAX_WITHOUT_LUGGAGE)

    def status_update(self, Seat: Seat, MAX_WAITING4ENTRY = 5 ,MAX_TEMPORARILY_EMPTY = 5, MAX_CHECKING_OUT = 5, MAX_WITHOUT_LUGGAGE = 5):
        """
        분당 반복되야하는 함수. Seat의 status를 업데이트 한다.
        """
        if Seat.status == SeatStatus.TEMPORARILY_EMPTY:
            Seat.waited_time += 1
            if Seat.waited_time > MAX_TEMPORARILY_EMPTY:
                Seat.waited_time = 0
                Seat.report_to_admin() # 관리자 연락
                Seat.penalize_user() # 이용자 경고, 벌점
                Seat.status = SeatStatus.CHECKING_OUT
                return
        elif Seat.status == SeatStatus.CHECKING_OUT:
            Seat.waited_time += 1
            if Seat.waited_time > MAX_CHECKING_OUT:
                Seat.waited_time = 0
                self.users_manager.check_out(Seat.user_id) # 퇴실 처리
                Seat.user_id = -1
                Seat.status = SeatStatus.AVAILABLE
                return

        if Seat.is_person:  # 사람이 있는가?
            if Seat.status in (SeatStatus.RESERVED_WAITING_ENTRY, SeatStatus.IN_USE, SeatStatus.CHECKING_OUT, SeatStatus.TEMPORARILY_EMPTY):
                Seat.status = SeatStatus.IN_USE
                Seat.waited_time = 0
                return
            else:
                Seat.report_to_admin() # 관리자 연락
                Seat.status = SeatStatus.UNAUTHORIZED_USE
                return
        else:
            if Seat.status == SeatStatus.RESERVED_WAITING_ENTRY:
                Seat.waited_time += 1
                if Seat.waited_time > MAX_WAITING4ENTRY:
                    Seat.waited_time = 0
                    self.users_manager.check_out(Seat.user_id) # 퇴실 처리
                    Seat.user_id = -1
                    Seat.status = SeatStatus.AVAILABLE
                    return
                else:
                    Seat.status = SeatStatus.RESERVED_WAITING_ENTRY
                    return
            elif Seat.status in (SeatStatus.IN_USE, SeatStatus.TEMPORARILY_EMPTY):
                if Seat.is_luggage: # 짐이 있는가?
                    Seat.luggage_waited_time = 0 # 검토 안됨
                    Seat.status = SeatStatus.TEMPORARILY_EMPTY
                    return
                else:
                    Seat.luggage_waited_time += 1
                    if Seat.luggage_waited_time > MAX_WITHOUT_LUGGAGE: # MAX_WITHOUT_LUGGAGE번의 update 동안 짐이 없으면 자리비움 진행
                        Seat.luggage_waited_time = 0
                        self.users_manager.check_out(Seat.user_id) # 퇴실 처리
                        Seat.user_id = -1
                        Seat.status = SeatStatus.AVAILABLE
                        return
                    else:
                        return
            elif Seat.status == SeatStatus.CHECKING_OUT:
                if Seat.is_luggage: # 짐이 있는가?
                    Seat.luggage_waited_time = 0 # 검토 안됨
                    Seat.status = SeatStatus.CHECKING_OUT
                    return
                else:
                    Seat.luggage_waited_time += 1
                    if Seat.luggage_waited_time > MAX_WITHOUT_LUGGAGE: # 3번의 update 동안 짐이 없으면 자리비움 진행
                        Seat.luggage_waited_time = 0
                        self.users_manager.check_out(Seat.user_id) # 퇴실 처리
                        Seat.user_id = -1
                        Seat.status = SeatStatus.AVAILABLE
                        return
                    else:
                        return
            elif Seat.is_luggage: # 짐이 있는가?
                Seat.report_to_admin() # 관리자 연락
                Seat.status = SeatStatus.UNAUTHORIZED_USE
                return
            else:
                self.users_manager.check_out(Seat.user_id) # 퇴실 처리
                Seat.user_id = -1 
                Seat.status = SeatStatus.AVAILABLE
                return
            
    