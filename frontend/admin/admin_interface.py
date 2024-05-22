import streamlit as st
import cv2
import numpy as np
import requests
import base64
import time
import sys


BACKEND_URL = "http://127.0.0.1:8000"
print("page reloaded")
if 'time_passed' not in st.session_state:
    st.session_state['time_passed'] = 0

def send_image_to_server(image, reserved_waiting_entry, temporarily_empty, checking_out,
                         conf_threshold, iou_threshold):
    try:
        _, encoded_img = cv2.imencode('.jpg', image)
        files = {'file': ('image.jpg', encoded_img.tobytes(), 'image/jpeg')}
        response = requests.post(f"{BACKEND_URL}/detect", files=files,
                                params={"reserved_waiting_entry": reserved_waiting_entry, 
                                        "temporarily_empty": temporarily_empty, 
                                        "checking_out": checking_out,
                                        "conf_threshold": conf_threshold,
                                        "iou_threshold": iou_threshold})
        response.raise_for_status()

        response_data = response.json()["image"]
        return base64.b64decode(response_data)
    except requests.exceptions.RequestException as e:
        print(f"Request failed: {e}")
        return None

def get_seat_diagram():
    try:
        response = requests.get(f"{BACKEND_URL}/draw")
        response.raise_for_status()
        response_data = response.json()["image"]
        return base64.b64decode(response_data)
    except requests.exceptions.RequestException as e:
        print(f"Request failed: {e}")
        return None

@st.cache_resource
def load_VideoCapture(type):
    print("Loading webcam")
    return cv2.VideoCapture(type)

# 관리자 페이지 화면 설정
st.title("REDDOT Demo")
time_show = st.empty()
col1, col2 = st.columns(2)
with col1:
    st_frame_col1 = st.empty()
with col2:
    st_frame_col2 = st.empty()
reserved_waiting_entry = st.sidebar.number_input("Reserved Waiting Entry Time (minutes)", min_value=1, value=5)
st.sidebar.write("예약 후 최대 대기 시간")

temporarily_empty = st.sidebar.number_input("Temporarily Empty Time (minutes)", min_value=1, value=5)
st.sidebar.write("가능한 최대 자리비움 시간")

checking_out = st.sidebar.number_input("Checking Out Time (minutes)", min_value=1, value=5)
st.sidebar.write("최대 자리비움 시간이 지나고, 퇴실까지 대기시간")

conf_threshold = st.sidebar.slider("Confidence Threshold", 0.3, 1.0, 0.6) 
st.sidebar.write("탐지 확률이 얼마나 높아야 객체로 판별할지 설정합니다.")

iou_threshold = st.sidebar.slider("IOU Threshold", 0.0, 1.0, 0.15) 
st.sidebar.write("사람이나 짐이 얼마나 많이 겹쳐야 그 자리에 있다고 판별할지 설정합니다.")


cap = load_VideoCapture(0)  # 웹캠

try:
    while cap.isOpened():
        time.sleep(1) #실제로는 1분

        success, image = cap.read()
        sys.stdout.write(f"\rtime passed: {st.session_state.time_passed} minutes, cap: {success}")
        sys.stdout.flush()
        time_show.text(f"Time passed: {st.session_state.time_passed} minutes")        
        st.session_state.time_passed +=1

        if success:
            resized_image = cv2.resize(image, (640, 480))

            processed_image = send_image_to_server(resized_image, reserved_waiting_entry, temporarily_empty, checking_out,
                                                   conf_threshold, iou_threshold)
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
# finally:
#     print("cap realeased")
#     cap.release()
