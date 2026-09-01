# makefile
GENERATED_FILES = src/mime_map/type_to_name.cr src/mime_map/name_to_type.cr

.PHONY: all clean gen spec

all: gen spec

gen: clean
	crystal scripts/generate_mime_maps.cr

spec:
	crystal spec

clean:
	rm -rf $(GENERATED_FILES)