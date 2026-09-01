GENERATED_FILES = src/mime_map.cr src/mime_map/type_to_name.cr src/mime_map/name_to_type.cr

.PHONY: all gen clean-full

all: gen

gen: clean
	crystal scripts/generate_mime_maps.cr

clean:
	rm -rf $(GENERATED_FILES)