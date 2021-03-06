require 'socket'
require 'ipaddr'

module Huemote
  class Bridge
    DEVICE_TYPE = "Huemote"
    GOOGLE_IP   = "64.233.187.99"
    USERNAME    = "HuemoteRubyGem"

    class << self
      def set_ip(ip)
        @static_ip = ip
      end

      def get
        @bridge ||= begin
          if @static_ip
            client = Huemote::Client.new
            body = client.get("http://#{@static_ip}:80/description.xml").body
            self.new(@static_ip,80,body)
          else
            discover
          end
        end
      end

      private

      def discover
        client  = Huemote::Client.new
        ip = UDPSocket.open {|s| s.connect(GOOGLE_IP, 1); s.addr.last}
        device = `nmap -sP #{ip.split('.')[0..-2].join('.')}.* > /dev/null && arp -na | grep 0:17:88`.split("\n")[0]
        host = /\((\d+\.\d+\.\d+\.\d+)\)/.match(device)[1]

        body = client.get("http://#{host}:80/description.xml").body

        @bridge = self.new(host,80,body)
      end
    end

    attr_accessor :name

    def initialize(host,port,body)
      @host, @port = host, port
      @name = body.match(/<friendlyName>([^<]+)<\/friendlyName>/)[1]
    end

    def _get(path,params={})
      request(:get,path,params)
    end

    def _post(path,params={})
      request(:post,path,params)
    end

    def _put(path,params={})
      request(:put,path,params)
    end

    private

    def request(method,path,params)
      auth! unless authed?
      JSON.parse(client.send(method,"#{base_url}/api/#{USERNAME}/#{path}",params.to_json).body)
    end

    def base_url
      @base_url ||= "http://#{@host}:#{@port}"
    end

    def authed?
      @authed ||= !client.get("#{base_url}/api/#{USERNAME}/lights").body.match('unauthorized user')
    end

    def auth!
      unless authed?
        body = client.post("#{base_url}/api",{devicetype:DEVICE_TYPE,username:USERNAME}.to_json).body
        if body.match('link button not pressed')
          puts "In order for the Hue Bridge to interact, please press the button just this once and try again."
          false
        end
      end
    end

    def client
      @client ||= Huemote::Client.new
    end

  end
end
