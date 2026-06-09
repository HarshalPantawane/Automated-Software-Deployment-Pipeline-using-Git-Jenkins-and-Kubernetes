# Multi-stage Dockerfile for building and running the Spring Boot app

# Build stage: use Maven with JDK 17 to build the fat jar
FROM maven:3.9.4-eclipse-temurin-17 AS build
WORKDIR /app

# Copy only the pom first for dependency caching
COPY ./pom.xml ./pom.xml
RUN mvn -B -f pom.xml dependency:go-offline

# Copy the source and build
COPY src ./src
RUN mvn -B -f pom.xml package -DskipTests

# Runtime stage: use a lightweight JRE image
FROM eclipse-temurin:17-jre
WORKDIR /app

# Copy the built jar from the build stage
COPY --from=build /app/target/*.jar /app/app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
