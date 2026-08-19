class DirectClient:
    pass


class InstrumentedClient:
    def __init__(self, client, metrics):
        self.client = client
        self.metrics = metrics


def build_client(client, metrics):
    return InstrumentedClient(client, metrics)
