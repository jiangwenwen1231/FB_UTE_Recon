#! /bin/bash
if [ $# -ne 3 ]
then
    echo "Usage: convert.sh input do_soft hard_Nbins"
    echo "Example: convert.sh UWUTE_case1 1 0"
    exit 113
fi

in=$1
do_soft=$2
hard_Nbins=$3


matlab -nodesktop -nosplash -r "uwute_convert('"$in"','"$in"',"$do_soft","$hard_Nbins");quit;"
