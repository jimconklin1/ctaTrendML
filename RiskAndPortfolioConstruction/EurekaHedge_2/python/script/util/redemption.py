import pandas as pd
import numpy as np
import re

_freq_periods = {
    'month':       1,
    'daily':        .05,
    'week':         .25,
    'annual':     12,
    'quarter':     3,
    'none':         .05,
    'not applic':   .05,
    'biennially': 24, # accomodate for typos. Possible they meant "semi-ammual", but we take it as is for now.
}

_prefix_mult = {
    'semi':  .5,
    'bi'  : 2,
}

_notif_periods = {
    'month':    1,
    'calendar\\s+month': 1,
    'week':      .25,
    'day':      1/30,
    'business\\s+day': 1/20,
    'working\\s+day':  1/20,
    'banking\\s+day':  1/20,
    'calendar\\s+day': 1/30,
}

def handle_frequency(df):
    df = df.copy()
    for v, len_mo in _freq_periods.items():
        matched_new_idx = df.index.str.lower().str.startswith(v) & pd.isna(df['len_mo'])
        df.loc[matched_new_idx, 'len_mo'] = len_mo
        for pr, pr_factor in _prefix_mult.items():
            matched_new_pr_idx = df.index.str.lower().str.startswith(pr+'-'+v) & pd.isna(df['len_mo'])
            df.loc[matched_new_pr_idx, 'len_mo'] = len_mo * pr_factor
    return df

def apply_captured_regex(df, cap, len_mo):
    df = df.copy()
    captured_exp = pd.Series(np.tile(np.nan, (len(df))))
    captured_exp[cap.index] = cap.to_numpy().ravel()
    matched_new_idx = ( ~pd.isna(captured_exp).to_numpy() & pd.isna(df['len_mo']).to_numpy() )
    df.loc[matched_new_idx, 'len_mo'] = captured_exp[matched_new_idx].astype(np.float64).to_numpy() * len_mo
    if len_mo < 1/20:
        # if unit is "calendar days" and length is 5 or less, "downgrade" to business days
        sub_idx = matched_new_idx & (captured_exp.astype(np.float64) <= 5.0).to_numpy()
        df.loc[sub_idx, 'len_mo'] = captured_exp[sub_idx].astype(np.float64).to_numpy() * 1/20
    return df

def handle_time_periods(df):
    for v, len_mo in _notif_periods.items():
        captured = df.index.str.extractall('^([0-9]+)\s+'+v, flags=re.IGNORECASE).groupby(level=0).max()
        df = apply_captured_regex(df, captured, len_mo)
    return df

def handle_dflt_redemption(df, dflt=None):
    if dflt is not None:
        df = df.copy()
        df.loc[pd.isna(df.len_mo), 'len_mo'] = dflt
    return df

def extract_notification_lookup(df, include_count=False, dflt=None):
    notify_stat_df =  df.groupby(['REDEMPTION_NOTIFY_PERIOD']).count().loc[:,['FUND_NAME']].rename(columns={'FUND_NAME':'cnt'}).sort_values(by='cnt', ascending=False)
    
    if include_count:
        notify_stat_df = df.groupby(['REDEMPTION_NOTIFY_PERIOD']).count().loc[:,['FUND_NAME']].rename(columns={'FUND_NAME':'cnt'}).sort_values(by='cnt', ascending=False)
    else:
        notify_stat_df = pd.DataFrame(index=df['REDEMPTION_NOTIFY_PERIOD'].unique()).drop(index=[None], errors='ignore')
    
    notify_stat_df = notify_stat_df.assign(len_mo=np.nan)
    notify_stat_df = handle_frequency(notify_stat_df)
    notify_stat_df = handle_time_periods(notify_stat_df)

    captured_tplus = notify_stat_df.index.str.extractall('^[TD][+-]([0-9]+)', flags=re.IGNORECASE).groupby(level=0).max()
    notify_stat_df = apply_captured_regex(notify_stat_df, captured_tplus, 0.05)
    return handle_dflt_redemption(notify_stat_df, dflt)

def extract_frequency_lookup(df, include_count=False, dflt=None):
    if include_count:
        freq_stat_df = df.groupby(['REDEMPTION_FREQUENCY']).count().loc[:,['FUND_NAME']].rename(columns={'FUND_NAME':'cnt'}).sort_values(by='cnt', ascending=False)
    else:
        freq_stat_df = pd.DataFrame(index=df['REDEMPTION_FREQUENCY'].unique()).drop(index=[None], errors='ignore')
    freq_stat_df = freq_stat_df.assign(len_mo=np.nan)
    freq_stat_df = handle_frequency(freq_stat_df)
    freq_stat_df = handle_time_periods(freq_stat_df)
    return handle_dflt_redemption(freq_stat_df, dflt)

def parse_redemption_info(df, dflt_delay, dflt_notification):
    freq_lookup = extract_frequency_lookup(df, dflt=dflt_delay)
    notif_lookup = extract_notification_lookup(df, dflt=dflt_notification)
    freq_lookup.rename(columns={'len_mo': 'redemp_freq_len_mo'}, inplace=True)
    notif_lookup.rename(columns={'len_mo': 'redemp_notif_len_mo'}, inplace=True) 
    df1 = df.join(freq_lookup, on=['REDEMPTION_FREQUENCY'], how='left')   
    df1 = df1.join(notif_lookup, on=['REDEMPTION_NOTIFY_PERIOD'], how='left')   
    assert len(df) == len(df1), "Lost records during redemption enrichment!"
    return df1