import cv2
import numpy as np
from .Colors import get_color
from .SeatStatus import Status, state_colors
from .Seat import Seat

class SeatDiagram:
    def __init__(self, imgsz, background_color="white"):
        self.width,self.height = imgsz
        self.background_color = get_color(background_color)
        self.image = np.full((self.height, self.width, 3), self.background_color, dtype=np.uint8)
        self.seats = []

    def add_seat(self, Seat: Seat):
        self.seats.append(Seat)
    
    def draw_seats(self):
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

            # seat number and status text를 적음
            seat_text = f"Seat {seat.seat_number}"
            status_text = seat.status.name
            cv2.putText(self.image, seat_text, 
                        (cx - 50, cy - 10), cv2.FONT_HERSHEY_SIMPLEX, 
                        0.6, get_color("black"), 2)
            cv2.putText(self.image, status_text, 
                        (cx - 50, cy + 10), cv2.FONT_HERSHEY_SIMPLEX,
                        0.6, get_color("black"), 2)
            
    def get_color_by_state(self, state):
        return state_colors.get(state, "black")
    
    def add_label(self, text, position, font_scale=0.5, color_name="black", thickness=1):
        color = get_color(color_name)
        cv2.putText(self.image, text, position, cv2.FONT_HERSHEY_SIMPLEX, font_scale, color, thickness)
    
    def show_diagram(self, window_name="Seat Diagram"):
        self.draw_seats()
        cv2.imshow(window_name, self.image)
        cv2.waitKey(0)
        cv2.destroyAllWindows()