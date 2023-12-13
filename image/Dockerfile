FROM ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update && \
    apt install -y ca-certificates msmtp mutt && \
    rm -rf /var/lib/apt/lists/*
ADD _ /
ENTRYPOINT ["/init.sh"]
