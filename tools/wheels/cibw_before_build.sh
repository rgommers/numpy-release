set -xe

PROJECT_DIR="${1:-$PWD}"
NUMPY_SRC_DIR="${1:-$PWD}/numpy-src"


# Update license
echo "" >> $NUMPY_SRC_DIR/LICENSE.txt
echo "----" >> $NUMPY_SRC_DIR/LICENSE.txt
echo "" >> $NUMPY_SRC_DIR/LICENSE.txt
cat $NUMPY_SRC_DIR/LICENSES_bundled.txt >> $NUMPY_SRC_DIR/LICENSE.txt
if [[ $RUNNER_OS == "Linux" ]] ; then
    cat $PROJECT_DIR/tools/wheels/LICENSE_linux.txt >> $NUMPY_SRC_DIR/LICENSE.txt
elif [[ $RUNNER_OS == "macOS" ]]; then
    cat $PROJECT_DIR/tools/wheels/LICENSE_osx.txt >> $NUMPY_SRC_DIR/LICENSE.txt
elif [[ $RUNNER_OS == "Windows" ]]; then
    cat $PROJECT_DIR/tools/wheels/LICENSE_win32.txt >> $NUMPY_SRC_DIR/LICENSE.txt
fi

if [[ $(python -c"import sys; print(sys.maxsize)") < $(python -c"import sys; print(2**33)") ]]; then
    echo "No BLAS used for 32-bit wheels"
    export INSTALL_OPENBLAS=false
elif [ -z $INSTALL_OPENBLAS ]; then
    # the macos_arm64 build might not set this variable
    export INSTALL_OPENBLAS=true
fi

# Install OpenBLAS from scipy-openblas64
if [[ "$INSTALL_OPENBLAS" = "true" ]] ; then
    # By default, use scipy-openblas64
    # On 32-bit platforms and on win-arm64, use scipy-openblas32
    OPENBLAS=openblas64
    # Possible values for RUNNER_ARCH in GitHub Actions are: X86, X64, ARM, or ARM64
    if [[ $RUNNER_ARCH == "X86" || $RUNNER_ARCH == "ARM" ]] ; then
        OPENBLAS=openblas32
    elif [[ $RUNNER_ARCH == "ARM64" && $RUNNER_OS == "Windows" ]] ; then
        OPENBLAS=openblas32
    fi
    PKG_CONFIG_PATH=$PROJECT_DIR/.openblas
    echo PKG_CONFIG_PATH is $PKG_CONFIG_PATH, OPENBLAS is ${OPENBLAS}
    rm -rf $PKG_CONFIG_PATH
    mkdir -p $PKG_CONFIG_PATH
    python -m pip install -r $PROJECT_DIR/requirements/openblas_requirements.txt
    python -c "import scipy_${OPENBLAS}; print(scipy_${OPENBLAS}.get_pkg_config())" > $PKG_CONFIG_PATH/scipy-openblas.pc
fi

# cibuildwheel doesn't install delvewheel by default (it does install
# auditwheel on Linux and delocate on macOS)
if [[ $RUNNER_OS == "Windows" ]]; then
    python -m pip install delvewheel
fi
