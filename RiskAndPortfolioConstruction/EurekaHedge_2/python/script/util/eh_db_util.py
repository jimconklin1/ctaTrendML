import configparser
from pathlib import Path
#import logging
import cx_Oracle

def connect_to_oracle_db(username, pwd, alias):
    con_str = "{}/{}@{}".format(username, pwd, alias)
    #logger.info("Connecting to Oracle [{}]...".format(alias))
    conn =  cx_Oracle.connect(con_str)
    return conn

def connect_to_cfg_db(cfg_key):
    db_ini = "{}\\Documents\\PubEq\\Databases.ini".format(Path.home())
    db_config = configparser.ConfigParser()
    db_config.read(db_ini)
    db_params = db_config[cfg_key]
    db_vendor = db_params['vendor']
    if db_vendor == 'Oracle':
        return connect_to_oracle_db(db_params['username'], db_params['password'], db_params['alias'])
    elif db_vendor == 'Postgres':
        return connect_to_postgres_db(db_params['host'], db_params['dbname'], db_params['username'], db_params['password'])
    else:
        raise Exception("Unknown database vendor: {}".format(db_vendor))
