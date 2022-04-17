function o = cdx_fetch_user_daily(ids, start_date, end_date, row_fmt)
import tsrp.*
o = cdx_fetch_one(ids, 'udts', row_fmt, start_date, end_date, true);