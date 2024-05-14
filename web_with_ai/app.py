import streamlit as st
from ultralytics import YOLO
import cv2
import numpy as np
import math
from ClassNames import classNames
from functions import _display_detected_frames

@st.cache_resource
def load_model(model_path):
    print("model loaded successfully")
    return YOLO(model_path)

@st.cache_resource
def load_VideoCapture(type):
    return cv2.VideoCapture(0)

# Streamlit app setup
st.title("REDDOT Demo")
conf_threshold = st.sidebar.slider("Confidence Threshold", 0.3, 1.0, 0.6)

#cache를 통해 새로고침해도 계속 사용
model = load_model("webcam_demo/yolov8s.pt") #ai 모델
cap = load_VideoCapture(0) #웹캠

try:
    st_frame = st.empty()
    while (cap.isOpened()):
        success, image = cap.read()
        if success:
            _display_detected_frames(conf_threshold,
                                        model,
                                        st_frame,
                                        image
                                        )
        else:
            cap.release()
            break
except Exception as e:
    st.sidebar.error("Error loading video: " + str(e))  