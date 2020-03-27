<pre><code>

About keycloak user permission:

https://osc.github.io/ood-documentation/master/authentication/tutorial-oidc-keycloak-rhel7/install-keycloak.html

Run as linux service:
---------------------------

sudo cat > /etc/systemd/system/keycloak.service <<EOF

[Unit]
Description=Jboss Application Server
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
EOF
---------------------------

Run keycloak as a CentOS 7 Service : https://www.pimwiddershoven.nl/entry/install-keycloak-on-centos-7-with-mysql-backend

nginx proxy configuration for keycloak:

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

---------------------------------------------------------------
-----------------------keycloak/standalone/configuration/standalone.xml-------------
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
