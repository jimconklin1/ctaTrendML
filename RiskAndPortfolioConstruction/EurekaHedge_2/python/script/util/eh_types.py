
class FilterItem:
    def __init__(self, filter, dscr):
        self.filter = filter
        self.dscr = dscr

class PosWeightItem:
    def __init__(self, inv_strats, min_weight, max_weight):
        assert not(min_weight > max_weight), "Min. weight should be <= max. weight" # None's are OK
        self.inv_strats = inv_strats
        self.min_weight = min_weight
        self.max_weight = max_weight
