module Faraday
  module Hypermedia
    class Navigation < Middleware
      attr_reader :history

      def initialize(app, history = nil, options = {})
        super(app)
        puts 'Navigation Enabled!'
        @history = history || History.new
        # state = self
        # connection.define_singleton_method(:history) do
        #   state.history
        # end
      end

      def call(request_env)
        # request
        url = request_env[:url]
        if url.scheme == 'navigation'
          case url.to
          when 'back'
            @history.back
            request_env[:url] = @history.current_state.url
          when 'forward'
            @history.forward
            request_env[:url] = @history.current_state.url
          when 'go'
            # TODO
          when /\Alink(?:\((\d+)\))?\z/ # link or link(index)
            index = (Regexp.last_match(1) || 1).to_i # one origin
            matched_links = @history.current_links
            unless url.queries.empty?
              attr_name, attr_value = url.queries.first # TODO: multiple
              matched_links = matched_links.select { |_ ,v| v[attr_name] && v[attr_name].include?(attr_value) } # TODO: multiple
            end
            raise 'cannot find link' if matched_links.empty?
            matched_url = matched_links.to_a[index - 1].first
            matched_url = URITemplate.new(matched_url).expand if matched_url =~ RE_URI_TEMPLATE
            request_env[:url] = URI(matched_url)
          else
            raise "cannot use #{url.to}"
          end
        end

        # response
        @app.call(request_env).on_complete do |response_env|
          @history.push response_env
        end
      end
    end
  end
end
