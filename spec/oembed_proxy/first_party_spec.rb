# frozen_string_literal: true

require 'oembed_proxy/first_party'

RSpec.describe OembedProxy::FirstParty do
  describe '#handles_url?' do
    it 'returns false for nil argument' do
      fp = described_class.new
      expect(fp.handles_url?(nil)).to eql(false)
    end

    it 'returns false for unhandled url' do
      fp = described_class.new
      expect(fp.handles_url?('http://example.com')).to eql(false)
    end

    it 'returns false for non-string argument' do
      fp = described_class.new
      expect(fp.handles_url?(:'https://www.youtube.com/watch?v=9jK-NcRmVcw')).to eql(true)
    end
  end

  describe '#get_data' do
    def test_error_states(code, message)
      error_url = "https://www.youtube.com/watch?v=#{code}"
      stub_request(:get, "https://www.youtube.com/oembed?format=json&url=https://www.youtube.com/watch?v=#{code}").to_return(status: code, body: '', headers: {})

      fp = described_class.new
      expect { fp.get_data(error_url) }.to raise_error(OembedProxy::OembedException, message)
    end

    it 'raises an error for upstream error codes' do
      test_error_states(400, '400 Bad Request')
      test_error_states(401, '401 Unauthorized')
      test_error_states(403, '403 Forbidden')
      test_error_states(404, '404 Not Found')
      test_error_states(500, '500 Internal Server Error')
      test_error_states(501, '501 Not Implemented')
      test_error_states(503, '503 Service Unavailable')
      test_error_states(560, 'Unknown response: Net::HTTPServerError')
    end

    it 'returns nil for invalid json response' do
      error_url = 'https://www.youtube.com/watch?v=200'
      stub_request(:get, 'https://www.youtube.com/oembed?format=json&url=https://www.youtube.com/watch?v=200').to_return(status: 200, body: 'akljdfhlkjkasdfkhkskskk kskfkhksf kskkkk;kfhks;skfkk()', headers: {})

      fp = described_class.new
      expect(fp.get_data(error_url)).to be_nil
    end

    context 'when the first-party API call redirects' do
      let(:embed_url) { 'https://open.spotify.com/album/redirect_ohno' }
      let(:final_url) { 'https://embed.spotify.com/oembed?format=json&url=https://open.spotify.com/album/0R7CaOFFuPynpABahVNaMs' }
      let(:redirected_url) { 'https://embed.spotify.com/oembed?format=json&url=https://open.spotify.com/album/redirect_ohno' }

      before :each do
        stub_request(:get, final_url).to_return(status: 200, body: fixture('spotify/album-0R7CaOFFuPynpABahVNaMs.json'), headers: {})
      end

      it 'follows fully-qualified redirects' do
        stub_request(:get, redirected_url).to_return(status: 301, body: final_url, headers: { 'location' => final_url })

        fp = described_class.new
        data = fp.get_data(embed_url)
        expect(data['title']).to eq('Land Speed Record')
      end

      it 'follows 308 redirects' do
        stub_request(:get, redirected_url).to_return(status: 308, body: final_url, headers: { 'location' => final_url })

        fp = described_class.new
        data = fp.get_data(embed_url)
        expect(data['title']).to eq('Land Speed Record')
      end

      it 'follows relative redirects with a slash' do
        stub_request(:get, redirected_url).to_return(status: 301, body: final_url, headers: { 'location' => '/oembed?format=json&url=https://open.spotify.com/album/0R7CaOFFuPynpABahVNaMs' })

        fp = described_class.new
        data = fp.get_data(embed_url)
        expect(data['title']).to eq('Land Speed Record')
      end

      it 'follows relative redirects without a slash' do
        stub_request(:get, 'https://embed.spotify.com/other/path').to_return(status: 200, body: fixture('spotify/album-0R7CaOFFuPynpABahVNaMs.json'), headers: {})
        stub_request(:get, redirected_url).to_return(status: 301, body: final_url, headers: { 'location' => 'other/path' })

        fp = described_class.new
        data = fp.get_data(embed_url)
        expect(data['title']).to eq('Land Speed Record')
      end
    end
  end

  context 'YouTube' do
    before :each do
      stub_request(:get, 'https://www.youtube.com/oembed?format=json&url=https://www.youtube.com/watch?v=9jK-NcRmVcw')
        .to_return(status: 200, body: fixture('youtube/9jK-NcRmVcw.json'), headers: {})
    end

    it_behaves_like 'provider standard' do
      let(:handled_url) { 'https://www.youtube.com/watch?v=9jK-NcRmVcw' }
      let(:klass) { described_class.new }
    end

    describe '#handles_url?' do
      it 'returns true for https' do
        fp = described_class.new
        expect(fp.handles_url?('https://www.youtube.com/watch?v=9jK-NcRmVcw')).to eql(true)
      end

      it 'returns true for https short url' do
        fp = described_class.new
        expect(fp.handles_url?('https://youtu.be/_c4OgOb7S80')).to eql(true)
      end

      it 'returns true for https playlist' do
        fp = described_class.new
        expect(fp.handles_url?('https://www.youtube.com/playlist?list=PL8ufCCC-rPcvlfFE7SfPYHVI_YSzVuE0j')).to eql(true)
      end

      it 'returns true for http' do
        fp = described_class.new
        expect(fp.handles_url?('http://www.youtube.com/watch?v=Nk_zpMory-0')).to eql(true)
      end
    end

    describe '#get_data' do
      it 'returns expected embed' do
        fp = described_class.new

        expected_hash = { 'type' => 'video', 'thumbnail_url' => 'https://i.ytimg.com/vi/9jK-NcRmVcw/hqdefault.jpg', 'title' => 'Europe - The Final Countdown (Official Video)', 'html' => '<iframe width="459" height="344" src="https://www.youtube.com/embed/9jK-NcRmVcw?feature=oembed" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>', 'width' => 459, 'version' => '1.0', 'thumbnail_width' => 480, 'author_url' => 'https://www.youtube.com/user/EuropeVEVO', 'thumbnail_height' => 360, 'height' => 344, 'provider_name' => 'YouTube', 'author_name' => 'EuropeVEVO', 'provider_url' => 'https://www.youtube.com/' }

        values = fp.get_data('https://www.youtube.com/watch?v=9jK-NcRmVcw')

        # Test each key, so if something changes it is clearer.
        expected_hash.each do |key, value|
          expect(values[key]).to eql(value)
        end

        # Test the whole hash to see if anything has been added or changed.
        expect(values).to eql(expected_hash)
      end

      it 'returns expected embed with maxwidth and maxheight' do
        stub_request(:get, 'https://www.youtube.com/oembed?format=json&maxheight=30&maxwidth=20&url=https://www.youtube.com/watch?v=9jK-NcRmVcw')
          .to_return(status: 200, body: fixture('youtube/9jK-NcRmVcw-30x30.json'), headers: {})

        fp = described_class.new

        expected_hash = { 'type' => 'video', 'thumbnail_url' => 'https://i.ytimg.com/vi/9jK-NcRmVcw/hqdefault.jpg', 'title' => 'Europe - The Final Countdown (Official Video)', 'html' => '<iframe width="200" height="150" src="https://www.youtube.com/embed/9jK-NcRmVcw?feature=oembed" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>', 'width' => 200, 'version' => '1.0', 'thumbnail_width' => 480, 'author_url' => 'https://www.youtube.com/user/EuropeVEVO', 'thumbnail_height' => 360, 'height' => 150, 'provider_name' => 'YouTube', 'author_name' => 'EuropeVEVO', 'provider_url' => 'https://www.youtube.com/' }

        values = fp.get_data('https://www.youtube.com/watch?v=9jK-NcRmVcw', maxwidth: 20, maxheight: 30)

        # Test each key, so if something changes it is clearer.
        expected_hash.each do |key, value|
          expect(values[key]).to eql(value)
        end

        # Test the whole hash to see if anything has been added or changed.
        expect(values).to eql(expected_hash)
      end
    end
  end

  context 'Spotify' do
    describe '#get_data' do
      it 'returns odd case' do
        stub_request(:get, 'https://embed.spotify.com/oembed?format=json&url=https://open.spotify.com/album/0R7CaOFFuPynpABahVNaMs')
          .to_return(status: 200, body: fixture('spotify/album-0R7CaOFFuPynpABahVNaMs.json'), headers: {})

        fp = described_class.new

        expected_hash = { 'type' => 'rich', 'thumbnail_url' => 'https://i.scdn.co/image/bd0164310f51645e2df1f33281b194aaec539d13', 'title' => 'Land Speed Record', 'html' => '<iframe src="https://open.spotify.com/embed/album/0R7CaOFFuPynpABahVNaMs" width="300" height="380" frameborder="0" allowtransparency="true"></iframe>', 'width' => 300, 'version' => '1.0', 'thumbnail_width' => 300, 'thumbnail_height' => 300, 'height' => 380, 'provider_name' => 'Spotify', 'provider_url' => 'https://www.spotify.com' }

        values = fp.get_data('https://open.spotify.com/album/0R7CaOFFuPynpABahVNaMs')

        # Test each key, so if something changes it is clearer.
        expected_hash.each do |key, value|
          expect(values[key]).to eql(value)
        end

        # Test the whole hash to see if anything has been added or changed.
        expect(values).to eql(expected_hash)
      end
    end
  end

  context 'Instagram' do
    describe '#handles_url?' do
      it 'returns true for http URL' do
        url = 'http://instagram.com/p/2JKROVoZpO/'
        fp = described_class.new
        expect(fp.handles_url?(url)).to eql(true)
      end

      it 'returns true for https URL' do
        url = 'https://instagram.com/p/2JKROVoZpO/'
        fp = described_class.new
        expect(fp.handles_url?(url)).to eql(true)
      end

      it 'returns true for www URL' do
        url = 'https://www.instagram.com/p/2JKROVoZpO/'
        fp = described_class.new
        expect(fp.handles_url?(url)).to eql(true)
      end
    end

    describe '#get_data' do
      it 'returns rich type' do
        # If we define the ?beta=true flag for instagram, they return a rich type.
        stub_request(:get, 'https://api.instagram.com/oembed?beta=true&format=json&url=http://instagram.com/p/viyEC5IZr4/')
          .to_return(status: 200, body: fixture('instagram/viyEC5IZr4.json'), headers: {})

        fp = described_class.new

        values = fp.get_data('http://instagram.com/p/viyEC5IZr4/')

        expect(values['type']).to eql('rich')
        expect(values['html']).to_not be_empty
      end
    end
  end

  context 'Facebook' do
    describe '#handles_url?' do
      it 'returns true for video URLs' do
        fp = described_class.new
        expect(fp.handles_url?('https://www.facebook.com/video.php?v=918613058159587')).to eql(true)
        expect(fp.handles_url?('https://www.facebook.com/LivefromHereAPM/videos/2431224630485642/')).to eql(true)
      end

      it 'returns true for post URLs' do
        fp = described_class.new
        expect(fp.handles_url?('https://www.facebook.com/TheCurrent/posts/10156676903452657')).to eql(true)
      end
    end

    describe '#get_data' do
      it 'returns expected embed for video' do
        stub_request(:get, 'https://www.facebook.com/plugins/video/oembed.json?format=json&url=https://www.facebook.com/LivefromHereAPM/videos/2431224630485642/').to_return(status: 200, body: fixture('facebook/video_2431224630485642.json'), headers: {})

        fp = described_class.new
        values = fp.get_data('https://www.facebook.com/LivefromHereAPM/videos/2431224630485642/')
        expected_hash = {
          'author_name' => 'Live from Here',
          'author_url' => 'https://www.facebook.com/LivefromHereAPM/',
          'height' => 280,
          'html' => "<div id=\"fb-root\"></div>\n<script async=\"1\" defer=\"1\" crossorigin=\"anonymous\" src=\"https://connect.facebook.net/en_US/sdk.js#xfbml=1&amp;version=v6.0\"></script><div class=\"fb-video\" data-href=\"https://www.facebook.com/LivefromHereAPM/videos/2431224630485642/\"><blockquote cite=\"https://www.facebook.com/LivefromHereAPM/videos/2431224630485642/\" class=\"fb-xfbml-parse-ignore\"><a href=\"https://www.facebook.com/LivefromHereAPM/videos/2431224630485642/\">The Origin of &quot;Ahoy!&quot;</a><p>Where did Chris&#039;s weekly call-and-response greeting come from? \n&quot;Ahoy!&quot; actually predates our radio show...</p>Posted by <a href=\"https://www.facebook.com/LivefromHereAPM/\">Live from Here</a> on Friday, October 11, 2019</blockquote></div>",
          'provider_name' => 'Facebook',
          'provider_url' => 'https://www.facebook.com',
          'success' => true,
          'type' => 'video',
          'url' => 'https://www.facebook.com/LivefromHereAPM/videos/2431224630485642/',
          'version' => '1.0',
          'width' => 500,
        }
        expect(values).to eql(expected_hash)
      end
    end
  end

  context 'DocumentCloud' do
    describe '#handles_url?' do
      it 'handles DocumentCloud URL' do
        url = 'https://www.documentcloud.org/documents/3901810-07242017-Minn-BCA-search-warrant-for-area.html'
        fp = described_class.new
        expect(fp.handles_url?(url)).to eql(true)
      end
    end

    describe '#get_data' do
      it 'returns expected embed' do
        stub_request(:get, 'https://www.documentcloud.org/api/oembed.json?format=json&url=https://www.documentcloud.org/documents/3901810-07242017-Minn-BCA-search-warrant-for-area.html')
          .to_return(status: 200, body: fixture('documentcloud/3901810-07242017-Minn-BCA-search-warrant-for-area.json'), headers: {})

        fp = described_class.new

        values = fp.get_data('https://www.documentcloud.org/documents/3901810-07242017-Minn-BCA-search-warrant-for-area.html')
        expected_hash = {
          'type' => 'rich',
          'html' => '<div class="DC-embed DC-embed-document DV-container"> <div style="position:relative;padding-bottom:129.42857142857142%;height:0;overflow:hidden;max-width:100%;"> <iframe src="//www.documentcloud.org/documents/3901810-07242017-Minn-BCA-search-warrant-for-area.html?embed=true&amp;responsive=false&amp;sidebar=false" title="07242017 Minn BCA search warrant for area (Hosted by DocumentCloud)" sandbox="allow-scripts allow-same-origin allow-popups allow-forms" frameborder="0" style="position:absolute;top:0;left:0;width:100%;height:100%;border:1px solid #aaa;border-bottom:0;box-sizing:border-box;"></iframe> </div> </div>',
          'width' => 700,
          'version' => '1.0',
          'height' => 906,
          'provider_name' => 'DocumentCloud',
          'provider_url' => 'https://www.documentcloud.org',
          'cache_age' => 300,
        }
        expect(values).to eql(expected_hash)
      end
    end
  end
end
