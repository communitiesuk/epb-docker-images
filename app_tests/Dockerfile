FROM aws-standard-ubuntu

RUN  apt-get update \
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
