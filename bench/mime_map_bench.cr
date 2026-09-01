# bench/mime_map_bench.cr
require "benchmark"
require "../src/mime_map"

name         = "zip"
upper_name   = "ZIP"
missing_name = "invalid-name"
type         = "application/zip"
upper_type   = "Application/Zip"
missing_type = "application/invalid"
filename     = "archive.zip"

Benchmark.ips do |x|
  x.report("media_type? (hit)") { MimeMap.media_type?(name) }
  x.report("media_type? (miss)") { MimeMap.media_type?(missing_name) }
  x.report("media_type? (case-insensitive hit)") { MimeMap.media_type?(upper_name) }
  x.report("media_type (hit)") { MimeMap.media_type(name) }
  x.report("media_type (default hit)") { MimeMap.media_type(missing_name, "application/octet-stream") }

  x.report("name? (hit)") { MimeMap.name?(type) }
  x.report("name? (miss)") { MimeMap.name?(missing_type) }
  x.report("name (hit)") { MimeMap.name(type) }

  x.report("extensions (hit)") { MimeMap.extensions(type) }
  x.report("extensions (case-insensitive hit)") { MimeMap.extensions(upper_type) }

  x.report("from_ext (hit)") { MimeMap.from_ext(".zip") }
  x.report("from_filename (hit)") { MimeMap.from_filename(filename) }

  x.report("image? (ext hit)") { MimeMap.image?("png") }
  x.report("image? (filename hit)") { MimeMap.image?("photo.png") }
  x.report("image? (type hit)") { MimeMap.image?("image/png") }
  x.report("image? (miss)") { MimeMap.image?("application/json") }
end
