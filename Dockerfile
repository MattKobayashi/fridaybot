FROM python:3.13.0-alpine3.20

# Create and switch to working directory
WORKDIR /opt/fridaybot

# Download and install packages
RUN adduser --system fridaybot \
    && apk add --no-cache tzdata supercronic

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
