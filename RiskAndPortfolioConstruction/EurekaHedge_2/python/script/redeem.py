import pandas as pd
import numpy as np
import os

from util.redemption import *
from util.basic_util import *
from util.eh_util import *
from util.eh_db_util import *

ml_data_path = "D:/Local/PubEq/MLData/EH2"
output_path = "{}/{}/redeem".format(ml_data_path, "out") 

ml_import_dir = "{}/ml_to_python".format(ml_data_path)

ref_pickle_fn = "{}/ref.pkl".format(ml_import_dir)
if os.path.isfile(ref_pickle_fn):
    ref_df = pd.read_pickle(ref_pickle_fn)
else:    
    db = connect_to_cfg_db("PubEqCoreProd_RO")
    ref_df = pd.read_sql("select * from eh.fund", db, parse_dates=['INCEPTION_DATE'], index_col='FUND_ID')
    ref_df.to_pickle(ref_pickle_fn)

x = parse_redemption_info(ref_df)
x[['FUND_NAME', 'REDEMPTION_FREQUENCY', 'REDEMPTION_NOTIFY_PERIOD', 'redemp_freq_len_mo', 'redemp_notif_len_mo']].to_csv("{}/ref_enriched.csv".format(output_path))

notify_stat_df = extract_notification_lookup(ref_df, include_count=True)
freq_stat_df = extract_frequency_lookup(ref_df, include_count=True)

#notify_stat_df = extract_notification_lookup(ref_df, include_count=True)
#freq_stat_df = extract_frequency_lookup(ref_df, include_count=True)

freq_stat_df.to_csv("{}/freq.csv".format(output_path))
notify_stat_df.to_csv("{}/notify.csv".format(output_path))

#notify_top_df = notify_stat_df.iloc[:10,0]
