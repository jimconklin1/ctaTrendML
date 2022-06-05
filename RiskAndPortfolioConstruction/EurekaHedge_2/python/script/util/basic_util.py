import pandas as pd

diff_list = lambda l1,l2: [x for x in l1 if x not in l2]
dict_subset = lambda d,l: {x: d[x] for x in d.keys() if x in l}
first_item_shape = lambda x: next(iter(x.values())).shape
none_if = lambda x, v: None if x==v else x

def add_to_dict(d, k, v):
    if k in d:
        raise ValueError("Key {} already exists".format(k))
    d[k] = v

def coalesce(*args):
    for v in args: 
        if v is not None: return v
    return None

def empty_copy(obj):
    class Empty(obj.__class__):
        def __init__(self): pass
    newcopy = Empty(  )
    newcopy.__class__ = obj.__class__
    return newcopy

# Apply a 2nd coordinate filter to all attributes of an object 
# (all attributes must be 2d arrays with same M x N dimensions)
def filter_attr_cols_2d(o, flt):
    res = empty_copy(o)
    for v in vars(o):
        setattr(res, v, getattr(o,v)[:, flt])
    return res

def cumsum_with_reset(x):
    # Brilliant!
    # https://stackoverflow.com/questions/45964740/python-pandas-cumsum-with-reset-everytime-there-is-a-0
    a = pd.DataFrame(x!=0)
    cs = a.cumsum()
    # > cs.where(~a) are cumsums in the 0/NaN spots of the original array
    # > cs.where(~a).ffill() propagates all of that forward onto non-missing elements,
    #     effectively returning the previous cumsum for all non-missing elements
    # > fillna(0) is necessary for all-blank columns
    return (cs-cs.where(~a).ffill().fillna(0).astype(int)).to_numpy()

