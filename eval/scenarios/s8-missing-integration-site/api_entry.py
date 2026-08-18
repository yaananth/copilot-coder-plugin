from client import DirectClient, build_client


def create_api_client(metrics):
    return build_client(DirectClient(), metrics)
