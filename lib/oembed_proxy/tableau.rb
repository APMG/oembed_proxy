# frozen_string_literal: true

require 'oembed_proxy/inactive_support'

module OembedProxy
  # Tableau Fauxembed
  class Tableau
    using InactiveSupport

    TABLEAU_REGEX = %r{\Ahttps://public\.tableau\.com/(?:profile/[^/]+/vizhome|views)/([^?]+)}.freeze

    def handles_url?(url)
      !TABLEAU_REGEX.match(url).nil?
    end

    def get_data(url, _other_params = {}) # rubocop:disable Metrics/MethodLength
      return nil unless handles_url? url

      chart_id = url.match(TABLEAU_REGEX)[1]
      div_id = self.class.build_div_id(chart_id)

      {
        'type' => 'rich',
        'version' => '1.0',
        'provider_name' => 'Tableau',
        'provider_url' => 'https://tableau.com/',
        'width' => 500,
        'height' => 500,
        'html' => <<~HTML,
          <div id="#{div_id}"></div>
          <script type="text/javascript" src="https://public.tableau.com/javascripts/api/tableau-2.min.js"></script>
          <script type="text/javascript">
            (function() {
              var container = document.getElementById('#{div_id}');
              var url = 'https://public.tableau.com/views/#{chart_id}?:embed=y&:display_count=yes';
              var options = {};
              var viz = new tableau.Viz(container, url, options);
            })();
          </script>
        HTML
      }
    end

    # Make a unique div_id by slapping a random 10-digit number on the end
    def self.build_div_id(chart_id)
      chart_slug = chart_id.parameterize
      format('%<slug>s-%<rand>010d', slug: chart_slug, rand: rand(1_000_000_000))
    end
  end
end
