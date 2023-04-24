#!/bin/bash
set -e
# This is for running the tests in a self managed environment
# It is intended only for software packagers
# It assumes strictyaml is already installed

THIS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

VIRTUALENV_BIN="${VIRTUALENV_BIN:-virtualenv}" 
PYTHON_BIN="${PYTHON_BIN:-python}"

rm -rf /tmp/testvenv/
rm -rf /tmp/testgen/
mkdir /tmp/testgen/
$VIRTUALENV_BIN /tmp/testvenv
/tmp/testvenv/bin/pip install -r $THIS_DIR/hitchreqs.txt

cd $THIS_DIR/
/tmp/testvenv/bin/python $THIS_DIR/self_env_test.py $PYTHON_BIN
