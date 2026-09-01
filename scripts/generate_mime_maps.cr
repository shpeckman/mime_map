# scripts/generate_mime_maps.cr
require "csv"
require "http/client"

module GenerateMimeMap
  DEFAULT_SOURCE     = "https://www.iana.org/assignments/media-types/application.csv"
  DEFAULT_OUTPUT_DIR = "src"

  record Entry, name : String, media_type : String

  def self.read(source : String) : String
    if source.starts_with?("http://") || source.starts_with?("https://")
      response = HTTP::Client.get(source)
      raise "GET #{source} failed: #{response.status_code}" unless response.success?
      response.body
    else
      File.read(source)
    end
  end

  def self.parse(body : String) : Array(Entry)
    entries = [] of Entry
    csv     = CSV.new(body, headers: true)
    while csv.next
      name       = csv["Name"].strip
      media_type = csv["Template"].strip
      next if name.empty? || media_type.empty?
      entries << Entry.new(name, media_type)
    end
    entries.sort_by!(&.name)
  end

  def self.escape(value : String) : String
    value.gsub('\\', "\\\\").gsub('"', "\\\"")
  end

  def self.emit_map(io : IO, path : String, constant : String, pairs : Array({String, String})) : Nil
    io << "# " << path << '\n'
    io << '\n'
    io << "module MimeMap\n"
    io << "  " << constant << " = {\n"
    pairs.each do |key, value|
      io << "    \"" << escape(key) << "\" => \"" << escape(value) << "\",\n"
    end
    io << "  }\n"
    io << "end\n"
  end

  def self.emit(entries : Array(Entry), output_dir : String) : Nil
    map_dir = File.join(output_dir, "mime_map")
    Dir.mkdir_p(map_dir)

    name_to_type_path = File.join(map_dir, "name_to_type.cr")
    File.open(name_to_type_path, "w") do |io|
      pairs = entries.map { |entry| {entry.name, entry.media_type} }
      emit_map(io, name_to_type_path, "NAME_TO_TYPE", pairs)
    end

    type_to_name_path = File.join(map_dir, "type_to_name.cr")
    File.open(type_to_name_path, "w") do |io|
      pairs = entries.sort_by(&.media_type).map { |entry| {entry.media_type, entry.name} }
      emit_map(io, type_to_name_path, "TYPE_TO_NAME", pairs)
    end
  end

  def self.run(source : String, output_dir : String) : Nil
    entries = parse(read(source))
    emit(entries, output_dir)
    STDERR.puts "Wrote #{entries.size} entries to #{output_dir}/"
  end
end

source     = ARGV[0]? || GenerateMimeMap::DEFAULT_SOURCE
output_dir = ARGV[1]? || GenerateMimeMap::DEFAULT_OUTPUT_DIR
GenerateMimeMap.run(source, output_dir)
