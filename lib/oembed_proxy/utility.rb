module OembedProxy
  class Utility
    def self.clean_pattern(pattern)
      if pattern.strip =~ /^#.*#i$/
        pattern.strip.slice(1..-3)
      else
        pattern.strip
      end
    end
  end
end
