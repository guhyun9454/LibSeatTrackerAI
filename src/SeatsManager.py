import cv2
import numpy as np
from .Seat import Seat
from .Colors import get_color, state_colors

class SeatsManager:
    """
    여러 자리를 관리하는 객체
    도식화한 diagram도 가짐.
    """

    def __init__(self, diagram_sz, background_color="white"):
        self.seats = []
        self.width ,self.height = diagram_sz
        self.background_color = get_color(background_color)
        self.image = np.full((self.height, self.width, 3), self.background_color, dtype=np.uint8)
    
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
            color_name = self.get_color_by_state(seat.status)
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
            seat_text = f"Seat {seat.seat_number}"
            status_text = f"Status: {seat.status.name}"
            person_text = "Person: Yes" if seat.is_person else "Person: No"
            luggage_text = "Luggage: Yes" if seat.is_luggage else "Luggage: No"
            
            cv2.putText(self.image, seat_text, (cx - 50, cy - 30), cv2.FONT_HERSHEY_SIMPLEX, 0.6, get_color("black"), 2)
            cv2.putText(self.image, status_text, (cx - 50, cy - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.6, get_color("black"), 2)
            cv2.putText(self.image, person_text, (cx - 50, cy + 10), cv2.FONT_HERSHEY_SIMPLEX, 0.6, get_color("black"), 2)
            cv2.putText(self.image, luggage_text, (cx - 50, cy + 30), cv2.FONT_HERSHEY_SIMPLEX, 0.6, get_color("black"), 2)
    
    def get_color_by_state(self, state):
        return state_colors.get(state, "black")