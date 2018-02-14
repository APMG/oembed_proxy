# frozen_string_literal: true

module OembedProxy
  # Utility methods
  module Utility
    def self.clean_pattern(pattern)
      if pattern.strip =~ /^#.*#i$/
        pattern.strip.slice(1..-3)
      else
        pattern.strip
      end
    end
  end
end
