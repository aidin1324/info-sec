FROM python:3.13.7-bookworm

RUN apt-get update \
    && apt-get install -y --no-install-recommends cron vim \
    && rm -rf /var/lib/apt/lists/*
