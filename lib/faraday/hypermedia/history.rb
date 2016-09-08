require 'http_link_header'
require 'uri_template'

module Faraday
  module Hypermedia
    class History
      State = Struct.new(:data, :title, :url)

      def initialize
        @stored_states = [build_state]
        @current_index = 0
        reset_current_links
      end

      def current_state
        @stored_states[@current_index]
      end

      # いったんここに実装
      def current_links
        @current_links ||= build_current_links
      end

      def pp_current_links
        # TODO: きれいにする
        # current_links.to_a.join("#{current_links.class::DELIMETER}\n")
        rels = current_links.map{|url, params| params['rel'].to_a.map{|rel| [rel, [url, params]] }}.flatten(1).group_by{|rel, _| rel}
        rels.each do |rel, links|
          puts("rel=#{rel}")
          if links.length >= 2
            links.each.with_index(1) do |(_, link), i|
              url, params = link
              params = params.dup
              params.delete('rel')
              print(" (#{i}) <#{url}>")
              print(" (#{params})") unless params.empty?
              puts
            end
          else
            url, params = links.first.last
            params = params.dup
            params.delete('rel')
            print(" <#{url}>")
            print(" (#{params})") unless params.empty?
            puts
          end
        end
        nil
      end

      def fill_in_template_params(template_params)
        template_urls = current_links.keys.select { |k| k =~ RE_URI_TEMPLATE }
        template_urls.each do |template_url|
          expanded_url = URITemplate.new(template_url).expand(template_params) # Addressable のほうが良いかも
          link_params = current_links.delete(template_url)
          current_links.store(expanded_url, link_params)
        end
      end

      def reset_current_links
        @current_links = nil
      end

      def push_state(data, title, url)
        if url == current_state.url
          replace_state(data, title, url)
        else
          @stored_states.slice!((@current_index+1)..-1) # current_index の先から最後まで削除
          state = build_state(data: data, title: title, url: url)
          @stored_states.push(state)
          @current_index += 1
          reset_current_links
          state
        end
      end

      def replace_state(data, title, url)
        reset_current_links
        @stored_states[@current_index] = build_state(data: data, title: title, url: url)
      end

      def push(response_env)
        url = response_env[:url]
        push_state(response_env, '', url)
      end

      def back
        if @current_index >= 1
          @current_index -= 1
          reset_current_links
        end
      end

      def forward
        if @current_index < @stored_states.length - 1
          @current_index += 1
          reset_current_links
        end
      end

      private

      def build_state(source = {})
        State.new(
          source[:data]  || {},
          source[:title] || '',
          source[:url]   || URI('navigation:blank')
        )
      end

      def build_current_links
        current_response_headers = current_state.data[:response_headers]
        return HttpLinkHeader.new unless current_response_headers
        links = current_response_headers['link'].to_s.scan(/<[^>]*>[^,]*/)
        link_templates = current_response_headers['link-template'].to_s.scan(/<[^>]*>[^,]*/) # 自前でsplitする
        HttpLinkHeader.new(links + link_templates)
      end
    end
  end
end
