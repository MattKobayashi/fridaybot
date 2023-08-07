FROM python:3-alpine

# Create and switch to working directory
WORKDIR /opt/fridaybot

# Set environment variables
ARG TARGETPLATFORM
ENV SUPERCRONIC_SHA1SUM_amd64=7a79496cf8ad899b99a719355d4db27422396735 \
    SUPERCRONIC_SHA1SUM_arm=d8124540ebd8f19cc0d8a286ed47ac132e8d151d \
    SUPERCRONIC_SHA1SUM_arm64=e4801adb518ffedfd930ab3a82db042cb78a0a41 \
    SUPERCRONIC_SHA1SUM_i386=bcc522ec4ead6de0d564670f6499a88e35082d1f \
    SUPERCRONIC_VERSION=v0.2.26

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
