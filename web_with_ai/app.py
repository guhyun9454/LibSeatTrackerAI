import streamlit as st
from ultralytics import YOLO
import cv2
import numpy as np
import math

from src.ClassNames import classNames
from src.DetectArea import DetectArea
# from src.Seat import DetectArea


@st.cache_resource
def load_model(model_path):
    print("model loaded successfully")
    return YOLO(model_path)

@st.cache_resource
def load_VideoCapture(type):
    return cv2.VideoCapture(0)

@st.cache_resource
def init_DetectArea(p1,p2,p3,p4):
    return DetectArea(p1,p2,p3,p4)

# Streamlit app setup
st.title("REDDOT Demo")
conf_threshold = st.sidebar.slider("Confidence Threshold", 0.3, 1.0, 0.6)

#cache를 통해 새로고침해도 계속 사용
model = load_model("webcam_demo/yolov8s.pt") #ai 모델
cap = load_VideoCapture(0) #웹캠

#구역 설정
area1 = init_DetectArea((80, 150), (280, 150), (280, 330), (80, 330))
area2 = init_DetectArea((360, 150), (560, 150), (560, 330), (360, 330))


try:
    st_frame = st.empty()
    while (cap.isOpened()):
        success, image = cap.read()
        if success:
            #모델 추론
            res = model.predict(image, conf=conf_threshold, verbose = False, classes = [0,39,41,62,63,64,66,67,73]) 

            #사진에 객체탐지 결과를 그림
            pp = res[0].plot()

            #구역들을 그림
            area1.draw(pp, color_name = "dark_red", alpha = 0.5)
            area2.draw(pp, color_name = "dark_blue", alpha = 0.35)
            

            #streamlit에 업데이트
            st_frame.image(pp, caption='Detected Video', channels="BGR", use_column_width=True)
        else:
            cap.release()
            break
except Exception as e:
    st.sidebar.error("Error loading video: " + str(e))  