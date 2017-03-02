#! /bin/bash
if [ $# -ne 1 ]
then
    echo "Usage: h5_convert.sh input"
    echo "Example: h5_convert.sh UWUTE_003"
    exit 113
fi

in=$1
matlab -nodesktop -nosplash -nodisplay -r "h5_convert('"$in"','"$in"');quit;"
