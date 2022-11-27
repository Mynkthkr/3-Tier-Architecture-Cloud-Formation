FROM ubuntu
RUN apt-get update
RUN apt-get install -y openjdk-8-jdk
RUN apt-get install -y maven
RUN apt-get install -y net-tools
WORKDIR /spring-boot-rest-example
COPY . .
RUN mvn dependency:go-offline -B
CMD mvn package
#EXPOSE 8089
ENTRYPOINT ["java", "-jar", "-Dspring.profiles.active=mysql", "./target/spring-boot-rest-example-0.5.0.war"]


