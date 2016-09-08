require 'faraday'
require 'faraday/hypermedia/history'
require 'faraday/hypermedia/link_extractor'
require 'faraday/hypermedia/navigation'
require 'faraday/hypermedia/version'
require_relative '../uri/navigation'

module Faraday
  module Hypermedia
    RE_URI_TEMPLATE = /\{.*\}/
  end

  Middleware.register_middleware navigation: Hypermedia::Navigation
  Response.register_middleware link_cj: Hypermedia::LinkExtractorCJ
  Response.register_middleware link_github: Hypermedia::LinkExtractorGithub

end
