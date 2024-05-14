import cv2

def _display_detected_frames(conf, model, st_frame, image):
    """
    Display the detected objects on a video frame using the YOLOv8 model.

    Args:
    - conf (float): Confidence threshold for object detection.
    - model (YoloV8): A YOLOv8 object detection model.
    - st_frame (Streamlit object): A Streamlit object to display the detected video.
    - image (numpy array): A numpy array representing the video frame.

    Returns:
    None
    """

    # Resize the image to a standard size
    image = cv2.resize(image, (640, int(640*(9/16))))


    res = model.predict(image, 
                        conf=conf, 
                        verbose = False,
                        classes = [0,39,41,62,63,64,66,67,73])

    # # Plot the detected objects on the video frame
    res_plotted = res[0].plot()
    st_frame.image(res_plotted,
                   caption='Detected Video',
                   channels="BGR",
                   use_column_width=True
                   )