```
docker run -d --restart always -p 8080:8080 --name keycloak \
-e DB_VENDOR=mysql \
-e DB_ADDR=mysql-address \
-e DB_PORT=3306 \
-e DB_USER=dbuser \
-e DB_PASSWORD=password \
-e JDBC_PARAMS='useSSL=false' \
-e PROXY_ADDRESS_FORWARDING=true \ <----- proxy address configuration 
jboss/keycloak:9.0.2
```
