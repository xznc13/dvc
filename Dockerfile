FROM centos

VOLUME /var/lib/mysql
VOLUME /initdbscripts

COPY container-files /

CMD ["true"]
