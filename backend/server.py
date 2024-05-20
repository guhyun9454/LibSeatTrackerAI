from fastapi import FastAPI, HTTPException, status, UploadFile, File
from fastapi.responses import JSONResponse
from ultralytics import YOLO
import cv2
import numpy as np
import platform
import base64

from src.SeatStatus import SeatStatus
from src.SeatsManager import SeatsManager
from src.Seat import Seat
from src.IoU import calculate_iou

app = FastAPI()

#초기 세팅
image_size = (640, 480)
device = "mps" if platform.system() == 'Darwin' else None
model_path = "yolo_weights/yolov8s.pt"
iou_threshold = 0.2
conf_threshold = 0.6

#자리 세팅 
seats_manager = SeatsManager(image_size)
seats_manager.add_seat(Seat(seat_number = 0, coordinates= ((80, 150), (280, 150), (280, 330), (80, 330))))
seats_manager.add_seat(Seat(seat_number = 1, coordinates = ((360, 150), (560, 150), (560, 330), (360, 330))))

#ai 모델 세팅
model = YOLO(model_path)


# @app.get("/")
# async def root():
#     return RedirectResponse(url="/seats/")

@app.get("/seats/")
async def get_seats():
    return [seat.status for seat in seats_manager.seats]

# @app.get("/seat/")
# async def get_my_seat(user_id: int):
#     for seat in seats:
#         if seat.user_id == user_id:
#             return {"my_seat" : seat.seat_number}
#     raise HTTPException(status_code=404, detail="There are no seat you reserved.")

@app.put("/seats/")
async def reserve_seat(seat_number: int, user_id: int):
    if seat_number < 0 or seat_number >= len(seats_manager.seats):
        raise HTTPException(status_code=404, detail="Seat number isn't available")
    if seats_manager.seats[seat_number].status == SeatStatus.AVAILABLE:
        seats_manager.seats[seat_number].user_id = user_id
        seats_manager.seats[seat_number].status = SeatStatus.RESERVED_WAITING_ENTRY
        return {"message": "Seat reserved successfully"}
    else:
        raise HTTPException(status_code=404, detail="Seat isn't available")

#admin페이지를 위한 APIs

@app.get("/seats/admin")
async def get_seats_with_id():
    return [[seat.status, seat.user_id] for seat in seats_manager.seats]

# @app.post("/seats/admin")
# async def init_seat(seat_number: int):
#     seats.append(Seat(seat_number=seat_number, status=SeatStatus.AVAILABLE, user_id=-1))

# @app.put("/seats/admin")
# async def update_seat(seat_number: int, seat_status: int, user_id: int):
#     if seat_number < 0 or seat_number >= len(seats):
#         raise HTTPException(status_code=404, detail="Seat number isn't available")
#     seats[seat_number].status = seat_status
#     seats[seat_number].user_id = user_id

@app.delete("/seats/admin")
async def delete_all_seat():
    seats_manager.seats.clear()

@app.post("/detect")
async def detect_objects(file: UploadFile = File(...)):
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
                                 verbose=False, classes=[0, 39, 41, 62, 63, 64, 66, 67, 73],
                                 device=device, imgsz=image_size[::-1])

    #각 자리의 상태를 모델의 결과를 통해 업데이트
    for seat in seats_manager.seats:
        seat.is_person = False
        seat.is_luggage = False
        for result in model_result[0].boxes:
            cls = int(result.cls[0])
            iou = calculate_iou(seat.DetectArea.polygon.reshape(-1)[[0, 1, 4, 5]], result.xyxy[0])
            if cls == 0 and iou > iou_threshold:  # 사람
                seat.is_person = True
            elif cls != 0 and iou > iou_threshold:  # 짐
                seat.is_luggage = True
        seat.status_update()

    
    # 웹캠 이미지에 DetectArea 그리기
    res = model_result[0].plot()
    for seat in seats_manager.seats:
        color_name = "dark_red" if seat.seat_number == 0 else "dark_blue"
        seat.DetectArea.draw(res, color_name=color_name, alpha=0.5)


    _, encoded_img = cv2.imencode('.jpg', res)
    base64_img = base64.b64encode(encoded_img).decode('utf-8')
    return JSONResponse(content={"image": base64_img})

@app.get("/draw")
async def draw_seats():
    """
    seats_manager의 자리들을 도식화한 이미지를 반환
    """
    seats_manager.draw_seats()
    _, encoded_img = cv2.imencode('.jpg', seats_manager.image)
    base64_img = base64.b64encode(encoded_img).decode('utf-8')
    return JSONResponse(content={"image": base64_img})