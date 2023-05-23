FROM python:3-alpine

# Create and switch to working directory
WORKDIR /opt/fridaybot

# Set environment variables
ARG TARGETPLATFORM
ENV SUPERCRONIC_SHA1SUM_amd64=6817299e04457e5d6ec4809c72ee13a43e95ba41 \
    SUPERCRONIC_SHA1SUM_arm=fad9380ed30b9eae61a5b1089f93bd7ee8eb1a9c \
    SUPERCRONIC_SHA1SUM_arm64=fce407a3d7d144120e97cfc0420f16a18f4637d9 \
    SUPERCRONIC_SHA1SUM_i386=f1e1317fee6ebf610252c6ea77d8e44af67c93d6 \
    SUPERCRONIC_VERSION=v0.2.24

# Download and install packages
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then ARCH=amd64; elif [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then ARCH=arm; elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then ARCH=arm64; elif [ "$TARGETPLATFORM" = "linux/i386" ]; then ARCH=i386; else exit 1; fi \
    && export SUPERCRONIC="supercronic-linux-${ARCH}" \
    && export SUPERCRONIC_URL="https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/${SUPERCRONIC}" \
    && wget "$SUPERCRONIC_URL" \
    && eval SUPERCRONIC_SHA1SUM='$SUPERCRONIC_SHA1SUM_'$ARCH \
    && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
    && chmod +x "$SUPERCRONIC" \
    && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
    && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic \
    && adduser --system fridaybot \
    && apk --no-cache upgrade \
    && apk add --no-cache tzdata

# Set user
USER fridaybot

# Copy files to distribution image
COPY requirements.txt .
COPY fridaybot-cron ./crontab/fridaybot-cron
COPY fridaybot.py .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 3000
ENTRYPOINT ["supercronic", "./crontab/fridaybot-cron"]

LABEL org.opencontainers.image.authors="MattKobayashi <matthew@kobayashi.au>"
