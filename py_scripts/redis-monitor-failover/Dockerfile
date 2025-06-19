# Use Python 3.11 slim image as base
FROM python:3.11-slim

# Set working directory
WORKDIR /app

RUN pip install --no-cache-dir redis

# Copy your Python script to the container
COPY ./script.py .

# Make sure the script is executable (optional, but good practice)
RUN chmod +x script.py

# Keep container running with bash shell
CMD ["bash"]
