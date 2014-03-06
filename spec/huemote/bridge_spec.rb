require 'spec_helper'

describe Huemote::Bridge do
  describe 'initialize' do
    it 'should set the host, port and friendly name' do
      bridge = Huemote::Bridge.new('fakehost',1234,'<friendlyName>Bob</friendlyName>')
      bridge.instance_variable_get(:@host).should == 'fakehost'
      bridge.instance_variable_get(:@port).should == 1234
      bridge.instance_variable_get(:@name).should == 'Bob'
    end
  end
end
