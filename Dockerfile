FROM alpine:latest

ADD install.sh install.sh
RUN sh install.sh && rm install.sh

ENV dpath null
ENV spath null
ENV retention 10
ENV shedule null

ADD run.sh run.sh
ADD backup.sh backup.sh

WORKDIR data

CMD ["sh", "run.sh"]