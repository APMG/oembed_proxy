# frozen_string_literal: true

require 'oembed_proxy/npr'

RSpec.describe OembedProxy::Npr do
  let(:klass) { OembedProxy::Npr.new }
  it_behaves_like 'provider standard' do
    let(:handled_url) { 'https://apps.npr.org/liveblogs/20200203-iowa/embed.html' }
  end

  let(:simple_url) { 'https://apps.npr.org/liveblogs/20200203-iowa/embed.html' }



  describe '#handles_url?' do
    it 'returns true for a simple Npr URL' do
      dc = OembedProxy::Npr.new
      result = dc.handles_url?(simple_url)
      expect(result).to eql(true)
    end
  end

  describe '#get_data' do
    # Note the \1 in the 5th line of the regex. We want to make sure it
    # matches the ID captured in line 1 exactly.
    let(:embed) do
      <<~EMBED
        <div class='sidechain-wrapper'>
          <side-chain src="#{simple_url}"></side-chain>
        </div>
      EMBED
    end

    it 'creates an oembed for a simple Npr URL' do
      dc = OembedProxy::Npr.new
      result = dc.get_data(simple_url)

      expect(result).to_not be_nil

      expect(result['html']).to eql(embed)
      expect(result['provider_name']).to eql('NPR')
      expect(result['provider_url']).to eql('https://www.npr.org/')
    end

    it 'returns nil for invalid url' do
      dc = OembedProxy::Npr.new
      result = dc.get_data 'akjdhflkahdlfhalkjsdfh'

      expect(result).to be_nil
    end
  end
end
