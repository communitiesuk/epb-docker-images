FROM aws-standard-ubuntu

RUN wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | apt-key add - \
    && echo "deb https://packages.cloudfoundry.org/debian stable main" | tee /etc/apt/sources.list.d/cloudfoundry-cli.list \
    && apt-get update \
    && apt-get install cf-cli \
    && apt-get clean

RUN mkdir bundle-deps \
    && cd bundle-deps \
    && wget -q https://raw.githubusercontent.com/communitiesuk/epb-register-api/master/Gemfile \
    && wget -q https://raw.githubusercontent.com/communitiesuk/epb-register-api/master/Gemfile.lock \
    && bundle install \
    && cd .. \
    && rm -r bundle-deps

RUN mkdir bundle-deps \
    && cd bundle-deps \
    && wget -q https://raw.githubusercontent.com/communitiesuk/epb-frontend/master/Gemfile \
    && wget -q https://raw.githubusercontent.com/communitiesuk/epb-frontend/master/Gemfile.lock \
    && bundle install \
    && cd .. \
    && rm -r bundle-deps

ENTRYPOINT ["dockerd-entrypoint.sh"]
