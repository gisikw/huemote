require 'json'

require_relative './huemote/version'

module Huemote
  require_relative './huemote/client'
  require_relative './huemote/light'
  require_relative './huemote/bridge'

  class << self
    def set_ip(ip)
      Huemote::Bridge.send(:set_ip,ip)
    end

    def discover
      Huemote::Bridge.send(:discover)
    end
  end
end
