from PyP100 import PyL530
import asyncio
from .SeatStatus import SeatStatus
from .Colors import get_color, state_colors
from kasa import Discover, Credentials
import colorsys
import os
from dotenv import load_dotenv

# .env 파일 로드
load_dotenv()

class BulbManager:
    def __init__(self):
        self.username = os.getenv('TAPO_USERNAME')
        self.password = os.getenv('TAPO_PASSWORD')
        if not self.username or not self.password:
            raise Exception("Tapo username or password not set in environment variables")
        self.credentials = Credentials(self.username, self.password)
        self.bulbs = {}  # 좌석 ID와 연결된 전구 객체를 저장할 공간

    async def discover_bulbs(self):
        devices = await Discover.discover(credentials=self.credentials)
        if not devices:
            raise Exception("No device found.")
        for dev in devices.values():
            await dev.update()
            seat_id = int(dev.alias) - 1  # alias는 좌석 ID로 사용
            bulb = PyL530.L530(dev.host, self.username, self.password)
            bulb.handshake()
            bulb.login()
            self.bulbs[seat_id] = bulb
            bulb.turnOff()

    async def disable_bulbs(self):
        for bulb in self.bulbs.values():
            bulb.turnOff()

    async def change_bulb_state(self, seat_id, state):
        if seat_id in self.bulbs:
            bulb = self.bulbs[seat_id]
            color_name = state_colors.get(state)
            color = get_color(color_name)
            hsv = colorsys.rgb_to_hsv(color[2]/255.0, color[1]/255.0, color[0]/255.0)  # BRG to RGB to HSV
            hue = int(hsv[0] * 360)
            saturation = int(hsv[1] * 100)
            self._apply_state(bulb, hue, saturation)

    def _apply_state(self, bulb, hue, saturation):
        if hue == 120:  # Green for AVAILABLE state
            bulb.turnOff()
        else:
            bulb.turnOn()
            bulb.setColor(hue, saturation)