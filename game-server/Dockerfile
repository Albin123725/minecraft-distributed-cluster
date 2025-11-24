FROM eclipse-temurin:21-jre

WORKDIR /app

RUN apt-get update && apt-get install -y wget curl python3 && apt-get clean

# Download PaperMC
RUN wget -O paper.jar https://api.papermc.io/v2/projects/paper/versions/1.21.10/builds/115/downloads/paper-1.21.10-115.jar

# Copy only essential files
COPY start.sh .
RUN chmod +x *.sh

# Create necessary directories
RUN mkdir -p /app/plugins /app/worlds

# Accept EULA
RUN echo "eula=true" > /app/eula.txt

# Expose both Minecraft port and HTTP health port range
EXPOSE 25566-25581 8081-8096

CMD ["./start.sh"]
