import h5py
import numpy as np
import os
import sys
import time
import subprocess

def set_curr_task(task):
    
    workflow_name = os.environ.get("WORKFLOW_NAME")
    path_for_task_files = os.environ.get("PATH_FOR_TASK_FILES")
    vfd_task_file = None
    vol_task_file = None
    
    if workflow_name and path_for_task_files:
        vfd_task_file = os.path.join(path_for_task_files, f"{workflow_name}_vfd.curr_task")
        vol_task_file = os.path.join(path_for_task_files, f"{workflow_name}_vol.curr_task")

    # vfd_task_file = /tmp/$USER/pyflextrkr_vfd.curr_task
    
    if vfd_task_file and os.path.exists(vfd_task_file):
        if os.path.isfile(vfd_task_file):
            command = f"echo -n {task} > {vfd_task_file}"
            subprocess.run(command, shell=True)


    if vol_task_file and os.path.exists(vol_task_file):
        if os.path.isfile(vol_task_file):
            command = f"echo -n {task} > {vol_task_file}"
            subprocess.run(command, shell=True)

    else:
        print("Invalid or missing PATH_FOR_TASK_FILES environment variable.")    


def set_curr_task_env(task):
    os.environ['CURR_TASK'] = task
    command = "echo running task [$CURR_TASK]"
    command2 = "export CURR_TASK=$CURR_TASK"
    subprocess.run(command, shell=True)
    subprocess.run(command2, shell=True)

def check_equals(datasets_1, datasets_2):
    print("Checking if datasets are equal")
    for i in range(len(datasets_1)):
        if not np.array_equal(datasets_1[i], datasets_2[i]):
            print(f"Dataset {i}: Not Equal")
        else:
            print(f"Dataset {i}: Equal")

def run_write(file_name, datasets):
    task_name = "h5_write"
    print(f"Running Task : {task_name}")
    set_curr_task(task_name)

    hf = h5py.File(file_name, mode='w')
    # Create a group for each dataset
    group = hf.create_group('data')
    
    # iterate except the last one
    for i, data in enumerate(datasets[:-1]):
        print(f"datatype is {data[0].dtype}")
        # Create a dataset for variable-length data
        vlen_dtype = h5py.vlen_dtype(data[0].dtype)
        ds = group.create_dataset(f'dataset{i}', (len(data),), dtype=vlen_dtype)
        
        # Populate the dataset with variable-length data
        ds[:] = data
    
    # Write dataset with fixed length
    ds = group.create_dataset(f'dataset{len(datasets)-1}', data=datasets[-1])
    
    # flush hf
    hf.close()

def run_read(file_name):
    task_name = "h5_read"
    print(f"Running Task: {task_name}")
    set_curr_task(task_name)

    hf = h5py.File(file_name, 'r')
    group = hf['data']
    datasets = []
    for key in group.keys():
        ds = group[key]

        # Check if the dataset contains variable-length sequences
        if ds.dtype.kind == 'O' and ds.shape[1:] == ():
            # If yes, convert to a list of NumPy arrays
            data = [np.array(item, dtype=np.float32) for item in ds[:]]
        else:
            # Otherwise, convert the whole dataset to a NumPy array
            data = np.array(ds[:], dtype=np.float32)
        
        datasets.append(data)

        print(f"Read dataset {key} with datatype {ds.dtype}")
    
    hf.close()    
    return datasets


def write_read_separate(file_name):
    dtype = np.float32
    # Create some sample data
    d1 = [np.random.randn(10000).astype(dtype)]
    d2 = [np.random.randn(100000).astype(dtype)]
    d3 = [np.random.randn(1000000).astype(dtype)]
    d4 = np.random.randn(3000, 1000).astype(dtype)

    # check all shapes
    print(f"d1 shape {d1[0].shape}")
    print(f"d2 shape {d2[0].shape}")
    print(f"d3 shape {d3[0].shape}")

    write_datasets = [d1, d2, d3, d4]

    run_write(file_name, write_datasets)
    read_datasets = run_read(file_name)
    # read_datasets = run_read(file_name, len(write_datasets))
    

    if read_datasets:
        check_equals(write_datasets, read_datasets)

if __name__ == "__main__":
    # get user argument with file name
    if len(sys.argv) < 2:
        print("Please provide a file name.")
        sys.exit(1)

    file_name = sys.argv[1]
    
    print(f"Running test for file {file_name}")
    write_read_separate(file_name)


