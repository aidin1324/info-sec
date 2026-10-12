#!/usr/bin/env python3
from http.server import BaseHTTPRequestHandler, HTTPServer
import json


class API(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path != '/health':
            self.send_error(404)
            return
        body = json.dumps({'ok': True, 'service': 'lab10-api'}).encode()
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)


if __name__ == '__main__':
    HTTPServer(('127.0.0.1', 9000), API).serve_forever()
