
# UVM Verification Environment for a Synchronous FIFO

A self-checking, constrained-random UVM testbench for a parameterized synchronous FIFO,
built from a written specification and a verification plan, and run on Cadence Xcelium.

This is a learning project. Its goal is to show a complete, small-scale verification flow:
spec, verification plan, testbench, checking, functional coverage, coverage closure and
testbench validation by bug injection.

## Highlights

- Complete UVM environment: agent (sequencer, driver, monitor), scoreboard with a queue-based
  reference model, functional coverage subscriber, configuration object.
- **Spec first.** The checker is derived from the specification (`doc/SPEC_sync_fifo_v1.0.md`),
  not from the RTL. Ambiguous corner cases (simultaneous read/write when full or empty) were
  resolved in the spec as design decisions D2 and D3 before the testbench was written.
- **Sequence library** with random, directed corner-case, pointer wrap-around and nested sequences.
- **Seven tests**, including a factory-override test and a passive-agent test.
- **Functional coverage** with cross coverage on the corner cases, plus a multi-seed regression
  and merged coverage report.
- **Testbench validation:** bugs were injected into the RTL to confirm the scoreboard catches them
  (see `doc/bug_injection.md`).

## DUT

`sync_fifo` is a single-clock FIFO with a synchronous active-low reset.

| Item                 | Value                                                                            |
| -------------------- | -------------------------------------------------------------------------------- |
| Parameters           | `DWIDTH` (default 8), `DEPTH` (default 16, power of two)                     |
| Ports                | `clk`, `rst_n`, `wr_en`, `din`, `rd_en`, `dout`, `full`, `empty` |
| Read                 | Synchronous: `dout` is registered and valid one cycle after an accepted read   |
| Flags                | `full` and `empty` are derived from an occupancy counter                     |
| Overflow / underflow | The command is ignored, stored data is not corrupted                             |

Behavior in every read/write/full/empty combination is defined by the truth table in
section 4.6 of the spec. Two cases are worth noting:

- **D2:** write and read in the same cycle while full: the read is accepted, the write is blocked.
- **D3:** write and read in the same cycle while empty: the write is accepted, the read is ignored.

## Testbench architecture

```text
                 +------------------------ fifo_env ------------------------+
                 |                                                          |
 test ---------> |  fifo_agent                                              |
 (selects        |   +-----------+    +--------+                            |
  sequences)     |   | sequencer |--->| driver |-----> fifo_if ---> sync_fifo
                 |   +-----------+    +--------+          |                 |
                 |                    +---------+         |                 |
                 |                    | monitor |<--------+                 |
                 |                    +----+----+                           |
                 |                         | analysis port (broadcast)      |
                 |                +--------+--------+                       |
                 |                v                 v                       |
                 |          scoreboard         coverage                     |
                 |        (queue model)       (covergroup)                  |
                 +----------------------------------------------------------+
```

The monitor is independent of the driver: it observes the pins and rebuilds transactions, so it
reports what the DUT actually did and not what the testbench intended. Because the DUT has a
synchronous read, the monitor holds each read transaction for one cycle and fills in `dout` when it
becomes valid.

![UVM architecture](doc/img/uvm_arch.png)

## Repository layout

```text
.
├── rtl/        sync_fifo.sv                  DUT
├── tb/         fifo_if.sv, tb_top.sv         interface (clocking blocks) and top module
├── env/        UVM package and components    item, config, driver, monitor, agent,
│                                             scoreboard, coverage, env
├── seq/        fifo_seq_lib.sv               sequence library
├── test/       fifo_test_lib.sv              test library
├── bringup/    tb_bringup.sv                 plain SystemVerilog sanity test of the DUT
├── sim/        filelist.f, Makefile,         run and regression scripts
│               run_seeds.sh, regress.sh
└── doc/        spec, verification plan, bug injection log, diagrams
```

## How to run

Requires Cadence Xcelium (developed with Xcelium 25.03) with its built-in UVM library
(`-uvm`). A commercial simulator license is needed.

```bash
cd sim

make run TEST=fifo_corner_test            # run one test
make run TEST=fifo_corner_test VERB=UVM_HIGH CLEAN=1   # more verbose, rebuild from scratch
make regress                              # all tests, random test with 8 seeds, merged coverage
make regress NSEED=20                     # more random seeds
make merge                                # merge coverage and list uncovered bins in holes.txt
make wave                                 # open waveform
make clean                                # remove generated files
```

Each run prints a summary of the form:

```text
[SB_RPT]  Writes accepted / Reads checked / Overflow / Underflow / Errors
[COV]     functional coverage per coverpoint and cross
[RESULT]  *** TEST PASSED ***   or   *** TEST FAILED ***
```

## Tests

| Test                     | Purpose                                                                                  |
| ------------------------ | ---------------------------------------------------------------------------------------- |
| `fifo_write_read_test` | Sanity: write N items, read them back                                                    |
| `fifo_random_test`     | Constrained-random stress, run with many seeds                                           |
| `fifo_corner_test`     | Fill the FIFO beyond `DEPTH` (overflow), then drain beyond empty (underflow), repeated |
| `fifo_wrap_test`       | Pointer wrap-around without the FIFO ever becoming full                                  |
| `fifo_edge_test`       | Simultaneous write and read exactly at the full and empty boundaries (D2, D3)            |
| `fifo_wr_only_test`    | Factory type override: replaces the item with a write-only item                          |
| `fifo_passive_test`    | Agent in passive mode: no stimulus, the monitor only observes                            |

## Checking and coverage

**Scoreboard.** A SystemVerilog queue models the FIFO. For every observed transaction the
scoreboard compares the `full` and `empty` flags with the model state, then applies the read and
the write in the order given by the spec truth table (all decisions use the state before the clock
edge). Read data is compared with the head of the queue. Messages are tagged `SB_FLAG`,
`SB_DATA`, `SB_OF` (overflow) and `SB_UF` (underflow) so failures can be filtered and located by
transaction number.

**Coverage.** Sampled from monitor transactions, never from sequences.

| Item                            | Content                                                                                                          |
| ------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| `cp_op`                       | write only, read only, both (idle is an illegal bin)                                                             |
| `cp_full`, `cp_empty`       | flag state at the time of the operation                                                                          |
| `cp_din`                      | data ranges plus the boundary values `0x00` and `0xFF`, sampled on writes only                               |
| `cx_op_full`, `cx_op_empty` | operation crossed with the flags: write when full, read when empty, simultaneous read and write at each boundary |

## Results

> Replace every `TBD` below with the numbers from your own run (`make regress`).

| Test                     | Seeds | Result |
| ------------------------ | ----- | ------ |
| `fifo_write_read_test` | 1     | TBD    |
| `fifo_corner_test`     | 1     | TBD    |
| `fifo_wrap_test`       | 1     | TBD    |
| `fifo_edge_test`       | 1     | TBD    |
| `fifo_wr_only_test`    | 1     | TBD    |
| `fifo_passive_test`    | 1     | TBD    |
| `fifo_random_test`     | TBD   | TBD    |

Merged functional coverage over all runs: **TBD %**. Bins waived, with the reason, are listed in
`doc/vplan.md`.

## Testbench validation by bug injection

To check that the testbench can actually find bugs, defects were injected into the RTL, one at a
time, and the scoreboard result was recorded. Example entries (full log in `doc/bug_injection.md`):

| Injected bug                                          | Detected by | First failing message |
| ----------------------------------------------------- | ----------- | --------------------- |
| `full` asserted at `DEPTH-1` instead of `DEPTH` | `SB_FLAG` | TBD                   |
| Read data corrupted by one bit                        | `SB_DATA` | TBD                   |

## Limitations and future work

- Reset in the middle of a simulation is not exercised (listed as a waiver in the verification plan).
- No SystemVerilog assertions yet; invariants such as "`full` and `empty` are never both high"
  are only checked indirectly by the scoreboard.
- Only functional coverage is collected; code coverage is not.
- Single clock domain and a single agent, by design of the DUT.

## Documents

- `doc/SPEC_sync_fifo_v1.0.md`: functional specification and design decisions.
- `doc/vplan.md`: verification plan mapping each feature to stimulus, checker and coverage bin.
- `doc/bug_injection.md`: bugs injected to validate the testbench.
