FROM alpine:latest
RUN apk add postgresql

RUN apk add --no-cache \
        python3 \
        py3-pip \
    && pip3 install --upgrade pip \
    && pip3 install --no-cache-dir \
        awscli \
    && rm -rf /var/cache/apk/*

VOLUME /root/.aws

ADD run.sh /run.sh

ENTRYPOINT [ "/run.sh" ]