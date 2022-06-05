from scipy.io import loadmat
import argparse
import numpy as np
import pandas as pd

from util.basic_util import diff_list

_special_calc_flds = ['betas', 'dates_str']

def ml_datenum_to_py_date(ml_dt):
    origin = np.datetime64('0000-01-01', 'D') - np.timedelta64(1, 'D')
    dt = ml_dt * np.timedelta64(1, 'D') + origin    
    return dt

def import_our_ts(our_ts):
    hdr = np.concatenate(np.concatenate(our_ts[0][0]['header']))
    dts = ml_datenum_to_py_date(np.concatenate(our_ts[0][0]['dates']))
    vals = our_ts[0][0]['values']
    df = pd.DataFrame(vals, columns=hdr, index=dts)
    return df

def import_ml_calc(ml_calc):
    res = argparse.Namespace()
    res.betas = ml_calc[0,0]['betas'][0,0] # 2d ndarray
    res.dates = pd.to_datetime(ml_calc[0,0]['dates_chr'], format = '%Y-%m-%d')

    for fld in diff_list(ml_calc.dtype.names, _special_calc_flds):
        setattr(res, fld, ml_calc[0,0][fld])
    return res

def import_ml_db_data(ml_db_data):
    res = argparse.Namespace()
    for fld in ('equHFrtns','equFactorRtns'):
        setattr(res, fld, import_our_ts(ml_db_data[0,0][fld]))
    res.aumTS = pd.DataFrame(ml_db_data[0,0]['aumTS'], columns=res.equHFrtns.columns, index=res.equHFrtns.index) 
    res.fund_ids = ml_db_data[0,0]['fundIdHeader'].ravel()
    res.aum_ever_achieved_mm = ml_db_data[0,0]['aumEverAchieved'][0,0] / 1000 / 1000
    return res

def import_ml_output(ml_obj):
    res = argparse.Namespace()
    res.calc = import_ml_calc(ml_obj['calc_py'])
    res.db_data = import_ml_db_data(ml_obj['dbData_py'])
    res.first_period_dt = pd.to_datetime(ml_obj['firstPeriodStr'][0], format = '%Y-%m-%d')
    res.last_period_dt = pd.to_datetime(ml_obj['lastPeriodStr'][0], format = '%Y-%m-%d')
    res.months_per_period = ml_obj['monthsPerPeriod'][0][0]
    return res

def load_ml(file_name):
    ml = loadmat(file_name)
    return import_ml_output(ml)
    
    
def load_ml_entry_signal(file_name):
    ml = loadmat(file_name)
    res = argparse.Namespace()
    res.entry_filter = ml['totEntryFilter']
    return res
