#!/bin/bash


# Originally written by Nathan Muncy on 11/20/17.
# Butchered by Ben Carter, 2019-04-09.


#SBATCH --time=10:00:00   # walltime
#SBATCH --ntasks=2   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem-per-cpu=32gb   # memory per CPU core
#SBATCH -J "Struc"   # job name

# Compatibility variables for PBS. Delete if not needed.
export PBS_NODEFILE=`/fslapps/fslutils/generate_pbs_nodefile`
export PBS_JOBID=$SLURM_JOB_ID
export PBS_O_TEMPLATE_DIR="$SLURM_SUBMIT_DIR"
export PBS_QUEUE=batch

# Set the max number of threads to use for programs using OpenMP. Should be <= ppn. Does nothing if the program doesn't use OpenMP.
export OMP_NUM_THREADS=$SLURM_CPUS_ON_NODE

#######################
# --- ENVIRONMENT --- #
#######################

START_DIR=${pwd} 											# in case you want an easy reference to return to the directory you started in.
STUDY=~/compute/skilledReadingStudy					    	# location of study directory
TEMPLATE_DIR=${STUDY}/template 								# destination for template output
DICOM_DIR=${STUDY}/dicomdir/${1}/t1_*						# location of raw dicoms for participant
SCRIPT_DIR=~/analyses/structuralSkilledReading				# location of scripts that might be referenced; assumed to be separate from the data directory.
PARTICIPANT_STRUCT=${STUDY}/structural/${1}					# location of derived participant structural data
D2N=~/apps/dcm2niix/bin/dcm2niix							# path to dcm2niix
ACPC=~/apps/art/acpcdetect									# path to acpcdetect
N4BC=~/apps/ants/bin/N4BiasFieldCorrection					# path to N4BiasFieldCorrection

####################
# --- COMMANDS --- #
####################
# ------------------
# OPERATIONS: these are performed once per participant as submitted.
# 1. NIFTIs are created from the native DICOMS
# 2. NIFTIs are ACPC aligned
# 3. N4Bias corrections are performed.
# ------------------

# 1. Create NIFTI files from the DICOMs
# check for the dicoms
if [ ! -d ${DICOM_DIR} && ! -f ${DICOM_DIR}/*.dcm ]; then
	echo "I did not find anything to process."
	exit 1
fi

# make a place to put the NIFTI files
if [ ! -d ${PARTICIPANT_STRUCT} ]; then
	mkdir -p ${PARTICIPANT_STRUCT}	
fi

# make NIFTI files
if [ ! -f ${PARTICIPANT_STRUCT}/struct_orig.nii.gz ]; then
	cd ${PARTICIPANT_STRUCT}
	${D2N} \
	-a y \
	-g n \
	-x y \
	${DICOM_DIR}/*.dcm
	#mv co*.nii ${PARTICIPANT_STRUCT}/struct_orig.nii
fi

# 2. Perform ACPC alignment
if [ ! -f ${PARTICIPANT_STRUCT}/struct_acpc.nii.gz ]; then
	${ACPC} \
	-M \
	-o ${PARTICIPANT_STRUCT}/struct_acpc.nii.gz \
	-i ${PARTICIPANT_STRUCT}/struct_orig.nii
fi


# 3. Perform N4-Bias Correction
DIM=3
ACPC=${PARTICIPANT_STRUCT}/struct_acpc.nii.gz
N4=${PARTICIPANT_STRUCT}/struct_n4bc.nii.gz

CON=[50x50x50x50,0.0000001]
SHRINK=4
BSPLINE=[200]

if [ ! -f $N4 ]; then

	${N4BC} \
	-d $DIM \
	-i $ACPC \
	-s $SHRINK \
	-c $CON \
	-b $BSPLINE \
	-o $N4

fi

cd ${START_DIR}

done
