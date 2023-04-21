# vol-datalife

Build .so file
==================
Change HDF5_DIR to your hdf5 install path, type make to generate the dynamic shared library file libh5datalife.so.


Link to application
=================
Set these environment variables:
HDF5_VOL_CONNECTOR="provenance under_vol=0;under_info={};path=$YOUR_TRACE_FILE_PATH;level=2;format="
# Trace file path including the path and the file name.
# Level 1 for prints only, level 2 for file only, level 3 for file and prints.
# Leave format blank for now

HDF5_PLUGIN_PATH=$PATH_TO_SO_FILE_DIR.
#the path that holds libh5datalife.so.

Then make your hdf5 application as usual, no need to change it's code or Makefile.


Trace format
==================
Trace file is plain text. By default, it has two column, function name index and function duration in usec. You need to check the dictionary file (func_dic_733.txt) for the names.

If you want other info in the trace, change the dlife_write() function sprintf line. 
For example:
	    sprintf(pline, "[%s][User:%s][PID:%d][TID:%llu][Func:%s][%luus]\n", time, helper_in->user_name, helper_in->pid, helper_in->tid, msg, duration);
		//msg is captured function name


<!-- Running testcase application (VPIC)
==================
Makefile contains the testcase section that complies VPIC and links h5datalife to it. Default "make" builds the library and testcase. To run a simplified test case:
./vpicio_uni_h5 ./my_data.dat 2 2 1 ./my_trace.log -->
