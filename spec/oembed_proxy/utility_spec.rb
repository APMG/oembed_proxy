# frozen_string_literal: true

require 'oembed_proxy/utility'

RSpec.describe OembedProxy::Utility do
  it '.clean_pattern converts php edge case regex to ruby regex' do
    expect(OembedProxy::Utility.clean_pattern('#http://.*viddler\.com/v/.*#i')).to eql('http://.*viddler\\.com/v/.*')
    expect(OembedProxy::Utility.clean_pattern('#http://.*viddler\.com/v/.*#i  ')).to eql('http://.*viddler\\.com/v/.*')
    expect(OembedProxy::Utility.clean_pattern('http://.*viddler\.com/v/.*')).to eql('http://.*viddler\\.com/v/.*')
    expect(OembedProxy::Utility.clean_pattern('http://.*viddler\.com/v/.*  ')).to eql('http://.*viddler\\.com/v/.*')
  end
end
