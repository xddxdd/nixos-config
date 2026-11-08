import gzip
import json
import re
import socket
from datetime import datetime
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import parse_qs, urlsplit


class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        uri = urlsplit(self.path)
        assert uri.path == "/insert/jsonline", self.path
        assert parse_qs(uri.query, keep_blank_values=True, strict_parsing=True) == {
            "_stream_fields": ["job,host"],
            "_msg_field": ["log"],
            "_time_field": ["date"],
            "extra_fields": [f"job=audit,host={socket.gethostname()}"],
        }, self.path
        assert self.headers.get("Content-Encoding") == "gzip", self.headers
        assert self.headers.get_content_type() == "application/x-ndjson", self.headers
        data = gzip.decompress(self.rfile.read(int(self.headers["Content-Length"])))
        # An empty batch is harmless, but must not fabricate a received record.
        records = [json.loads(line) for line in data.splitlines() if line.strip()]
        for record in records:
            assert isinstance(record, dict), record
            assert isinstance(record.get("log"), str) and record["log"], record
            assert isinstance(record.get("source"), str), record
            assert record["source"].startswith("/var/log/audit/audit.log"), record
            date = record.get("date")
            assert isinstance(date, str) and re.fullmatch(
                r"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z", date
            ), record
            datetime.fromisoformat(date.replace("Z", "+00:00"))
        if records:
            with open("/run/mock-loki/received.jsonl", "a") as output:
                for record in records:
                    output.write(json.dumps(record) + "\n")
        self.send_response(204)
        self.end_headers()

    def log_message(self, *_):
        pass


HTTPServer(("127.0.0.1", 3100), Handler).serve_forever()
