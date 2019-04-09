#!/bin/bash


# Originally written by Nathan Muncy on 11/20/17.
# Then butchered by Ben Carter, 2019-04-09.


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

START_DIR=${pwd} 										# in case you want an easy reference to return to the directory you started in.
STUDY=~/compute/skilledReading							# location of study directory
TEMPLATE_DIR=${STUDY}/template 							# destination for template output
DICOM_DIR=${STUDY}/data/dicomdir 						# location of raw dicoms
SCRIPT_DIR=${STUDY}/analyses/structuralSkilledReading 	# location of scripts that might be referenced
LIST=${SCRIPT_DIR}/participants.tsv 					# list of participant IDs

####################
# --- COMMANDS --- #
####################

# Create NIFTI files from the DICOMs
cd $DICOM_DIR

for i in $(ls $LIST); do

    T1_DIR=${DICOM_DIR}/$i
    PARTICIPANT_DIR=${TEMPLATE_DIR}/"${i/t1_Luke_Reading_}"

    if [ ! -d $PARTICIPANT_DIR ]; then
        mkdir $PARTICIPANT_DIR
    fi


    # construct
    if [ ! -f ${PARTICIPANT_DIR}/struct_orig.nii.gz ]; then

        cd $T1_DIR
        dcm2nii -a y -g n -x y *.dcm
        mv co*.nii ${PARTICIPANT_DIR}/struct_orig.nii
        rm *.nii

    fi


    cd $PARTICIPANT_DIR

    # acpc align
    if [ ! -f struct_acpc.nii.gz ]; then
        acpcdetect -M -o struct_acpc.nii.gz -i struct_orig.nii
    fi


    # n4bc
    dim=3
    input=struct_acpc.nii.gz
    n4=struct_n4bc.nii.gz

    con=[50x50x50x50,0.0000001]
    shrink=4
    bspline=[200]

    if [ ! -f $n4 ]; then

        N4BiasFieldCorrection \
        -d $dim \
        -i $input \
        -s $shrink \
        -c $con \
        -b $bspline \
        -o $n4

    fi

cd $DICOM_DIR
done
