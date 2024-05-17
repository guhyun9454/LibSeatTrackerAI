import streamlit as st
from ultralytics import YOLO
import cv2
import numpy as np
import math
import os

from src.SeatDiagram import SeatDiagram
from src.SeatStatus import Status
from src.Seat import Seat

device = "mps" if os.uname().sysname == 'Darwin' else None
model_path = "yolo_weights/yolov8s.pt"
image_size = (640, 480)

@st.cache_resource
def load_model(model_path):
    print(f"model loaded successfully from {model_path}")
    return YOLO(model_path)

@st.cache_resource
def load_VideoCapture(type):
    return cv2.VideoCapture(0)

@st.cache_resource
def init_Seat(seat_num,coordinates):
    return Seat(seat_num,coordinates)

# Streamlit app setup
st.title("REDDOT Demo")
conf_threshold = st.sidebar.slider("Confidence Threshold", 0.3, 1.0, 0.6)

#cache를 통해 새로고침해도 계속 사용
model = load_model(model_path) #ai 모델
cap = load_VideoCapture(1) #웹캠

#자리 설정
Seat1 = init_Seat(seat_num=1,coordinates=((80, 150), (280, 150), (280, 330), (80, 330)))
Seat2 = init_Seat(seat_num=2,coordinates=((360, 150), (560, 150), (560, 330), (360, 330)))

col1,col2 = st.columns(2)

try:
    with col1:
        st_frame_col1 = st.empty()
    with col2:
        st_frame_col2 = st.empty()
    
    while (cap.isOpened()):
        success, image = cap.read()
        if success:
            #리사이징
            resized_image = cv2.resize(image, image_size)

            #모델 추론
            res = model.predict(resized_image, conf=conf_threshold, 
                                verbose = False, classes = [0,39,41,62,63,64,66,67,73],
                                device = device, imgsz = image_size[::-1]) 

            #사진에 객체탐지 결과를 그림
            res = res[0].plot()

            #구역들을 그림
            Seat1.DetectArea.draw(res, color_name = "dark_red", alpha = 0.5)
            Seat2.DetectArea.draw(res, color_name = "dark_blue", alpha = 0.35)
            
            diagram = SeatDiagram(imgsz=(640,480), background_color="white")
            diagram.add_seat(Seat1)
            diagram.add_seat(Seat2)
            diagram.draw_seats()


            #streamlit에 업데이트
            #카메라
            with col1:
                st_frame_col1.image(res, caption='Detected Video', channels="BGR")
            #자리 도식화
            with col2:
                st_frame_col2.image(diagram.image, caption='Seat Diagram', channels="BGR")

except Exception as e:
    st.sidebar.error("Error loading video: " + str(e))  