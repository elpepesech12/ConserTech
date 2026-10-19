# Etapa 1: Build con Maven y Eclipse Temurin (Java 17 o 21)
FROM eclipse-temurin:21-jdk-jammy AS build
WORKDIR /app

# Copiar archivos de dependencias para aprovechar caché
COPY .mvn/ .mvn
COPY mvnw pom.xml ./
RUN chmod +x mvnw
RUN ./mvnw dependency:go-offline -B

# Copiar código fuente y compilar
COPY src ./src
RUN ./mvnw clean package -DskipTests

# Etapa 2: Imagen ligera de ejecución
FROM eclipse-temurin:21-jre-jammy
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]