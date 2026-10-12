# Lab 13: Isolated keyboard logging

[Assignment](https://docs.google.com/document/d/1BUWl22Yae_IXFWq59ZpDx7LRFUjT7-4J/edit).

## Run

From the repository root, with Docker running:

```bash
docker build -t info-sec-course -f lab-env/Dockerfile lab-env
docker build -t info-sec-runtime lab-runtime
docker run --rm --network none --mount "type=bind,src=$PWD/lab-13,dst=/lab,readonly" info-sec-runtime bash /lab/demo.sh
```

## Result and mechanism

The real `pynput` listener records key presses/releases on a separate X11 display inside Docker. Space and Enter save a word locally and send it to a loopback API. Escape stops the listener. the timeout is 10 seconds. The API accepts only `testing`, `my`, `lab`. The demonstration types those words into an X11 terminal, compares both files and stops all processes.

It does not monitor the host keyboard, run secretly or send data to an external server.

[Actual execution log](results/session.txt).


The source task also discusses stealth delivery. That part is not implemented. This is an explicit, isolated classroom demonstration of capture and API delivery.

[Escape-stop verification](results/escape.txt). Add `--escape` after `/lab/demo.sh` to repeat that check.
