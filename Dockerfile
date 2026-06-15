# Paso 1: Compilar el código usando Maven
FROM maven:3.9-eclipse-temurin-17 AS build
COPY . .
RUN mvn clean package -DskipTests

# Paso 2: Ejecutar en Tomcat
FROM tomcat:10.1-jdk17
# Copia el archivo .war generado en el paso anterior a la carpeta de despliegue de Tomcat
COPY --from=build /target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
