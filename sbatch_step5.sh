#!/bin/bash


# Written by Nathan Muncy on 11/20/17
# Butchered by Ben Carter, 2019-04-09.

#SBATCH --time=36:00:00   # walltime
#SBATCH --ntasks=1   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem-per-cpu=32gb   # memory per CPU core
#SBATCH -J "step5"   # job name
#SBATCH --mail-user=ben88@byu.edu  # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

#######################
# --- ENVIRONMENT --- #
#######################

WORK_DIR=~/compute/skilledReadingStudy/template/construct
C3D=~/apps/c3d/bin

jlfList=(1002 1003 1005 1006 1007 1008 1009 1010 1011 1012 1013 1014 1015 1016 1017 1018 1019 1020 1021 1022 1023 1024 1025 1026 1027 1028 1029 1030 1031 1034 1035 2002 2003 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024 2025 2026 2027 2028 2029 2030 2031 2034 2035 6 10 11 12 13 16 17 18 26 28 91 45 49 50 51 52 53 54 58 60 92 630 631 632)
roiLen=${#jlfList[@]}

####################
# --- COMMANDS --- #
####################
# ------------------
# OPERATIONS: these are performed once per participant as submitted.
# 1. Creates a grey matter mask using JLF list
#
# REQUIRES: things needed to run this script
# 1. Output from the first four steps
# ------------------


cd $WORK_DIR

c=0; while [ $c -lt $roiLen ]; do

    ${C3D}/c3d JLF_Labels.nii.gz -thresh ${jlfList[$c]} ${jlfList[$c]} ${jlfList[$c]} 0 -o label_${jlfList[$c]}.nii.gz
    let c=$[$c+1]
done

${C3D}/c3d label*.nii.gz -accum -add -endaccum -o gm_mask_raw.nii.gz
${C3D}/c3d gm_mask_raw.nii.gz -thresh 1 inf 1 0 -o dyce_mni_GM.nii.gz
