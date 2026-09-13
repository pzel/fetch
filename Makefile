
LIBDIR := lib/github.com/pzel/fetch
MLCOMP ?= polymlb
SMLPKG_PATH := -mlb-path-var "SMLPKG $(shell pwd)/lib"

ifeq ($(MLCOMP), polymlb)
MLCOMP_FLAGS=-ann "ignoreFiles call-main.sml"
POLY_PATH := -mlb-path-var "POLY \$$(SML_LIB)/basis/"
else
POLY_PATH := -mlb-path-var "POLY \$$(SMLPKG)/github.com/pzel/polyml-fill/"
endif

.PHONY: all
all:	 test

.PHONY: clean
clean:
	-@rm -f bin/*

.PHONY: test
test: bin/test
	./$<

COMP := $(MLCOMP) $(MLCOMP_FLAGS) $(SMLPKG_PATH) $(POLY_PATH) -output

bin/test: $(shell find $(LIBDIR))
	$(COMP) $@ $(LIBDIR)/test/test.mlb

