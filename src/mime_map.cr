# src/mime_map.cr
require "./mime_map/ext_to_type"
require "./mime_map/type_to_exts"

module MimeMap
  def self.media_type?(name : String) : String?
    EXT_TO_TYPE[name.downcase]?
  end

  def self.media_type(name : String) : String
    EXT_TO_TYPE[name.downcase]
  end

  def self.media_type(name : String, default : String) : String
    EXT_TO_TYPE.fetch(name.downcase, default)
  end

  def self.name?(media_type : String) : String?
    extensions(media_type).first?
  end

  def self.name(media_type : String) : String
    TYPE_TO_EXTS[media_type.downcase].first
  end

  def self.extensions(media_type : String) : Array(String)
    TYPE_TO_EXTS[media_type.downcase]? || [] of String
  end

  def self.from_ext(ext : String) : String?
    normalized_ext = ext.starts_with?('.') ? ext[1..] : ext
    media_type?(normalized_ext)
  end

  def self.from_filename(path : String) : String?
    ext = File.extname(path)
    return nil if ext.empty?
    from_ext(ext)
  end

  private def self.resolve_media_type(input : String) : String
    from_filename(input) || from_ext(input) || input.downcase
  end

  {% for category in %w(application audio font image message model multipart text video) %}
    def self.{{category.id}}?(input : String) : Bool
      resolve_media_type(input).starts_with?("{{category.id}}/")
    end
  {% end %}
end

