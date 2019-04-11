#!/bin/bash

#SBATCH --time=10:00:00   # walltime
#SBATCH --ntasks=1   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem-per-cpu=32gb   # memory per CPU core
#SBATCH -J "template"   # job name
#SBATCH --mail-user=ben88@byu.edu  # email address
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

# Compatibility variables for PBS. Delete if not needed.
export PBS_NODEFILE=`/fslapps/fslutils/generate_pbs_nodefile`
export PBS_JOBID=$SLURM_JOB_ID
export PBS_O_TEMPLATE_DIR="$SLURM_SUBMIT_DIR"
export PBS_QUEUE=batch

# Set the max number of threads to use for programs using OpenMP. Should be <= ppn. Does nothing if the program doesn't use OpenMP.
export OMP_NUM_THREADS=$SLURM_CPUS_ON_NODE

# Written by Ben Carter, 2019-04-11.

#####################
# --- VARIABLES --- #
#####################

STUDY=~/compute/skilledReadingStudy					    # location of study directory
TEMPLATE_DIR=${STUDY}/template 							# destination for template output
SCRIPT_DIR=~/analyses/structuralSkilledReading			# location of scripts that might be referenced; assumed to be separate from the data directory.
LIST=${SCRIPT_DIR}/participants.tsv 					# list of participant IDs
LOG=~/logfiles											# where to put documentation about errors and outputs
TIME=`date '+%Y_%m_%d-%H_%M_%S'`						# time stamp for e's and o's

# check for participant list
if [ ! -f ${LIST} ]; then
	echo ${LIST} does not exist, check your variable LIST
	exit 1
fi

# check for logfiles destination
OUT=${LOG}/TEMPLATE_STEP2_${TIME}
if [ ! -d ${OUT} ]; then
	mkdir -p ${OUT}
fi

# submit the job script once
sbatch \
-o ${OUT}/output_step3.txt \
-e ${OUT}/error_step3.txt \
${SCRIPT_DIR}/sbatch_step3.sh

sleep 1