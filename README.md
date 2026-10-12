# Information Security

Laboratory work for the Information Security course at AUCA. Labs 1–4 use Bash and Python 3 on macOS. Labs 5–13 run in disposable Debian Linux Docker containers.

## Labs

| Lab | Work |
|---|---|
| [1: UNIX commands](lab-01/README.md) | File operations, HTTP requests with curl, tar archives. |
| [2: custom commands](lab-02/README.md) | System information and four Bash scripts. |
| [3: toy shell](lab-03/README.md) | Date input, file filtering and a command available through PATH. |
| [4: phishing awareness](lab-04/README.md) | Local HTML → Flask → file demonstration with fixed fictional data and a sample email preview. |
| [5: Linux users and groups](lab-05/README.md) | Account lifecycle, supplementary groups and actual file-access checks in Docker. |
| [6: Linux permissions](lab-06/README.md) | Numeric permissions, file ownership and group access. |
| [7: cron](lab-07/README.md) | Schedule a Python job in an isolated Linux container. |
| [8: Vim](lab-08/README.md) | Edit a file with Vim's modes and commands. |
| [9: packages](lab-09/README.md) | Install, inspect, upgrade, remove and purge NGINX. |
| [10: NGINX](lab-10/README.md) | Serve HTML and proxy requests to a local API. |
| [11: source installation](lab-11/README.md) | Install youtube-dl, neofetch and GNU Hello from source. |
| [12: dictionary attacks](lab-12/README.md) | Run Hydra against two fictional accounts on isolated loopback. |
| [13: keyboard events](lab-13/README.md) | Record isolated X11 key events and deliver fixed words to a local API. |

Each lab contains source files, run instructions and actual execution logs from 12 October 2026. All 13 labs include unedited screenshots captured in Chrome on the laptop. Labs 4 and 10 show the local pages. The other screenshots show the actual execution logs on GitHub. 

The Python shell is adapted from the linked course example. Labs 4–6 also cover the [supplementary assignments](https://docs.google.com/document/d/1iLU-oof3YflO--nj00r0LgKvT8UiGYt2/edit). Lab 4 follows their local-simulation scope.

Each lab README explains how to run its demonstration. Labs 5–13 use disposable Docker containers so Linux account and permission changes do not affect macOS.

## Screenshots

Screenshots are unedited. Each lab README includes its image. Original files are saved in `~/Desktop/InfoSec-screenshots-2026-10-12/`.

[Lab 4: saved form](lab-04/screenshots/desktop.jpg) · [Lab 10: NGINX page](lab-10/screenshots/site.jpg).
