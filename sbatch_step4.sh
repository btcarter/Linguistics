#!/bin/bash


# Written by Nathan Muncy on 11/20/17
# Butchered by Ben Carter, 2019-04-09.


#SBATCH --time=50:00:00   # walltime
#SBATCH --ntasks=6   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem-per-cpu=16gb   # memory per CPU core
#SBATCH -J "step4Temp"   # job name

# Compatibility variables for PBS. Delete if not needed.
export PBS_NODEFILE=`/fslapps/fslutils/generate_pbs_nodefile`
export PBS_JOBID=$SLURM_JOB_ID
export PBS_O_WORK_DIR="$SLURM_SUBMIT_DIR"
export PBS_QUEUE=batch

# Set the max number of threads to use for programs using OpenMP. Should be <= ppn. Does nothing if the program doesn't use OpenMP.
export OMP_NUM_THREADS=$SLURM_CPUS_ON_NODE


#######################
# --- ENVIRONMENT --- #
#######################

WORK_DIR=/fslhome/nmuncy/compute/Ben_template/construct
OASIS_DIR=~/templates/adult/OASIS-TRT-20_volumes

####################
# --- COMMANDS --- #
####################
# ------------------
# OPERATIONS: these are performed once per participant as submitted.
# 1. Performs model segmentation and labeling via antsJointLabelFusion_fixed.sh
#
# REQUIRES: things needed to run this script
# 1. OASIS 20 atlas and labels (OASIS-TRT-20_volumes.tar.gz found at https://osf.io/tyvhs/) from the Mindboggle Project (https://osf.io/nhtur/).
# ------------------


cd $WORK_DIR

dim=3
out=${WORK_DIR}/JLF_
subj=${WORK_DIR}/dyce_mni_template.nii.gz
atlas=${OASIS_DIR}
labels=${OASIS_DIR}
parallel=5
cores=6
post=${WORK_DIR}/priors_JLF/label_%04d.nii.gz


antsJointLabelFusion.sh \
-d ${dim} \
-t ${subj} \
-o ${out} \
-p ${post} \
-c ${parallel} \
-j ${cores} \
-q 0 \
-u 50:00:00 \
-v 16gb \
-w 50:00:00 \
-z 16gb \
-g ${atlas}/OASIS-TRT-20-1/t1weighted.nii.gz -l ${labels}/OASIS-TRT-20-1/labels.DKT31.manual.nii.gz \
-g ${atlas}/OASIS-TRT-20-2/t1weighted.nii.gz -l ${labels}/OASIS-TRT-20-2/labels.DKT31.manual.nii.gz \
-g ${atlas}/OASIS-TRT-20-3/t1weighted.nii.gz -l ${labels}/OASIS-TRT-20-3/labels.DKT31.manual.nii.gz \
-g ${atlas}/OASIS-TRT-20-4/t1weighted.nii.gz -l ${labels}/OASIS-TRT-20-4/labels.DKT31.manual.nii.gz \
-g ${atlas}/OASIS-TRT-20-5/t1weighted.nii.gz -l ${labels}/OASIS-TRT-20-5/labels.DKT31.manual.nii.gz \
-g ${atlas}/OASIS-TRT-20-6/t1weighted.nii.gz -l ${labels}/OASIS-TRT-20-6/labels.DKT31.manual.nii.gz \
-g ${atlas}/OASIS-TRT-20-7/t1weighted.nii.gz -l ${labels}/OASIS-TRT-20-7/labels.DKT31.manual.nii.gz \
-g ${atlas}/OASIS-TRT-20-8/t1weighted.nii.gz -l ${labels}/OASIS-TRT-20-8/labels.DKT31.manual.nii.gz \
-g ${atlas}/OASIS-TRT-20-9/t1weighted.nii.gz -l ${labels}/OASIS-TRT-20-9/labels.DKT31.manual.nii.gz \
-g ${atlas}/OASIS-TRT-20-10/t1weighted.nii.gz -l ${labels}/OASIS-TRT-20-10/labels.DKT31.manual.nii.gz \
-g ${atlas}/OASIS-TRT-20-11/t1weighted.nii.gz -l ${labels}/OASIS-TRT-20-11/labels.DKT31.manual.nii.gz \
-g ${atlas}/OASIS-TRT-20-12/t1weighted.nii.gz -l ${labels}/OASIS-TRT-20-12/labels.DKT31.manual.nii.gz \
-g ${atlas}/OASIS-TRT-20-13/t1weighted.nii.gz -l ${labels}/OASIS-TRT-20-13/labels.DKT31.manual.nii.gz \
-g ${atlas}/OASIS-TRT-20-14/t1weighted.nii.gz -l ${labels}/OASIS-TRT-20-14/labels.DKT31.manual.nii.gz \
-g ${atlas}/OASIS-TRT-20-15/t1weighted.nii.gz -l ${labels}/OASIS-TRT-20-15/labels.DKT31.manual.nii.gz \
-g ${atlas}/OASIS-TRT-20-16/t1weighted.nii.gz -l ${labels}/OASIS-TRT-20-16/labels.DKT31.manual.nii.gz \
-g ${atlas}/OASIS-TRT-20-17/t1weighted.nii.gz -l ${labels}/OASIS-TRT-20-17/labels.DKT31.manual.nii.gz \
-g ${atlas}/OASIS-TRT-20-18/t1weighted.nii.gz -l ${labels}/OASIS-TRT-20-18/labels.DKT31.manual.nii.gz \
-g ${atlas}/OASIS-TRT-20-19/t1weighted.nii.gz -l ${labels}/OASIS-TRT-20-19/labels.DKT31.manual.nii.gz \
-g ${atlas}/OASIS-TRT-20-20/t1weighted.nii.gz -l ${labels}/OASIS-TRT-20-20/labels.DKT31.manual.nii.gz
