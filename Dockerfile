FROM alpine:latest

ADD install.sh install.sh
RUN sh install.sh && rm install.sh

RUN mkdir /data
RUN mkdir /backup

WORKDIR /data

#ENV DPATH /backup
#ENV SPATH .
ENV RETENTION 10
ENV RETENTION_DEPTH 32
ENV SCHEDULE null

ADD run.sh /usr/share/run.sh
ADD backup.sh /usr/share/backup.sh
ADD rotate.sh /usr/share/rotate.sh



CMD ["sh", "/usr/share/run.sh"]
