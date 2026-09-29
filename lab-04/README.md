# Lab 4: phishing-awareness demonstration

A local classroom adaptation of the [assignment](https://docs.google.com/document/d/1cGUkFKaxVDsjgh9YeU5-b-tgZ3gNHti0/edit). It demonstrates an HTML form, an HTTP POST, Flask processing and persistence in a file. The page is visibly labelled as training and accepts only fixed fictional values. A [sample email](results/training-email.eml) illustrates a link to the page; it is a local preview and was not sent.

The original assignment also describes deceptive distribution and a public lookalike domain. Those parts are not implemented here. This submission demonstrates the technical mechanism as a controlled exercise; acceptance of that adaptation is up to the instructor.

## Run

From the repository root, with Python 3 installed:

```bash
python3 -m venv .venv
.venv/bin/python -m pip install -r lab-04/requirements.txt
.venv/bin/python lab-04/app.py
```

Open <http://127.0.0.1:8040/> and press the training button. Stop the server with Ctrl+C.

The server writes one JSON object per line to `lab-04/runtime/submissions.jsonl`. That runtime directory is ignored by Git. Read the file with:

```bash
cat lab-04/runtime/submissions.jsonl
```

## Main mechanics / главное для защиты

1. HTML defines the fields. JavaScript converts their values to JSON and sends `POST /submit` with `fetch`.
2. Flask matches the URL to `submit()`, validates the entire object and appends it to a file. HTTP `201` confirms successful saving; `400` rejects other values.
3. The file belongs to the server. Closing the browser or restarting this server does not delete previously saved rows.

**Фишинг:** человека убеждают отправить данные постороннему получателю. Копирование внешнего вида не меняет владельца сервера. Проверять нужно адрес назначения, а не только оформление страницы.

The fields are read-only for clarity. The server independently enforces the fixed values, since a user can modify HTML in the browser. No real card data is accepted or stored. The server binds only to `127.0.0.1`, with the Flask debugger disabled.

## Evidence and checks

- [Live HTTP demonstration](results/http.txt), including a rejected non-demo request.
- [Saved fictional data](results/submissions.jsonl).
- [Browser check](results/browser.txt): the actual form was opened and submitted through Computer Use.
- `tests/test_lab04.py`: app restart persistence, append behavior, every modified field, missing/extra fields, invalid JSON, oversized requests and unsupported HTTP methods.

The implementation follows Flask's [routing documentation](https://flask.palletsprojects.com/en/stable/quickstart/) and [test client documentation](https://flask.palletsprojects.com/en/stable/testing/).
