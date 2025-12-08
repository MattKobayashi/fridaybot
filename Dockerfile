FROM python:3.14.2-alpine@sha256:f74e244c26cf94c81a2a6ec8e4e5e55e59bae979063c83382cafb87f03fc1f56

# Create and switch to working directory
WORKDIR /opt/fridaybot

# Download and install packages
RUN adduser --system fridaybot \
    && apk --no-cache add \
    curl \
    jq \
    tzdata

# Supercronic
# renovate: datasource=github-releases packageName=aptible/supercronic
ARG SUPERCRONIC_VERSION="v0.2.40"
ARG SUPERCRONIC="supercronic-linux-amd64"
ARG SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/${SUPERCRONIC}
RUN export SUPERCRONIC_SHA256SUM=$(curl -fsSL \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/repos/aptible/supercronic/releases \
    | jq -r '.[] | select(.name == $ENV.SUPERCRONIC_VERSION) | .assets[] | select(.name == $ENV.SUPERCRONIC) | .digest') \
    && echo "SHA256 digest from API: ${SUPERCRONIC_SHA256SUM}" \
    && curl -fsSLO "$SUPERCRONIC_URL" \
    && echo "${SUPERCRONIC_SHA256SUM}  ${SUPERCRONIC}" | sed -e 's/^sha256://' | sha256sum -c - \
    && chmod +x "$SUPERCRONIC" \
    && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
    && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic

# Set user
USER fridaybot

# Copy files to distribution image
COPY requirements.txt .
COPY fridaybot-cron ./crontab/fridaybot-cron
COPY main.py .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 3000
ENTRYPOINT ["/usr/local/bin/supercronic", "./crontab/fridaybot-cron"]

LABEL org.opencontainers.image.authors="MattKobayashi <matthew@kobayashi.au>"
