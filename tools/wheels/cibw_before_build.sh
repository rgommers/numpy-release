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

# Install OpenBLAS from scipy-openblas32|64
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

    # The PKG_CONFIG_PATH environment variable will be pointed to this path in
    # cibuildwheel.toml and .github/workflows/wheels.yml. Note that
    # `pkgconf_path` here is only a bash variable local to this file.
    pkgconf_path=$PROJECT_DIR/.openblas
    echo pkgconf_path is $pkgconf_path, OPENBLAS is ${OPENBLAS}
    rm -rf $pkgconf_path
    mkdir -p $pkgconf_path
    python -m pip install -r $PROJECT_DIR/requirements/openblas_requirements.txt
    python -c "import scipy_${OPENBLAS}; print(scipy_${OPENBLAS}.get_pkg_config())" > $pkgconf_path/scipy-openblas.pc

    # Copy scipy-openblas DLL's to a fixed location so we can point delvewheel
    # at it in `repair_windows.sh` (needed only on Windows because of the lack
    # of RPATH support).
    if [[ $RUNNER_OS == "Windows" ]]; then
        python <<EOF
import os, scipy_${OPENBLAS}, shutil
srcdir = os.path.join(os.path.dirname(scipy_${OPENBLAS}.__file__), "lib")
shutil.copytree(srcdir, os.path.join("$pkgconf_path", "lib"))
EOF
    fi
fi

# cibuildwheel doesn't install delvewheel by default
if [[ $RUNNER_OS == "Windows" ]]; then
    python -m pip install -r $PROJECT_DIR/requirements/delvewheel_requirements.txt
fi
