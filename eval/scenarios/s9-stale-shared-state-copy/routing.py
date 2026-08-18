class Router:
    def __init__(self, routes):
        self.routes = tuple(routes)

    def set_target(self, slot, target):
        updated = list(self.routes)
        updated[slot] = target
        self.routes = tuple(updated)

    def route(self, slot):
        return self.routes[slot]
