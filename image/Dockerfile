FROM alpine:3.24
RUN apk add --no-cache msmtp mutt ca-certificates fish
ADD files /
ENTRYPOINT ["/entrypoint"]
