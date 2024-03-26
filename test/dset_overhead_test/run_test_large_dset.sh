#!/bin/bash


TRACKER_SRC_DIR=../../build/src
export VOL_NAME="tracker"
export HDF5_USE_FILE_LOCKING='FALSE' # TRUE FALSE BESTEFFORT
export TRACKER_VFD_PAGE_SIZE=65536 #65536

IO_FILE="$(pwd)/sample.h5"
ARRAY_SIZE=1024

PREP_TASK_NAME () {
    TASK_NAME=$1
    export CURR_TASK=$TASK_NAME
    export WORKFLOW_NAME="dset_overhead_test"
    export PATH_FOR_TASK_FILES="/tmp/$USER/$WORKFLOW_NAME"
    mkdir -p $PATH_FOR_TASK_FILES
    > $PATH_FOR_TASK_FILES/${WORKFLOW_NAME}_vfd.curr_task # clear the file
    > $PATH_FOR_TASK_FILES/${WORKFLOW_NAME}_vol.curr_task # clear the file

    echo -n "$TASK_NAME" > $PATH_FOR_TASK_FILES/${WORKFLOW_NAME}_vfd.curr_task
    echo -n "$TASK_NAME" > $PATH_FOR_TASK_FILES/${WORKFLOW_NAME}_vol.curr_task
}

SIMPLE_VFD_VOL_IO () {

    local task1="write_read"
    local task2="read2"

    schema_file_path="`pwd`"
    rm -rf $schema_file_path/*vfd_data_stat.json
    rm -rf $schema_file_path/*vol_data_stat.json

    # echo "TRACKER_VFD_DIR : `ls -l $TRACKER_SRC_DIR/*`"

    export HDF5_VOL_CONNECTOR="$VOL_NAME under_vol=0;under_info={};path=$schema_file_path;level=2;format="
    export HDF5_PLUGIN_PATH=$TRACKER_SRC_DIR/vfd:$TRACKER_SRC_DIR/vol #:$HDF5_PLUGIN_PATH
    export HDF5_DRIVER=hdf5_tracker_vfd
    export HDF5_DRIVER_CONFIG="${schema_file_path};${TRACKER_VFD_PAGE_SIZE}"

    PREP_TASK_NAME "$task1"
    python3 large_dset_write.py $IO_FILE $ARRAY_SIZE

    PREP_TASK_NAME "$task2"
    python3 large_dset_read.py $IO_FILE $ARRAY_SIZE
}

# get execution time in ms
start_time=$(date +%s%3N)
mkdir -p save_logs
LOGFILE=save_logs/${test_type}_run.log
# get execution time in ms
start_time=$(date +%s%3N)

echo "Running VFD and VOL Tracker test"
SIMPLE_VFD_VOL_IO 2>&1 | tee $LOGFILE

end_time=$(date +%s%3N)
echo "Execution time: $((end_time-start_time)) ms"

du -h $IO_FILE