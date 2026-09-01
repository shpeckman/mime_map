# spec/spec_helper.cr
require "spec"
require "../src/mime_map"

VALID_MAPPINGS = {
  "zip"                      => "application/zip",
  "zlib"                     => "application/zlib",
  "zstd"                     => "application/zstd",
  "1d-interleaved-parityfec" => "application/1d-interleaved-parityfec",
  "3gpdash-qoe-report+xml"   => "application/3gpdash-qoe-report+xml",
  "jpg"                      => "image/jpeg",
  "jpeg"                     => "image/jpeg",
  "json"                     => "application/json",
  "png"                      => "image/png"
}

INVALID_NAMES = [
  "invalid-name",
  "unknown",
  "not-a-zip",
  "application/zip",
]

INVALID_TYPES = [
  "application/invalid",
  "video/mp4-invalid",
  "zip",
  "text/plain-invalid",
]

