FROM aws-standard-ubuntu

RUN  apt-get update \
    && apt-get clean

RUN mkdir bundle-deps \
    && cd bundle-deps \
    && wget -q https://raw.githubusercontent.com/communitiesuk/epb-register-api/master/Gemfile \
    && wget -q https://raw.githubusercontent.com/communitiesuk/epb-register-api/master/Gemfile.lock \
    && bundle install \
    && cd .. \
    && rm -r bundle-deps \
    && printf "EPB-DEBUG: Register API dependencies installed."

RUN mkdir bundle-deps \
    && cd bundle-deps \
    && wget -q https://raw.githubusercontent.com/communitiesuk/epb-frontend/master/Gemfile \
    && wget -q https://raw.githubusercontent.com/communitiesuk/epb-frontend/master/Gemfile.lock \
    && bundle install \
    && cd .. \
    && rm -r bundle-deps \
    && printf "EPB-DEBUG: Frontend dependencies installed."

RUN mkdir bundle-deps \
    && cd bundle-deps \
    && wget -q https://raw.githubusercontent.com/communitiesuk/epb-auth-server/master/Gemfile \
    && wget -q https://raw.githubusercontent.com/communitiesuk/epb-auth-server/master/Gemfile.lock \
    && bundle install \
    && cd .. \
    && rm -r bundle-deps \
    && printf "EPB-DEBUG: Auth server dependencies installed."

RUN mkdir bundle-deps \
    && cd bundle-deps \
    && wget -q https://raw.githubusercontent.com/communitiesuk/epb-data-warehouse/master/Gemfile \
    && wget -q https://raw.githubusercontent.com/communitiesuk/epb-data-warehouse/master/Gemfile.lock \
    && bundle install \
    && cd .. \
    && rm -r bundle-deps \
    && printf "EPB-DEBUG: Data warehouse dependencies installed."

ENTRYPOINT ["dockerd-entrypoint.sh"]
