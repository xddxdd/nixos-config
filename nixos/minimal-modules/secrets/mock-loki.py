import gzip
from http.server import BaseHTTPRequestHandler, HTTPServer
import json


class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        data = self.rfile.read(int(self.headers['Content-Length']))
        if self.headers.get('Content-Encoding') == 'gzip':
            data = gzip.decompress(data)
        payload = json.loads(data)
        assert payload['streams']
        with open('/run/mock-loki/received.jsonl', 'a') as output:
            output.write(json.dumps(payload) + '\n')
        self.send_response(204)
        self.end_headers()

    def log_message(self, *_):
        pass


HTTPServer(('127.0.0.1', 3100), Handler).serve_forever()
