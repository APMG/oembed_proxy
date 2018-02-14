# frozen_string_literal: true

require 'oembed_proxy/google_document'

RSpec.describe OembedProxy::GoogleDocument do
  let(:klass) { OembedProxy::GoogleDocument.new }

  it_behaves_like 'provider standard' do
    let(:handled_url) { 'https://docs.google.com/document/d/1UbsHE_KsmNjelwhu0Z0Az1BFf35lTQl1PjSHMc5fAgo/pub' }
  end

  it '.handles_url? returns true for Google Document urls' do
    dc = OembedProxy::GoogleDocument.new
    result = dc.handles_url? 'https://docs.google.com/document/d/1UbsHE_KsmNjelwhu0Z0Az1BFf35lTQl1PjSHMc5fAgo/pub'
    expect(result).to eql(true)
  end

  it '.get_data returns valid Google Document oembed' do
    url = 'https://docs.google.com/document/d/1UbsHE_KsmNjelwhu0Z0Az1BFf35lTQl1PjSHMc5fAgo/pub'

    dc = OembedProxy::GoogleDocument.new
    result = dc.get_data url

    expect(result).to_not be_nil

    expect(result['html']).to eql('<iframe class="google-docs document" width="100%" height="500" frameborder="0" scrolling="yes" marginheight="0" marginwidth="0" src="https://docs.google.com/document/d/1UbsHE_KsmNjelwhu0Z0Az1BFf35lTQl1PjSHMc5fAgo/pub"></iframe>')
    expect(result['provider_name']).to eql('Google Apps Documents')
    expect(result['provider_url']).to eql('https://docs.google.com/document/‎')
    expect(result['width']).to eql(500)
    expect(result['height']).to eql(500)
  end

  it '.get_data returns nil for invalid url' do
    dc = OembedProxy::GoogleDocument.new
    result = dc.get_data 'akjdhflkahdlfhalkjsdfh'

    expect(result).to be_nil
  end
end
