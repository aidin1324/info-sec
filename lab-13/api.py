#!/usr/bin/env python3
from pathlib import Path
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

app = FastAPI()


class LogEntry(BaseModel):
    word: str = Field(min_length=1, max_length=100)


@app.post('/logs', status_code=201)
def save_log(entry: LogEntry):
    if entry.word not in {'testing', 'my', 'lab'}:
        raise HTTPException(400, 'Only the fixed classroom words are accepted.')
    path = Path('/tmp/lab13/server-log.txt')
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('a') as file:
        file.write(entry.word + '\n')
    return {'saved': True}
