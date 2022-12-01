FROM openjdk:8
#MAINTAINER "saurav"
RUN apt-get update
#RUN apt-get install -y openjdk-8-jdk
RUN apt-get install -y maven
WORKDIR /java-springboot
COPY . .
COPY entry.sh /entry.sh
RUN chmod 755 /entry.sh
RUN mvn clean install
EXPOSE 8090
ENTRYPOINT ["/bin/bash", "/entry.sh"]

