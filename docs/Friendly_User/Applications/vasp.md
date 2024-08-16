## VASP on Kestrel

### Running using modules

#### GPU

!!! tip "Important"
	Until we have gpu log in nodes, it is necessary to source /nopt/nrel/apps/gpu_stack/env_cpe23.sh to access gpu modules on Kestrel. 

??? example "Sample job script: Kestrel - Full GPU node"

    ```
    #!/bin/bash
    #SBATCH --account=<your-account-name> 
    #SBATCH --reservation=<friendly-users-reservation>
    #SBATCH --partition=gpu-h100
    #SBATCH --nodes=1
    #SBATCH --gres=gpu:h100:4 
    #SBATCH --ntasks-per-node=4
    #SBATCH --cpus-per-task=1
    #SBATCH --time=02:00:00
    #SBATCH --job-name=<your-job-name>

    export MPICH_GPU_SUPPORT_ENABLED=1
    export CUDA_VISIBLE_DEVICES=0,1,2,3
    
    source /nopt/nrel/apps/gpu_stack/env_cpe23.sh
    module load vasp/6.3.2

    srun vasp_std |& tee out

    ```

??? example "Sample job script: Kestrel - Shared (partial) GPU node"
    GPU nodes can be shared so you may request fewer than all 4 GPUs on a node. When doing so, you must also request appropriate CPU cores and memory. To run VASP on N GPUs, we recommend requesting --ntasks-per-node=N and --mem=N*90G. See the below sample script for running on 2 GPUs. 

    ```
    #!/bin/bash
    #SBATCH --account=<your-account-name> 
    #SBATCH --reservation=<friendly-users-reservation>
    #SBATCH --partition=gpu-h100
    #SBATCH --nodes=1
    #SBATCH --gres=gpu:h100:2 
    #SBATCH --mem=180G
    #SBATCH --ntasks-per-node=2
    #SBATCH --cpus-per-task=1
    #SBATCH --time=02:00:00
    #SBATCH --job-name=<your-job-name>

    export MPICH_GPU_SUPPORT_ENABLED=1
    export CUDA_VISIBLE_DEVICES=0,1

    source /nopt/nrel/apps/gpu_stack/env_cpe23.sh
    module load vasp/6.3.2

    srun vasp_std |& tee out
    ```

### Building VASP on Kestrel

Sample makefiles for vasp5 (cpu version) and vasp6 (cpu and gpu versions) on Kestrel can be found in our [Kestrel Repo](https://github.com/NREL/HPC/tree/master/kestrel) under the vasp folder.

#### GPU

##### Compiling your build

??? example "Build recommendations for VASP"

    ```
    #Make sure to salloc to a gpu node
    salloc -N 1 --time=01:00:00 --account=hpcapps --reservation=<friendly-users-reservation> --gres=gpu:h100:4 --partition=gpu-h100

    # Load appropriate modules for your build. For our example these are:
    module restore
    source /nopt/nrel/apps/gpu_stack/env_cpe23.sh
    ml gcc
    ml PrgEnv-nvhpc
    ml cray-libsci/23.05.1.4
    ml craype-x86-genoa

    make DEPS=1 -j8 all
    ```

##### Running your build

??? example "Sample job script: How to run your own build"

    See sample jobs scripts above for sbatch and export directives to request full or shared gpu nodes.

    ```
    # Load modules appropriate for your build. For ours these are:
    module restore
    source /nopt/nrel/apps/gpu_stack/env_cpe23.sh
    ml gcc
    ml PrgEnv-nvhpc
    ml cray-libsci/23.05.1.4
    ml craype-x86-genoa

    # Export path to your buid
    export VASP_PATH=/PATH/TO/YOUR/BUILD/bin

    srun ${VASP_PATH}/vasp_std |& tee out
    ```

