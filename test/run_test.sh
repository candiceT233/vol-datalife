#!/bin/bash


TRACKER_SRC_DIR=../build/src
VOL_NAME="tracker"

export HDF5_USE_FILE_LOCKING='FALSE' # TRUE FALSE BESTEFFORT


export WORKFLOW_NAME="h5_write_read"
export PATH_FOR_TASK_FILES="/tmp/$USER/$WORKFLOW_NAME"
mkdir -p $PATH_FOR_TASK_FILES
> $PATH_FOR_TASK_FILES/${WORKFLOW_NAME}_vfd.curr_task # clear the file
> $PATH_FOR_TASK_FILES/${WORKFLOW_NAME}_vol.curr_task # clear the file

IO_FILE="$(pwd)/vlen_sample.h5"
rm -rf $IO_FILE $(pwd)/*.h5
export TRACKER_VFD_PAGE_SIZE=65536

SIMPLE_VOL_IO (){
    schema_file_path="`pwd`"
    rm -rf $schema_file_path/*vol_data_stat.yaml
    
    export HDF5_VOL_CONNECTOR="$VOL_NAME under_vol=0;under_info={};path=$schema_file_path;level=2;format="
    export HDF5_PLUGIN_PATH=$TRACKER_SRC_DIR/vol
    python vlen_h5_write_read.py $IO_FILE
    python vlen_h5_read2.py $IO_FILE
    
}

SIMPLE_VFD_IO (){
    schema_file_path="`pwd`"
    rm -rf $schema_file_path/*vfd_data_stat.yaml
    

    echo "TRACKER_VFD_DIR = $TRACKER_SRC_DIR/vfd"
    
    # HDF5_VOL_CONNECTOR="under_vol=0;under_info={};path=`pwd`" \

    # Only VFD
    set -x
    # LD_LIBRARY_PATH=$TRACKER_SRC_DIR/vfd:$LD_LIBRARY_PATH \
    # export CURR_TASK="example_test"

    export HDF5_DRIVER_CONFIG="true ${TRACKER_VFD_PAGE_SIZE}"
    export HDF5_DRIVER=hdf5_tracker_vfd
    export HDF5_LOG_FILE_PATH="$schema_file_path"
    export HDF5_PLUGIN_PATH=$TRACKER_SRC_DIR/vfd
    
    python vlen_h5_write_read.py $IO_FILE
    # python vlen_h5_read2.py $IO_FILE
}

SIMPLE_VFD_VOL_IO () {

    schema_file_path="`pwd`"
    rm -rf $schema_file_path/*vfd_data_stat.yaml
    rm -rf $schema_file_path/*vol_data_stat.yaml
    TRACKER_VFD_PAGE_SIZE=65536 #65536

    echo "TRACKER_VFD_DIR : `ls -l $TRACKER_SRC_DIR/*`"
    
    # HDF5_VOL_CONNECTOR="under_vol=0;under_info={};path=`pwd`" \

    # Only VFD
    set -x
    # LD_LIBRARY_PATH=$TRACKER_SRC_DIR/vfd:$LD_LIBRARY_PATH \
    # export CURR_TASK="example_test"

    export HDF5_VOL_CONNECTOR="$VOL_NAME under_vol=0;under_info={};path=$schema_file_path;level=2;format="
    export HDF5_PLUGIN_PATH=$TRACKER_SRC_DIR/vol:$TRACKER_SRC_DIR/vfd:$HDF5_PLUGIN_PATH
    export HDF5_DRIVER=hdf5_tracker_vfd
    export HDF5_DRIVER_CONFIG="true ${TRACKER_VFD_PAGE_SIZE}"
    export HDF5_LOG_FILE_PATH="$schema_file_path"

    python vlen_h5_write_read.py $IO_FILE
    # python vlen_h5_read2.py $IO_FILE

}

# get execution time in ms
start_time=$(date +%s%3N)
# SIMPLE_VFD_IO 2>&1 | tee VFD_run.log
# SIMPLE_VOL_IO 2>&1 | tee VOL_run.log
SIMPLE_VFD_VOL_IO 2>&1 | tee DL_run.log
end_time=$(date +%s%3N)
echo "Execution time: $((end_time-start_time)) ms"