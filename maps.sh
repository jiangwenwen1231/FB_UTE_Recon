#! /bin/bash
if [ $# -ne 1 ]
then
    echo "Not enough arguments supplied"
    echo "Usage: maps.sh input"
    exit 113
fi

in=$1

export DEBUG_LEVEL = 5
set -x

c=24

dims=(`estdims $in"_traj"`)
bart fmac $in"_data" $in"_sg_dcf" $in"_dcfdata"

# Iterative gridding on center
# nufft -i -t -d $c:$c:$c $in"_traj" $in"_data" $in"_calib"

bart nufft -a -d  $c:$c:$c $in"_traj" $in"_dcfdata" $in"_calib"

bart fft 7 $in"_calib" $in"_kcalib"

bart resize -c 0 ${dims[0]} 1 ${dims[1]} 2 ${dims[2]} $in"_kcalib" $in"_kcalib_zpad"

# ecalib
time bart ecalib -S -c 0.6 -m 1 -r $c $in"_kcalib_zpad" $in"_maps"

rm $in"_calib".*
rm $in"_kcalib".*
rm $in"_kcalib_zpad".*
rm $in"_dcfdata".*
