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
    @h.calculate_stats('h2.txt', 'malikbakt')
    @h.calculate_stats('h3.txt', 'malikbakt')
    @h.calculate_stats('h4.txt', 'malikbakt')
    puts
    @h.calculate_stats('h3.txt', 'Stringi')
    
    if false
      @h.calculate_stats('h5.txt', 'malikbakt')
      @h.calculate_stats('h3.txt', 'kaisersax')
      @h.calculate_stats('h3.txt', 'Stringi')
      @h.calculate_stats('h6.txt', 'malikbakt')
      @h.calculate_stats('h7.txt', 'malikbakt')
    end
  end
end
