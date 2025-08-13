FROM python:3.13.6-alpine@sha256:97990f8cff85f0a25eef434f77f265d63d3767d15f59bfd19860de0b7f702ead

# Create and switch to working directory
WORKDIR /opt/fridaybot

# Download and install packages
RUN adduser --system fridaybot \
    && apk --no-cache add supercronic tzdata

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
