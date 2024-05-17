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
            cv2.polylines(self.image, [seat.DetectArea.polygon], isClosed=True, color=color, thickness=2)
    
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