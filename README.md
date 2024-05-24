# LibSeatTrackerAI

## About Project
![Example Image](img/1.jpeg)
![Example Image](img/2.jpeg)
![Example Image](img/3.jpeg)
![Example Image](img/4.jpeg)
![Example Image](img/5.jpeg)
![Example Image](img/6.jpeg)
![Example Image](img/7.jpeg)

## Getting Started

Follow these steps to run the project locally:

1. **Start the backend server:**
   ```bash
   uvicorn backend.server:app --host 0.0.0.0 --port 8000
   ```

2. **Start the admin frontend:**
   ```bash
   streamlit run frontend/admin/admin_interface.py --server.port 8501
   ```

3. **Start the user frontend:**
   ```bash
   streamlit run frontend/user/user_interface.py --server.port 8502
   ```
