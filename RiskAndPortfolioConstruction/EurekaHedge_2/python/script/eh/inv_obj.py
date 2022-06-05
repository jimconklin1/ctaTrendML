from util.eh_util import build_pos, pos_pad, calc_weights_by_style, calc_uniform_weights, pad_pos_array
from util.const import *
style_fld = 'MAIN_INVESTMENT_STRATEGY'

class FundIndexBuilder:
    def __init__(self, inv, ref):
        self._inv = inv
        self._ref = ref

    def run(self):
        p = build_pos(self._inv.sig, self._inv.cfg, self._inv.entry_delay, self._inv.exit_delay)
        self.pos = pad_pos_array(p.pos)
        self.stat = p.stat

        if self._inv.cfg.weigh_by_strategy:
            self.weights, self.style_wgt_range = calc_weights_by_style(
                self.ref.df.loc[self.ref.fund_ids[self.ref.fund_flt], [style_fld]]
                , self.cfg._inv.weight_cfg, self.pos, style_fld)
        else:
            self.weights = calc_uniform_weights(self.pos)
            self.style_wgt_range = None

class FundInvestor:
    def __init__(self):
        pass

