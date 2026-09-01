# src/mime_map.cr
require "./mime_map/name_to_type"
require "./mime_map/type_to_name"

module MimeMap
  def self.media_type?(name : String) : String?
    NAME_TO_TYPE[name]?
  end

  def self.media_type(name : String) : String
    NAME_TO_TYPE[name]
  end

  def self.name?(media_type : String) : String?
    TYPE_TO_NAME[media_type]?
  end

  def self.name(media_type : String) : String
    TYPE_TO_NAME[media_type]
  end
end
