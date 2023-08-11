# Copyright 2020-2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Amazon Software License (the "License"). You may not use this file except in compliance with the License.
# A copy of the License is located at
#
#    http://aws.amazon.com/asl/
#
# or in the "license" file accompanying this file.
# This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, express or implied.
# See the License for the specific language governing permissions and limitations under the License.

FROM ubuntu:20.04 AS core

ARG DEBIAN_FRONTEND="noninteractive"

# Install git, SSH, and other utilities
RUN set -ex \
    && echo 'Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/99use-gzip-compression \
    && apt-get update \
    && apt install -y apt-transport-https gnupg ca-certificates \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
    && apt-get install software-properties-common -y --no-install-recommends \
    && apt-add-repository -y ppa:git-core/ppa \
    && apt-get update \
    && apt-get install git=1:2.* -y --no-install-recommends \
    && git version \
    && apt-get install -y --no-install-recommends openssh-client \
    && mkdir ~/.ssh \
    && touch ~/.ssh/known_hosts \
    && ssh-keyscan -t rsa,dsa -H github.com >> ~/.ssh/known_hosts \
    && ssh-keyscan -t rsa,dsa -H bitbucket.org >> ~/.ssh/known_hosts \
    && chmod 600 ~/.ssh/known_hosts \
    && apt-get install -y --no-install-recommends \
          apt-utils asciidoc autoconf automake build-essential bzip2 \
          bzr curl dirmngr docbook-xml docbook-xsl dpkg-dev \
          e2fsprogs expect fakeroot file g++ gcc gettext gettext-base \
          groff gzip iptables jq less libapr1 libaprutil1 \
          libargon2-0-dev libbz2-dev libc6-dev libcurl4-openssl-dev \
          libdb-dev libdbd-sqlite3-perl libdbi-perl libdpkg-perl \
          libedit-dev liberror-perl libevent-dev libffi-dev libgeoip-dev \
          libglib2.0-dev libhttp-date-perl libio-pty-perl libjpeg-dev \
          libkrb5-dev liblzma-dev libmagickcore-dev libmagickwand-dev \
          libmysqlclient-dev libncurses5-dev libncursesw5-dev libonig-dev \
          libpq-dev libreadline-dev libserf-1-1 libsqlite3-dev libssl-dev \
          libsvn1 libsvn-perl libtcl8.6 libtidy-dev libtimedate-perl \
          libtool libwebp-dev libxml2-dev libxml2-utils libxslt1-dev \
          libyaml-dev libyaml-perl llvm locales make mlocate \
          netbase openssl patch pkg-config procps python3-configobj \
          python-openssl rsync sgml-base sgml-data stunnel \
          tar tcl tcl8.6 tk tk-dev unzip wget xfsprogs xml-core xmlto xsltproc \
          libzip5 libzip-dev vim xvfb xz-utils zip zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

ENV LC_CTYPE="C.UTF-8"

RUN useradd codebuild-user

#=======================End of layer: core  =================


FROM core AS tools

# AWS Tools
# https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_CLI_installation.html
RUN curl -sS -o /usr/local/bin/aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.16.8/2020-04-16/bin/linux/amd64/aws-iam-authenticator \
    && curl -sS -o /usr/local/bin/kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.16.8/2020-04-16/bin/linux/amd64/kubectl \
    && curl -sS -o /usr/local/bin/ecs-cli https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-latest \
    && curl -sS -L https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz | tar xz -C /usr/local/bin \
    && chmod +x /usr/local/bin/kubectl /usr/local/bin/aws-iam-authenticator /usr/local/bin/ecs-cli /usr/local/bin/eksctl \
    && printf "EPB-DEBUG: AWS tools installed.\n"

# Install AWS CLI v2
# https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html
RUN curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o /tmp/awscliv2.zip \
    && unzip /tmp/awscliv2.zip -d /opt \
    && /opt/aws/install -i /usr/local/aws-cli -b /usr/local/bin \
    && rm /tmp/awscliv2.zip \
    && rm -rf /opt/aws \
    && aws --version \
    && printf "EPB-DEBUG: AWS CLI v2 installed.\n"

# Install env tools for runtimes

#nodejs
ARG SRC_DIR="/usr/src"
ARG N_SRC_DIR="$SRC_DIR/n"
RUN git clone https://github.com/tj/n $N_SRC_DIR \
    && cd $N_SRC_DIR && make install

#ruby
ARG RBENV_SRC_DIR="/usr/local/rbenv"

ENV PATH="/root/.rbenv/shims:$RBENV_SRC_DIR/bin:$RBENV_SRC_DIR/shims:$PATH" \
    RUBY_BUILD_SRC_DIR="$RBENV_SRC_DIR/plugins/ruby-build"

RUN set -ex \
    && git clone https://github.com/rbenv/rbenv.git $RBENV_SRC_DIR \
    && mkdir -p $RBENV_SRC_DIR/plugins \
    && git clone https://github.com/rbenv/ruby-build.git $RUBY_BUILD_SRC_DIR \
    && sh $RUBY_BUILD_SRC_DIR/install.sh

#python
RUN curl https://pyenv.run | bash
ENV PATH="/root/.pyenv/shims:/root/.pyenv/bin:$PATH"

#=======================End of layer: tools  =================
FROM tools AS runtimes

#****************      NODEJS     ****************************************************

ENV NODE_16_VERSION="16.17.1"
ENV NODE_18_VERSION="18.13.0"

RUN     n $NODE_18_VERSION && npm install --save-dev -g -f grunt && npm install --save-dev -g -f grunt-cli && npm install --save-dev -g -f webpack \
     && n $NODE_16_VERSION && npm install --save-dev -g -f grunt && npm install --save-dev -g -f grunt-cli && npm install --save-dev -g -f webpack \
     && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
     && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
     && apt-get update && apt-get install -y --no-install-recommends yarn \
     && yarn --version \
     && cd / && rm -rf $N_SRC_DIR;rm -rf /tmp/* \
     && printf "EPB-DEBUG: Node 16, 18 and yarn installed.\n"

#****************      END NODEJS     ****************************************************

#****************      CHROME/ CHROMEDRIVER *****************************

# using Chrome For Testing to ensure same Chrome/Chromedriver versions @see https://developer.chrome.com/blog/chrome-for-testing/

# Install Chrome
RUN set -ex \
    && npx @puppeteer/browsers install chrome@stable \
    && printf "EPB-DEBUG: Chrome installed.\n"

# Install ChromeDriver
RUN set -ex \
    && npx @puppeteer/browsers install chromedriver@stable \
    && printf "EPB-DEBUG: Chromedriver installed.\n"

#****************       END CHROME/ CHROMEDRIVER

#**************** RUBY *********************************************************

ENV RUBY_31_VERSION="3.1.3"

RUN rbenv install $RUBY_31_VERSION; rm -rf /tmp/*; rbenv global $RUBY_31_VERSION;ruby -v \
    && printf "EPB-DEBUG: Ruby $RUBY_31_VERSION installed.\n"

#**************** END RUBY *****************************************************

#**************** PYTHON *****************************************************
ENV PYTHON_3_11_VERSION="3.11.2"

ARG PYTHON_PIP_VERSION=22.3.1

COPY tools/runtime_configs/python/$PYTHON_3_11_VERSION /root/.pyenv/plugins/python-build/share/python-build/$PYTHON_3_11_VERSION
RUN   env PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install $PYTHON_3_11_VERSION; rm -rf /tmp/*
RUN   pyenv global  $PYTHON_3_11_VERSION
RUN set -ex \
    && pip3 install --no-cache-dir --upgrade --force-reinstall "pip==$PYTHON_PIP_VERSION" \
    && pip3 install --no-cache-dir --use-pep517 --upgrade "PyYAML==6.0" \
    && pip3 install --no-cache-dir --upgrade setuptools wheel aws-sam-cli boto3 pipenv virtualenv
RUN printf "EPB-DEBUG: Python $PYTHON_3_11_VERSION and PIP $PYTHON_PIP_VERSION installed.\n"

#**************** END PYTHON *****************************************************

#=======================End of layer: runtimes  =================

FROM runtimes AS runtimes_n_corretto

#****************        DOCKER    *********************************************
ARG DOCKER_BUCKET="download.docker.com"
ARG DOCKER_CHANNEL="stable"
ARG DIND_COMMIT="3b5fac462d21ca164b3778647420016315289034"
ARG DOCKER_COMPOSE_VERSION="1.27.4"
ARG SRC_DIR="/usr/src"

ARG DOCKER_SHA256="544262f4a3621222afb79960bfad4d486935dab80893478b5cc9cf8ebaf409ae"
ARG DOCKER_VERSION="23.0.6"

# Install Docker
RUN set -ex \
    && curl -fSL "https://${DOCKER_BUCKET}/linux/static/${DOCKER_CHANNEL}/x86_64/docker-${DOCKER_VERSION}.tgz" -o docker.tgz \
    && echo "${DOCKER_SHA256} *docker.tgz" | sha256sum -c - \
    && tar --extract --file docker.tgz --strip-components 1  --directory /usr/local/bin/ \
    && rm docker.tgz \
    && docker -v \
    # set up subuid/subgid so that "--userns-remap=default" works out-of-the-box
    && addgroup dockremap \
    && useradd -g dockremap dockremap \
    && echo 'dockremap:165536:65536' >> /etc/subuid \
    && echo 'dockremap:165536:65536' >> /etc/subgid \
    && wget -nv "https://raw.githubusercontent.com/docker/docker/${DIND_COMMIT}/hack/dind" -O /usr/local/bin/dind \
    && curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-Linux-x86_64 > /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/dind /usr/local/bin/docker-compose \
    # Ensure docker-compose works
    && docker-compose version

VOLUME /var/lib/docker
#*********************** END  DOCKER  ****************************

#****************  PAKETO    *********************************************
# Install pack-cli for Paketo
RUN (curl -sSL "https://github.com/buildpacks/pack/releases/download/v0.30.0-rc1/pack-v0.30.0-rc1-linux.tgz" | sudo tar -C /usr/local/bin/ --no-same-owner -xzv pack)   
    
#*********************** END PAKETO  ****************************

#=======================End of layer: corretto  =================
FROM runtimes_n_corretto AS std_v5

# Activate runtime versions specific to image version.
RUN n $NODE_16_VERSION
RUN pyenv  global $PYTHON_3_11_VERSION
RUN rbenv  global $RUBY_31_VERSION
RUN gem install bundler:2.3.22

# Configure SSH
COPY ssh_config /root/.ssh/config
COPY runtimes.yml /codebuild/image/config/runtimes.yml
COPY dockerd-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["dockerd-entrypoint.sh"]

#=======================END of STD:5.0  =================


