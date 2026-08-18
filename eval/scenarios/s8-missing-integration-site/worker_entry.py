from client import DirectClient, build_client


def create_worker_client(metrics):
    return build_client(DirectClient(), metrics)
