import json


def as_json(f):
    def wrapped(*args, **kwargs):
        return json.dumps(f(*args, **kwargs))
    return wrapped
