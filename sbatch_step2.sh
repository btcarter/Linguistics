#!/bin/bash


# Originally written by Nathan Muncy on 11/20/17
# Butchered by Ben Carter, 2019-04-09.

#SBATCH --time=10:00:00   # walltime
#SBATCH --ntasks=2   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem-per-cpu=32gb   # memory per CPU core
#SBATCH -J "mniV2ants"   # job name

# Compatibility variables for PBS. Delete if not needed.
export PBS_NODEFILE=`/fslapps/fslutils/generate_pbs_nodefile`
export PBS_JOBID=$SLURM_JOB_ID
export PBS_O_WORKDIR="$SLURM_SUBMIT_DIR"
export PBS_QUEUE=batch

# Set the max number of threads to use for programs using OpenMP. Should be <= ppn. Does nothing if the program doesn't use OpenMP.
export OMP_NUM_THREADS=$SLURM_CPUS_ON_NODE

#######################
# --- ENVIRONMENT --- #
#######################

START_DIR=${pwd} 											# in case you want an easy reference to return to the directory you started in.
STUDY=~/compute/skilledReadingStudy					    	# location of study directory
TEMPLATE_DIR=${STUDY}/template 								# destination for template output
SCRIPT_DIR=~/analyses/structuralSkilledReading				# location of scripts that might be referenced; assumed to be separate from the data directory.
PARTICIPANT_STRUCT=${STUDY}/structural/${1}					# location of derived participant structural data
ATLAS=~/templates/adult/MNI152c/mni_icbm152_nlin_sym_09c	# location of the MNI ICBM 2009c Nonlinear Symmetric atlas NIFTI files

####################
# --- COMMANDS --- #
####################
# ------------------
# OPERATIONS: these are performed once per participant as submitted.
# 1. N4BC NIFTIs are subjected to an ANTs based affine registration.
# 2. Registration used to move participant T1 into MNI space completed via WarpImageMultiTransform.
#
# REQUIRES: things needed to run this script
# 1. MNI ICBM 2009c Nonlinear Symmetric atlas NIFTI files. Can be downloaded via command 'wget
#	 http://www.bic.mni.mcgill.ca/~vfonov/icbm/2009/mni_icbm152_nlin_sym_09c_nifti.zip'.
# ------------------

# 1. Affine transformation
MOV=${PARTICIPANT_STRUCT}/${1}_T1w_n4bc.nii.gz
OUT=${PARTICIPANT_STRUCT}/${1}_T1w_ants_

ITS=100x100x100x20
DIM=3
LMWT=0.9
INTWT=4
PCT=0.8
PARZ=100
INTENSITY=CC[${ATLAS},${MOV},${INTWT},4]

if [ ! -f ${OUT}Affine.txt ]; then

    ${ANTSPATH}/ANTS \
    $DIM \
    -o $OUT \
    -i $ITS \
    -t SyN[0.1] \
    -r Gauss[3,0.5] \
    -m $INTENSITY

fi


# 2. WarpImageMultiTransform
if [ ! -f ${PARTICIPANT_STRUCT}/${1}_T1w_mni.nii.gz ]; then

    WarpImageMultiTransform $DIM $MOV ${PARTICIPANT_STRUCT}/${1}_T1w_mni.nii.gz ${OUT}Warp.nii.gz ${OUT}Affine.txt -R ${ATLAS}

fi
