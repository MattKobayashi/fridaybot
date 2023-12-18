FROM python:3-alpine

# Create and switch to working directory
WORKDIR /opt/fridaybot

# Set environment variables
ARG TARGETPLATFORM
ENV SUPERCRONIC_SHA1SUM_amd64=cd48d45c4b10f3f0bfdd3a57d054cd05ac96812b \
    SUPERCRONIC_SHA1SUM_arm=75e065bf0909f920b06d5bd797c0e6b31e68b112 \
    SUPERCRONIC_SHA1SUM_arm64=512f6736450c56555e01b363144c3c9d23abed4c \
    SUPERCRONIC_SHA1SUM_i386=3436985298ce241d7d9477eb9eab164b582717a8 \
    SUPERCRONIC_VERSION=v0.2.29

# Download and install packages
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then ARCH=amd64; elif [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then ARCH=arm; elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then ARCH=arm64; elif [ "$TARGETPLATFORM" = "linux/i386" ]; then ARCH=i386; else exit 1; fi \
    && export SUPERCRONIC="supercronic-linux-${ARCH}" \
    && export SUPERCRONIC_URL="https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/${SUPERCRONIC}" \
    && wget "$SUPERCRONIC_URL" \
    && eval SUPERCRONIC_SHA1SUM='$SUPERCRONIC_SHA1SUM_'$ARCH \
    && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
    && chmod +x "${SUPERCRONIC}" \
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
