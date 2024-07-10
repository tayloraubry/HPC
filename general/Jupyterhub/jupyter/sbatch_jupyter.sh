#!/bin/bash  --login

## Modify walltime and account at minimum
#SBATCH --time=<time_request>
#SBATCH --account=<project_handle>

#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=104

module purge
module load conda
source activate /home/$USER/.conda-envs/<MY_ENVIRONMENT>  # insert your conda environment

port=7878

echo "run the following command on your machine"
echo ""
echo "ssh -L $port:$HOSTNAME:$port $SLURM_SUBMIT_HOST.hpc.nrel.gov"

jupyter lab --no-browser --ip=0.0.0.0 --port=$port
