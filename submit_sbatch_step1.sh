#!/bin/bash


# Originally written by Nathan Muncy on 11/20/17.
# Butchered by Ben Carter, 2019-04-09.

# This script will check for the necessary directory structure and kill itself when things go awry or submit 1 job per participant.

#####################
# --- VARIABLES --- #
#####################

START_DIR=${pwd} 										# in case you want an easy reference to return to the directory you started in.
STUDY=~/compute/skilledReadingStudy					    # location of study directory
TEMPLATE_DIR=${STUDY}/template 							# destination for template output
DICOM_DIR=${STUDY}/dicomdir 						    # location of raw dicoms
SCRIPT_DIR=~/analyses/structuralSkilledReading			# location of scripts that might be referenced; assumed to be separate from the data directory.
LIST=${SCRIPT_DIR}/participants.tsv 					# list of participant IDs
LOG=~/logfiles											# where to put documentation about errors and outputs
TIME=`date '+%Y_%m_%d-%H_%M_%S'`						# time stamp for e's and o's


# Ensure conditions are right for this to run
# create a directory for the template
if [ ! -d ${TEMPLATE_DIR} ]; then
	mkdir -p ${TEMPLATE_DIR}
fi

# make sure the dicom directory exists
if [ ! -d ${DICOM_DIR} ]; then
	echo ${DICOM_DIR} does not exist, check your variable DICOM_DIR.
	exit 1
fi

# check for participant list
if [ ! -f ${LIST} ]; then
	echo ${LIST} does not exist, check your variable LIST
	exit 1
fi


for i in $(cat $LIST); do

	OUT=${LOG}/TEMPLATE_STEP1_${TIME}
	
    sbatch \
    -o ${OUT}/output_step1_${i}.txt \
    -e ${OUT}/error_step1_${i}.txt \
    sbatch_step1.sh ${i}

    sleep 1

done
