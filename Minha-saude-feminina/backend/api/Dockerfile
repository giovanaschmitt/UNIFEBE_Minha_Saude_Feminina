FROM eclipse-temurin:21-jre-jammy
WORKDIR /app

RUN groupadd --system spring && useradd --system --gid spring spring \
    && mkdir -p /app/uploads && chown -R spring:spring /app

USER spring:spring
COPY --chown=spring:spring target/*.jar app.jar

VOLUME /app/uploads
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
