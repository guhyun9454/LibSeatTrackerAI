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
users_manager.add_user(User(5678,"컴퓨터공학과","고길동"))

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
    user = users_manager.find_user(user_id)
    if user:
        return {"message": "User found", "user": {"user_id": user.user_id, "department": user.department, "name": user.name, "warning_count": user.warning_count}}
    else:
        raise HTTPException(status_code=404, detail="User not found")

@app.get("/usr/seat_id/")
async def get_seat_id(user_id: int):
    user = users_manager.find_user(user_id)
    if user:
        return {"seat_id": user.seat_id}
    else:
        raise HTTPException(status_code=404, detail="User not found")

@app.get("/usr/warning_count/")
async def get_warning_count(user_id: int):
    user = users_manager.find_user(user_id)
    if user:
        return {"warning_count": user.warning_count}
    else:
        raise HTTPException(status_code=404, detail="User not found")

#예약을 진행하는 API
@app.put("/reserve/")
async def reserve_seat(seat_id: int, user_id: int):
    if seat_id < 0 or seat_id >= len(seats_manager.seats): 
        raise HTTPException(status_code=404, detail="Seat number isn't available")
    if seats_manager.seats[seat_id].status == SeatStatus.AVAILABLE:
        seats_manager.seats[seat_id].user_id = user_id
        seats_manager.seats[seat_id].status = SeatStatus.RESERVED_WAITING_ENTRY

        user = users_manager.find_user(user_id)
        if user:
            user.seat_id = seat_id #유저가 사용중인 seat_id를 업데이트
            return {"message": "Seat reserved successfully"}
        else:
            raise HTTPException(status_code=404, detail="User not found")
    else:
        raise HTTPException(status_code=404, detail="Seat isn't available")

#admin페이지를 위한 APIs
@app.post("/detect")
async def detect_objects(file: UploadFile = File(...), 
                         MAX_WAITING4ENTRY: int = 5, 
                         MAX_TEMPORARILY_EMPTY: int = 5, 
                         MAX_CHECKING_OUT: int = 5,
                         MAX_WITHOUT_LUGGAGE: int = 5,
                         conf_threshold: float = 0.6,
                         iou_threshold: float = 0.15,
                         detect_classes: List[int] = Query(...)):
    """
    입력으로 받은 이미지를 모델을 통해 처리 
    객체 탐지 결과를 그리고,
    각 자리의 탐지 구역을 투명하게 표기한 사진을 반환
    """
    contents = await file.read()
    nparr = np.frombuffer(contents, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

    resized_image = cv2.resize(img, image_size)
    model_result = model.predict(resized_image, conf=conf_threshold,
                                 verbose=True, classes = detect_classes + [0],
                                 device=device, imgsz=image_size[::-1])
    #각 자리의 상태를 모델의 결과를 통해 업데이트
    seats_manager.update_all_seats(model_result,iou_threshold,MAX_WAITING4ENTRY,MAX_TEMPORARILY_EMPTY,MAX_CHECKING_OUT,MAX_WITHOUT_LUGGAGE)

    # 웹캠 이미지에 DetectArea 그리기
    res = model_result[0].plot()
    for seat in seats_manager.seats:
        color_name = "dark_red" if seat.seat_id == 0 else "dark_blue"
        seat.DetectArea.draw(res, color_name=color_name, alpha=0.5)

    ret = ndarray_to_b64(res)
    return JSONResponse(content={"image": ret})

@app.get("/draw")
async def draw_seats():
    """
    seats_manager의 자리들을 도식화한 이미지를 반환
    """
    seats_manager.draw_seats()
    ret = ndarray_to_b64(seats_manager.image)
    return JSONResponse(content={"image": ret})