import openpyxl.cell.cell
from openpyxl.utils.dataframe import dataframe_to_rows
import numpy as np
import pandas as pd

def my_opx_append_rows(ws, rows, hdr_row_cnt=1, hdr_col_cnt=0, styles=None, number_formats=None, hdr_font=None, starting_row=None):
    if starting_row is None:
        starting_row = ws._current_row+1
    for i, r in enumerate(rows):
        for col_idx, content in enumerate(r):
            row_idx = starting_row+i
            cell = openpyxl.cell.cell.Cell(ws, row=row_idx, column=col_idx+1, value=content)
            if (i<hdr_row_cnt) and (hdr_font is not None):
                cell.font = hdr_font
            if (i>=hdr_row_cnt) and (styles is not None) and (len(styles)>col_idx-hdr_col_cnt) and (col_idx>=hdr_col_cnt):
                style = styles[col_idx-hdr_col_cnt]
                if style is not None:
                    cell.style = style
            if (i>=hdr_row_cnt) and (number_formats is not None) and (len(number_formats)>col_idx-hdr_col_cnt) and (col_idx>=hdr_col_cnt):
                nf = number_formats[col_idx-hdr_col_cnt]
                if nf is not None:
                    cell.number_format = nf
            ws._cells[(row_idx, col_idx+1)] = cell

def opx_df_to_rows_patched(df, *args, **kwargs):
    skip_empty_row = not ('index' in kwargs) or kwargs['index']
    for i, r in enumerate(dataframe_to_rows(df, *args, **kwargs)):
        if skip_empty_row and (i==1) and np.all(pd.isna(r)):
            continue
        yield r