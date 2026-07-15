# Copyright 2020-2022 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Amazon Software License (the "License"). You may not use this file except in compliance with the License.
# A copy of the License is located at
#
#    http://aws.amazon.com/asl/
#
# or in the "license" file accompanying this file.
# This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, express or implied.
# See the License for the specific language governing permissions and limitations under the License.

FROM public.ecr.aws/ubuntu/ubuntu:24.04 AS core

ARG DEBIAN_FRONTEND="noninteractive"

# Install SSH, and other utilities
RUN set -ex \
    && echo 'Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/99use-gzip-compression \
    && apt-get update \
    && apt install -y -qq apt-transport-https gnupg ca-certificates sudo \
    && apt-get install software-properties-common -y -qq --no-install-recommends \
    && apt-get install -y -qq --no-install-recommends openssh-client \
    && mkdir -p ~/.ssh \
    && mkdir -p /codebuild/image/config \
    && touch ~/.ssh/known_hosts \
    && ssh-keyscan -t rsa,dsa,ed25519,ecdsa -H github.com >> ~/.ssh/known_hosts \
    && ssh-keyscan -t rsa,dsa,ed25519,ecdsa -H bitbucket.org >> ~/.ssh/known_hosts \
    && chmod 600 ~/.ssh/known_hosts \
    && apt-get install -y -qq --no-install-recommends \
        acl apt-utils aria2 asciidoc autoconf automake \
        binutils bison brotli build-essential bzip2 bzr \
        coreutils curl dirmngr dnsutils docbook-xml docbook-xsl dpkg dpkg-dev \
        e2fsprogs expect fakeroot file findutils flex fonts-noto-color-emoji ftp \
        g++ gcc git-lfs gettext gettext-base gnupg2 groff gzip \
        haveged imagemagick iproute2 iptables jq less \
        lib32z1 libapr1 libaprutil1 libbz2-dev \
        libc++-dev libc++abi-dev libc6-dev libcurl4-openssl-dev \
        libdb-dev libdbd-sqlite3-perl libdbi-perl libdpkg-perl \
        libedit-dev liberror-perl libevent-dev libffi-dev  \
        libgeoip-dev libgbm-dev libglib2.0-dev libgsl-dev libgtk-3-0 \
        libhttp-date-perl libio-pty-perl libjpeg-dev libkrb5-dev liblzma-dev \
        libmagic-dev libmagickcore-dev libmagickwand-dev libmysqlclient-dev \
        libncurses5-dev libncursesw5-dev libonig-dev libpq-dev libreadline-dev \
        libsecret-1-dev libserf-1-1 libsodium-dev libsqlite3-dev libssl-dev \
        libsvn1 libsvn-perl libtcl8.6 libtidy-dev libtimedate-perl libtool libunwind8 \
        libwebp-dev libxkbfile-dev libxml2-dev libxml2-utils libxslt1-dev libxss1 \
        libyaml-dev libyaml-perl libzip-dev llvm locales lz4 \
        m4 make mediainfo mercurial net-tools netbase netcat-openbsd \
        openssl patch p7zip-full p7zip-rar parallel pass patchelf pigz pkg-config pollinate procps \
        python-is-python3 python3-configobj python3-openssl rpm rsync \
        sgml-base sgml-data shellcheck sphinxsearch sqlite3 ssh sshpass subversion sudo swig systemd-coredump \
        tar tcl tcl8.6 telnet texinfo time tk tk-dev tzdata \
        unzip upx vim wget xfsprogs xml-core xmlto xorriso xsltproc \
        xvfb xz-utils zip zlib1g-dev zsync \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -y unattended-upgrades && \
    unattended-upgrade -v --dry-run && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV LC_CTYPE="C.UTF-8"

# Set locale
RUN locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8

RUN useradd codebuild-user

#=======================End of layer: core  =================

FROM core AS tools

# Install Git
RUN set -ex \
    && GIT_VERSION=2.53.0 \
    && GIT_TAR_FILE=git-$GIT_VERSION.tar.gz \
    && GIT_SRC=https://github.com/git/git/archive/v${GIT_VERSION}.tar.gz  \
    && curl -L -o $GIT_TAR_FILE $GIT_SRC \
    && tar zxf $GIT_TAR_FILE \
    && cd git-$GIT_VERSION \
    && make -j4 \
    && make install prefix=/usr \
    && cd .. && rm -rf git-$GIT_VERSION \
    && rm -rf $GIT_TAR_FILE /tmp/* \
    && git --version

# Install AWS SAM CLI
RUN wget -nv https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip -O /tmp/samcli.zip \
    && unzip -q /tmp/samcli.zip -d /opt/samcli \
    && /opt/samcli/install --update -i /usr/local/sam-cli -b /usr/local/bin \
    && rm -rf /opt/samcli /tmp/* \
    && sam --version

# Install AWS CLI v2
# https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html
RUN curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o /tmp/awscliv2.zip \
    && unzip -q /tmp/awscliv2.zip -d /opt/awscli \
    && /opt/awscli/aws/install --update -i /usr/local/aws-cli -b /usr/local/bin \
    && rm -rf /opt/awscli /tmp/* \
    && aws --version

# Install stunnel
RUN set -ex \
    && STUNNEL_VERSION=5.77 \
    && STUNNEL_TAR=stunnel-$STUNNEL_VERSION.tar.gz \
    && STUNNEL_SHA256="ec026f4fae4e0d25b940cc7a9451d925e359e7fd59e9edad20baea66ce45f263" \
    && curl -o $STUNNEL_TAR https://www.stunnel.org/archive/5.x/$STUNNEL_TAR && echo "$STUNNEL_SHA256 $STUNNEL_TAR" | sha256sum --check && tar xfz $STUNNEL_TAR \
    && cd stunnel-$STUNNEL_VERSION \
    && ./configure \
    && make -j4 \
    && make install \
    && openssl genrsa -out key.pem 2048 \
    && openssl req -new -x509 -key key.pem -out cert.pem -days 1095 -subj "/C=US/ST=Washington/L=Seattle/O=Amazon/OU=Codebuild/CN=codebuild.amazon.com" \
    && cat key.pem cert.pem >> /usr/local/etc/stunnel/stunnel.pem \
    && cd .. && rm -rf stunnel-${STUNNEL_VERSION}* \
    && stunnel -version

# AWS Tools
# aws-iam-authenticator: https://github.com/kubernetes-sigs/aws-iam-authenticator/releases
# kubectl: https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html
# eksctl: https://eksctl.io/installation/
# ecs-cli: https://github.com/aws/amazon-ecs-cli?tab=readme-ov-file#installing
# Check out the KUBERNETES_VERSION and AMAZON_EKS_S3_PATH from the curl command in:
# https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html#linux_amd64_kubectl
RUN set -ex \
    && KUBERNETES_VERSION=1.35.2 \
    && AMAZON_EKS_S3_PATH=2026-02-27 \
    && curl -sS -o /usr/local/bin/aws-iam-authenticator https://s3.us-west-2.amazonaws.com/amazon-eks/$KUBERNETES_VERSION/$AMAZON_EKS_S3_PATH/bin/linux/amd64/aws-iam-authenticator \
    && chmod +x /usr/local/bin/aws-iam-authenticator \
    && aws-iam-authenticator version \
    && curl -sS -o /usr/local/bin/kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/$KUBERNETES_VERSION/$AMAZON_EKS_S3_PATH/bin/linux/amd64/kubectl \
    && chmod +x /usr/local/bin/kubectl \
    && kubectl version --client \
    && curl -sS -L https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz | tar xz -C /usr/local/bin \
    && chmod +x /usr/local/bin/eksctl \
    && eksctl version \
    && curl -sS -o /usr/local/bin/ecs-cli https://amazon-ecs-cli.s3.amazonaws.com/ecs-cli-linux-amd64-latest \
    && chmod +x /usr/local/bin/ecs-cli \
    && ecs-cli --version

# Install amazon-ecr-credential-helper
# To configure: https://github.com/awslabs/amazon-ecr-credential-helper?tab=readme-ov-file#configuration
# ecr-login is not configured because it conflicts with docker login commands https://github.com/awslabs/amazon-ecr-credential-helper/issues/102
RUN set -ex \
    && apt-get update \
    && apt-get install -y -qq amazon-ecr-credential-helper \
    && docker-credential-ecr-login -v

# Configure SSM
RUN set -ex \
    && mkdir /tmp/ssm \
    && cd /tmp/ssm \
    && wget -q https://s3.amazonaws.com/amazon-ssm-us-east-1/latest/debian_amd64/amazon-ssm-agent.deb \
    && dpkg -i amazon-ssm-agent.deb

# Install Pack
RUN set -ex \
    && PACK_VERSION=0.39.1 \
    && (curl -sSL "https://github.com/buildpacks/pack/releases/download/v${PACK_VERSION}/pack-v${PACK_VERSION}-linux.tgz" | tar -C /usr/local/bin/ --no-same-owner -xzv pack) \
    && pack --version

#****************        DOCKER    *********************************************
ARG DOCKER_BUCKET="download.docker.com"
ARG DOCKER_CHANNEL="stable"
ARG DIND_COMMIT="3b5fac462d21ca164b3778647420016315289034"
ARG DOCKER_COMPOSE_VERSION="5.1.0"
ARG DOCKER_BUILDX_VERSION="0.32.1"
ARG SRC_DIR="/usr/src"

ARG DOCKER_SHA256="ea90cfd12e1eeb12aa1c971741adb8bd4ed88e2a574eaac13f5029a1dbc6300d"
ARG DOCKER_VERSION="28.5.2"

# Install Docker
RUN set -ex \
    && curl -fSL "https://${DOCKER_BUCKET}/linux/static/${DOCKER_CHANNEL}/x86_64/docker-${DOCKER_VERSION}.tgz" -o docker.tgz \
    && echo "${DOCKER_SHA256} *docker.tgz" | sha256sum -c - \
    && tar --extract --file docker.tgz --strip-components 1  --directory /usr/local/bin/ \
    && rm docker.tgz \
    && docker -v \
    # Check runc version
    && runc -v \
    # set up subuid/subgid so that "--userns-remap=default" works out-of-the-box
    && addgroup dockremap \
    && useradd -g dockremap dockremap \
    && echo 'dockremap:165536:65536' >> /etc/subuid \
    && echo 'dockremap:165536:65536' >> /etc/subgid \
    && wget -q "https://raw.githubusercontent.com/docker/docker/${DIND_COMMIT}/hack/dind" -O /usr/local/bin/dind \
    # Install docker compose as docker plugin and maintain docker-compose usage
    && mkdir -p /usr/local/lib/docker/cli-plugins \
    && curl -L https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-Linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose \
    && chmod +x /usr/local/bin/dind /usr/local/lib/docker/cli-plugins/docker-compose \
    && ln -s /usr/local/lib/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose \
    # Ensure docker-compose and docker compose work
    && docker-compose version \
    && docker compose version \
    # Add docker buildx tool
    && curl -L https://github.com/docker/buildx/releases/download/v${DOCKER_BUILDX_VERSION}/buildx-v${DOCKER_BUILDX_VERSION}.linux-amd64 -o /usr/local/lib/docker/cli-plugins/docker-buildx \
    && chmod +x /usr/local/lib/docker/cli-plugins/docker-buildx \
    && ln -s /usr/local/lib/docker/cli-plugins/docker-buildx /usr/local/bin/docker-buildx \
    # Ensure docker-buildx works
    && docker-buildx version \
    && docker buildx version

VOLUME /var/lib/docker
#*********************** END  DOCKER  ****************************

# Install gh
# Instruction: https://github.com/cli/cli/blob/trunk/docs/install_linux.md#debian-ubuntu-linux-raspberry-pi-os-apt
RUN mkdir -p -m 755 /etc/apt/keyrings \
    && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt update \
    && apt install gh -y

# Install Chrome
RUN set -ex \
    && curl -L https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb --output /tmp/google-chrome-stable_current_amd64.deb \
    && dpkg -i /tmp/google-chrome-stable_current_amd64.deb || apt-get install -f -y \
    && rm -rf /tmp/* \
    && google-chrome --version

# Install ChromeDriver
# https://googlechromelabs.github.io/chrome-for-testing/
# https://github.com/GoogleChromeLabs/chrome-for-testing#json-api-endpoints
RUN set -ex \
    && CHROME_DRIVER_DOWNLOAD_URL=$(curl -sL https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json | jq -r '.channels.Stable.downloads.chromedriver[] | select(.platform == "linux64") | .url') \
    && curl -L $CHROME_DRIVER_DOWNLOAD_URL --output /tmp/chromedriver-linux64.zip \
    && unzip -q /tmp/chromedriver-linux64.zip -d /opt/chromedriver \
    && ln -s /opt/chromedriver/chromedriver-linux64/chromedriver /usr/local/bin/chromedriver \
    && rm -rf /tmp/* \
    && chromedriver --version

# Install Chromium
# See instruction: https://www.chromium.org/getting-involved/download-chromium/
RUN set -ex \
    && CHROMIUM_VERSION=$(curl -sL https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2FLAST_CHANGE?alt=media) \
    && CHROMIUM_DOWNLOAD_URL=https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F$CHROMIUM_VERSION%2Fchrome-linux.zip?alt=media \
    && curl -L $CHROMIUM_DOWNLOAD_URL --output /tmp/chromium-linux.zip \
    && unzip -q /tmp/chromium-linux.zip -d /opt/chromium \
    && ln -s /opt/chromium/chrome-linux/chrome /usr/local/bin/chromium \
    && ln -s /opt/chromium/chrome-linux/chrome /usr/local/bin/chromium-browser \
    && rm -rf /tmp/* \
    && chromium --version \
    && chromium-browser --version

#=======================End of stage: tools  =================
FROM tools AS runtimes

#****************      NODEJS     ****************************************************

#nodejs
ARG SRC_DIR="/usr/src"
ARG N_SRC_DIR="$SRC_DIR/n"

ENV NODE_22_VERSION="22.22.0" \
    NODE_24_VERSION="24.14.0"

RUN git clone https://github.com/tj/n $N_SRC_DIR \
    && cd $N_SRC_DIR && make install

# Install all Node.js versions
RUN n $NODE_22_VERSION && npm install --save-dev -g -f grunt grunt-cli webpack yarn && \
    n $NODE_24_VERSION && npm install --save-dev -g -f grunt grunt-cli webpack yarn

# Install npm 11.4.2 globally and copy to Node cache locations
RUN npm install -g npm@11.4.2 && \
    cp -rf /usr/local/lib/node_modules/npm /usr/local/n/versions/node/$NODE_22_VERSION/lib/node_modules/ && \
    cp -rf /usr/local/lib/node_modules/npm /usr/local/n/versions/node/$NODE_24_VERSION/lib/node_modules/

# Clean up
RUN cd / && rm -rf $N_SRC_DIR && rm -rf /tmp/*

ENV N_PRESERVE_COREPACK=1
#****************      END NODEJS     ****************************************************

#**************** RUBY *********************************************************

#rubyenv
ENV RBENV_SRC_DIR="/usr/local/rbenv"

ENV PATH="/root/.rbenv/shims:$RBENV_SRC_DIR/bin:$RBENV_SRC_DIR/shims:$PATH" \
    RUBY_BUILD_SRC_DIR="$RBENV_SRC_DIR/plugins/ruby-build"

RUN set -ex \
    && git clone https://github.com/rbenv/rbenv.git $RBENV_SRC_DIR \
    && mkdir -p $RBENV_SRC_DIR/plugins \
    && git clone https://github.com/rbenv/ruby-build.git $RUBY_BUILD_SRC_DIR \
    && sh $RUBY_BUILD_SRC_DIR/install.sh

ENV RUBY_34_VERSION="3.4.9" \
    RUBY_33_VERSION="3.3.10"

RUN rbenv install $RUBY_34_VERSION \
    && rbenv install $RUBY_33_VERSION \
    && rbenv global $RUBY_34_VERSION && ruby -v \
    && rm -rf /tmp/*
#**************** END RUBY *****************************************************

#**************** PYTHON *****************************************************

#Install pyenv
RUN curl -s -S -L https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer | bash
ENV PATH="/root/.pyenv/shims:/root/.pyenv/bin:$PATH"

ENV PYTHON_314_VERSION="3.14.3" \
    PYTHON_PIP_VERSION="26.0.1" \
    PYYAML_VERSION="6.0.3" \
    PYTHON_SETUPTOOLS_VERSION="82.0.0" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --enable-loadable-sqlite-extensions"

#Install python 14
RUN set -ex \
    && for version in $PYTHON_314_VERSION; do \
        pyenv install $version \
        && pyenv global $version \
        && pip3 install --no-cache-dir --upgrade --force-reinstall "pip==$PYTHON_PIP_VERSION" \
        && pip3 install wheel \
        && pip3 install --no-cache-dir --upgrade "setuptools==$PYTHON_SETUPTOOLS_VERSION" boto3 pipenv virtualenv \
        && pip3 install --no-build-isolation "Cython<3" "PyYAML==$PYYAML_VERSION" \
        && pip3 uninstall cython --yes; \
    done \
    && rm -rf /tmp/*
#**************** END PYTHON *****************************************************


#=======================End of stage: runtimes  =================

FROM runtimes AS std_v7

# Activate runtime versions specific to image version.
RUN n $NODE_22_VERSION
RUN pyenv global $PYTHON_314_VERSION
RUN rbenv global $RUBY_34_VERSION

# Configure SSH
COPY ssh_config /root/.ssh/config
COPY runtimes.yml /codebuild/image/config/runtimes.yml
COPY dockerd-entrypoint.sh /usr/local/bin/dockerd-entrypoint.sh
RUN chmod +x /usr/local/bin/dockerd-entrypoint.sh
COPY legal/bill_of_material.txt /usr/share/doc/bill_of_material.txt
COPY amazon-ssm-agent.json /etc/amazon/ssm/amazon-ssm-agent.json

ENTRYPOINT ["/usr/local/bin/dockerd-entrypoint.sh"]

#=======================END of STD:7.0  =================
