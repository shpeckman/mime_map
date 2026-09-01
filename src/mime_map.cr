# src/mime_map.cr
require "./mime_map/ext_to_type"
require "./mime_map/type_to_exts"

# MimeMap provides bidirectional mapping between file extensions and MIME/media types.
# It utilizes dynamically generated data from the official IANA registry and Apache mime.types.
module MimeMap
  alias Extension = String
  alias MediaType = String

  enum Category
    Application
    Audio
    Font
    Image
    Message
    Model
    Multipart
    Text
    Video
  end

  # Returns the MIME type for the given extension/name, or `nil` if not found.
  # The lookup is case-insensitive.
  #
  # ```
  # MimeMap.media_type?("json") # => "application/json"
  # MimeMap.media_type?("ZIP")  # => "application/zip"
  # MimeMap.media_type?("foo")  # => nil
  # ```
  def self.media_type?(name : Extension) : MediaType?
    EXT_TO_TYPE[name.downcase]?
  end

  # Returns the MIME type for the given extension/name.
  # Raises a `KeyError` if the extension is not found.
  #
  # ```
  # MimeMap.media_type("json") # => "application/json"
  # ```
  def self.media_type(name : Extension) : MediaType
    EXT_TO_TYPE[name.downcase]
  end

  # Returns the MIME type for the given extension/name, or the provided `default` value if not found.
  #
  # ```
  # MimeMap.media_type("foo", "application/octet-stream") # => "application/octet-stream"
  # ```
  def self.media_type(name : Extension, default : MediaType) : MediaType
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
  def self.name?(media_type : MediaType) : Extension?
    extensions(media_type).first?
  end

  # Returns the primary file extension associated with the given MIME type.
  # Raises an `Exception` (via `Enumerable#first`) if the type has no mapped extensions.
  #
  # ```
  # MimeMap.name("application/json") # => "json"
  # ```
  def self.name(media_type : MediaType) : Extension
    TYPE_TO_EXTS[media_type.downcase].first
  end

  # Returns an array of all known file extensions for the given MIME type.
  # Returns an empty array if the type is unknown.
  #
  # ```
  # MimeMap.extensions("image/jpeg") # => ["jpeg", "jpg"]
  # MimeMap.extensions("unknown/x")  # => []
  # ```
  def self.extensions(media_type : MediaType) : Array(Extension)
    TYPE_TO_EXTS[media_type.downcase]? || [] of Extension
  end

  # Looks up the MIME type for a file extension.
  # Handles extensions with or without a leading dot.
  #
  # ```
  # MimeMap.from_ext(".png")     # => "image/png"
  # MimeMap.from_ext("png")      # => "image/png"
  # MimeMap.from_ext(".invalid") # => nil
  # ```
  def self.from_ext(ext : Extension) : MediaType?
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
  def self.from_filename(path : String) : MediaType?
    ext = File.extname(path)
    return nil if ext.empty?
    from_ext(ext)
  end

  # Returns the Category enum for the given input (extension, filename, or media type), or `nil` if unknown.
  #
  # ```
  # MimeMap.category?("png")         # => MimeMap::Category::Image
  # MimeMap.category?("archive.zip") # => MimeMap::Category::Application
  # MimeMap.category?("invalid-ext") # => nil
  # ```
  def self.category?(input : String) : Category?
    media_type = resolve_media_type(input)
    prefix     = media_type.split('/', 2).first?
    return nil unless prefix
    Category.parse?(prefix)
  end

  # Returns the Category enum for the given input.
  # Raises a `KeyError` if the category cannot be determined.
  #
  # ```
  # MimeMap.category("png") # => MimeMap::Category::Image
  # ```
  def self.category(input : String) : Category
    category?(input) || raise KeyError.new("Unknown category for input: #{input}")
  end

  private def self.resolve_media_type(input : String) : MediaType
    from_filename(input) || from_ext(input) || input.downcase
  end

  {% for cat in Category.constants %}
    # Checks if the given input belongs to the `{{cat.id.downcase}}` media category.
    # The input can be a raw extension (`"png"`), an extension with a dot (`".png"`),
    # a filename (`"photo.png"`), or a full MIME type (`"{{cat.id.downcase}}/something"`).
    #
    # ```
    # MimeMap.{{cat.id.downcase}}?("...")
    # ```
    def self.{{cat.id.downcase}}?(input : String) : Bool
      category?(input) == Category::{{cat.id}}
    end
  {% end %}
end
