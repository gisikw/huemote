require 'json'

require_relative './huemote/version'

module Huemote
  require_relative './huemote/client'
  require_relative './huemote/light'
  require_relative './huemote/bridge'

  class << self
    def discover(broadcast='255.255.255.255')
      Huemote::Bridge.send(:discover,broadcast)
    end
  end
end
