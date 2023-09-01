# frozen_string_literal: true

module OembedProxy
  # Google Spreadsheet Fauxembed
  class GoogleSpreadsheet
    GOOGLE_SPREADSHEET_REGEX = %r{\Ahttps://docs\.google\.com/spreadsheet.+}

    def handles_url?(url)
      !(url =~ GOOGLE_SPREADSHEET_REGEX).nil?
    end

    def get_data(url, _other_params = {})
      return nil unless handles_url? url

      oembed = {}

      oembed['type'] = 'rich'
      oembed['version'] = '1.0'

      oembed['provider_name'] = 'Google Apps Spreadsheets'
      oembed['provider_url'] = 'https://docs.google.com/spreadsheet/‎'

      oembed['html'] = <<~HTML.chomp
        <iframe class="google-docs spreadsheet" width="100%" height="500" frameborder="0" scrolling="yes" marginheight="0" marginwidth="0" src="#{url}&amp;output=html"></iframe>
      HTML
      oembed['width'] = 500
      oembed['height'] = 500

      oembed
    end
  end
end
