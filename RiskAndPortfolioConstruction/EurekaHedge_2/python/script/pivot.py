import argparse
import pandas as pd
import sys
#sys.path.append("../util")
from util.pivot_util import *

parser = argparse.ArgumentParser(
    description='Pivot a csv file'
    , formatter_class=argparse.RawTextHelpFormatter
)

parser.add_argument('input', help="Input file")
parser.add_argument('-o', '--output_file', help="Output file name")
parser.add_argument('-p', '--pivot', required=True, help="Column name to pivot")
parser.add_argument('-v', '--value', help="Value column (optional). 1/0 will be used if not specified.")

args = parser.parse_args()

df = pd.read_csv(args.input)
pvt = our_pivot(df, **dict_subset(vars(args), ['value', 'pivot']))

# Alternative way to pivot with aggregating functions is df.pivot_table:
# https://towardsdatascience.com/pandas-pivot-the-ultimate-guide-5c693e0771f3
# At the moment we want to get an error message if duplicate keys are found,
# thus using df.pivot. Can be added as a command-line option later.

print("hello")