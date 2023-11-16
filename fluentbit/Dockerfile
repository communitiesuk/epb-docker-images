FROM bitnami/fluent-bit:latest

USER root
RUN install_packages curl
USER 1001

ENV LOG_LEVEL=debug

ADD fluent-bit.conf /fluent-bit.conf

EXPOSE 2020
