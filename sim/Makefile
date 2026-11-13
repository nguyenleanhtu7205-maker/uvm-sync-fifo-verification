# =============================================================================
# Makefile - UVM testbench for the synchronous FIFO (Cadence Xcelium)
# Chay trong thu muc sim/:   make help
# =============================================================================

TEST  ?= fifo_write_read_test
SEED  ?= 1
VERB  ?= UVM_MEDIUM
NSEED ?= 8

NAME   := $(TEST)_s$(SEED)
XCLEAN := $(if $(CLEAN),-clean,)
XRUN_COMMON := -f filelist.f -coverage u -covoverwrite -run -exit

.PHONY: help run regress merge wave clean

help:
	@echo "Cac muc tieu:"
	@echo "  make run TEST=<ten_test> [SEED=n] [VERB=UVM_HIGH] [CLEAN=1]  - chay mot test"
	@echo "  make regress [NSEED=8]   - chay tat ca test, tong hop pass/fail, gop coverage"
	@echo "  make merge               - gop coverage tu cov_work/ va in danh sach bin chua phu"
	@echo "  make wave                - mo waveform wave.vcd bang SimVision"
	@echo "  make clean               - xoa file sinh ra (log, coverage, du lieu bien dich)"
	@echo ""
	@echo "Vi du: make run TEST=fifo_corner_test VERB=UVM_HIGH CLEAN=1"

run:
	@mkdir -p logs
	xrun $(XCLEAN) $(XRUN_COMMON) +UVM_TESTNAME=$(TEST) +UVM_VERBOSITY=$(VERB) -svseed $(SEED) -covtest $(NAME) -l logs/$(NAME).log
	@grep -E 'TONG|RESULT' logs/$(NAME).log || true

regress:
	./regress.sh $(NSEED)

merge:
	imc -execcmd "merge cov_work/scope/*_s* -out cov_work/scope/merged -overwrite; load -run cov_work/scope/merged; report -detail -uncovered -metrics covergroup -out holes.txt"
	@echo "Danh sach bin chua phu: holes.txt"

wave:
	simvision wave.vcd &

clean:
	rm -rf xcelium.d INCA_libs cov_work logs holes.txt wave.vcd waves.shm .simvision xrun.log xrun.history xrun.key