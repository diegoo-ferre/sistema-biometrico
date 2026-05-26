FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app
COPY . .

RUN mvn clean package

FROM tomcat:9-jdk17

RUN rm -rf /usr/local/tomcat/webapps/ROOT

COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080