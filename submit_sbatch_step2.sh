#!/bin/bash


# Originally written by Nathan Muncy on 11/20/17.
# Butchered by Ben Carter, 2019-04-09.

# This script will check for the necessary directory structure and kill itself when things go awry or submit 1 job per participant.

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

# submit the job script once per participant
for i in $(cat $LIST); do
	
    sbatch \
    -o ${OUT}/output_step2_${i}.txt \
    -e ${OUT}/error_step2_${i}.txt \
    ${SCRIPT_DIR}/sbatch_step2.sh ${i}

    sleep 1

done
