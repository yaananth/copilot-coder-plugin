from routing import Router
from route_view import RouteView


def build_app():
    router = Router(["central", "east-2", "east"])
    view = RouteView(router)
    return router, view
