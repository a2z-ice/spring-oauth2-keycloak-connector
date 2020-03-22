# spring-oauth2-keycloak-connector (Source code for Article published)

Complete source code used to explain an article on Securing REST API using Keycloak and Spring Oauth2   

https://medium.com/@bcarunmail/securing-rest-api-using-keycloak-and-spring-oauth2-6ddf3a1efcc2

 
To continue reading on how to Access a Secure REST API using Spring OAuth2RestTemplate, refer below article

https://medium.com/@bcarunmail/accessing-secure-rest-api-using-spring-oauth2resttemplate-ef18377e2e05



docker run -p 8080:8080 --name keycloak -e KEYCLOAK_USER=admin -e KEYCLOAK_PASSWORD=admin -e DB_VENDOR=mysql -e DB_ADDR=192.168.0.101 -e DB_PORT=53306 -e DB_USER=root -e DB_PASSWORD=root_password -e JDBC_PARAMS='useSSL=false' jboss/keycloak
