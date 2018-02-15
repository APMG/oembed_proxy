# frozen_string_literal: true

require 'oembed_proxy/handler'

RSpec.describe OembedProxy::Handler do
  it 'composes multiple providers' do
    handler = described_class.new
    handler.register double('Provider1', get_data: 'data1', handles_url?: false)
    handler.register double('Provider2', get_data: 'data2', handles_url?: true)

    expect(handler.handles_url?('test')).to eq true
    expect(handler.get_data('test')).to eq 'data2'
  end

  it 'works with a single provider' do
    handler = described_class.new
    handler.register double('Provider1', get_data: 'data1', handles_url?: true)

    expect(handler.handles_url?('test')).to eq true
    expect(handler.get_data('test')).to eq 'data1'
  end

  it 'fails gracefully' do
    handler = described_class.new
    handler.register double('Provider1', get_data: 'data1', handles_url?: false)

    expect(handler.handles_url?('test')).to eq false
    expect(handler.get_data('test')).to eq nil
  end

  it 'composes via constructor multiple providers' do
    handler = described_class.new(
      double('Provider1', get_data: 'data1', handles_url?: false),
      double('Provider2', get_data: 'data2', handles_url?: true)
    )

    expect(handler.handles_url?('test')).to eq true
    expect(handler.get_data('test')).to eq 'data2'
  end
end
