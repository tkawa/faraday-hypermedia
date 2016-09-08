require 'faraday_collection_json'
require 'faraday_middleware'

module Faraday
  module Hypermedia
    class LinkExtractorCJ < FaradayCollectionJSON::ParseCollectionJSON
      def process_response(response_env)
        # TODO: collectionのlinksしか取り出していない。itemsにも存在する
        # TODO: itemsのselfがあれば取り出す
        cj = parse(response_env[:body])
        return if cj.links.empty? && cj.items.empty?
        # link_arrays = cj.links.map do |link|
        #   attrs = [['rel', link.rel]]
        #   attrs << ['title', link.name] if link.name
        #   [link.href, attrs]
        # end
        # link_value = LinkHeader.new(link_arrays).to_s
        link_values = cj.links.map { |link|
          value = %(<#{link.href}>;rel="#{link.rel}")
          value += %(;title="#{link.name}") if link.name
          value
        }
        item_values = cj.items.map { |item| %(<#{item.href}>;rel="item") if item.href }.compact
        link_header = (link_values + item_values).join(',')
        if response_env[:response_headers]['link']
          response_env[:response_headers]['link'] += ",#{link_header}"
        else
          response_env[:response_headers]['link'] = link_header
        end
      end
    end

    class LinkExtractorGithub < FaradayMiddleware::ParseJson
      def process_response(response_env)
        doc = parse(response_env[:body])
        if doc.is_a? Hash
          link_template_props, link_props = doc.select { |name, _| name.end_with?('_url') }.partition { |_, url| url =~ RE_URI_TEMPLATE }
          self_url = doc['url']
          return if link_props.empty? && self_url.nil?
          link_values = build_link_values(link_props)
          link_values.unshift(%(<#{self_url}>;rel="self")) if self_url
          item_props = doc.map { |name, c| [name, c['url']] if c.is_a?(Hash) && c['url'] }.compact
          link_values.concat build_item_link_values(item_props)
          link_template_values = build_link_values(link_template_props)
        elsif doc.is_a? Array
          # treat it as a collection
          item_props = doc.map { |d| [d['name'], d['url']] if d['url'] }.compact
          return if item_props.empty?
          link_values = build_item_link_values(item_props)
          link_template_values = []
        else
          return
        end
        link_header = link_values.join(',')
        unless link_header.empty?
          if response_env[:response_headers]['link']
            response_env[:response_headers]['link'] += ",#{link_header}"
          else
            response_env[:response_headers]['link'] = link_header
          end
        end
        link_template_header = link_template_values.join(',')
        unless link_template_header.empty?
          if response_env[:response_headers]['link-template']
            response_env[:response_headers]['link-template'] += ",#{link_template_header}"
          else
            response_env[:response_headers]['link-template'] = link_template_header
          end
        end
      end

      private

      def build_link_values(props)
        props.map { |name, url|
          rel = name.slice(0..-5) # '_url' を除いた名前
          %(<#{url}>;rel="#{rel}") if url.to_s != ''
        }.compact
      end

      def build_item_link_values(props)
        props.map { |name, url|
          %(<#{url}>;rel="item";title="#{name}") if url.to_s != ''
        }.compact
      end
    end
  end
end
