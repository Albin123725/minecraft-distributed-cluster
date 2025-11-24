FROM python:3.9-slim

WORKDIR /app

RUN apt-get update && apt-get install -y curl && apt-get clean

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY ../requirements-gdrive.txt .
RUN pip install -r requirements-gdrive.txt

COPY start.sh .
COPY rcon-manager.py .
COPY management-dashboard.py .
COPY file-manager.py .
COPY health-api.py .
COPY ../server-files/gdrive-manager.py .

RUN chmod +x /app/start.sh

RUN echo '#!/bin/bash\ncurl -f http://localhost:10000/health || exit 1' > /app/health-check.sh && \
    chmod +x /app/health-check.sh

EXPOSE 10000

CMD ["./start.sh"]
