# frozen_string_literal: true

module OembedProxy
  # A couple of things pulled in from ActiveSupport, but using refinements
  # instead of monkeypatching.
  module InactiveSupport
    refine String do
      def parameterize(sep = '-')
        parameterized_string = dup.downcase
        # Turn unwanted chars into the separator
        parameterized_string.gsub!(/[^a-z0-9\-_]+/, sep)
        unless sep.nil? || sep.empty?
          re_sep = Regexp.escape(sep)
          # No more than one of the separator in a row.
          parameterized_string.gsub!(/#{re_sep}{2,}/, sep)
          # Remove leading/trailing separator.
          parameterized_string.gsub!(/^#{re_sep}|#{re_sep}$/, '')
        end
        parameterized_string.downcase
      end
    end
  end
end
