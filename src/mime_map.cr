# src/mime_map.cr
require "./mime_map/ext_to_type"
require "./mime_map/type_to_exts"

# MimeMap provides bidirectional mapping between file extensions and MIME/media types.
# It utilizes dynamically generated data from the official IANA registry and Apache mime.types.
module MimeMap
  # Returns the MIME type for the given extension/name, or `nil` if not found.
  # The lookup is case-insensitive.
  #
  # ```
  # MimeMap.media_type?("json") # => "application/json"
  # MimeMap.media_type?("ZIP")  # => "application/zip"
  # MimeMap.media_type?("foo")  # => nil
  # ```
  def self.media_type?(name : String) : String?
    EXT_TO_TYPE[name.downcase]?
  end

  # Returns the MIME type for the given extension/name.
  # Raises a `KeyError` if the extension is not found.
  #
  # ```
  # MimeMap.media_type("json") # => "application/json"
  # ```
  def self.media_type(name : String) : String
    EXT_TO_TYPE[name.downcase]
  end

  # Returns the MIME type for the given extension/name, or the provided `default` value if not found.
  #
  # ```
  # MimeMap.media_type("foo", "application/octet-stream") # => "application/octet-stream"
  # ```
  def self.media_type(name : String, default : String) : String
    EXT_TO_TYPE.fetch(name.downcase, default)
  end

  # Returns the primary file extension associated with the given MIME type, or `nil` if not found.
  # The lookup is case-insensitive.
  #
  # ```
  # MimeMap.name?("application/json") # => "json"
  # MimeMap.name?("image/jpeg")       # => "jpeg"
  # MimeMap.name?("invalid/type")     # => nil
  # ```
  def self.name?(media_type : String) : String?
    extensions(media_type).first?
  end

  # Returns the primary file extension associated with the given MIME type.
  # Raises an `Exception` (via `Enumerable#first`) if the type has no mapped extensions.
  #
  # ```
  # MimeMap.name("application/json") # => "json"
  # ```
  def self.name(media_type : String) : String
    TYPE_TO_EXTS[media_type.downcase].first
  end

  # Returns an array of all known file extensions for the given MIME type.
  # Returns an empty array if the type is unknown.
  #
  # ```
  # MimeMap.extensions("image/jpeg") # => ["jpeg", "jpg"]
  # MimeMap.extensions("unknown/x")  # => []
  # ```
  def self.extensions(media_type : String) : Array(String)
    TYPE_TO_EXTS[media_type.downcase]? || [] of String
  end

  # Looks up the MIME type for a file extension.
  # Handles extensions with or without a leading dot.
  #
  # ```
  # MimeMap.from_ext(".png")     # => "image/png"
  # MimeMap.from_ext("png")      # => "image/png"
  # MimeMap.from_ext(".invalid") # => nil
  # ```
  def self.from_ext(ext : String) : String?
    normalized_ext = ext.starts_with?('.') ? ext[1..] : ext
    media_type?(normalized_ext)
  end

  # Extracts the extension from a file path and returns its mapped MIME type.
  # Returns `nil` if the path has no extension or if the extension is unknown.
  #
  # ```
  # MimeMap.from_filename("document.pdf")      # => "application/pdf"
  # MimeMap.from_filename("/path/to/data.csv") # => "text/csv"
  # MimeMap.from_filename("Makefile")          # => nil
  # ```
  def self.from_filename(path : String) : String?
    ext = File.extname(path)
    return nil if ext.empty?
    from_ext(ext)
  end

  private def self.resolve_media_type(input : String) : String
    from_filename(input) || from_ext(input) || input.downcase
  end

  {% for category in %w(application audio font image message model multipart text video) %}
    # Checks if the given input belongs to the `{{category.id}}` media category.
    # The input can be a raw extension (`"png"`), an extension with a dot (`".png"`),
    # a filename (`"photo.png"`), or a full MIME type (`"{{category.id}}/something"`).
    #
    # ```
    # MimeMap.{{category.id}}?("...")
    # ```
    def self.{{category.id}}?(input : String) : Bool
      resolve_media_type(input).starts_with?("{{category.id}}/")
    end
  {% end %}
end
