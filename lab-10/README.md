# Lab 10: NGINX and proxy_pass

[Assignment](https://docs.google.com/document/d/1XX3pRm01ffvhdgbhIwixGDnK9cAxIk2N/edit).

## Run

From the repository root, with Docker running:

```bash
docker build -t info-sec-course -f lab-env/Dockerfile lab-env
docker build -t info-sec-runtime lab-runtime
docker run --rm --network none --mount "type=bind,src=$PWD/lab-10,dst=/lab,readonly" info-sec-runtime bash /lab/demo.sh
```

## Results

Created a site in `sites-available`, enabled its symlink, checked `nginx -t` and reloaded NGINX. `/` serves HTML. `/api/health` reaches the Python API through `proxy_pass`. The trailing slash strips `/api/` from the upstream path. A missing file returns 404.

Container reload uses `nginx -s reload` because there is no systemd.

[Execution log](results/session.txt).

## Open in browser

```bash
docker run --rm --name info-sec-lab10-preview -p 127.0.0.1:18010:8000 --mount "type=bind,src=$PWD/lab-10,dst=/lab,readonly" info-sec-runtime bash /lab/demo.sh --serve
```

Open <http://127.0.0.1:18010/>. Port 18010 on macOS maps to port 8000 in Docker. Stop the preview with `docker stop info-sec-lab10-preview`.

![Actual NGINX page, unedited screenshot](screenshots/site.jpg)

Chrome displayed the static page. Chrome blocked direct display of `/api/health` with `ERR_BLOCKED_BY_CLIENT`. `curl` returned HTTP 200. The execution log contains the response.
