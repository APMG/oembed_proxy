# frozen_string_literal: true

require 'oembed_proxy/google_spreadsheet'

RSpec.describe OembedProxy::GoogleSpreadsheet do
  let(:klass) { OembedProxy::GoogleSpreadsheet.new }

  it_behaves_like 'provider standard' do
    let(:handled_url) { 'https://docs.google.com/spreadsheet/pub?key=0Arx6U7Sl74uxdHRpd3p4bk5lV1BOVXhDa0N1VWxnblE&output=html' }
  end

  it '.handles_url? returns true for Google Spreadsheet urls' do
    dc = OembedProxy::GoogleSpreadsheet.new
    result = dc.handles_url? 'https://docs.google.com/spreadsheet/pub?key=0Arx6U7Sl74uxdHRpd3p4bk5lV1BOVXhDa0N1VWxnblE&output=html'
    expect(result).to eql(true)
  end

  it '.get_data returns valid Google Spreadsheet oembed' do
    url = 'https://docs.google.com/spreadsheet/pub?key=0Arx6U7Sl74uxdHRpd3p4bk5lV1BOVXhDa0N1VWxnblE&output=html'

    dc = OembedProxy::GoogleSpreadsheet.new
    result = dc.get_data url

    expect(result).to_not be_nil

    expect(result['html']).to eql('<iframe class="google-docs spreadsheet" width="100%" height="500" frameborder="0" scrolling="yes" marginheight="0" marginwidth="0" src="https://docs.google.com/spreadsheet/pub?key=0Arx6U7Sl74uxdHRpd3p4bk5lV1BOVXhDa0N1VWxnblE&output=html&amp;output=html"></iframe>')
    expect(result['provider_name']).to eql('Google Apps Spreadsheets')
    expect(result['provider_url']).to eql('https://docs.google.com/spreadsheet/‎')
    expect(result['width']).to eql(500)
    expect(result['height']).to eql(500)
  end

  it '.get_data returns nil for invalid url' do
    dc = OembedProxy::GoogleSpreadsheet.new
    result = dc.get_data 'akjdhflkahdlfhalkjsdfh'

    expect(result).to be_nil
  end
end
