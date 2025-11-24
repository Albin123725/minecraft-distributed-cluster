FROM python:3.9-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y curl && apt-get clean

# Copy requirements and install Python packages
COPY requirements.txt .
COPY requirements-gdrive.txt .

RUN pip install -r requirements.txt
RUN pip install -r requirements-gdrive.txt

# Copy all application files
COPY start.sh .
COPY rcon-manager.py .
COPY management-dashboard.py .
COPY file-manager.py .
COPY gdrive-uploader.py .
COPY player-manager.py .
COPY analytics-dashboard.py .
COPY health-api.py .
COPY gdrive-manager.py .

RUN chmod +x start.sh

# Create health check script
RUN echo '#!/bin/bash\ncurl -f http://localhost:10000/health || exit 1' > /app/health-check.sh && \
    chmod +x /app/health-check.sh

EXPOSE 10000

CMD ["./start.sh"]
