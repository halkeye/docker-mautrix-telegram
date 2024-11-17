FROM curlimages/curl:8.11.0 AS builder
ARG TARGETPLATFORM
ARG UPSTREAM_VERSION=0.15.2
RUN DOCKER_ARCH=$(case ${TARGETPLATFORM:-linux/amd64} in \
  "linux/amd64")   echo "amd64"  ;; \
  "linux/arm/v7")  echo "arm64"   ;; \
  "linux/arm64")   echo "arm64" ;; \
  *)               echo ""        ;; esac) \
  && echo "DOCKER_ARCH=$DOCKER_ARCH" \
  && curl -sL https://github.com/mautrix/telegram/releases/download/v${UPSTREAM_VERSION}/mautrix-telegram-${DOCKER_ARCH} > /tmp/mautrix-telegram
RUN chmod 0755 /tmp/mautrix-telegram

FROM debian:12.8-slim AS runtime
RUN apt-get update && apt-get install -y \
  ca-certificates=20230311 \
  gettext-base=0.21-12 \
  && rm -rf /var/lib/apt/lists/*
COPY --from=builder /tmp/mautrix-telegram /usr/bin/mautrix-telegram
USER 1337
ENTRYPOINT ["/usr/bin/mautrix-telegram"]
