require 'spec_helper'

describe HandHistory do
  example 'initialize' do
    @h = HandHistory.new('./fixtures')
  end

  xit 'parse' do
    @h = HandHistory.new(File.join(File.dirname(__FILE__), '/fixtures'))
    @h.parse('h1.txt')
  end

  example 'vpip' do
    @h = HandHistory.new(File.join(File.dirname(__FILE__), '/fixtures'))
    puts
    @h.calculate_stats('hh.txt', 'malik_msk')
  end
end
