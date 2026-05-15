from flask import Flask

app = Flask(__name__)


@app.route('/')
def hello():
    return 'Hello, World!'


def greet(name):
    """Greet function for testing"""
    return f"Hello, {name}!"


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
