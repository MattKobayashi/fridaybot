FROM python:3.13.5-alpine@sha256:610020b9ad8ee92798f1dbe18d5e928d47358db698969d12730f9686ce3a3191

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
