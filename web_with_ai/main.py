import streamlit as st
from ultralytics import YOLO
import cv2
import numpy as np
import math
import platform

from src.SeatsManager import SeatsManager
from src.SeatStatus import Status
from src.Seat import Seat

device = "mps" if platform.system() == 'Darwin' else None
model_path = "yolo_weights/yolov8s.pt"
image_size = (640, 480)

@st.cache_resource
def load_model(model_path):
    print(f"model loaded successfully from {model_path}")
    return YOLO(model_path)

@st.cache_resource
def load_VideoCapture(type):
    print("loading webcam")
    return cv2.VideoCapture(0)

@st.cache_resource
def init_Seat(seat_number, coordinates, status=Status.AVAILABLE, user_id=-1):
    return Seat(seat_number,coordinates, status, user_id)

# Streamlit app setup
st.title("REDDOT Demo")
conf_threshold = st.sidebar.slider("Confidence Threshold", 0.3, 1.0, 0.6)
col1,col2 = st.columns(2)
with col1:
    st_frame_col1 = st.empty()
with col2:
    st_frame_col2 = st.empty()


#cache를 통해 새로고침해도 계속 사용
model = load_model(model_path) #ai 모델
cap = load_VideoCapture(1) #웹캠

#자리 설정
Seat1 = init_Seat(seat_number=1,coordinates=((80, 150), (280, 150), (280, 330), (80, 330)))
Seat2 = init_Seat(seat_number=2,coordinates=((360, 150), (560, 150), (560, 330), (360, 330)))

#자리 관리 객체 생성
seat_manager = SeatsManager(image_size)
seat_manager.add_seat(Seat1)
seat_manager.add_seat(Seat2)


try:
    while (cap.isOpened()):
        #웹캠으로부터 한 프레임씩 불러와 처리
        success, image = cap.read()
        if success:
            #웹캠의 프레임을 리사이징
            resized_image = cv2.resize(image, image_size)

            #모델 추론
            model_result = model.predict(resized_image, conf=conf_threshold, 
                                verbose = False, classes = [0,39,41,62,63,64,66,67,73],
                                device = device, imgsz = image_size[::-1]) 

            #모델 결과를 통해 각 자리에 짐과 사람의 여부를 업데이트
            


            # <왼쪽>
            # res (np.ndarray)
            # 웹캠을 통해 객체 인식한 결과 + 각 자리의 DetectArea을 를투명하게 그림

            #사진에 객체탐지 결과를 그림
            res = model_result[0].plot()
            #구역들을 그림
            Seat1.DetectArea.draw(res, color_name = "dark_red", alpha = 0.5)
            Seat2.DetectArea.draw(res, color_name = "dark_blue", alpha = 0.35)
            
            # <오른쪽>
            # diagram.image (SeatDiagram 객체의 np.ndarray)
            # diagram 객체에 단색 배경을 만들고, Seat의 DetectArea와 동일한 위치에 
            # Colors에 지정한 상태별 색상에 따라 도식화한 사진을 저장함.

            # SeatManager을 통해 자리 상태를 도식화한 사진에 업데이트함
            seat_manager.draw_seats()


            #streamlit 화면에 업데이트
            #왼쪽:
            with col1:
                st_frame_col1.image(res, caption='Detected Video', 
                                    channels="BGR")
            #오른쪽:
            with col2:
                st_frame_col2.image(seat_manager.image, caption='Seat Diagram', 
                                    channels="BGR")

except Exception as e:
    st.sidebar.error("Error loading video: " + str(e))  