# BUILD stage compile the application source code
FROM maven:3.9.6-eclipse-temurin-17 AS build

# Set working directory inside container
WORKDIR /app

# Copy Maven config file (for dependency download + build)
COPY pom.xml .

# Copy source code into container
COPY src ./src

# Build Spring Boot JAR (skip tests for faster build)
RUN mvn clean package -DskipTests

# RUNTIME STAGE: Run application
FROM eclipse-temurin:17-jre

# Set working directory for runtime container
WORKDIR /app

# Copy JAR from build stage to runtime image
COPY --from=build /app/target/*.jar app.jar

# Expose application port
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]