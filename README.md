# Information Security

Laboratory work for the Information Security course at AUCA. Labs 1–4 were checked on macOS using Bash and Python 3. Lab 5 runs in a disposable Debian Linux Docker container.

## Labs

| Lab | Work |
|---|---|
| [1: UNIX commands](lab-01/README.md) | File operations, HTTP requests with curl, tar archives. |
| [2: custom commands](lab-02/README.md) | System information and four Bash scripts. |
| [3: toy shell](lab-03/README.md) | Date input, file filtering and a command available through PATH. |
| [4: phishing awareness](lab-04/README.md) | Local HTML → Flask → file demonstration with fixed fictional data and a sample email preview. |
| [5: Linux users and groups](lab-05/README.md) | Account lifecycle, supplementary groups and actual file-access checks in Docker. |

Each lab contains source files and saved output. Labs 1–3 also include screenshots of execution reports. The Python shell is adapted from the example in the assignment, linked in its README. Lab 4 is a visibly labelled local training adaptation; it does not send deceptive emails or host a public lookalike site.

## Checks

```bash
python3 tests/test_labs.py
```

The checks cover saved HTTP responses, moved and extracted files, word counts, workday boundaries, cleanup, date validation and shell exit behavior. Cleanup tests use disposable directories.

For all five labs, install Lab 4's dependencies as documented there, start Docker, and run:

```bash
.venv/bin/python -m unittest discover -s tests -v
```

Lab 4 tests use temporary files. Lab 5 tests use a new disposable container and are skipped if the Docker executable is absent. If Docker is installed, its daemon must be running. The recorded complete check is in [tests/results.txt](tests/results.txt).

## Employment certificate

[Certificate issued on 16 September 2026 (PDF)](docs/employment-certificate.pdf).

The certificate confirms employment at MDigital as an AI Engineer since 1 June 2026.
