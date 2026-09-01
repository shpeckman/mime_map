# spec/mime_map_spec.cr
require "./spec_helper"

describe MimeMap do
  describe ".media_type?" do
    VALID_MAPPINGS.each do |name, type|
      it "returns the mapped media type for #{name}" do
        MimeMap.media_type?(name).should eq(type)
      end
    end

    it "is case-insensitive" do
      MimeMap.media_type?("ZIP").should eq("application/zip")
    end

    INVALID_NAMES.each do |name|
      it "returns nil for missing name #{name}" do
        MimeMap.media_type?(name).should be_nil
      end
    end
  end

  describe ".media_type" do
    VALID_MAPPINGS.each do |name, type|
      it "returns the mapped media type for #{name}" do
        MimeMap.media_type(name).should eq(type)
      end
    end

    it "returns the default value when provided and missing" do
      MimeMap.media_type("invalid-name", "application/octet-stream").should eq("application/octet-stream")
    end

    INVALID_NAMES.each do |name|
      it "raises KeyError for missing name #{name}" do
        expect_raises(KeyError) do
          MimeMap.media_type(name)
        end
      end
    end
  end

  describe ".name?" do
    VALID_MAPPINGS.each do |name, type|
      it "returns a valid mapped name for #{type}" do
        MimeMap.name?(type).should_not be_nil
      end
    end

    it "is case-insensitive" do
      MimeMap.name?("Application/Zip").should_not be_nil
    end

    INVALID_TYPES.each do |type|
      it "returns nil for missing type #{type}" do
        MimeMap.name?(type).should be_nil
      end
    end
  end

  describe ".name" do
    VALID_MAPPINGS.each do |name, type|
      it "returns a mapped name for #{type}" do
        MimeMap.name(type).should be_a(String)
      end
    end

    INVALID_TYPES.each do |type|
      it "raises KeyError for missing type #{type}" do
        expect_raises(KeyError) do
          MimeMap.name(type)
        end
      end
    end
  end

  describe ".extensions" do
    it "returns an array of extensions for a valid type" do
      exts = MimeMap.extensions("image/jpeg")
      exts.should be_a(Array(String))
      exts.should contain("jpg")
      exts.should contain("jpeg")
    end

    it "returns an empty array for an invalid type" do
      MimeMap.extensions("application/invalid").should be_empty
    end
  end

  describe ".from_ext" do
    it "returns the mime type for an extension with a leading dot" do
      MimeMap.from_ext(".json").should eq("application/json")
    end

    it "returns the mime type for an extension without a leading dot" do
      MimeMap.from_ext("json").should eq("application/json")
    end

    it "returns nil for an unknown extension" do
      MimeMap.from_ext(".invalid").should be_nil
    end
  end

  describe ".from_filename" do
    it "extracts the extension and returns the mime type" do
      MimeMap.from_filename("document.pdf").should eq("application/pdf")
    end

    it "handles filenames without extensions" do
      MimeMap.from_filename("Makefile").should be_nil
    end

    it "handles paths with directories" do
      MimeMap.from_filename("/path/to/image.png").should eq("image/png")
    end
  end
end

