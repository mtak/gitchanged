FROM alpine:latest

RUN apk add --no-cache git bash msmtp ca-certificates

WORKDIR /app

COPY check_changed.sh .

RUN chmod +x check_changed.sh

ENTRYPOINT ["bash", "-c", "./check_changed.sh"]

