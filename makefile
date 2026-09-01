# makefile
GENERATED_FILES = src/mime_map/type_to_name.cr src/mime_map/name_to_type.cr

.PHONY: all clean gen spec bench

all: gen spec

gen: clean
	@echo
	crystal scripts/generate_mime_maps.cr
	@echo

spec:
	@echo
	crystal spec
	@echo

bench:
	@echo
	crystal run --release bench/mime_map_bench.cr
	@echo

clean:
	@rm -rf $(GENERATED_FILES)