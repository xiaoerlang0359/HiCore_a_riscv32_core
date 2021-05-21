SIM_DIR := ${PWD}
RUN_DIR := ${PWD}/run
TESTNAME := rv32ui-p-add
TESTCASE := ${RUN_DIR}/../../riscv-tools/riscv-tests/isa/generated/${TESTNAME}
DUMPWAVE := 1
CORE := e203
CFG := ${CORE}_config

H601 := HiCore601

CORE_NAME = $(shell echo $(CORE) | tr a-z A-Z)
core_name = $(shell echo $(CORE) | tr A-Z a-z)

all: run_test

install:
	mkdir -p ${SIM_DIR}/install/tb
	cp ${SIM_DIR}/../tb/tb_top.v ${SIM_DIR}/install/tb/ -rf
	cp ${SIM_DIR}/../rtl/core ${SIM_DIR}/install/rtl -rf

${RUN_DIR}:
	mkdir -p ${RUN_DIR}
	rm -f ${RUN_DIR}/Makefile
	ln -s ${SIM_DIR}/bin/run.makefile ${RUN_DIR}/Makefile

compile: ${RUN_DIR}
	make compile RUN_DIR=${RUN_DIR} -C ${RUN_DIR}

wave: ${RUN_DIR}
	make wave TESTCASE=${TESTCASE} RUN_DIR=${RUN_DIR} -C ${RUN_DIR}

run_test: compile
	make run DUMPWAVE=${DUMPWAVE} TESTCASE=${TESTCASE} RUN_DIR=${RUN_DIR} -C ${RUN_DIR}

SELF_TEST := $(patsubst %.dump,%,$(wildcard ${RUN_DIR}/../../riscv-tools/riscv-tests/isa/generated/rv32ui-p*.dump))
SELF_TEST += $(patsubst %.dump,%,$(wildcard ${RUN_DIR}/../../riscv-tools/riscv-tests/isa/generated/rv32mi-p*.dump))

regress_prepare:
	make compile
	@-rm -rf ${RUN_DIR}/rv32*.log
regress_run:
	$(foreach tst,$(SELF_TEST), make run_test DUMPWAVE=0 TESTCASE=$(tst);)
regress_collect:
	@-rm -rf ${RUN_DIR}/regress.res
	@find ${RUN_DIR} -name "rv32*.log" -exec bin/find_test_fail.csh {} >> ${RUN_DIR}/regress.res \;
	@cat ${RUN_DIR}/regress.res
regress: regress_prepare regress_run regress_collect

clean:
	rm -rf run
	rm -rf install

.PHONY: compile run install clean all run_test regress regress_prepare regress_run regress_collect

