# SPDX-License-Identifier: GPL-2.0
# X-SPDX-Copyright-Text: (c) Solarflare Communications Inc
#  bpfintf.a: userspace access library for linking with BPF client
#  applications, implements the API in oobpf.h

BPFINTF_SO = oobpfintf0.so
TARGETS		:= $(BPFINTF_LIB) $(BPFINTF_SO)
MMAKE_TYPE	:= LIB

LIB_SRCS	:= oobpf.c oobpf_elf.c
EXTRA_LIBS  :=

ifeq ($(HAVE_LIBELF),1)
EXTRA_LIBS += -lelf
LIB_SRCS += libbpf.o
MMAKE_CFLAGS += -DCI_HAVE_LIBELF=1

ifeq ($(BPF_TEST_LIBBPF),1)
BPFINTF_TEST_SO = oolibbpftest.so
TARGETS += $(BPFINTF_TEST_SO)
endif
else
MMAKE_CFLAGS += -DCI_HAVE_LIBELF=0
endif

ifndef MMAKE_NO_RULES

MMAKE_OBJ_PREFIX := ci_bpf_
LIB_OBJS	:= $(patsubst %.o,$(MMAKE_OBJ_PREFIX)%_st.o,$(LIB_SRCS:%.c=%.o))
SHARED_LIB_OBJS := $(patsubst %.o,$(MMAKE_OBJ_PREFIX)%_sh.o,$(LIB_SRCS:%.c=%.o))
SHARED_TEST_LIB_OBJS := $(patsubst %.o,$(MMAKE_OBJ_PREFIX)%_sh_test.o,$(LIB_SRCS:%.c=%.o))

MMAKE_INCLUDE := $(MMAKE_INCLUDE) \
                 -I$(TOP)/$(CURRENT)/../bpfimpl/kernel/bpf_include

MMAKE_CFLAGS += -fvisibility=hidden

ALL		:= $(TARGETS)

$(MMAKE_OBJ_PREFIX)%_st.o: %.c
	$(MMakeCompileC) -DOOBPFIMPL_STATIC

$(MMAKE_OBJ_PREFIX)%_sh.o: %.c
	$(MMakeCompileC)

$(MMAKE_OBJ_PREFIX)%_sh_test.o: %.c
	$(MMakeCompileC) -DTEST_LIBBPF

$(MMAKE_OBJ_PREFIX)%_st.o: libbpf/%.c
	$(MMakeCompileC) -DOOBPFIMPL_STATIC

$(MMAKE_OBJ_PREFIX)%_sh.o: libbpf/%.c
	$(MMakeCompileC)

$(MMAKE_OBJ_PREFIX)%_sh_test.o: libbpf/%.c
	$(MMakeCompileC) -DTEST_LIBBPF

all: $(ALL)

lib: $(TARGETS)

clean:
	@$(MakeClean)
	rm -f uk_bpf_intf_ver.h


$(BPFINTF_LIB): $(LIB_OBJS)
	$(MMakeLinkStaticLib)

$(BPFINTF_SO): $(SHARED_LIB_OBJS)
	@(soname="$(BPFINTF_SO)"; libs="$(EXTRA_LIBS)"; $(MMakeLinkDynamicLib))

$(BPFINTF_TEST_SO): $(SHARED_TEST_LIB_OBJS)
	@(soname="$(BPFINTF_TEST_SO)"; libs="$(EXTRA_LIBS)"; $(MMakeLinkDynamicLib))

endif


######################################################################
# Autogenerated header for checking user/kernel consistency.
#
_UK_BPF_INTF_HDRS	:= onload/bpf_api.h onload/bpf_ioctl.h

UK_BPF_INTF_HDRS	:= $(_UK_BPF_INTF_HDRS:%=$(SRCPATH)/include/%)

objd	:=
$(MMAKE_OBJ_PREFIX)oobpf_st.o $(MMAKE_OBJ_PREFIX)oobpf_sh.o: uk_bpf_intf_ver.h

$(objd)uk_bpf_intf_ver.h: $(UK_BPF_INTF_HDRS)
	@echo "  GENERATE $@"
	@md5=$$(cat $(UK_BPF_INTF_HDRS) | md5sum | sed 's/ .*//'); \
	echo "#define OO_UK_BPF_INTF_VER  \"$$md5\"" >"$@"
