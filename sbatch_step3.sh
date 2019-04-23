#!/bin/bash

#SBATCH --time=72:00:00   # walltime
#SBATCH --ntasks=6   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem-per-cpu=32gb   # memory per CPU core
#SBATCH -J "step3"   # job name
#SBATCH --mail-user=ben88@byu.edu  # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

# Compatibility variables for PBS. Delete if not needed.
export PBS_NODEFILE=`/fslapps/fslutils/generate_pbs_nodefile`
export PBS_JOBID=$SLURM_JOB_ID
export PBS_O_TEMPLATE_DIR="$SLURM_SUBMIT_DIR"
export PBS_QUEUE=batch

# Set the max number of threads to use for programs using OpenMP. Should be <= ppn. Does nothing if the program doesn't use OpenMP.
export OMP_NUM_THREADS=$SLURM_CPUS_ON_NODE

# Originally written by Nathan Muncy on 11/20/17.
# Butchered by Ben Carter, 2019-04-09.

#######################
# --- ENVIRONMENT --- #
#######################

START_DIR=${pwd} 											# in case you want an easy reference to return to the directory you started in.
STUDY=~/compute/skilledReadingStudy					    	# location of study directory
TEMPLATE_DIR=${STUDY}/template 								# destination for template output
CONSTRUCT_DIR=${TEMPLATE_DIR}/construct						# directory for template construction
SCRIPT_DIR=~/analyses/structuralSkilledReading			# location of scripts that might be referenced; assumed to be separate from the data directory.
LIST=${SCRIPT_DIR}/participants.tsv 					# list of participant IDs
PARTICIPANT_STRUCT=${STUDY}/structural					# location of derived participant structural data
ATLAS=~/templates/adult/MNI152c/mni_icbm152_nlin_sym_09c/mni_icbm152_t1_tal_nlin_sym_09c.nii	# location of the MNI ICBM 2009c Nonlinear Symmetric atlas NIFTI files


####################
# --- COMMANDS --- #
####################
# ------------------
# OPERATIONS: these are performed once per participant as submitted.
# 1. Participant MNI aligned images are copied into a single directory.
# 2. An MNI aligned study template is created using the MNI ICBM 2009c Nonlinear Symmetric atlas (or other input atlas if you so prefer).
#
# REQUIRES: things needed to run this script
# 1. MNI ICBM 2009c Nonlinear Symmetric atlas NIFTI files. Can be downloaded via command 'wget
#	 http://www.bic.mni.mcgill.ca/~vfonov/icbm/2009/mni_icbm152_nlin_sym_09c_nifti.zip'.
# ------------------

# 1. Copy participant aligned images

if [ ! -d ${CONSTRUCT_DIR} ]; then
	mkdir -p ${CONSTRUCT_DIR}
fi


for i in $(cat ${LIST}); do
    if [ ! -f ${CONSTRUCT_DIR}/${i}_T1w_mni.nii.gz ]; then
        cp ${PARTICIPANT_STRUCT}/${i}/${i}_T1w_mni.nii.gz ${CONSTRUCT_DIR}/${i}_T1w_mni.nii.gz
    fi
done

# 2. Build a study template
cd ${CONSTRUCT_DIR}

DIM=3
ITER=30x90x30
TRANS=GR
SIM=CC
CON=2
PROC=6

buildtemplateparallel.sh \
-d $DIM \
-m $ITER \
-t $TRANS \
-s $SIM \
-c $CON \
-j $PROC \
-o dyce_mni_ \
-z ${ATLAS} \
*mni.nii.gz
