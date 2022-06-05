import argparse 
import operator
import pandas as pd
import numpy as np

from .basic_util import *
from .eh_util import combine_filter_map
from .eh_types import FilterItem, PosWeightItem

def get_config():
    cfg = argparse.Namespace(entry=argparse.Namespace(), exit=argparse.Namespace()
            , rpt=argparse.Namespace(), output=argparse.Namespace()
            , inv=argparse.Namespace(entry=argparse.Namespace(), exit=argparse.Namespace()))

    cfg.rpt.style_by_period = True
    cfg.rpt.excel = False
    cfg.output.highlight_mean_return_csv = True

# Model Spec: Begin
    cfg.ccy_flt = ['USD', 'EUR' ,'GBP' ,'CHF' ,'AUD' ,'JPY' , 'CAD', 'HKD']
    cfg.inv.entry.delay = 3
    cfg.inv.entry.allow_cancel = True
    cfg.inv.hold_months = 12
    cfg.entry.track_rec_mo = 18

    cfg.entry.beta = .2
    cfg.exit.beta = .4

    #cfg.entry.rtn_12mo = 0.15
    cfg.entry.sr_12mo = 1
    #cfg.exit.sr_12mo = .5

    cfg.exit.sr_36mo = 0
    #if hasattr(cfg.exit, 'sr_36mo'):
    #    cfg.entry.sr_36mo = cfg.exit.sr_36mo + .1

    cfg.entry.vol_12mo_floor = .03
    cfg.exit.vol_12mo_floor = .02

    #cfg.entry.vol_12mo_cap = .06
    #cfg.exit.vol_12mo_cap = .08

    cfg.entry.aum_mm = 300
    #cfg.exit.aum_mm = 50

    cfg.entry.vol_jump_factor = 2.5
    #cfg.exit.vol_jump_factor = 2

    cfg.inv.exit.is_uniform_delay = False
    cfg.inv.exit.delay = 3
    cfg.inv.exit.processing_time = 1

    cfg.inv.weigh_by_strategy = False
    cfg.inv.weight_cfg = [
        PosWeightItem(['CTA/Managed Futures'], .1, .25),
        PosWeightItem(['Macro'], .15, .3),
        PosWeightItem(['Long Short Equities', 'Bottom-Up', 'Top-Down'], .15, .3),
        PosWeightItem(['Multi-Strategy'], .1, .3),
        PosWeightItem(['Fixed Income', 'Relative Value'], .05, .2),
    ]

# Model Spec: End

    return cfg

def build_signals(cfg, ml):
    lookback = int(12//cfg.inv.months_per_period * 2)
    paVol_1 = pd.DataFrame(ml.calc.pAlphaVol_12mo).shift(periods= lookback)
    paVol_1.iloc[0:lookback,:] = paVol_1.iloc[lookback, :]
    vol_growth = (ml.calc.pAlphaVol_12mo / paVol_1).to_numpy()
    res=argparse.Namespace()
    res.entry_map = {}
    res.entry_map['TR'] = FilterItem(np.array([ml.calc.dates]).T > np.array([cfg.min_invest_dt]), 'Track record > {}mo'.format(cfg.entry.track_rec_mo))

    if hasattr(cfg.entry, 'beta'):
        add_to_dict(res.entry_map, 'B', FilterItem((ml.calc.betas < cfg.entry.beta) & (ml.calc.betas >-999999), 'Beta < {}'.format(cfg.entry.beta)))
    if hasattr(cfg.entry, 'rtn_12mo'):
        add_to_dict(res.entry_map, 'R1y', FilterItem(ml.calc.pAlphaRtn_12mo > cfg.entry.rtn_12mo, 'Pr.Alpha Ret(1yr) > {}'.format(cfg.entry.rtn_12mo)))
    if hasattr(cfg.entry, 'sr_12mo'):
        add_to_dict(res.entry_map, 'SR1y', FilterItem(ml.calc.pAlphaSrp_12mo > cfg.entry.sr_12mo, 'Pr.Alpha SR(1yr) > {}'.format(cfg.entry.sr_12mo)))
    if hasattr(cfg.entry, 'sr_36mo'):
        add_to_dict(res.entry_map, 'SR3y', FilterItem(ml.calc.pAlphaSrp_36mo > cfg.entry.sr_36mo, 'Pr.Alpha SR(3yr) > {}'.format(cfg.entry.sr_36mo)))
    if hasattr(cfg.entry, 'vol_12mo_floor'):
        add_to_dict(res.entry_map, 'VF', FilterItem(ml.calc.pAlphaVol_12mo > cfg.entry.vol_12mo_floor, 'Pr.Alpha Vol(1yr) > {}'.format(cfg.entry.vol_12mo_floor)))
    if hasattr(cfg.entry, 'vol_12mo_cap'):
        add_to_dict(res.entry_map, 'VC', FilterItem(ml.calc.pAlphaVol_12mo < cfg.entry.vol_12mo_cap, 'Pr.Alpha Vol(1yr) < {}'.format(cfg.entry.vol_12mo_cap)))
    if hasattr(cfg.entry, 'aum_mm'):
        add_to_dict(res.entry_map, 'A', FilterItem(ml.db_data.aumTS.loc[ml.calc.dates].to_numpy() >= cfg.entry.aum_mm * 1000 * 1000, 'AUM >= ${}mm'.format(cfg.entry.aum_mm)))
    if hasattr(cfg.entry, 'vol_jump_factor'):
        add_to_dict(res.entry_map, 'VG', FilterItem(vol_growth < cfg.entry.vol_jump_factor, 'Vol(1yr primAlha) / Vol(1yr primAlha, -1yr) < {}'.format(cfg.entry.vol_jump_factor)))

    res.exit_map = {}
    if hasattr(cfg.exit, 'beta'):
        add_to_dict(res.exit_map, 'B', FilterItem((ml.calc.betas > cfg.exit.beta) & (ml.calc.betas >-999999), 'Beta > {}'.format(cfg.exit.beta)))
    if hasattr(cfg.exit, 'sr_12mo'):
        add_to_dict(res.exit_map, 'SR1y', FilterItem(ml.calc.pAlphaSrp_12mo < cfg.exit.sr_12mo, 'SR(primAlpha, 1yr) < {}'.format(cfg.exit.sr_12mo)))
    if hasattr(cfg.exit, 'sr_36mo'):
        add_to_dict(res.exit_map, 'SR3y', FilterItem(ml.calc.pAlphaSrp_36mo < cfg.exit.sr_36mo, 'SR(primAlpha, 3yr) < {}'.format(cfg.exit.sr_36mo)))
    if hasattr(cfg.exit, 'vol_12mo_floor'):
        add_to_dict(res.exit_map, 'VF', FilterItem(ml.calc.pAlphaVol_12mo < cfg.exit.vol_12mo_floor, 'Pr.Alpha Vol(1yr) < {}'.format(cfg.exit.vol_12mo_floor)))
    if hasattr(cfg.exit, 'vol_12mo_cap'):
        add_to_dict(res.exit_map, 'VC', FilterItem(ml.calc.pAlphaVol_12mo > cfg.exit.vol_12mo_cap, 'Pr.Alpha Vol(1yr) > {}'.format(cfg.exit.vol_12mo_cap)))
    if hasattr(cfg.exit, 'aum_mm'):
        add_to_dict(res.exit_map, 'A', FilterItem(ml.db_data.aumTS.loc[ml.calc.dates].to_numpy() < cfg.exit.aum_mm * 1000 * 1000, 'AUM < ${}mm'.format(cfg.exit.aum_mm)))
    if hasattr(cfg.exit, 'vol_jump_factor'):
        add_to_dict(res.exit_map, 'VG', FilterItem(vol_growth > cfg.exit.vol_jump_factor, 'Vol(1yr primAlha) / Vol(1yr primAlha, -1yr) > {}'.format(cfg.exit.vol_jump_factor)))

    return res
