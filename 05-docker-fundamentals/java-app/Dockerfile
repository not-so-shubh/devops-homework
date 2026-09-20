FROM eclipse-temurin:21-jdk-alpine AS build
WORKDIR /src
COPY HelloServer.java ./
RUN javac --add-modules jdk.httpserver HelloServer.java

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=build /src/HelloServer.class ./

USER 10001:10001
EXPOSE 8080
CMD ["java", "--add-modules", "jdk.httpserver", "-cp", "/app", "HelloServer"]
