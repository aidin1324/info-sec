# Information Security

Laboratory work for the Information Security course at AUCA. Commands and scripts were checked on macOS using Bash and Python 3.

## Labs

| Lab | Work |
|---|---|
| [1: UNIX commands](lab-01/README.md) | File operations, HTTP requests with curl, tar archives. |
| [2: custom commands](lab-02/README.md) | System information and four Bash scripts. |
| [3: toy shell](lab-03/README.md) | Date input, file filtering and a command available through PATH. |

Each lab contains source files, saved output and screenshots of execution reports. The Python shell is adapted from the example in the assignment, linked in its README.

## Checks

```bash
python3 tests/test_labs.py
```

The checks cover saved HTTP responses, moved and extracted files, word counts, workday boundaries, cleanup, date validation and shell exit behavior. Cleanup tests use disposable directories.

## Employment certificate

[Certificate issued on 16 September 2026 (PDF)](docs/employment-certificate.pdf).

The certificate confirms employment at MDigital as an AI Engineer since 1 June 2026.
