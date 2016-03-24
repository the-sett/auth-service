#!/bin/sh
. /etc/profile

/usr/bin/java -jar /opt/auth/auth.jar db migrate /opt/auth/config.yml >> /var/log/auth/auth.log 2>&1
/usr/bin/java -jar /opt/auth/auth.jar refdata    /opt/auth/config.yml >> /var/log/auth/auth.log 2>&1

exec /usr/bin/java -Xmx2048m -Dlogging.config=/opt/auth/logback.xml -jar /opt/auth/auth.jar server config.yml >> /var/log/auth/auth.log 2>&1
