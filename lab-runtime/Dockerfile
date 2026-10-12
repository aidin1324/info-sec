FROM info-sec-course
RUN apt-get update \
    && apt-get install -y --no-install-recommends nginx hydra xvfb xterm xdotool xauth \
    && rm -rf /var/lib/apt/lists/*
COPY requirements.txt /tmp/lab-requirements.txt
RUN python3 -m pip install --no-cache-dir -r /tmp/lab-requirements.txt
