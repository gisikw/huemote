# Huemote [![Build Status](https://travis-ci.org/gisikw/huemote.png?branch=master)](https://travis-ci.org/gisikw/huemote) [![Gem Version](https://badge.fury.io/rb/huemote.png)](http://badge.fury.io/rb/huemote) [![Coverage Status](https://coveralls.io/repos/gisikw/huemote/badge.png)](https://coveralls.io/r/gisikw/huemote) [![Code Climate](https://codeclimate.com/github/gisikw/huemote.png)](https://codeclimate.com/github/gisikw/huemote)

Huemote is an interface for controlling Philips Hue lights. Unlike other implementations, it does not rely on Philips backend servers for upnp discovery.

## Installation

Add this line to your application's Gemfile:

    gem 'huemote'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install huemote

## Usage

You can fetch all lights on your network via:

```ruby
lights = Huemote::Light.all #=> [#<Huemote::Light:0x511ee8dd @name="Hallway", @id="1">, #<Huemote::Light:0x444a2ec6 @name="Main Room", @id="2">, #<Huemote::Light:0x6244ec30 @name="Bathroom 1", @id="3">, #<Huemote::Light:0x1aee75b7 @name="Bathroom 2", @id="4">, #<Huemote::Light:0x1d724f31 @name="Bathroom 3", @id="5">]
```

Or select a light by its friendly name:

```ruby
switch = Huemote::Light.find('Hallway') #=> #<Huemote::Light:0x511ee8dd @name="Hallway", @id="1">
```

Given a Light instance, you can call the following methods:
```ruby
light.off? #=> [true,false]
light.on? #=> [true,false]
light.on!
light.off!
light.toggle!
light.brightness(250)
light.saturation(50)
light.effect('colorloop')
light.alert('select')
light.hue(5)
light.xy([0.123,0.425])
light.ct(300)
```

## Performance

Huemote is designed to be performant - and as such, it will leverage the best HTTP library available for making requests. Currently, Wemote will use (in order of preference): `manticore`, `typhoeus`, `httparty`, and finally (miserably) `net/http`. Because you probably like things fast too, we recommend you `gem install manticore` on JRuby, or `gem install typhoeus` on another engine. In order to keep the gem as flexible as possible, none of these are direct dependencies. They just make Wemote happy and fast.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
