#!/bin/bash
# =============================================================================
# regress.sh - chay toan bo test cua testbench FIFO, tong hop pass/fail,
#              gop coverage bang IMC.
#
# Cach dung (trong thu muc sim/):
#   chmod +x regress.sh        # chi can lam mot lan
#   ./regress.sh               # test random chay 8 seed
#   ./regress.sh 20            # test random chay 20 seed
#
# Ket qua: bang tong hop in ra man hinh, log tung lan chay trong logs/,
# ma thoat khac 0 neu co test fail.
# =============================================================================

cd "$(dirname "$0")" || exit 1

NSEED=${1:-8}

# Test directed: moi test chay 1 seed (ket qua giong nhau o moi seed)
DIRECTED="fifo_write_read_test fifo_corner_test fifo_wrap_test fifo_wr_only_test fifo_edge_test fifo_passive_test"
# Test random: chay nhieu seed
RANDOM_TESTS="fifo_random_test"

TESTLIB="../test/fifo_test_lib.sv"
XRUN_OPTS="-f filelist.f +UVM_VERBOSITY=UVM_MEDIUM -coverage u -covoverwrite -run -exit"

mkdir -p logs
rm -rf cov_work            # bat dau tu coverage sach, de ban gop chi gom lan chay nay

n_pass=0
n_fail=0
n_skip=0
FAILED=""

# run_one <test> <seed>: chay mot lan, in mot dong ket qua
run_one() {
  local test=$1
  local seed=$2
  local name=${test}_s${seed}
  local log=logs/${name}.log

  xrun $XRUN_OPTS +UVM_TESTNAME=$test -svseed $seed -covtest $name -l $log > /dev/null 2>&1

  local status="FAIL"
  if grep -qF '*** TEST PASSED ***' "$log" 2>/dev/null && ! grep -qE '\*E,|\*F,' "$log"; then
    status="PASS"
  fi

  local cov
  cov=$(grep -m1 'TONG' "$log" 2>/dev/null | sed -E 's/.*= *//')
  [ -z "$cov" ] && cov="n/a"

  printf "%-24s seed=%-4s %-5s coverage=%s\n" "$test" "$seed" "$status" "$cov"

  if [ "$status" = "PASS" ]; then
    n_pass=$((n_pass + 1))
  else
    n_fail=$((n_fail + 1))
    FAILED="$FAILED ${name}"
  fi
}

# test_exists <test>: kiem tra class test co trong thu vien test khong
test_exists() {
  grep -qE "^class[[:space:]]+$1[[:space:]]" "$TESTLIB"
}

echo "=============================================================="
echo " REGRESSION: test directed 1 seed, test random $NSEED seed"
echo "=============================================================="

for t in $DIRECTED; do
  if test_exists "$t"; then
    run_one "$t" 1
  else
    printf "%-24s SKIP  (chua co trong %s)\n" "$t" "$TESTLIB"
    n_skip=$((n_skip + 1))
  fi
done

for t in $RANDOM_TESTS; do
  if test_exists "$t"; then
    for s in $(seq 1 "$NSEED"); do
      run_one "$t" "$s"
    done
  else
    printf "%-24s SKIP  (chua co trong %s)\n" "$t" "$TESTLIB"
    n_skip=$((n_skip + 1))
  fi
done

echo "--------------------------------------------------------------"
echo " PASS: $n_pass   FAIL: $n_fail   SKIP: $n_skip"
if [ "$n_fail" -ne 0 ]; then
  echo " Cac lan chay that bai:$FAILED"
  echo " Xem log tuong ung trong logs/ (tim dong *E, UVM_ERROR, UVM_FATAL)"
fi
echo "--------------------------------------------------------------"

# Gop coverage cua tat ca cac lan chay (neu co IMC)
if command -v imc > /dev/null 2>&1; then
  echo " Dang gop coverage bang IMC ..."
  imc -execcmd "merge cov_work/scope/*_s* -out cov_work/scope/merged -overwrite; load -run cov_work/scope/merged; report -detail -uncovered -metrics covergroup -out holes.txt" > logs/imc.log 2>&1
  if [ -s holes.txt ]; then
    echo " Danh sach bin chua phu: holes.txt"
  else
    echo " Khong tao duoc holes.txt. Xem logs/imc.log (cu phap IMC co the can chinh theo phien ban)."
  fi
else
  echo " Khong tim thay lenh 'imc': bo qua buoc gop coverage."
fi

[ "$n_fail" -eq 0 ]