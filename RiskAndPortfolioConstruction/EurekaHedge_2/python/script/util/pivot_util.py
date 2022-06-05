from .basic_util import *

def our_pivot(df, pivot, value=None):
    if not value:
        if "val" in df.columns:
            value = "val" # ''.join(random.choice(string.ascii_lowercase) for i in range(5)
        elif "value" in df.columns:
            value = "value"
        else:
            # add a column of 1's
            df = df.assign(val = 1)
            value = "val"

    pvt = df.pivot(index=diff_list(df.columns, [pivot, value]), columns=pivot, values=value)
    return pvt
