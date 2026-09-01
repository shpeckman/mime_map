# mime_map

A blazing fast, lightweight Crystal shard for bidirectional mapping between file extensions and MIME/media types. 

`mime_map` dynamically generates its mappings at installation time using the most up-to-date IANA registries (covering `application`, `audio`, `font`, `image`, `message`, `model`, `multipart`, `text`, and `video`) as well as the comprehensive Apache `mime.types` fallback list.

## Installation

1. Add the dependency to your `shard.yml`:

```yaml
   dependencies:
     mime_map:
       github: shpeckman/mime_map
       version: ~> 1.0.0
```

2. Run `shards install`

> **Note:** The installation process uses a `postinstall` hook to run `make`, which fetches the latest MIME type data directly from IANA and Apache and compiles it into static Crystal Hash structures for O(1) performance.

## Usage

```crystal
require "mime_map"

MimeMap.media_type?("json")
MimeMap.media_type?("ZIP")
MimeMap.media_type?("foo")

MimeMap.media_type("csv")

MimeMap.media_type("unknown", "application/octet-stream")

MimeMap.name?("application/json")

MimeMap.extensions("image/jpeg")

MimeMap.from_ext(".png")

MimeMap.from_filename("/var/www/uploads/document.pdf")
MimeMap.from_filename("Makefile")

MimeMap.category?("png")
MimeMap.category?("archive.zip")
MimeMap.category?("invalid-ext")

MimeMap.category("document.pdf")

MimeMap.image?("png")
MimeMap.image?("photo.png")
MimeMap.image?("image/png")
MimeMap.image?("application/json")

MimeMap.audio?("mp3")
MimeMap.application?("document.pdf")
MimeMap.text?("text/html")
```

## Available Category Checkers

The following category checking methods are automatically generated and backed by the `MimeMap::Category` enum:

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

1. Fork it ([https://github.com/shpeckman/mime_map/fork](https://www.google.com/search?q=https://github.com/shpeckman/mime_map/fork))
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request