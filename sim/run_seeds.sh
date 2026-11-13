#!/bin/bash
# run_seeds.sh - chay mot test voi nhieu seed (Questa)
# Cach dung (trong thu muc sim/):   ./run_seeds.sh <test> <so_seed>
# Vi du:                            ./run_seeds.sh fifo_random_test 8

cd "$(dirname "$0")" || exit 1

TEST=${1:?"Thieu ten test. Vi du: ./run_seeds.sh fifo_random_test 8"}
N=${2:-8}

mkdir -p logs ucdb
test -d work || vlib work
vlog -sv -f filelist.f > logs/compile.log 2>&1 || { echo "Bien dich that bai, xem logs/compile.log"; exit 1; }

for s in $(seq 1 "$N"); do
  NAME=${TEST}_s${s}
  vsim -c tb_top -coverage -sv_seed "$s" +UVM_TESTNAME="$TEST" +UVM_VERBOSITY=UVM_MEDIUM \
       -l logs/${NAME}.log \
       -do "coverage save -onexit ucdb/${NAME}.ucdb; run -all; quit -f" > /dev/null 2>&1
  echo "--- seed $s ---"
  grep -E 'TONG|RESULT' logs/${NAME}.log
done
