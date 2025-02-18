FROM ubuntu:24.04
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update && \
    apt install -y msmtp mutt && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*
ADD files /
ENTRYPOINT ["/entrypoint.sh"]
