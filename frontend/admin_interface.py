import streamlit as st
import cv2
import numpy as np
import requests
import base64
import time

def send_image_to_server(image):
    _, encoded_img = cv2.imencode('.jpg', image)
    files = {'file': ('image.jpg', encoded_img.tobytes(), 'image/jpeg')}
    response = requests.post("http://127.0.0.1:8000/detect", files=files)
    response_data = response.json()["image"]
    return base64.b64decode(response_data)

def get_seat_diagram():
    response = requests.get("http://127.0.0.1:8000/draw")
    response_data = response.json()["image"]
    return base64.b64decode(response_data)

@st.cache_resource
def load_VideoCapture(type):
    print("Loading webcam")
    return cv2.VideoCapture(type)

# 관리자 페이지 화면 설정
st.title("REDDOT Demo")
col1, col2 = st.columns(2)
with col1:
    st_frame_col1 = st.empty()
with col2:
    st_frame_col2 = st.empty()

cap = load_VideoCapture(0)  # 웹캠

try:
    while cap.isOpened():
        time.sleep(1)
        success, image = cap.read()
        if success:
            resized_image = cv2.resize(image, (640, 480))

            processed_image = send_image_to_server(resized_image)
            seat_diagram = get_seat_diagram()

            #디코딩
            processed_image = np.frombuffer(processed_image, np.uint8)
            processed_image = cv2.imdecode(processed_image, cv2.IMREAD_COLOR)
            seat_diagram = np.frombuffer(seat_diagram, np.uint8)
            seat_diagram = cv2.imdecode(seat_diagram, cv2.IMREAD_COLOR)

            with col1:
                st_frame_col1.image(processed_image, caption='CCTV', channels="BGR", use_column_width=True)
            with col2:
                st_frame_col2.image(seat_diagram, caption='Diagram', channels="BGR", use_column_width=True)

except Exception as e:
    st.sidebar.error("Error loading video: " + str(e))
finally:
    cap.release()
