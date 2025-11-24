FROM openjdk:21-slim

WORKDIR /app

RUN apt-get update && apt-get install -y wget curl && apt-get clean

# Download BungeeCord
RUN wget -O bungee.jar https://ci.md-5.net/job/BungeeCord/lastSuccessfulBuild/artifact/bootstrap/target/BungeeCord.jar

# Copy configuration
COPY config.yml .
COPY start.sh .
COPY health-check.sh .
RUN chmod +x start.sh health-check.sh

EXPOSE 25565

CMD ["./start.sh"]
