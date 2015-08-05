FROM centos6/centos6
MAINTAINER Dennis Kanbier <dennis@kanbier.net>

# Update base images.
RUN yum distribution-synchronization -y
RUN yum -y -q install cronie
RUN chkconfig crond on
RUN service crond start

# Install Zabbix release packages.
RUN yum install -y http://repo.zabbix.com/zabbix/2.4/rhel/6/x86_64/zabbix-release-2.4-1.el6.noarch.rpm
RUN rpm -ivh http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
RUN yum -y install python-pip
RUN pip install pika pyzabbix

RUN yum makecache


# Install Apache and PHP5
RUN yum -y -q install httpd php php-mysql php-snmp

# Install the rest of the zabbix packages
RUN yum -y -q install zabbix-web zabbix-web-mysql

# Cleaining up.
RUN yum clean all

# Zabbix Conf Files
ADD ./zabbix/zabbix.ini                                 /etc/php.d/zabbix.ini
ADD ./zabbix/httpd_zabbix.conf                  /etc/httpd/conf.d/zabbix.conf
ADD ./zabbix/zabbix.conf.php                    /etc/zabbix/web/zabbix.conf.php
ADD ./zabbix/monitor.py                         /etc/zabbix/web/monitor.py
RUN chmod -R a+x /etc/zabbix/web/monitor.py

RUN echo "* * * * *   /etc/zabbix/web/monitor.py" | crontab -


# https://github.com/dotcloud/docker/issues/1240#issuecomment-21807183
RUN echo "NETWORKING=yes" > /etc/sysconfig/network

# Expose http port
EXPOSE 80

# Start apache in the foreground
CMD ["apachectl", "-DFOREGROUND"]