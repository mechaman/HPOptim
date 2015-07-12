from ctypes import byref, cdll, c_int
import ctypes
import numpy as np
import cython

def runModel(params):
	lualib = ctypes.CDLL("/home/toor/torch/install/lib/libluajit.so", mode=ctypes.RTLD_GLOBAL)
	l = cdll.LoadLibrary('HPOptim/libcluaf.so')

	l.computeCost.argtypes = [ctypes.POINTER(ctypes.c_char_p), ctypes.POINTER(ctypes.c_float), ctypes.c_int, ctypes.POINTER(ctypes.c_float)]


	arr_a = (ctypes.c_char_p * len(params))()
	arr_b = (ctypes.c_float * len(params))()



	i = 0
	for key, value in params.iteritems():
		arr_a[i] = key
		arr_b[i] = value
		print(arr_a[i])
		print(arr_b[i])
		i = i + 1

	result = (ctypes.c_float)()

	l.computeCost(arr_a,arr_b,ctypes.c_int(len(params)),result)
	return result.value

def main(job_id, params):
    print 'Anything printed here will end up in the output directory for job #%d' % job_id
    return runModel(params)