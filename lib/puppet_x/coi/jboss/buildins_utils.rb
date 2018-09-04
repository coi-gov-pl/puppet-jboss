# This module contains vaious utility functions for Ruby buildins types
module PuppetX::Coi::Jboss::BuildinsUtils
  # Matcher for hash-like objects
  class HashlikeMatcher
    # Constructor
    # @param {Object} target to be tested
    def initialize(target)
      @target = target
    end

    # Method returns true if passed object is a hashlike object, but not String or Symbol
    def hashlike?
      @target.respond_to?(:[]) && @target.respond_to?(:each) && !@target.is_a?(String) && !@target.is_a?(Symbol)
    end
  end

  # Matcher for blank objects (empty collections or false objects)
  class BlankMatcher
    # Constructor
    # @param {Object} target to be tested
    def initialize(target)
      @target = target
    end

    # Method returns true if passed object is a hashlike object, but not String or Symbol
    def blank?
      return true if @target.nil?
      @target.respond_to?(:empty?) ? @target.empty? : !@target
    end
  end

  # Thsi class handles convertion from various types to boolean
  class ToBooleanConverter
    # Constructor
    # @param {Object} target to be converted
    def initialize(target)
      @target = target
    end

    # Converts given value to boolean value
    def to_bool
      str = if @target.respond_to?(:empty?)
              @target
            else
              @target.to_s
            end
      return @target != 0 if @target.is_a? Numeric
      return true if @target == true || str =~ /(true|t|yes|y)$/i
      bm = BlankMatcher.new(@target)
      return false if @target == false || bm.blank? || str =~ /(false|f|no|n)$/i
      raise(ArgumentError, "invalid value for Boolean: \"#{@target}\"")
    end
  end
end
