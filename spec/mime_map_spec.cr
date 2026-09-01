# spec/mime_map_spec.cr
require "./spec_helper"

describe MimeMap do
  describe ".media_type?" do
    VALID_MAPPINGS.each do |name, type|
      it "returns the mapped media type for #{name}" do
        MimeMap.media_type?(name).should eq(type)
      end
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
      it "returns the mapped name for #{type}" do
        MimeMap.name?(type).should eq(name)
      end
    end

    INVALID_TYPES.each do |type|
      it "returns nil for missing type #{type}" do
        MimeMap.name?(type).should be_nil
      end
    end
  end

  describe ".name" do
    VALID_MAPPINGS.each do |name, type|
      it "returns the mapped name for #{type}" do
        MimeMap.name(type).should eq(name)
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
end
