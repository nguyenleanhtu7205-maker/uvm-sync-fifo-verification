-64bit
-sv
-uvm
-timescale 1ns/1ps
-access +rwc
-top tb_top
+incdir+../env
+incdir+../seq
+incdir+../test
../rtl/sync_fifo.sv
../tb/fifo_if.sv
../env/fifo_pkg.sv
../tb/tb_top.sv