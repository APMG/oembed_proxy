# frozen_string_literal: true

require 'oembed_proxy/embedly'

RSpec.describe OembedProxy::Embedly do
  let(:api_key) { '1234567' }
  let(:klass) { described_class.new(api_key) }

  before :each do
    stub_request(:get, 'https://api.embed.ly/1/oembed?format=json&key=1234567&url=https://maps.google.com/maps/ms?msid=214867082919963799901.0004bf28aee35e475fe57%26msa=0')
      .to_return(status: 200, body: fixture('embedly/google_maps/214867082919963799901.json'), headers: {})
  end

  it_behaves_like 'provider standard' do
    let(:handled_url) { 'https://foursquare.com/v/minnesota-public-radio--american-public-media/4ae5ae75f964a5206aa121e3' }
    before :each do
      stub_request(:get, 'https://api.embed.ly/1/oembed?format=json&key=1234567&url=https://foursquare.com/v/minnesota-public-radio--american-public-media/4ae5ae75f964a5206aa121e3')
        .to_return(status: 200, body: fixture('embedly/foursquare/mpr.json'), headers: {})
    end
  end

  it '.handles_url? google maps short code' do
    ebdly = described_class.new(api_key)
    expect(ebdly.handles_url?('http://goo.gl/maps/F0fc2')).to eql(true)
    expect(ebdly.handles_url?('https://goo.gl/maps/F0fc2')).to eql(true)
  end

  it '.handles_url? google maps long url' do
    url = 'https://www.google.com/maps/place/Dodd+Rd+%26+Smith+Ave+S,+West+St+Paul,+MN+55118/@44.9161109,-93.1017871,17z/data=!3m1!4b1!4m2!3m1!1s0x87f62b2bf353ff1f:0xfce33e5f2b7438b6'
    ebdly = described_class.new(api_key)
    expect(ebdly.handles_url?(url)).to eql(true)
  end

  it '.handles_url? new Facebook video URL' do
    url = 'https://www.facebook.com/video.php?v=918613058159587'
    ebdly = described_class.new(api_key)
    expect(ebdly.handles_url?(url)).to eql(true)
  end

  it '.get_data handles Google Maps' do
    json = '{"provider_url": "http://google.com/maps", "description": "Tornado Simulation Tornado Warning Track", "title": "Tornado Simulation Tornado Warning Track", "thumbnail_width": 504, "height": 450, "width": 600, "html": "<iframe class=\"embedly-embed\" src=\"//cdn.embedly.com/widgets/media.html?src=https%3A%2F%2Fwww.google.com%2Fmaps%2Fd%2Fembed%3Fmid%3D11YCN4-pcX1wLjPeT81JQm1-QbP8%26hl%3Den_US&url=https%3A%2F%2Fwww.google.com%2Fmaps%2Fd%2Fviewer%3Fmid%3D11YCN4-pcX1wLjPeT81JQm1-QbP8%26hl%3Den_US&image=https%3A%2F%2Fwww.google.com%2Fmaps%2Fd%2Fthumbnail%3Fmid%3D11YCN4-pcX1wLjPeT81JQm1-QbP8%26hl%3Den_US&key=947137f52db64271b6e122909bac3123&type=text%2Fhtml&schema=google\" width=\"600\" height=\"450\" scrolling=\"no\" frameborder=\"0\" allowfullscreen></iframe>", "version": "1.0", "provider_name": "Google Maps", "thumbnail_url": "https://www.google.com/maps/d/thumbnail?mid=11YCN4-pcX1wLjPeT81JQm1-QbP8&hl=en_US", "type": "rich", "thumbnail_height": 520}'

    emly = described_class.new(api_key)

    expected_hash = JSON[json]

    values = emly.get_data('https://maps.google.com/maps/ms?msid=214867082919963799901.0004bf28aee35e475fe57&msa=0')

    # Test each key, so if something changes it is clearer.
    expected_hash.each do |key, value|
      expect(values[key]).to eql(value)
    end

    # Test the whole hash to see if anything has been added or changed.
    expect(values).to eql(expected_hash)
  end

  it '.get_data handles upstream errors' do
    test_error_states 400, '400 Bad Request'
    test_error_states 401, '401 Unauthorized'
    test_error_states 403, '403 Forbidden'
    test_error_states 404, '404 Not Found'
    test_error_states 500, '500 Internal Server Error'
    test_error_states 501, '501 Not Implemented'
    test_error_states 503, '503 Service Unavailable'
  end

  def test_error_states(code, message)
    error_url = "https://foursquare.com/v/#{code}"
    stub_request(:get, "https://api.embed.ly/1/oembed?format=json&key=#{api_key}&url=https://foursquare.com/v/#{code}").to_return(status: code, body: '', headers: {})

    emly = described_class.new(api_key)
    expect { emly.get_data(error_url) }.to raise_error(OembedProxy::OembedException, message)
  end
end
