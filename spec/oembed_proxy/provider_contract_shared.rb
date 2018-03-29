# frozen_string_literal: true

RSpec.shared_examples 'provider standard' do
  # klass is passed by the calling spec.

  describe '#handles_url?' do
    # handled_url is passed by the calling spec.

    it 'exists' do
      expect(klass).to respond_to(:handles_url?)
    end

    it 'returns true with a handled url' do
      expect(klass.handles_url?(handled_url)).to eql(true)
    end

    it 'returns false with an unhandled URL' do
      expect(klass.handles_url?('hweksalahlahflh')).to eql(false)
    end
  end

  describe '#get_data' do
    it 'exists' do
      expect(klass).to respond_to(:get_data)
    end

    it 'includes required fields for handled url' do
      out = klass.get_data(handled_url)

      # Type required
      expect(out['type']).to_not be_nil
      expect(out['type']).to_not eq ''

      # Version required
      expect(out['version']).to_not be_nil
      expect(out['version']).to_not eq ''
    end

    it 'returns nil for unhandled url' do
      out = klass.get_data('sjflsjflsjfljslfjslllslls')

      expect(out).to be_nil
    end
  end
end
