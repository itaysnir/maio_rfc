#!/bin/bash

set -exuo pipefail

ncat -l 8080 --keep-open --exec "/bin/cat" 
