FROM python:3-alpine

# Create and switch to working directory
WORKDIR /opt/fridaybot

# Set environment variables
ARG TARGETPLATFORM
ENV SUPERCRONIC_SHA1SUM_amd64=642f4f5a2b67f3400b5ea71ff24f18c0a7d77d49 \
    SUPERCRONIC_SHA1SUM_arm=4f625d77d2f9a790ea4ad679d0d2c318a14ec3be \
    SUPERCRONIC_SHA1SUM_arm64=0b658d66bd54cf10aeccd9bdbd95fc7d9ba84a61 \
    SUPERCRONIC_SHA1SUM_i386=1b5ebdd122b05cd2ff38b585022f1d909b0146ff \
    SUPERCRONIC_VERSION=v0.2.25

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
