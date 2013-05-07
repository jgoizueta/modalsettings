require 'rubygems'
require 'modalsupport' # requires modalsupport >= 0.8.1
require 'yaml'
require 'ostruct'
require 'erb'

# Settings container, supporting nested settings.
class Settings < OpenStruct

  # This uses implementation details of OpenStruct (the @table instance variable) that could change
  # in future releases of Ruby.

  class << self
    # Settings constructor. A hash is passed to define properties
    #
    #   s = Settings[:x=>100, :y=>200]
    #
    def [](settings={})
      ModalSupport.recursive_map(settings){|v|
        # We keep hashes with keys other than strings/symbols as hashe
        (v.kind_of?(Hash) && !v.keys.detect{|k| !k.respond_to?(:to_sym)}) ? Settings.new(v) : v
      }
    end

    # Build a Settings from a YAML file defining a properties Hash. The YAML can include ERB macros.
    # An optional second argument defines the name of an attribute to be merge into the top level.
    def load(settings_filename, merge_key=nil)
      properties = File.exists?(settings_filename) ? YAML.load(ERB.new(File.read(settings_filename)).result(binding)) : {}
      s = Settings[properties]
      if merge_key
        merge_settings = s[merge_key]
        s.merge! merge_settings if merge_settings && merge_settings.kind_of?(Settings)
      end
      s
    end
  end

  # Read a property with Hash syntax (with either a String or Symbol property name)
  def [](k)
    @table[k.to_sym]
  end

  # Write a property with Hash syntax (with either a String or Symbol property name)
  def []=(k,v)
    @table[k.to_sym] = Settings[v]
  end

  def method_missing(mth, *args)
    # property assignments convert Hashes to Settings
    args = Settings[args] if mth.to_s[-1,1]=='='
    super mth, *args
  end

  # Convert to a hash of properties indexed by symbolic property names. Nested Settings objects are also
  # converted to hash.
  def to_h
    ModalSupport.recursive_map(self){|s| s.kind_of?(Settings) ? s.instance_variable_get(:@table) : s}
  end

  # A Settings object converts to YAML as a Hash.
  def to_yaml
    to_h.to_yaml
  end

  # Iterator of key-value pairs.
  def each(&blk)
    @table.each(&blk)
  end

  # Merge with another Settings or Hash object (deeply).
  def merge(other)
    dup.merge!(other)
  end

  # Merge with another Settings or Hash object mutator (deeply).
  def merge!(other)
    other.each do |k,v|
      if self[k].kind_of?(Settings) && (v.kind_of?(Settings) || v.kind_of?(Hash))
        self[k].merge! v
      else
        self[k] = v
      end
    end
    self
  end

  # Deep copy (in relation to nested Settings; other non-inmediate values (e.g. arrays) are to cloned)
  def dup
    copy = super
    copy.each do |k, v|
      copy[k] = v.dup if v.kind_of?(Settings)
    end
    copy
  end

  # Keys that need [] syntax for access (because of collision with defined methods)
  def collisions(recursive=false)
    unless defined?(@@predefined_keys)
      empty = Settings.new
      # note that private & protected methods do not collide
      @@predefined_keys = (empty.methods).map{|k| k.to_sym}
    end
    keys = @table.keys & @@predefined_keys
    if recursive
      @table.each_pair do |key, value|
        if value.kind_of?(Settings)
          keys += value.collisions(recursive).map{|k| k.kind_of?(Array) ? [key]+k : [key, k]}
        end
      end
    end
    keys
  end

end
