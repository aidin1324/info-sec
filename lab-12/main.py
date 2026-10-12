#!/usr/bin/env python3
"""Course FastAPI example. Fictional accounts, isolated Docker loopback only."""
from typing import Annotated
from fastapi import FastAPI, Form

app = FastAPI()


@app.post('/login')
def login(username: Annotated[str, Form()], password: Annotated[str, Form()]):
    if username == 'admin' and password == '12345admin':
        return 'secret token'
    return 'Invalid credentials'


@app.post('/profile-login')
def profile_login(username: Annotated[str, Form()], password: Annotated[str, Form()]):
    if username == 'demo' and password == 'Mira1999!':
        return 'fictional profile token'
    return 'Invalid credentials'
