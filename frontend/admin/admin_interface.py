import streamlit as st
import cv2
import numpy as np
import requests
import base64
import time
import pandas as pd

def send_image_to_server(image, reserved_waiting_entry, temporarily_empty, checking_out,
                         conf_threshold, iou_threshold, detect_classes):
    try:
        _, encoded_img = cv2.imencode('.jpg', image)
        files = {'file': ('image.jpg', encoded_img.tobytes(), 'image/jpeg')}
        response = requests.post(f"{BACKEND_URL}/update", files=files,
                                params={"reserved_waiting_entry": reserved_waiting_entry, 
                                        "temporarily_empty": temporarily_empty, 
                                        "checking_out": checking_out,
                                        "conf_threshold": conf_threshold,
                                        "iou_threshold": iou_threshold,
                                        "detect_classes": detect_classes})
        response.raise_for_status()

        return response.json()["message"] == "Update successful"
    except requests.exceptions.RequestException as e:
        print(f"Request failed: {e}")
        return None

def get_seat_diagram():
    try:
        response = requests.get(f"{BACKEND_URL}/diagram")
        response.raise_for_status()
        response_data = response.json()["image"]
        return base64.b64decode(response_data)
    except requests.exceptions.RequestException as e:
        print(f"Request failed: {e}")
        return None

def get_plot_image():
    try:
        response = requests.get(f"{BACKEND_URL}/plot")
        response.raise_for_status()
        response_data = response.json()["image"]
        return base64.b64decode(response_data)
    except requests.exceptions.RequestException as e:
        print(f"Request failed: {e}")
        return None
    
def get_all_users():
    try:
        response = requests.get(f"{BACKEND_URL}/users")
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Request failed: {e}")
        return []

@st.cache_resource
def load_VideoCapture(type):
    print("Loading webcam")
    return cv2.VideoCapture(type)

#초기 세팅
BACKEND_URL = "http://127.0.0.1:8000"
detect_items = {
    "backpack :briefcase:": 24,
    "handbag :handbag:": 26,
    "bottle :cup_with_straw:": 39,
    "cup :beer:": 41,
    "pizza :pizza:": 53,
    "laptop	:computer:": 63,
    "mouse :three_button_mouse:": 64,
    "keyboard :keyboard:": 66,
    "cell phone :iphone:": 67,
    "book :book:": 73,
    "teddy bear :teddy_bear:": 77
}
print("page reloaded")
if 'time_passed' not in st.session_state:
    st.session_state['time_passed'] = 0


# 관리자 페이지 화면 설정
st.title("REDDOT Highfidelity Prototype")
time_show = st.empty()
col1, col2 = st.columns(2)
with col1:
    st_frame_col1 = st.empty()
with col2:
    st_frame_col2 = st.empty()
user_frame = st.empty()
reserved_waiting_entry = st.sidebar.number_input("MAX_WAITING4ENTRY (minutes)", min_value=1, value=5)
st.sidebar.write("예약 후 입실까지 최대 대기 시간")
temporarily_empty = st.sidebar.number_input("MAX_TEMPORARILY_EMPTY  (minutes)", min_value=1, value=5)
st.sidebar.write("가능한 최대 자리비움 시간")
checking_out = st.sidebar.number_input("MAX_CHECKING_OUT  (minutes)", min_value=1, value=5)
st.sidebar.write("최대 자리비움 시간이 지나고, 퇴실까지 대기시간")
checking_out = st.sidebar.number_input("MAX_WITHOUT_LUGGAGE (minutes)", min_value=1, value=5)
st.sidebar.write("짐이 없는 경우 자동 퇴실까지 대기 시간")
conf_threshold = st.sidebar.slider("Confidence Threshold", 0.3, 1.0, 0.6) 
st.sidebar.write("ai 모델의 확률이 얼마나 높아야 객체로 판별할지 설정합니다.")
iou_threshold = st.sidebar.slider("IOU Threshold", 0.0, 1.0, 0.15) 
st.sidebar.write("사람과 짐이 자리와 얼마나 많이 겹쳐야 그 자리에 있다고 판별할지 설정합니다.")
st.sidebar.divider()
st.sidebar.write("탐지할 객체를 선택합니다.")
selected_classes = [index for item, index in detect_items.items() if st.sidebar.checkbox(item,value=True)]

cap = load_VideoCapture(0)  # 웹캠

try:
    while cap.isOpened():
        delay_time = 1 
        time.sleep(delay_time)

        success, image = cap.read()
        print(f"time passed: {st.session_state.time_passed} minutes, cap: {success}")
        time_show.text(f"Time passed: {st.session_state.time_passed} minutes")        
        st.session_state.time_passed +=1

        if success:
            resized_image = cv2.resize(image, (640, 480))
            update_success = send_image_to_server(image, reserved_waiting_entry, temporarily_empty, checking_out,
                                                  conf_threshold, iou_threshold, selected_classes)
            plot_image = get_plot_image()
            seat_diagram = get_seat_diagram()

            print(f"    update_success: {update_success}, plot_image: {plot_image is not None}, seat_diagram: {seat_diagram is not None}")
            
            #디코딩
            if update_success and plot_image is not None and seat_diagram is not None:
                processed_image = np.frombuffer(plot_image, np.uint8)
                processed_image = cv2.imdecode(processed_image, cv2.IMREAD_COLOR)
                seat_diagram = np.frombuffer(seat_diagram, np.uint8)
                seat_diagram = cv2.imdecode(seat_diagram, cv2.IMREAD_COLOR)

                with col1:
                    st_frame_col1.image(processed_image, caption='CCTV', channels="BGR", use_column_width=True)
                with col2:
                    st_frame_col2.image(seat_diagram, caption='Diagram', channels="BGR", use_column_width=True)

            users_data = get_all_users()
            if users_data:
                users_df = pd.DataFrame(users_data)
                user_frame.table(users_df)

except Exception as e:
    st.sidebar.error("Error: " + str(e))
