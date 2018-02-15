# frozen_string_literal: true

module OembedProxy
  # Utility methods
  module Utility
    def self.clean_pattern(pattern_raw)
      pattern = pattern_raw.strip.freeze

      if pattern =~ /^#.*#i$/
        pattern.slice(1..-3)
      else
        pattern
      end
    end
  end
end
