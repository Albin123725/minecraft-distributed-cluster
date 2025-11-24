FROM openjdk:21-jdk-slim

WORKDIR /app

RUN apt-get update && apt-get install -y wget curl python3 python3-pip && apt-get clean

COPY requirements-gdrive.txt .
RUN pip3 install -r requirements-gdrive.txt

RUN wget -O paper.jar https://api.papermc.io/v2/projects/paper/versions/1.21.10/builds/115/downloads/paper-1.21.10-115.jar

COPY start.sh /app/start.sh
COPY sync-worlds.sh /app/sync-worlds.sh
COPY download-plugins.sh /app/download-plugins.sh
COPY gdrive-downloader.sh /app/gdrive-downloader.sh
COPY gdrive-download.py /app/gdrive-download.py
COPY server-optimizer.sh /app/server-optimizer.sh
COPY health-monitor.sh /app/health-monitor.sh
COPY ../server-files/gdrive-manager.py /app/gdrive-manager.py
COPY ../server-files/health-monitor.py /app/health-monitor.py
COPY ../server-files/backup-manager.py /app/backup-manager.py

RUN chmod +x /app/*.sh

RUN mkdir -p /app/plugins /app/worlds /app/config

RUN echo "eula=true" > /app/eula.txt

EXPOSE 25565-26581

CMD ["./start.sh"]
