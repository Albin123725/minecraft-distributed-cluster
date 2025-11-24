FROM eclipse-temurin:21-jre

WORKDIR /app

RUN apt-get update && apt-get install -y wget curl python3 && apt-get clean

# Download BungeeCord
RUN wget -O bungee.jar https://ci.md-5.net/job/BungeeCord/lastSuccessfulBuild/artifact/bootstrap/target/BungeeCord.jar

# Copy configuration
COPY config.yml .
COPY start.sh .
RUN chmod +x start.sh

# Expose Minecraft port + default health port
EXPOSE 25575 10000

CMD ["./start.sh"]
