from client import DirectClient, build_client


def create_client(metrics):
    return build_client(DirectClient(), metrics)
