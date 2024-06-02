from fastapi import FastAPI, HTTPException, status, UploadFile, File, Query
from typing import List
from fastapi.responses import JSONResponse
from ultralytics import YOLO
import cv2
import numpy as np
import platform
import base64

from src.SeatStatus import SeatStatus
from src.SeatsManager import SeatsManager
from src.User import User
from src.UsersManager import UsersManager
from src.Seat import Seat

def ndarray_to_b64(img):
    _, encoded_img = cv2.imencode('.jpg', img)
    base64_img = base64.b64encode(encoded_img).decode('utf-8')
    return base64_img

app = FastAPI()

#초기 세팅
image_size = (640, 480)
device = "mps" if platform.system() == 'Darwin' else None
model_path = "yolo_weights/yolov8x.pt"

#유저 세팅
users_manager = UsersManager()
users_manager.add_user(User(1234,"인공지능학과","홍길동"))
users_manager.add_user(User(5678,"컴퓨터공학과","철수"))
users_manager.add_user(User(1111,"소트프웨어융합학과","영희"))

#자리 세팅 
seats_manager = SeatsManager(image_size,users_manager)
seats_manager.add_seat(Seat(seat_id = 0, coordinates= ((80, 150), (280, 150), (280, 330), (80, 330))))
seats_manager.add_seat(Seat(seat_id = 1, coordinates = ((360, 150), (560, 150), (560, 330), (360, 330))))
# seats_manager.add_seat(Seat(seat_id = 0, coordinates= ((120, 90), (520, 90), (520, 390), (120, 390)))) #영상 시연용 한 자리 세팅

#ai 모델 세팅
model = YOLO(model_path)

@app.get("/")
async def health_check():
    return True

#자리의 상태를 불러오는 APIs
@app.get("/seats/number")
async def get_number_of_seats():
    return len(seats_manager.seats)

@app.get("/seats/status")
async def get_seats_statuses():
    return [seat.status for seat in seats_manager.seats]

@app.get("/seats/id")
async def get_seats_ids():
    return [seat.seat_id for seat in seats_manager.seats]

@app.get("/seats/is_person")
async def get_seats_is_person():
    return [seat.is_person for seat in seats_manager.seats]

@app.get("/seats/is_luggage")
async def get_seats_is_luggage():
    return [seat.is_luggage for seat in seats_manager.seats]

#유저 정보를 받아오는 API
@app.post("/login")
async def login(user_id: int):
    """
    로그인 과정
    성공하면 유저 정보를 반환
    실패시 404 상태코드를 반환
    """
    user = users_manager.find_user(user_id)
    if user:
        return {"message": "User found", "user": {"user_id": user.user_id, "department": user.department, "name": user.name, "warning_count": user.warning_count}}
    else:
        raise HTTPException(status_code=404, detail="User not found")

@app.get("/usr/seat_id/")
async def get_seat_id(user_id: int):
    """
    유효하지 않은 user_id이면 실패시 404 상태코드를 반환
    user_id를 가진 유저가 현재 사용중인 좌석을 반환
    만약 아무 자리도 사용중이지 않으면 -1을 반환
    """
    user = users_manager.find_user(user_id)
    if user:
        return {"seat_id": user.seat_id}
    else:
        raise HTTPException(status_code=404, detail="User not found")

@app.get("/usr/warning_count/")
async def get_warning_count(user_id: int):
    """
    유효하지 않은 user_id이면 실패시 404 상태코드를 반환
    user_id를 가진 유저의 경고 누적 횟수를 반환
    """
    user = users_manager.find_user(user_id)
    if user:
        return {"warning_count": user.warning_count}
    else:
        raise HTTPException(status_code=404, detail="User not found")

#예약을 진행하는 API
@app.put("/reserve/")
async def reserve_seat(seat_id: int, user_id: int):
    """
    user_id를 가진 사용자가 seat_id를 가진 자리를 예약함

    동작:
    자리 객체의 상태를 입실 대기 상태로 변경함
    자리 객체에 user_id를 추가함
    유저 객체의 seat_id를 추가함
    """

    #유효하지 않은 seat_id
    if seat_id < 0 or seat_id >= len(seats_manager.seats): 
        raise HTTPException(status_code=404, detail="Seat number isn't available")
    
    #유효하지 않은 user_id
    user = users_manager.find_user(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    #자리가 사용 가능 상태가 아닌 경우
    if seats_manager.seats[seat_id].status != SeatStatus.AVAILABLE:
        raise HTTPException(status_code=404, detail="Seat isn't available")
    
    seats_manager.seats[seat_id].user_id = user_id
    seats_manager.seats[seat_id].status = SeatStatus.RESERVED_WAITING_ENTRY
    user = users_manager.find_user(user_id)
    user.seat_id = seat_id #유저가 사용중인 seat_id를 업데이트
    return {"message": "Seat reserved successfully"}

@app.get("/cancel/")
async def cancel_seat(user_id: int):
    #유효하지 않은 user_id
    user = users_manager.find_user(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    else:
        if user.seat_id == -1:
            "예약된 좌석이 없는 경우"
            raise HTTPException(status_code=404, detail="No reserved Seat")
        else:
            seats_manager.seats[user.seat_id].clear()
            user.seat_cancel()
            return {"message": "Seat canceled successfully"}
       

#admin페이지를 위한 APIs
@app.get("/users")
async def get_all_users():
    """
    모든 사용자 정보를 반환
    """
    users = [{"user_id": user.user_id, "department": user.department, "name": user.name, "warning_count": user.warning_count, "seat_id": user.seat_id} for user in users_manager.database]
    return JSONResponse(content=users)

@app.post("/update")
async def update_status_with_IMG(file: UploadFile = File(...), 
                         MAX_WAITING4ENTRY: int = 5, 
                         MAX_TEMPORARILY_EMPTY: int = 5, 
                         MAX_CHECKING_OUT: int = 5,
                         MAX_WITHOUT_LUGGAGE: int = 5,
                         conf_threshold: float = 0.6,
                         iou_threshold: float = 0.15,
                         detect_classes: List[int] = Query(...)):
    """
    받아온 카메라의 프레임으로부터 ai모델을 사용하여 객체 탐지를 수행하고, 결과를 바탕으로 모든 자리의 상태들을 업데이트함

    file: 카메라의 프레임

    [자리 상태 업데이트 알고리즘 파라미터]
    MAX_WAITING4ENTRY: 예약 후 입실까지 최대 대기 시간
    MAX_TEMPORARILY_EMPTY: 가능한 최대 자리비움 시간
    MAX_CHECKING_OUT: 최대 자리비움 시간이 지나고, 퇴실까지 대기시간
    MAX_WITHOUT_LUGGAGE: 짐이 없는 경우 자동 퇴실까지 대기 시간
    iou_threshold: "사람과 짐이 자리와 얼마나 많이 겹쳐야 그 자리에 있다고 판별할지 설정

    [객체 탐지 모델 파라미터]
    conf_threshold: ai 모델의 확률이 얼마나 높아야 객체로 판별할지 설정
    detect_classes: 탐지할 객체의 종류들
    """
    #file로 받은 img를 ai모델로 처리
    contents = await file.read()
    nparr = np.frombuffer(contents, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    resized_image = cv2.resize(img, image_size)
    model_result = model.predict(resized_image, conf=conf_threshold,
                                 verbose=True, classes = detect_classes + [0],
                                 device=device, imgsz=image_size[::-1])
    
    #모든 자리의 상태를 모델의 결과를 통해 업데이트
    seats_manager.update_all_seats(model_result,iou_threshold,MAX_WAITING4ENTRY,MAX_TEMPORARILY_EMPTY,MAX_CHECKING_OUT,MAX_WITHOUT_LUGGAGE)

    #카메라 프레임에 객체탐지 결과를 그리고, 자리 구역을 투명하게 그리고 저장 
    res = model_result[0].plot()
    for seat in seats_manager.seats:
        color_name = "dark_red" if seat.seat_id == 0 else "dark_blue"
        seat.DetectArea.draw(res, color_name=color_name, alpha=0.5)
    seats_manager.plot = res

    return {"message": "Update successful"}

@app.get("/diagram")
async def get_seats_diagram():
    """
    seats_manager의 자리들을 도식화한 이미지를 반환
    """
    seats_manager.draw_seats()
    ret = ndarray_to_b64(seats_manager.image)
    return JSONResponse(content={"image": ret})

@app.get("/plot")
async def get_img_plot():
    """
    객체 탐지결과가 그려진 카메라 프레임을 반환
    """
    ret = ndarray_to_b64(seats_manager.plot)
    return JSONResponse(content={"image": ret})