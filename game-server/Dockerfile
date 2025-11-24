FROM eclipse-temurin:21-jre

WORKDIR /app

RUN apt-get update && apt-get install -y wget curl openssl && apt-get clean

# Download PaperMC
RUN wget -O paper.jar https://api.papermc.io/v2/projects/paper/versions/1.21.10/builds/115/downloads/paper-1.21.10-115.jar

# Copy only essential files
COPY start.sh .
COPY health-check.sh .
RUN chmod +x *.sh

# Create necessary directories
RUN mkdir -p /app/plugins /app/worlds

# Accept EULA
RUN echo "eula=true" > /app/eula.txt

EXPOSE 25565-26581

CMD ["./start.sh"]
