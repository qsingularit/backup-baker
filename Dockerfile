FROM alpine:latest

ADD install.sh install.sh
RUN sh install.sh && rm install.sh

ENV DPATH null
ENV SPATH .
ENV RETENTION 10
ENV RETENTION_DEPTH 32
ENV SHEDULE null

ADD run.sh run.sh
ADD backup.sh backup.sh
ADD rotate.sh rotate.sh

RUN mkdir /data

WORKDIR data

CMD ["sh", "run.sh"]
