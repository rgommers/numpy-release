set -xe

WHEEL="$1"
DEST_DIR="$2"

cwd=$PWD
cd $DEST_DIR

# The libopenblas_scipy DLL and the other DLLs it may need are placed into this
# directory in `cibw_before_build.sh`.
delvewheel repair --add-path $cwd/.openblas/lib -w $DEST_DIR $WHEEL
