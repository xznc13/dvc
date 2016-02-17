FROM centos

VOLUME /var/lib/mysql
VOLUME /initdbscripts

RUN  mkdir /initdbscripts/common
RUN  mkdir /initdbscripts/TEST
RUN  mkdir /initdbscripts/PROD
RUN  mkdir /initdbscripts/DEMO
COPY roverincfunc_gt.sql /initdbscripts/common/
COPY world.sql.gz /initdbscripts/common/
COPY ACCESSING-DEMO /initdbscripts/DEMO/
COPY ACCESSING-PROD /initdbscripts/PROD/
COPY ACCESSING-TEST /initdbscripts/TEST/

CMD ["true"]
