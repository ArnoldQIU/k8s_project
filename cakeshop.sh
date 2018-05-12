apt-get update
apt-get install openjdk-8-jdk -y
# Cakeshop is run with user `cakeshop`, uid = 1000
user=root
group=root
uid=1000
gid=1000
CAKESHOP_USER=$user
CAKESHOP_GROUP=$group
CAKESHOP_HOME=/home
USER=$CAKESHOP_USER
# tini as PID 1
# gosu to drop privs
TINI_VERSION=0.11.0
TINI_SHA=7c18e2d8fb33643505f50297afddc8bcac5751c8a219932143405eaa4cfa2b78
GOSU_VERSION=1.10
set -x \
&& apt-get update \
&& apt-get -y install curl \
&& curl -fsSL https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-static -o /bin/tini && chmod +x /bin/tini \
&& echo "$TINI_SHA  /bin/tini" | sha256sum -c - \
&& apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
&& dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" \
&& export GNUPGHOME="$(mktemp -d)" \
&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
&& gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
&& rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
&& chmod +x /usr/local/bin/gosu \
&& gosu nobody true \
&& rm -rf /usr/share/doc /usr/share/doc-base \
      /usr/share/man /usr/share/locale /usr/share/zoneinfo \
&& rm -rf /tmp/* /var/tmp/* \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*


export USER="$CAKESHOP_USER" \
&& cd "$CAKESHOP_HOME" \
&& gosu root java -jar ${CAKESHOP_HOME}/cakeshop.war example \
&& gosu root java -jar ${CAKESHOP_HOME}/cakeshop.war &