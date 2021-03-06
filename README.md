# docker with ssl
<pre><code>
----------------------------------------------docker ssl start--------------------------
version: '3.7'

networks:
  default:
    external:
      name: host

services:
  keycloak:
    container_name: keycloak_app
    image: jboss/keycloak
    depends_on:
      - mariadb
    restart: always
    ports:
      - "8080:8080"
      - "8443:8443"
    volumes:
      - "/srv/docker/keycloak/data/certs/:/etc/x509/https"   # map certificates to container
    environment:
      KEYCLOAK_USER: <user>
      KEYCLOAK_PASSWORD: <pw>
      KEYCLOAK_HTTP_PORT: 8080
      KEYCLOAK_HTTPS_PORT: 8443
      KEYCLOAK_HOSTNAME: sub.example.ocm
      DB_VENDOR: mariadb
      DB_ADDR: localhost
      DB_USER: keycloak
      DB_PASSWORD: <pw>
    network_mode: host

  mariadb:
    container_name: keycloak_db
    image: mariadb
    volumes:
      - "/srv/docker/keycloak/data/keycloak_db:/var/lib/mysql"
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: <pw>
      MYSQL_DATABASE: keycloak
      MYSQL_USER: keycloak
      MYSQL_PASSWORD: <pw>


<pre><code>

# work on integration test

# generate ssl selfsign certificate
openssl req -x509 -newkey rsa:4095 -keyout assad.keycloak.com.key -out assad.keycloak.com.pem -days 365

Installed JDK location in CentOS 7
readlink -f $(which java)
or
update-alternatives --config java

Export keysotre:
openssl s_client -connect sonarqube-at.remote.server:443 | openssl x509 -out sonar_ssl.cert

Import keystore:
sudo keytool -import -alias assad.keycloak.com -file ~/Downloads/Untitled.crt -keystore /Library/Java/JavaVirtualMachines/jdk1.8.0_191.jdk/Contents/Home/jre/lib/security/cacerts
</code></pre>

# About keycloak user permission:

https://osc.github.io/ood-documentation/master/authentication/tutorial-oidc-keycloak-rhel7/install-keycloak.html

Above line content save in googlesheet a2z.ice help/Keycloak Installation wiht nginx and keycloak user permission
<pre><code>
Run as linux service:
---------------------------

sudo vi /etc/systemd/system/keycloak.service

[Unit]
Description=Jboss Application Server For Keycloak
After=network.target

[Service]
Type=idle
User=keycloak
Group=keycloak
ExecStart=/opt/keycloak/bin/standalone.sh
ExecStop=/opt/keycloak/bin/jboss-cli.sh --connect command=:shutdown
ExecReload=/opt/keycloak/bin/jboss-cli.sh --connect command=:reload
TimeoutStartSec=600
TimeoutStopSec=600

[Install]
WantedBy=multi-user.target

---------------------------
</code></pre>

# Run keycloak as a CentOS 7 Service : 
https://www.pimwiddershoven.nl/entry/install-keycloak-on-centos-7-with-mysql-backend

# nginx proxy configuration for keycloak:

<pre><code>
---------------------/etc/nginx/config.d/ssl.config-----------

server {
    listen 7000 http2 ssl;
    listen [::]:7000 http2 ssl;

    server_name assad.keycloak.com;
   
    ssl_certificate /etc/ssl/assad.keycloak.com.pem;
    ssl_certificate_key /etc/ssl/assad.keycloak.com.key;
    ssl_password_file /etc/ssh/passphrase.pass; #passphrase file which contain passphrash password
    
    location / {
      proxy_pass http://127.0.0.1:8080;
      proxy_set_header	Host			$host;
      proxy_set_header	X-Real-IP		$remote_addr;
      proxy_set_header	X-Forwarded-For		$proxy_add_x_forwarded_for;
      proxy_set_header	X-Forwarded-Host	$host;
      proxy_set_header	X-Forwarded-Server	$host;
      proxy_set_header	X-Forwarded-Port	$server_port;
      proxy_set_header	X-Forwarded-Proto	$scheme;
    }

    error_page 404 /404.html;
        location = /40x.html {
    }

    error_page 500 502 503 504 /50x.html;
        location = /50x.html {
    }
}

</code></pre>

# ------------- keycloak/standalone/configuration/standalone.xml-------------
<pre><code>
&lt;http-listener name="default" socket-binding="http" redirect-socket="https" enable-http2="true" proxy-address-forwarding="true"/&gt; &lt;------Add proxy-address-forwarding="true"
&lt;https-listener name="https" socket-binding="https" security-realm="ApplicationRealm" enable-http2="true" proxy-address-forwarding="true"/&gt; &lt;------Add proxy-address-forwarding="true"
                
                

 &lt;interface name="management"&gt;
     &lt;inet-address value="${jboss.bind.address.management:0.0.0.0}"/&gt; &lt;--------Add 0.0.0.0 instead of 127.0.0.1
 &lt;/interface&gt;
 &lt;interface name="public"&gt;
     &lt;inet-address value="${jboss.bind.address:0.0.0.0}"/&gt;  &lt;--------Add 0.0.0.0 instead of 127.0.0.1
 &lt;/interface&gt; 


               

----------------------------------------------------------------------------


hake to disable TLS

docker exec -it {contaierID} bash
cd keycloak/bin
./kcadm.sh config credentials --server http://localhost:8080/auth --realm master --user admin
./kcadm.sh update realms/master -s sslRequired=NONE


mysql -u root -p

MariaDB [(none)]> GRANT ALL PRIVILEGES ON *.* TO 'root'@'%'IDENTIFIED BY 'password' WITH GRANT OPTION;
MariaDB [(none)]> FLUSH PRIVILEGES;

MariaDB [(none)]> SELECT User, Host FROM mysql.user;
exit; 

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
