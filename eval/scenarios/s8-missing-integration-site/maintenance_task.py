from client import DirectClient, build_client


def create_maintenance_client(metrics):
    return build_client(DirectClient(), metrics)
