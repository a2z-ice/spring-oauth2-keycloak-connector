<pre><code>
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%'IDENTIFIED BY 'password' WITH GRANT OPTION;

SELECT User, Host FROM mysql.user
 
 sudo vi /etc/my.cnf.d/server.cnf
 bind-address=0.0.0.0
 skip-networking=0
 
sudo /etc/init.d/mysql restart
 
sudo firewall-cmd --add-port=3306/tcp
sudo firewall-cmd --permanent --add-port=3306/tcp
  
</code></pre>


# spring-oauth2-keycloak-connector (Source code for Article published)

Complete source code used to explain an article on Securing REST API using Keycloak and Spring Oauth2   

https://medium.com/@bcarunmail/securing-rest-api-using-keycloak-and-spring-oauth2-6ddf3a1efcc2

 
To continue reading on how to Access a Secure REST API using Spring OAuth2RestTemplate, refer below article

https://medium.com/@bcarunmail/accessing-secure-rest-api-using-spring-oauth2resttemplate-ef18377e2e05


<pre><code>
====================>mariadb<====================
docker run -d --name mariadb --net keycloak-network -e MYSQL_ROOT_PASSWORD=password -e MYSQL_DATABASE=keycloak -e MYSQL_USER=keycloak -e MYSQL_PASSWORD=password -p 3306:3306 mariadb

====================>keycloak mariadb<====================
docker run -p 8080:8080 --name keycloak -e KEYCLOAK_USER=admin -e KEYCLOAK_PASSWORD=admin -e DB_VENDOR=mariadb -e DB_ADDR=192.168.0.101 -e DB_PORT=3306 -e DB_USER=root -e DB_PASSWORD=password -e JDBC_PARAMS='useSSL=false' jboss/keycloak


docker run -p 8080:8080 --name keycloak -e KEYCLOAK_USER=admin -e KEYCLOAK_PASSWORD=admin -e DB_VENDOR=mariadb -e DB_ADDR=192.168.0.101 -e DB_PORT=3306 -e DB_USER=keycloak -e DB_PASSWORD=password -e JDBC_PARAMS='useSSL=false' jboss/keycloak
================>Keycloak MySQL<==============
docker run -p 8080:8080 --name keycloak -e KEYCLOAK_USER=admin -e KEYCLOAK_PASSWORD=admin -e DB_VENDOR=mysql -e DB_ADDR=192.168.0.101 -e DB_PORT=53306 -e DB_USER=root -e DB_PASSWORD=root_password -e JDBC_PARAMS='useSSL=false' jboss/keycloak

#--------------Following docker compose not yet tested and completed------
volumes:
  mysql_data:
  driver: local

services:
  mysql:
  image: mysql:5.7
  volumes:
   - mysql_data:/var/lib/mysql
  ports:
   - 3306:3306
  environment:
  MYSQL_ROOT_PASSWORD: root
  MYSQL_DATABASE: keycloak
  MYSQL_USER: keycloak
  MYSQL_PASSWORD: password

  keycloak:
  build: keycloak-image
  image: km-keycloak
  environment:
  PROXY_ADDRESS_FORWARDING: "true"
  DB_VENDOR: MYSQL
  DB_ADDR: mysql
  DB_DATABASE: keycloak
  DB_USER: keycloak
  DB_PASSWORD: password
  KEYCLOAK_USER: admin
  KEYCLOAK_PASSWORD: admin
  volumes:
   - mysql_data:/opt/jboss/mysql_data
  depends_on:
   - mysql
  links:
   - mysql

</pre></code>
