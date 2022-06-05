import pandas as pd
from pivot_util import *

ml_data_path = "D:/Local/PubEq/MLData/EH"
entry_df = pd.read_csv("{}/eh_entry_flat.csv".format(ml_data_path))
ref_df = pd.read_csv("{}/eh_ref.csv".format(ml_data_path))

pvt_df = our_pivot(entry_df, 'DT')

ref_subset_df = ref_df[['FUND_ID', 'FUND_NAME', 'Beta', 'paSR_1y', 'paVol_1y', 'AUM', 'trackRecYrs']]

# Alternative way to pivot with aggregating functions is df.pivot_table:
# https://towardsdatascience.com/pandas-pivot-the-ultimate-guide-5c693e0771f3
# At the moment we want to get an error message if duplicate keys are found,
# thus using df.pivot. Can be added as a command-line option later.

out_df = pd.merge(ref_subset_df,pvt_df,left_on='FUND_ID', right_index=True)

out_df.to_csv("{}/eh_entry_ref_pivot_ORIG.csv".format(ml_data_path), index=False)
print("hello")