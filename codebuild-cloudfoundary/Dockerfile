FROM aws-standard-ubuntu

RUN wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | apt-key add - \
    && echo "deb https://packages.cloudfoundry.org/debian stable main" | tee /etc/apt/sources.list.d/cloudfoundry-cli.list \
    && apt-get update \
    && apt-get install cf-cli \
    && apt-get clean

ENTRYPOINT ["dockerd-entrypoint.sh"]
