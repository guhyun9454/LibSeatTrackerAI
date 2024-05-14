colors = {
    "red": (0, 0, 255),
    "green": (0, 255, 0),
    "blue": (255, 0, 0),
    "yellow": (0, 255, 255),
    "cyan": (255, 255, 0),
    "magenta": (255, 0, 255),
    "white": (255, 255, 255),
    "black": (0, 0, 0),
    "orange": (0, 165, 255),
    "purple": (128, 0, 128),
    "pink": (203, 192, 255),
    "light_blue": (255, 192, 203),
    "gray": (128, 128, 128),
    "dark_red": (0, 0, 139),
    "dark_green": (0, 100, 0),
    "dark_blue": (139, 0, 0)
}

def get_color(name):
    """
    Parameters:
    name (str): 색상의 이름

    Returns:
    tuple: 
    name에 해당하는 BGR color tuple을 리턴
    """
    return colors.get(name.lower(), colors["black"])