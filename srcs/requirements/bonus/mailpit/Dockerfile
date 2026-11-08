FROM debian:bookworm

ARG MAILPIT_VERSION

RUN apt-get update && apt-get install -y --no-install-recommends \
        curl ca-certificates \
    && curl -fsSL https://github.com/axllent/mailpit/releases/download/v${MAILPIT_VERSION}/mailpit-linux-amd64.tar.gz \
        | tar -xz -C /usr/local/bin mailpit \
    && rm -rf /var/lib/apt/lists/*

USER nobody

CMD ["mailpit", "--webroot", "/mailpit/", "--listen", "0.0.0.0:8025", "--smtp", "0.0.0.0:1025"]
