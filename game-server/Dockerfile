FROM openjdk:21

WORKDIR /app

RUN apt-get update && apt-get install -y wget curl python3 python3-venv && apt-get clean

# Create and activate virtual environment
RUN python3 -m venv /app/venv
ENV PATH="/app/venv/bin:$PATH"

# Copy requirements first for better caching
COPY requirements-gdrive.txt .

# Install Python packages in virtual environment
RUN /app/venv/bin/pip install --upgrade pip && /app/venv/bin/pip install -r requirements-gdrive.txt

# Download PaperMC 1.21.10
RUN wget -O paper.jar https://api.papermc.io/v2/projects/paper/versions/1.21.10/builds/115/downloads/paper-1.21.10-115.jar

# Copy all scripts
COPY start.sh .
COPY sync-worlds.sh .
COPY download-plugins.sh .
COPY gdrive-downloader.sh .
COPY gdrive-download.py .
COPY server-optimizer.sh .
COPY health-monitor.sh .
COPY backup-script.sh .

# Copy Python files
COPY gdrive-manager.py .
COPY health-monitor.py .
COPY backup-manager.py .

RUN chmod +x *.sh

# Create necessary directories
RUN mkdir -p /app/plugins /app/worlds /app/config

# Accept EULA
RUN echo "eula=true" > /app/eula.txt

EXPOSE 25565-26581

CMD ["./start.sh"]
