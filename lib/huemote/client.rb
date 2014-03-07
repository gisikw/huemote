module Huemote
  class Client

    def self.technique
      @technique ||= begin
        constants.collect {|const_name| const_get(const_name)}.select {|const| const.class == Module}.detect do |mod|
          fulfilled = false
          begin
            mod.const_get(:DEPENDENCIES).map{|d|require d}
            fulfilled = true
          rescue LoadError
          end
          fulfilled
        end
      end
    end

    module Manticore
      DEPENDENCIES = ['manticore']

      %w{get post put}.each do |name|
        define_method name do |*args|
          _req(::Manticore,name,*args).call
        end
      end

    end

    module Typhoeus
      DEPENDENCIES = ['typhoeus']

      %w{get post put}.each do |name|
        define_method name do |*args|
          _req(::Typhoeus,name,*args)
        end
      end

    end

    module HTTParty
      DEPENDENCIES = ['httparty']

      %w{get post put}.each do |name|
        define_method name do |*args|
          _req(::HTTParty,name,*args)
        end
      end

    end

    module NetHTTP
      DEPENDENCIES = ['net/http','uri']

      def get(url,body=nil,headers=nil)
        request(Net::HTTP::Get,url,body,headers)
      end

      def post(url,body=nil,headers=nil)
        request(Net::HTTP::Post,url,body,headers)
      end

      def put(url,body=nil,headers=nil)
        request(Net::HTTP::Put,url,body,headers)
      end

      def request(klass,url,body,headers)
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        request = klass.new(uri.request_uri)
        headers.map{|k,v|request[k]=v} if headers
        (request.body = body) if body
        response = http.request(request)
      end

    end

    def initialize
      extend Huemote::Client.technique
    end

    private

    def _req(lib,method,url,body=nil,headers=nil)
      lib.send(method,url,{body:body,headers:headers})
    end

  end
end
