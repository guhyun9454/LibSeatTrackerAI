import numpy as np
import cv2
from .Colors import get_color

class DetectArea:
    def __init__(self,p1,p2,p3,p4):
        """
        자리의 카메라상의 구역을 나타내는 객체

        p1, p2, p3, p4 (tuple):
        4개의 좌표쌍 (x: int, y: int) 
        좌측 상단(p1), 우측 상단(p2), 우측 하단(p3), 좌측 하단(p4)
        왼쪽 모서리가 (0,0)
        
        """
        self.polygon = np.array([p1, p2, p3, p4], np.int32).reshape((-1, 1, 2))
    
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

