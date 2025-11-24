FROM eclipse-temurin:21-jre

WORKDIR /app

RUN apt-get update && apt-get install -y wget curl python3 openssl unzip && apt-get clean

# Download PaperMC 1.21.10
RUN wget -O paper.jar https://api.papermc.io/v2/projects/paper/versions/1.21.10/builds/115/downloads/paper-1.21.10-115.jar

# Copy start script
COPY start.sh .
RUN chmod +x *.sh

# Create necessary directories
RUN mkdir -p /app/plugins /app/world

# Accept EULA
RUN echo "eula=true" > /app/eula.txt

EXPOSE 25566-25581 10000

CMD ["./start.sh"]
