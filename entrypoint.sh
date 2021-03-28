#!/bin/bash

# Fail on errors.
set -e

# Make sure .bashrc is sourced
. /root/.bashrc

# Allow the workdir to be set using an env var.
# Useful for CI pipiles which use docker for their build steps
# and don't allow that much flexibility to mount volumes
SRCDIR=$1

PYPI_URL=$2

PYPI_INDEX_URL=$3

WORKDIR=${SRCDIR:-/src}

SPEC_FILE=${4:-*.spec}

# wget http://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
# bash Miniconda3-latest-Linux-x86_64.sh -p /miniconda -b
# rm Miniconda3-latest-Linux-x86_64.sh
# PATH=/miniconda/bin:${PATH}
# conda update -y conda

apt-get update -qy --fix-missing
apt-get install -qfy build-essential libdb-dev python-lmdb=0.98-1

# conda install -c conda-forge pip wheel setuptools implicit python-lmdb pyinstaller
#
# In case the user specified a custom URL for PYPI, then use
# that one, instead of the default one.
#
if [[ "$PYPI_URL" != "https://pypi.python.org/" ]] || \
   [[ "$PYPI_INDEX_URL" != "https://pypi.python.org/simple" ]]; then
    # the funky looking regexp just extracts the hostname, excluding port
    # to be used as a trusted-host.
    mkdir -p /wine/drive_c/users/root/pip
    echo "[global]" > /wine/drive_c/users/root/pip/pip.ini
    echo "index = $PYPI_URL" >> /wine/drive_c/users/root/pip/pip.ini
    echo "index-url = $PYPI_INDEX_URL" >> /wine/drive_c/users/root/pip/pip.ini
    echo "trusted-host = $(echo $PYPI_URL | perl -pe 's|^.*?://(.*?)(:.*?)?/.*$|$1|')" >> /wine/drive_c/users/root/pip/pip.ini

    echo "Using custom pip.ini: "
    cat /wine/drive_c/users/root/pip/pip.ini
fi

cd $WORKDIR



if [ -f requirements.txt ]; then
    pip install -r requirements.txt
fi # [ -f requirements.txt ]


# if [[ "$@" == "" ]]; then
pyinstaller --clean -F --noconsole -y --dist ./dist/windows --workpath /tmp $SPEC_FILE
chown -R --reference=. ./dist/windows
# else
    # sh -c "$@"
# fi # [[ "$@" == "" ]]
