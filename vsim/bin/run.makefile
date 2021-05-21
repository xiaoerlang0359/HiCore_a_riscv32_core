RUN_DIR := ${PWD}

TESTCASE := ${RUN_DIR}/../../riscv-tools/riscv-tests/isa/generated/rv32ui-p-addi
DUMPWAVE := 1

VSRC_DIR := ${RUN_DIR}/../install/rtl
VTB_DIR := ${RUN_DIR}/../install/tb
TESTNAME := $(notdir $(patsubst %.dump,%,${TESTCASE}.dump))
TEST_RUNDIR := ${TESTNAME}

RTL_V_FILES := $(wildcard ${VSRC_DIR}/*.v)
TB_V_FILES := $(wildcard ${VTB_DIR}/*.v)

SIM_TOOL := vcs

SIM_OPTIONS := -timescale=1ns/1ns -fsdb -full64 -R +vc +v2k -sverilog -debug_all -P ${LD_LIBRARY_PATH}/novas.tab ${LD_LIBRARY_PATH}/pli.a -l vcs.log +incdir+${VSRC_DIR}/

SIM_EXEC := ../simv

WAV_TOOL := verdi
WAV_OPTIONS := -2001 -sv -top -tb_top +incdir+${VSRC_DIR}/
WAV_PFIX :=

all: run

compile.flg: ${RTL_V_FILES} ${TB_V_FILES}
	@-rm -rf compile.flg
	${SIM_TOOL} ${SIM_OPTIONS} ${RTL_V_FILES} ${TB_V_FILES} ;
	touch compile.flg

compile: compile.flg

wave:
	${WAV_TOOL} ${WAV_OPTIONS} ${RTL_V_FILES} ${TB_V_FILES} &
run: compile
	rm -rf ${TEST_RUNDIR}
	mkdir ${TEST_RUNDIR}
	cd ${TEST_RUNDIR}; ${SIM_EXEC} +DUMPWAVE=${DUMPWAVE} +TESTCASE=${TESTCASE} |& tee ${TESTNAME}.log; cd ${RUN_DIR};

.PHONY: run clean all
