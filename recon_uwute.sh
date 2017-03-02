#! /bin/bash
if [ $# -ne 1 ]
then
    echo "Not enough arguments supplied"
    echo "Usage: recon.sh input"
    exit 113
fi

in=$1

export DEBUG_LEVEL=5
set -x

time bart pics -p $in"_sg_dcf" -i 30 -r 0.005 -l1 -s 0.00000001 -t $in"_traj" $in"_data" $in"_maps" $in"_sg_rec"

