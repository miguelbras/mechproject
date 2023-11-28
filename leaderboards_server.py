#!/usr/bin/env python3
"""
License: MIT License
Copyright (c) 2023 Miel Donkers
Very simple HTTP server in python for logging requests
Usage::
    ./server.py [<port>]
"""
from http.server import BaseHTTPRequestHandler, HTTPServer
import logging
import json  
      
class S(BaseHTTPRequestHandler):
    def _set_response(self, content_length):
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', content_length)
        self.end_headers()

    def do_GET(self):
        logging.info("GET request,\nPath: %s\nHeaders:\n%s\n", str(self.path), str(self.headers))
        with open('leaderboards.json') as infile:
            data = json.load(infile)
        data["values"] = data["values"][0:min(100, len(data["values"]))]
        json_str = json.dumps(data, indent = 4) 
        self._set_response(len(json_str))
        self.wfile.write(json_str.encode(encoding='utf_8'))

    def do_POST(self):
        content_length = int(self.headers['Content-Length']) # <--- Gets the size of data
        post_data = self.rfile.read(content_length).decode('utf-8') # <--- Gets the data itself
        logging.info("POST request,\nPath: %s\nHeaders:\n%s\n\nBody:\n%s\n",
                str(self.path), str(self.headers), post_data)
        post_json = json.loads(post_data)

        if "name" not in post_json or "time" not in post_json or "secret" not in post_json or \
                not isinstance(post_json["name"], str) or not isinstance(post_json["time"], int) or not isinstance(post_json["secret"], str) or \
                post_json["time"] <= 0 or post_json["secret"] != "quwhrksdbvieurrhrfoqiushffowiihoqusbijqwbv":
            self.do_GET()
            return
        if len(post_json["name"]) > 20:
            post_json["name"] = post_json["name"][0:20]
        new_score = {"name": post_json["name"], "time": post_json["time"]}

        # Store score in file
        data = {}
        with open('leaderboards.json') as infile:
            data = json.load(infile)
        data["values"].append(new_score)
        data["values"] = sorted(data["values"], key=lambda x:x["time"])

        with open("leaderboards.json", "w") as outfile: 
            json.dump(data, outfile)

        # Respond
        self.do_GET()

def run(server_class=HTTPServer, handler_class=S, port=8080):
    logging.basicConfig(level=logging.INFO)
    server_address = ('127.0.0.1', port)
    httpd = server_class(server_address, handler_class)
    logging.info('Starting httpd...\n')
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
    httpd.server_close()
    logging.info('Stopping httpd...\n')

if __name__ == '__main__':
    from sys import argv

    if len(argv) == 2:
        run(port=int(argv[1]))
    else:
        run()