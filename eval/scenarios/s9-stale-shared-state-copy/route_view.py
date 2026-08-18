import copy


class RouteView:
    def __init__(self, router):
        self.router = copy.copy(router)

    def route(self, slot):
        return self.router.route(slot)
