import streamlit as st
import requests
import os

# --- 화면 구성 ---
st.title("좌석 예약")

user_id = st.text_input("USER ID:")

try:
    if user_id != "":
        user_id = int(user_id)
    else:
        st.error("학번을 입력해주세요.")
        st.stop()
except ValueError:
    st.error("정수를 입력해주세요.")
    st.stop()

# --- 좌석 상태 초기화 및 서버 연동 ---
FASTAPI_URL = os.environ.get("FASTAPI_URL", "http://127.0.0.1:8000")
try:
    response = requests.get(f"{FASTAPI_URL}/seats/status")
    response.raise_for_status()  # 에러 발생 시 예외 처리
    st.session_state.seats = response.json()

    data = requests.get(f"{FASTAPI_URL}/seat/?user_id={user_id}").json()
    if data.get("my_seat") is not None:
        st.session_state.my_seat = int(data.get('my_seat'))
    else:
        st.session_state.my_seat = -1
except requests.exceptions.RequestException as e:
    st.error(f"좌석 정보를 가져오는 중 오류 발생: {e}")
    st.stop()  # 앱 중단

# 좌석 선택 버튼 및 상태 표시
for i, seat in enumerate(st.session_state.seats):
    col1, col2 = st.columns(2)

    with col1:
        st.write(f"{i+1}번 좌석")

    with col2:
        if seat == 0:  # 예약 가능
            if st.button(f"예약하기", key=f"seatR_{i+1}",disabled=st.session_state.my_seat != -1):
                try:
                    response = requests.put(f"{FASTAPI_URL}/reserve/?seat_number={i}&user_id={user_id}")
                    response.raise_for_status()
                    st.session_state.seats = response.json()
                    st.rerun()
                except requests.exceptions.RequestException as e:
                    st.error(f"좌석 예약 중 오류 발생: {e}")
        elif i == st.session_state.my_seat:
            st.button(f"이용 중", key=f"seat_{i+1}", disabled=True)
        else:  # 예약 완료
            st.button(f"예약불가", key=f"seat_{i+1}", disabled=True)

if st.button("새로고침"):
    st.rerun()