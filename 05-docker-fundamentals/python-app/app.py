from flask import Flask

app = Flask(__name__)


@app.get("/")
def hello() -> str:
    return (
        "<!doctype html><html lang='en'><head><meta charset='utf-8'>"
        "<title>Python Hello</title></head><body><main>"
        "<h1>Hello World from Python</h1></main></body></html>"
    )
