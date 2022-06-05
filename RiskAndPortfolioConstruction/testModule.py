import numpy as np
import array as ar

# Start Matlab from Anaconda prompt:
# "C:\Program Files\MATLAB\R2019a\bin\matlab.exe"
# run "pyversion" in Matlab. if blank is returned, you need to set it up.
# Examples:
# pyversion C:\Users\dpopov\AppData\Local\Continuum\anaconda3\python.exe
# pyversion C:\Users\dpopov\AppData\Local\Continuum\anaconda3\envs\matlab\pythonw.exe
#
# A simple test of Python integration. call it like this, from the RAPC directory:
# >> py.importlib.import_module('testModule');
# >> py.testModule.pyadd(2,3)
# ans =
#   5
#
# to reload: 
# >> clear classes
# >> py.importlib.reload(py.importlib.import_module('testModule'));
#
# x1= py.testModule.dummy2().int64

def pyadd(x,y):
    return x+y
    
def inspect(x):
  print(type(x))
  print('-----')
  print(x)
  return x
  
def dummy(x):
    return {
      "input": x,
      "num": 5,
      "str": "xyz test",
      "vector": list(range(8))
    }

def dummy2():
  #return ar.array('d', [1,2,3])
  return np.asarray(range(8))

def dummy3():
  return np.array([[1.05, 2, 3], [4, 5, 6]], np.double)

