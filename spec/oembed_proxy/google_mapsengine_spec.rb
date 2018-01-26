# frozen_string_literal: true

require 'oembed_proxy/google_mapsengine'

RSpec.describe OembedProxy::GoogleMapsengine do
  let(:klass) { described_class.new }

  it_behaves_like 'provider standard' do
    let(:handled_url) { 'https://mapsengine.google.com/map/view?mid=zBvxTh1R8lJI.kF0XKl5M5Z8c' }
  end

  it '.handles_url? returns true for Google Mapsengine urls' do
    dc = described_class.new
    result = dc.handles_url? 'https://mapsengine.google.com/map/view?mid=zBvxTh1R8lJI.kF0XKl5M5Z8c'
    expect(result).to eql(true)
  end

  it '.handles_url? returns true for new mapsengine url' do
    dc = described_class.new
    result = dc.handles_url? 'https://www.google.com/maps/d/edit?mid=zIa7Y2cPwITM.kA-HjKLmEEos'
    expect(result).to eql(true)
  end

  it '.get_data returns valid Google Mapsengine oembed' do
    url = 'https://mapsengine.google.com/map/view?mid=zBvxTh1R8lJI.kF0XKl5M5Z8c'

    dc = described_class.new
    result = dc.get_data url

    expect(result).to_not be_nil

    expect(result['html']).to eql('<iframe class="google-map" width="640" height="480" frameborder="0" scrolling="no" marginheight="0" marginwidth="0" src="https://mapsengine.google.com/map/embed?mid=zBvxTh1R8lJI.kF0XKl5M5Z8c"></iframe>')
    expect(result['provider_name']).to eql('Google Maps Engine')
    expect(result['provider_url']).to eql('https://mapsengine.google.com/')
    expect(result['width']).to eql(500)
    expect(result['height']).to eql(500)
  end

  it '.get_data returns nil for invalid url' do
    dc = described_class.new
    result = dc.get_data 'akjdhflkahdlfhalkjsdfh'

    expect(result).to be_nil
  end
end
