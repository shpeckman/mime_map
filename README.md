<!-- README.md -->
# mime_map

A blazing fast, lightweight Crystal shard for bidirectional mapping between file extensions and MIME/media types. 

`mime_map` dynamically generates its mappings at installation time using the most up-to-date IANA registries (covering `application`, `audio`, `font`, `image`, `message`, `model`, `multipart`, `text`, and `video`) as well as the comprehensive Apache `mime.types` fallback list.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     mime_map:
       github: shpeckman/mime_map
       version: ~> 0.2.0
   ```

2. Run `shards install`

> **Note:** The installation process uses a `postinstall` hook to run `make`, which fetches the latest MIME type data directly from IANA and Apache and compiles it into static Crystal Hash structures for O(1) performance.

## Usage

```crystal
require "mime_map"

# --- Basic Lookups ---

# Safely lookup a MIME type by extension (case-insensitive)
MimeMap.media_type?("json") # => "application/json"
MimeMap.media_type?("ZIP")  # => "application/zip"
MimeMap.media_type?("foo")  # => nil

# Strict lookup (raises KeyError if not found)
MimeMap.media_type("csv")   # => "text/csv"

# Lookup with a fallback default
MimeMap.media_type("unknown", "application/octet-stream") # => "application/octet-stream"


# --- Reverse Lookups ---

# Get the primary extension for a MIME type
MimeMap.name?("application/json") # => "json"

# Get all known extensions for a MIME type
MimeMap.extensions("image/jpeg")  # => ["jpeg", "jpg"]


# --- File Path Helpers ---

# Lookup by extension with a leading dot
MimeMap.from_ext(".png") # => "image/png"

# Lookup directly from a file path
MimeMap.from_filename("/var/www/uploads/document.pdf") # => "application/pdf"
MimeMap.from_filename("Makefile")                      # => nil


# --- Category Checkers ---

# Easily verify if an extension, path, or MIME type belongs to a specific category
MimeMap.image?("png")                  # => true
MimeMap.image?("photo.png")            # => true
MimeMap.image?("image/png")            # => true
MimeMap.image?("application/json")     # => false

MimeMap.audio?("mp3")                  # => true
MimeMap.application?("document.pdf")   # => true
MimeMap.text?("text/html")             # => true
```

## Available Category Checkers

The following category checking methods are automatically generated:

* `MimeMap.application?(input)`
* `MimeMap.audio?(input)`
* `MimeMap.font?(input)`
* `MimeMap.image?(input)`
* `MimeMap.message?(input)`
* `MimeMap.model?(input)`
* `MimeMap.multipart?(input)`
* `MimeMap.text?(input)`
* `MimeMap.video?(input)`

## Contributing

1. Fork it (<https://github.com/shpeckman/mime_map/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
