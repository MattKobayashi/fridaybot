FROM python:3.10-alpine3.16

# Create and switch to working directory
WORKDIR /opt/fridaybot

# Set environment variables
ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.2.1/supercronic-linux-amd64 \
    SUPERCRONIC=supercronic-linux-amd64 \
    SUPERCRONIC_SHA1SUM=d7f4c0886eb85249ad05ed592902fa6865bb9d70 \
    TZ=UTC

# Download and install packages
RUN wget "$SUPERCRONIC_URL" \
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
COPY fridaybot-cron ./crontab/fridaybot-cron
COPY fridaybot.py .

EXPOSE 3000
ENTRYPOINT ["supercronic", "./crontab/fridaybot-cron"]

LABEL maintainer="matthew@kobayashi.au"
