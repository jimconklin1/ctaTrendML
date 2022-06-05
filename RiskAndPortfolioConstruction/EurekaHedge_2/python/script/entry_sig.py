import pandas as pd
import numpy as np
import argparse
import openpyxl.styles as opxs
import os
import datetime 
import dateutil
import operator

import openpyxl as pxl
from openpyxl.utils.dataframe import dataframe_to_rows

from util.eh_ml_io import load_ml, load_ml_entry_signal
from util.filter_item import FilterItem
from util.basic_util import *
from util.eh_util import *
from util.eh_db_util import *

ml_data_path = "D:/Local/PubEq/MLData/EH2"
ml_fn_suff = "1mo"

ml_import_dir = "{}/ml_to_python".format(ml_data_path)
ref_pickle_fn = "{}/ref.pkl".format(ml_import_dir)
if os.path.isfile(ref_pickle_fn):
    ref_df = pd.read_pickle(ref_pickle_fn)
else:    
    db = connect_to_cfg_db("PubEqCoreProd_RO")
    ref_df = pd.read_sql("select * from eh.fund", db, parse_dates=['INCEPTION_DATE'], index_col='FUND_ID')
    ref_df.to_pickle(ref_pickle_fn)

ml = load_ml("{}/eh2_{}.mat".format(ml_import_dir, ml_fn_suff))
#ref_df = pd.read_csv("{}/eh_ref_full.csv".format(ml_import_dir), index_col='FUND_ID')
ref_df = ref_df.loc[ml.db_data.fund_ids.ravel(),:]
assert len(ref_df) == len(ml.db_data.fund_ids.ravel()), "Some ref records were lost after filtering!"


ref_df.insert(loc=1, column='trackRecYrs', value=((ml.calc.dates[-1] - ref_df.INCEPTION_DATE).dt.days/365.25).ravel())
ref_df.insert(loc=1, column='AUM', value=ml.db_data.aumTS.loc[ml.calc.dates[-1]].to_numpy().ravel()/(1000*1000))
ref_df.insert(loc=1, column='paVol_1y', value=ml.calc.pAlphaVol_12mo[-1,:].ravel())
ref_df.insert(loc=1, column='paSR_1y', value=ml.calc.pAlphaSrp_12mo[-1,:].ravel())
ref_df.insert(loc=1, column='Beta', value=ml.calc.betas[-1,:].ravel())
ref_df.to_csv("{}/eh_ref_full_py.csv".format(ml_import_dir))
cfg = argparse.Namespace()
cfg.entry = argparse.Namespace()

cfg.entry.min_track_rec_mo = 18
cfg.entry.max_beta = .2
cfg.entry.min_sr_12mo = .75
cfg.entry.min_vol_12mo = .05
cfg.entry.min_aum_mm = 250

valid_incept_dt = ~pd.isna(ref_df.INCEPTION_DATE)
min_invest_dt = ref_df.INCEPTION_DATE.copy()
min_invest_dt[valid_incept_dt] += np.tile(
    dateutil.relativedelta.relativedelta(months=cfg.entry.min_track_rec_mo), np.sum(valid_incept_dt))

entry_flt_map = {}
entry_flt_map['TR'] = FilterItem(np.array([ml.calc.dates]).T > np.array([min_invest_dt])
    , 'Track record > {}mo'.format(cfg.entry.min_track_rec_mo))
entry_flt_map['B'] = FilterItem((ml.calc.betas < cfg.entry.max_beta) & (ml.calc.betas >-999999)
    , 'Beta < {}'.format(cfg.entry.max_beta))
entry_flt_map['SR'] = FilterItem(ml.calc.pAlphaSrp_12mo > cfg.entry.min_sr_12mo
    , 'Pr.Alpha SR(1yr) > {}'.format(cfg.entry.min_sr_12mo))
entry_flt_map['Vol'] = FilterItem(ml.calc.pAlphaVol_12mo > cfg.entry.min_vol_12mo
    , 'Pr.Alpha Vol(1yr) > {}'.format(cfg.entry.min_vol_12mo))
entry_flt_map['AUM'] = FilterItem(ml.db_data.aumTS.loc[ml.calc.dates].to_numpy() 
    >= cfg.entry.min_aum_mm * 1000 * 1000
    , 'AUM > ${}mm'.format(cfg.entry.min_aum_mm))

entry_sig = combine_filter_map(entry_flt_map, operator.and_)

entry_df = pd.DataFrame(entry_sig, index=ml.calc.dates.ravel(), columns=ml.db_data.fund_ids.ravel())
entry_up_df = pd.melt(entry_df, ignore_index=False)
entry_up_df = entry_up_df[entry_up_df.value]

entry_up_df['ID'] = entry_up_df['variable']
entry_up_df['DT'] = entry_up_df.index

entry_up_df[['ID', 'DT']].sort_values(by=['DT', 'ID']).to_csv("{}/eh_entry_flat_1mo_py.csv".format(ml_import_dir), index=False)

