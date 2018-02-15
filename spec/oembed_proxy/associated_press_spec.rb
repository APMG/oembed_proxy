# frozen_string_literal: true

require 'oembed_proxy/associated_press'

RSpec.describe OembedProxy::AssociatedPress do
  let(:klass) { described_class.new }

  it_behaves_like 'provider standard' do
    let(:handled_url) { 'http://hosted.ap.org/interactives/2014/ebola-virus/index.html' }
  end

  it '.handles_url? returns true for Associated Press urls' do
    dc = described_class.new
    result = dc.handles_url? 'http://hosted.ap.org/interactives/2014/ebola-virus/index.html'
    expect(result).to eql(true)
  end

  it '.handles_url? returns true for Associated Press https urls' do
    dc = described_class.new
    result = dc.handles_url? 'https://hosted.ap.org/interactives/2014/ebola-virus/index.html'
    expect(result).to eql(true)
  end

  it '.get_data returns valid Associated Press oembed' do
    url = 'http://hosted.ap.org/interactives/2014/ebola-virus/index.html'

    dc = described_class.new
    result = dc.get_data url

    expect(result).to_not be_nil

    expect(result['html']).to eql('<iframe class="ap-embed" width="100%" height="600" frameborder="0" scrolling="yes" marginheight="0" marginwidth="0" src="http://hosted.ap.org/interactives/2014/ebola-virus/index.html"></iframe>')
    expect(result['provider_name']).to eql('Associated Press')
    expect(result['provider_url']).to eql('http://www.ap.org/')
    expect(result['width']).to eql(600)
    expect(result['height']).to eql(600)
  end

  it '.get_data returns valid Associated Press oembed from new style url' do
    url = 'http://interactives.ap.org/2015/2016-entering-the-race/'

    dc = described_class.new
    result = dc.get_data url

    expect(result).to_not be_nil

    expect(result['html']).to eql('<iframe class="ap-embed" width="100%" height="600" frameborder="0" scrolling="yes" marginheight="0" marginwidth="0" src="http://interactives.ap.org/2015/2016-entering-the-race/"></iframe>')
    expect(result['provider_name']).to eql('Associated Press')
    expect(result['provider_url']).to eql('http://www.ap.org/')
    expect(result['width']).to eql(600)
    expect(result['height']).to eql(600)
  end

  it '.get_data returns nil for invalid url' do
    dc = described_class.new
    result = dc.get_data 'akjdhflkahdlfhalkjsdfh'

    expect(result).to be_nil
  end
end
