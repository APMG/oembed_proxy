# frozen_string_literal: true

require 'oembed_proxy/tableau'

RSpec.describe OembedProxy::Tableau do
  let(:klass) { OembedProxy::Tableau.new }
  it_behaves_like 'provider standard' do
    let(:handled_url) { 'https://public.tableau.com/views/LaborForceParticipationRateByAgeMN/Sheet1' }
  end

  let(:simple_url) { 'https://public.tableau.com/views/LaborForceParticipationRateByAgeMN/Sheet1' }

  let(:simple_url_with_args) { 'https://public.tableau.com/views/SupplementalPovertyMeasureImpactofProgramsandExpenses2016/Sheet1?:embed=y&:embed_code_version=3&:loadOrderID=1&:display_count=yes&publish=yes' }

  let(:profile_url) { 'https://public.tableau.com/profile/andi.egbert3857#!/vizhome/SupplementalPovertyMeasureImpactofProgramsandExpenses2016/Sheet1' }

  describe '#handles_url?' do
    it 'returns true for a simple Tableau URL' do
      dc = OembedProxy::Tableau.new
      result = dc.handles_url?(simple_url)
      expect(result).to eql(true)
    end

    it 'returns true for a simple Tableau URL with arguments' do
      dc = OembedProxy::Tableau.new
      result = dc.handles_url?(simple_url_with_args)
      expect(result).to eql(true)
    end

    it 'returns true for a profile URL' do
      dc = OembedProxy::Tableau.new
      result = dc.handles_url?(profile_url)
      expect(result).to eql(true)
    end
  end

  describe '#get_data' do
    # Note the \1 in the 5th line of the regex. We want to make sure it
    # matches the ID captured in line 1 exactly.
    let(:participation_rate_regex) { <<~'PART_RATE' }
      <div id="(laborforceparticipationratebyagemn-sheet1-\d{10})"></div>
      <script type="text/javascript" src="https://public.tableau.com/javascripts/api/tableau-2.min.js"></script>
      <script type="text/javascript">
        \(function\(\) {
          var container = document.getElementById\('\1'\);
          var url = 'https://public.tableau.com/views/LaborForceParticipationRateByAgeMN/Sheet1\?:embed=y&:display_count=yes';
          var options = {};
          var viz = new tableau.Viz\(container, url, options\);
        }\)\(\);
      </script>
    PART_RATE

    let(:poverty_measure_regex) { <<~'POVERTY_MEASURE' }
      <div id="(supplementalpovertymeasureimpactofprogramsandexpenses2016-sheet1-\d{10})"></div>
      <script type="text/javascript" src="https://public.tableau.com/javascripts/api/tableau-2.min.js"></script>
      <script type="text/javascript">
        \(function\(\) {
          var container = document.getElementById\('\1'\);
          var url = 'https://public.tableau.com/views/SupplementalPovertyMeasureImpactofProgramsandExpenses2016/Sheet1\?:embed=y&:display_count=yes';
          var options = {};
          var viz = new tableau.Viz\(container, url, options\);
        }\)\(\);
      </script>
    POVERTY_MEASURE

    it 'creates an oembed for a simple Tableau URL' do
      dc = OembedProxy::Tableau.new
      result = dc.get_data(simple_url)

      expect(result).to_not be_nil

      expect(result['html']).to match(Regexp.new(participation_rate_regex))
      expect(result['provider_name']).to eql('Tableau')
      expect(result['provider_url']).to eql('https://tableau.com/')
      expect(result['width']).to eql(500)
      expect(result['height']).to eql(500)
    end

    it 'creates an oembed for a simple Tableau URL with arguments' do
      dc = OembedProxy::Tableau.new
      result = dc.get_data(simple_url_with_args)

      expect(result).to_not be_nil

      expect(result['html']).to match(Regexp.new(poverty_measure_regex))
      expect(result['provider_name']).to eql('Tableau')
      expect(result['provider_url']).to eql('https://tableau.com/')
      expect(result['width']).to eql(500)
      expect(result['height']).to eql(500)
    end

    it 'creates an oembed for a profile URL' do
      dc = OembedProxy::Tableau.new
      result = dc.get_data(profile_url)

      expect(result).to_not be_nil

      expect(result['html']).to match(Regexp.new(poverty_measure_regex))
      expect(result['provider_name']).to eql('Tableau')
      expect(result['provider_url']).to eql('https://tableau.com/')
      expect(result['width']).to eql(500)
      expect(result['height']).to eql(500)
    end

    it 'returns nil for invalid url' do
      dc = OembedProxy::Tableau.new
      result = dc.get_data 'akjdhflkahdlfhalkjsdfh'

      expect(result).to be_nil
    end
  end
end
