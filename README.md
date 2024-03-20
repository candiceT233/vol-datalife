# DaYu-Tracker

This code monitors hdf5 program I/O from the Virtual Object Layer (VOL) level as well as the Vitual File Driver (VFD) level.


The VOL monitors objects accesses during program, implemented with the HDF5 Passthrough VOL.


The VFD monitors POSIX I/O operation during program, implemented with the HDF5 default sec2 I/O operations.


# How to use

## Setup program task name
Before running your program from a bash command, setup program task name two ways:
---
1. Setup with bash environment variable:
```shell
export CURR_TASK="my_program"
```
---
2. Setup with file in `/tmp` directory:
```bash

export WORKFLOW_NAME="my_program"
export PATH_FOR_TASK_FILES="/tmp/$USER/$WORKFLOW_NAME"
mkdir -p $PATH_FOR_TASK_FILES
> $PATH_FOR_TASK_FILES/${WORKFLOW_NAME}_vfd.curr_task # clear the file
> $PATH_FOR_TASK_FILES/${WORKFLOW_NAME}_vol.curr_task # clear the file

echo -n "$TASK_NAME" > $PATH_FOR_TASK_FILES/${WORKFLOW_NAME}_vfd.curr_task
echo -n "$TASK_NAME" > $PATH_FOR_TASK_FILES/${WORKFLOW_NAME}_vol.curr_task
```

## Dynamically load VFD and VOL libraries
```bash
TRACKER_SRC_DIR="../build/src" # dayu_tracker installation path
schema_file_path="`pwd`" #your_path_to_store_log_files
export HDF5_VOL_CONNECTOR="tracker under_vol=0;under_info={};path=$schema_file_path;level=2;format=" # VOL connector info string
export HDF5_PLUGIN_PATH=$TRACKER_SRC_DIR/vfd:$TRACKER_SRC_DIR/vol
export HDF5_DRIVER=hdf5_tracker_vfd # VFD driver name
export HDF5_DRIVER_CONFIG="${schema_file_path};${TRACKER_VFD_PAGE_SIZE}" # VFD info string

# Run your program
python h5py_write_read.py
```