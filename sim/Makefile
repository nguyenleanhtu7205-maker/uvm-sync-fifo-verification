# =============================================================================
# Makefile - UVM testbench for the synchronous FIFO (Siemens Questa)
# Chay trong thu muc sim/:   make help
# =============================================================================

TEST  ?= fifo_write_read_test
SEED  ?= 1
VERB  ?= UVM_MEDIUM
NSEED ?= 8

NAME := $(TEST)_s$(SEED)

.PHONY: help compile run regress merge wave clean

help:
	@echo "Cac muc tieu:"
	@echo "  make compile             - bien dich RTL + testbench (vlog)"
	@echo "  make run TEST=<ten_test> [SEED=n] [VERB=UVM_HIGH]  - bien dich va chay mot test"
	@echo "  make regress [NSEED=8]   - chay tat ca test, tong hop pass/fail, gop coverage"
	@echo "  make merge               - gop coverage (vcover) va in danh sach bin chua phu"
	@echo "  make wave                - mo waveform wave.vcd trong Questa"
	@echo "  make clean               - xoa file sinh ra (work, log, coverage)"
	@echo ""
	@echo "Vi du: make run TEST=fifo_corner_test SEED=3 VERB=UVM_HIGH"

compile:
	@test -d work || vlib work
	vlog -sv -f filelist.f

run: compile
	@mkdir -p logs ucdb
	vsim -c tb_top -coverage -sv_seed $(SEED) +UVM_TESTNAME=$(TEST) +UVM_VERBOSITY=$(VERB) -l logs/$(NAME).log -do "coverage save -onexit ucdb/$(NAME).ucdb; run -all; quit -f"
	@grep -E 'TONG|RESULT' logs/$(NAME).log || true

regress:
	./regress.sh $(NSEED)

merge:
	vcover merge -out merged.ucdb ucdb/*_s*.ucdb
	vcover report -details -cvg -zeros -output holes.txt merged.ucdb || vcover report -details -cvg -output holes.txt merged.ucdb
	@echo "Danh sach bin chua phu: holes.txt"

wave:
	vcd2wlf wave.vcd wave.wlf
	vsim -view wave.wlf -do "add wave -r /*" &

clean:
	rm -rf work logs ucdb merged.ucdb holes.txt wave.vcd wave.wlf transcript vsim.wlf modelsim.ini
