class FeatureClient:
    def __init__(self, primary):
        self.primary = primary

    def enabled_for(self, preloaded, feature, actor):
        key = (feature, actor)
        if key in preloaded:
            return preloaded[key]
        return self.primary.is_enabled(feature, actor)
