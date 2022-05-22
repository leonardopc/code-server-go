FROM golang:1.18.2-bullseye AS go

FROM debian:bullseye-slim
# set version label
LABEL maintainer="leonardopc"
LABEL build_version="code-server 4.4.0 golang 1.18.2 bullseye"
# environment settings
#ENV HOME="/config"
# add go binaries
COPY /code-server.sh /
COPY --from=go /usr/local/go/ /usr/local/go/
ENV PATH="/usr/local/go/bin:${PATH}"

RUN \
echo "**** install build dependencies ****" && \
apt-get update && \
apt-get install -y \
    git \
    build-essential \
    curl && \
curl -fsSL https://deb.nodesource.com/setup_17.x | bash - &&\
chmod +x code-server.sh && \
apt-get install -y \
    nodejs && \
echo "**** install code-server ****" && \
  if [ -z ${CODE_RELEASE+x} ]; then \
    CODE_RELEASE=$(curl -sX GET https://api.github.com/repos/coder/code-server/releases/latest \
    | awk '/tag_name/{print $4;exit}' FS='[""]' | sed 's|^v||'); \
  fi && \
  mkdir -p /app/code-server && \
  curl -o \
    /tmp/code-server.tar.gz -L \
    "https://github.com/coder/code-server/releases/download/v${CODE_RELEASE}/code-server-${CODE_RELEASE}-linux-amd64.tar.gz" && \
  tar xf /tmp/code-server.tar.gz -C \
    /app/code-server --strip-components=1 && \
echo "**** installing docker cli ****" && \
  curl -fsSL https://get.docker.com | bash - && \
echo "**** clean up ****" && \
  apt-get purge --auto-remove -y \
    nodejs && \
  apt-get clean && \
  rm -rf \
    /config/* \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /etc/apt/sources.list.d/nodesource.list

EXPOSE 8443
CMD ["/code-server.sh"]