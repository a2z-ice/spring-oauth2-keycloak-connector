
FROM java:8-jdk-alpine
USER root
ADD target/spring-oauth2-keycloak-connector-0.0.1-SNAPSHOT.jar spring-oauth2-keycloak-connector-0.0.1-SNAPSHOT.jar
COPY ./cacerts cacerts
RUN \
    cp cacerts $JAVA_HOME/jre/lib/security
EXPOSE 8085
ENTRYPOINT ["java", "-jar", "spring-oauth2-keycloak-connector-0.0.1-SNAPSHOT.jar"]