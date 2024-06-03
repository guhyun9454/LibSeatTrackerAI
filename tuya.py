import tinytuya
import json
import time

# JSON 파일 경로 설정
json_file_path = 'devices.json'

# JSON 파일 불러오기
with open(json_file_path, 'r') as file:
    devices = json.load(file)

# 불러온 JSON 데이터 확인
print(devices)

# 색상 데이터
colors = {
    "red": (255, 0, 0),
    "green": (0, 255, 0),
    "blue": (0, 0, 255),
    "yellow": (255, 255, 0),
    "cyan": (0, 255, 255),
    "magenta": (255, 0, 255),
    "white": (255, 255, 255),
    "black": (0, 0, 0),
    "orange": (255, 165, 0),
    "purple": (128, 0, 128),
    "pink": (255, 192, 203),
    "light_blue": (173, 216, 230),
    "gray": (128, 128, 128),
    "dark_red": (139, 0, 0),
    "dark_green": (0, 100, 0),
    "dark_blue": (0, 0, 139)
}


for device_info in devices:
    try:
        # 장치 객체 생성
        device = tinytuya.BulbDevice(
            dev_id=device_info['id'],
            address=device_info.get('ip', 'Auto'),  # IP 주소가 없으면 자동 검색
            local_key=device_info['key'],
            version=device_info.get('version', 3.3))  # 버전 정보가 없으면 기본값 3.3 사용

        device.set_mode('colour')
        # 장치 켜기
        print(f"Turning on {device_info['name']}")
        device.set_status(True, '20')  # '20' is the DPS code for switch_led
        status = device.status()
        print(f"Device {device_info['id']} status after turning on:", status)

        time.sleep(2)  # 2초 대기
        device.set_colour(255,0,0) # red
        time.sleep(2)  # 2초 대기
        device.set_colour(255,255,255) # white
        time.sleep(2)  # 2초 대기

        # 장치 상태 확인
        status = device.status()
        print(f"Device {device_info['id']} status after setting color:", status)

        # 장치 끄기
        print(f"Turning off {device_info['name']}")
        device.set_status(False, '20')  # '20' is the DPS code for switch_led
        status = device.status()
        print(f"Device {device_info['id']} status after turning off:", status)

    except Exception as e:
        print(f"Failed to control device {device_info['id']}: {e}")
