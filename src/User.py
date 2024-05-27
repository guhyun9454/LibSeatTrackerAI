class User:
    def __init__(self, user_id, department, name, warning_count = 0):
        self.user_id = user_id
        self.department = department
        self.name = name
        self.warning_count = warning_count
        self.seat_id = -1
    
    def add_warning(self):
        self.warning_count += 1

    def reset_warnings(self):
        self.warning_count = 0

    def __str__(self):
        return (f"User ID: {self.user_id}\n"
                f"Name: {self.name}\n"
                f"Department: {self.department}\n"
                f"Warning Count: {self.warning_count}\n"
                f"Seat ID: {self.seat_id}")