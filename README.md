## Getting Started

Follow these steps to run the project locally:

1. **Start the backend server:**
   ```bash
   uvicorn backend.server:app --host 0.0.0.0 -- post 8000
   ```

2. **Start the admin frontend:**
   ```bash
   streamlit run frontend/admin_interface.py --server.post 8501
   ```

3. **Start the user frontend:**
   ```bash
   streamlit run frontend/user_interface.py --server.post 8502
   ```