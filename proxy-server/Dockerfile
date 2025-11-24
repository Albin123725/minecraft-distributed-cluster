FROM openjdk:21-jdk-slim

WORKDIR /app

RUN apt-get update && apt-get install -y wget curl && apt-get clean

RUN wget -O bungee.jar https://ci.md-5.net/job/BungeeCord/lastSuccessfulBuild/artifact/bootstrap/target/BungeeCord.jar

COPY config.yml /app/config.yml
COPY start.sh /app/start.sh
COPY health-check.sh /app/health-check.sh
RUN chmod +x /app/start.sh /app/health-check.sh

EXPOSE 25565

CMD ["./start.sh"]
