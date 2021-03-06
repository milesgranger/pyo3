#!/bin/sh

set -e

### Setup Rust toolchain #######################################################

curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain=$TRAVIS_RUST_VERSION
export PATH=$PATH:$HOME/.cargo/bin
if [ $TRAVIS_JOB_NAME = 'Minimum nightly' ]; then
    rustup component add clippy
    rustup component add rustfmt
fi

### Setup python linker flags ##################################################

PYTHON_LIB=$(python -c "import sysconfig; print(sysconfig.get_config_var('LIBDIR'))")

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$PYTHON_LIB:$HOME/rust/lib"

echo ${LD_LIBRARY_PATH}

### Setup kcov #################################################################

if [ ! -f "$HOME/.cargo/bin/kcov" ]; then
    if [ ! -d "$HOME/kcov/.git" ]; then
        git clone --depth=1 https://github.com/SimonKagstrom/kcov "$HOME/kcov"
    fi

    cd $HOME/kcov
    git pull
    cmake .
    make
    install src/kcov $HOME/.cargo/bin/kcov
    cd $TRAVIS_BUILD_DIR
fi
