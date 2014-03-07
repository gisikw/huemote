require 'socket'
require 'ipaddr'

module Huemote
  class Bridge
    DEVICE_TYPE = "Huemote"
    USERNAME = "HuemoteRubyGem"
    MULTICAST_ADDR = '239.255.255.250'
    BIND_ADDR = '0.0.0.0'
    PORT = 1900
    DISCOVERY= <<-EOF
M-SEARCH * HTTP/1.1\r
HOST: 239.255.255.250:1900\r
MAN: "ssdp:discover"\r
MX: 10\r
ST: urn:schemas-upnp-org:device:Basic:1\r
\r
EOF

    class << self
      def get
        @bridge ||= begin
          client = Huemote::Client.new
          body = nil
          device = fetch_upnp.detect{|host,port|body = client.get("http://#{host}:#{port}/description.xml").body; body.match('<modelURL>http://www.meethue.com</modelURL>')}
          self.new(*device,body)
        end
      end

      def discover(socket = nil)
        @bridge = nil
        client  = Huemote::Client.new
        body    = nil

        devices, socket = fetch_upnp(true,socket)
        device = devices.detect{|host,port|body = client.get("http://#{host}:#{port}/description.xml").body; body.match('<modelURL>http://www.meethue.com</modelURL>')}
        @bridge = self.new(*device,body)

        socket
      end

      private

      def ssdp_socket
        socket = UDPSocket.new
        socket.setsockopt(Socket::IPPROTO_IP, Socket::IP_ADD_MEMBERSHIP, IPAddr.new(MULTICAST_ADDR).hton + IPAddr.new(BIND_ADDR).hton)
        socket.setsockopt(Socket::IPPROTO_IP, Socket::IP_MULTICAST_TTL, 1)
        socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEPORT, 1)
        socket.bind(BIND_ADDR,PORT)
        socket
      end

      def fetch_upnp(return_socket=false,socket=nil)
        socket ||= ssdp_socket
        devices = []

        3.times { socket.send(DISCOVERY, 0, MULTICAST_ADDR, PORT) }

        # The following is a bit silly, but is necessary for JRuby support,
        # which seems to have some issues with socket interruption.
        # If you have a working JRuby solution that doesn't require this
        # kind of hackery, by all means, submit a pull request!

        sleep 1

        parser = Thread.start do
          loop do
            message, _ = socket.recvfrom(1024)
            match = message.match(/LOCATION:\s+http:\/\/([^\/]+)/)
            devices << match[1].split(':') if match
          end
        end

        sleep 1
        parser.kill

        if return_socket
          [devices.uniq,socket]
        else
          socket.close
          devices.uniq
        end
      end
    end

    attr_accessor :name

    def initialize(host,port,body)
      @host, @port = host, port
      @name = body.match(/<friendlyName>([^<]+)<\/friendlyName>/)[1]
    end

    def _get(path,params={})
      auth! unless authed?
      JSON.parse(client.get("#{base_url}/api/#{USERNAME}/#{path}",params.to_json).body)
    end

    def _post(path,params={})
      auth! unless authed?
      JSON.parse(client.post("#{base_url}/api/#{USERNAME}/#{path}",params.to_json).body)
    end

    def _put(path,params={})
      auth! unless authed?
      JSON.parse(client.put("#{base_url}/api/#{USERNAME}/#{path}",params.to_json).body)
    end

    private

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
