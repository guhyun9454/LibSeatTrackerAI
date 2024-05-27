from .User import User
from typing import List
class UsersManager:
    """
    여러 유저를 관리하는 객체
    추후에 데이터베이스를 사용.
    """
    database: List[User]
    def __init__(self):
        self.database = []

    def add_user(self, user: User):
        self.database.append(user)

    def find_user(self, user_id) -> User:
        for user in self.database:
            if user.user_id == user_id:
                return user
        return None

    def check_out(self, user_id) -> bool:
        user = self.find_user(user_id)
        if user:
            user.seat_id = -1
            return True
        else:
            return False

    def penalize_user(self, user_id):
        user = self.find_user(user_id)
        if user:
            user.add_warning()
            print(user)
            return True
        return False
