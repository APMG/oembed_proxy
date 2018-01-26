# frozen_string_literal: true

require 'oembed_proxy/fusiontable_map'

RSpec.describe OembedProxy::FusiontableMap do
  let(:klass) { described_class.new }

  it_behaves_like 'provider standard' do
    let(:handled_url) { 'https://www.google.com/fusiontables/embedviz?viz=MAP&q=select+col6+from+1is6E5G4IwxTxG43X8F-v1N_OOSy_lJo_JhrI01U&h=false&lat=45.302540427209586&lng=-93.85018772275396&z=7&t=1&l=col6&y=6&tmplt=8' }
  end

  it '.handles_url? returns true for documentcloud urls' do
    dc = described_class.new
    result = dc.handles_url? 'https://www.google.com/fusiontables/embedviz?viz=MAP&q=select+col6+from+1is6E5G4IwxTxG43X8F-v1N_OOSy_lJo_JhrI01U&h=false&lat=45.302540427209586&lng=-93.85018772275396&z=7&t=1&l=col6&y=6&tmplt=8'
    expect(result).to eql(true)
  end

  it '.get_data returns valid documentcloud oembed' do
    url = 'https://www.google.com/fusiontables/embedviz?viz=MAP&q=select+col6+from+1is6E5G4IwxTxG43X8F-v1N_OOSy_lJo_JhrI01U&h=false&lat=45.302540427209586&lng=-93.85018772275396&z=7&t=1&l=col6&y=6&tmplt=8'

    dc = described_class.new
    result = dc.get_data url

    expect(result).to_not be_nil

    expect(result['html']).to eql('<iframe class="google-map" width="100%" height="500" frameborder="0" scrolling="no" marginheight="0" marginwidth="0" src="https://www.google.com/fusiontables/embedviz?viz=MAP&q=select+col6+from+1is6E5G4IwxTxG43X8F-v1N_OOSy_lJo_JhrI01U&h=false&lat=45.302540427209586&lng=-93.85018772275396&z=7&t=1&l=col6&y=6&tmplt=8"></iframe>')
    expect(result['provider_name']).to eql('Google Apps Fusion Tables')
    expect(result['provider_url']).to eql('https://www.google.com/drive/apps.html#fusiontables')
    expect(result['width']).to eql(500)
    expect(result['height']).to eql(500)
  end

  it '.get_data returns nil for invalid url' do
    dc = described_class.new
    result = dc.get_data 'akjdhflkahdlfhalkjsdfh'

    expect(result).to be_nil
  end
end
