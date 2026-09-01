# scripts/generate_mime_maps.cr
require "csv"
require "http/client"

module GenerateMimeMap
  IANA_REGISTRIES = %w(
    application audio font image message model multipart text video
  )
  APACHE_MIME_TYPES  = "https://raw.githubusercontent.com/apache/httpd/trunk/docs/conf/mime.types"
  DEFAULT_OUTPUT_DIR = "src"

  def self.read(source : String) : String
    if source.starts_with?("http://") || source.starts_with?("https://")
      response = HTTP::Client.get(source)
      raise "GET #{source} failed: #{response.status_code}" unless response.success?
      response.body
    else
      File.read(source)
    end
  end

  def self.escape(value : String) : String
    value.gsub('\\', "\\\\").gsub('"', "\\\"")
  end

  def self.run(output_dir : String) : Nil
    ext_to_type  = {} of String => String
    type_to_exts = {} of String => Array(String)

    IANA_REGISTRIES.each do |registry|
      body = read("https://www.iana.org/assignments/media-types/#{registry}.csv")
      csv  = CSV.new(body, headers: true)
      while csv.next
        name       = csv["Name"].strip.downcase
        media_type = csv["Template"].strip.downcase
        next if name.empty? || media_type.empty?

        ext_to_type[name] = media_type unless ext_to_type.has_key?(name)
        type_to_exts[media_type] ||= [] of String
        type_to_exts[media_type] << name
      end
    end

    body = read(APACHE_MIME_TYPES)
    body.each_line do |line|
      line = line.strip
      next if line.empty? || line.starts_with?('#')
      parts = line.split(/\s+/)
      next if parts.size < 2

      media_type = parts[0].downcase
      exts       = parts[1..].map(&.downcase)

      type_to_exts[media_type] ||= [] of String
      exts.each do |ext|
        ext_to_type[ext] = media_type
        type_to_exts[media_type] << ext
      end
    end

    type_to_exts.each do |k, v|
      type_to_exts[k] = v.uniq.sort
    end

    map_dir = File.join(output_dir, "mime_map")
    Dir.mkdir_p(map_dir)

    ext_to_type_path = File.join(map_dir, "ext_to_type.cr")
    File.open(ext_to_type_path, "w") do |io|
      io << "# " << ext_to_type_path << '\n'
      io << "module MimeMap\n"
      io << "  EXT_TO_TYPE = {\n"
      ext_to_type.to_a.sort_by(&.first).each do |key, value|
        io << "    \"" << escape(key) << "\" => \"" << escape(value) << "\",\n"
      end
      io << "  }\n"
      io << "end\n"
    end

    type_to_exts_path = File.join(map_dir, "type_to_exts.cr")
    File.open(type_to_exts_path, "w") do |io|
      io << "# " << type_to_exts_path << '\n'
      io << "module MimeMap\n"
      io << "  TYPE_TO_EXTS = {\n"
      type_to_exts.to_a.sort_by(&.first).each do |key, values|
        io << "    \"" << escape(key) << "\" => ["
        io << values.map { |v| "\"#{escape(v)}\"" }.join(", ")
        io << "],\n"
      end
      io << "  }\n"
      io << "end\n"
    end

    STDERR.puts "Wrote #{ext_to_type.size} extensions and #{type_to_exts.size} MIME types to #{output_dir}/"
  end
end

output_dir = ARGV[0]? || GenerateMimeMap::DEFAULT_OUTPUT_DIR
GenerateMimeMap.run(output_dir)
