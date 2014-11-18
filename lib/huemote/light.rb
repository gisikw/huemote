module Huemote
  class Light

    STATES = {
      brightness: 'bri',
      saturation: 'sat',
      effect:     'effect',
      alert:      'alert',
      hue:        'hue',
      xy:         'xy',
      ct:         'ct'
    }

    class << self

      def all(refresh=false)
        @lights = nil if refresh
        @lights ||= bridge._get('lights').map{|id,h|self.new(id,h['name'])}
      end

      def find(name)
        all.detect{|l|l.name == name}
      end

      private

      def bridge
        @bridge ||= Huemote::Bridge.get
      end

    end

    attr_accessor :name

    def initialize(id,name)
      @id, @name = id, name
    end

    def on!
      set!(on:true)
    end

    def off!
      set!(on:false)
    end

    def on?
      bridge._get("lights/#{@id}")['state']['on']
    end

    def off?
      !on?
    end

    def toggle!
      on? ? off! : on!
    end

    def kelvin(temp)
      ct [[1000000/temp,154].max,500].min
    end

    STATES.each do |name,state|
      define_method name do |arg|
        set!(state => arg)
      end
    end

    private

    def set!(params)
      bridge._put("lights/#{@id}/state",params)
    end

    def bridge
      @bridge ||= Huemote::Bridge.get
    end

  end
end
