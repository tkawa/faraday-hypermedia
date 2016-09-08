require 'uri'

module URI
  class Navigation < Generic
    DEFAULT_PORT = nil
    COMPONENT = [ :scheme, :to, :query ].freeze

    def initialize(*arg)
      super(*arg)
      to, query = @opaque.split('?', 2)
      @to = to
      self.query = query
    end

    attr_reader :to

    def query=(v)
      return @query = nil unless v

      x = v.to_str
      v = x.dup if x.equal? v
      v.encode!(Encoding::UTF_8) rescue nil
      v.delete!("\t\r\n")
      v.force_encoding(Encoding::ASCII_8BIT)
      v.gsub!(/(?!%\h\h|[!$-&(-;=?-_a-~])./n.freeze){'%%%02X' % $&.ord}
      v.force_encoding(Encoding::US_ASCII)
      @query = v
    end

    def queries
      @query.split('&').map { |x| x.split(/=/, 2) }.to_h
    end

    def to_s
      "#{@scheme}:#{@to}" + (@query && !@query.empty? ? "?#{@query}" : '')
    end
  end
  @@schemes['NAVIGATION'] = Navigation
end
