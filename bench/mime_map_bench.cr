# bench/mime_map_bench.cr
require "benchmark"
require "../src/mime_map"

name         = "zip"
missing_name = "invalid-name"
type         = "application/zip"
missing_type = "application/invalid"

Benchmark.ips do |x|
  x.report("media_type? (hit)") { MimeMap.media_type?(name) }
  x.report("media_type? (miss)") { MimeMap.media_type?(missing_name) }
  x.report("media_type (hit)") { MimeMap.media_type(name) }

  x.report("name? (hit)") { MimeMap.name?(type) }
  x.report("name? (miss)") { MimeMap.name?(missing_type) }
  x.report("name (hit)") { MimeMap.name(type) }
end
