module PokerStars
  class HandHistory
    autoload :Parser, 'poker_stars/hand_history/parser'
    autoload :Game, 'poker_stars/hand_history/game'
    
    attr_reader :path
    
    def initialize(path)
      @path = path
    end

    def parse(file)
      f = File.join(@path, file)
      parser = Parser.new(File.open(f))
      parser.parse { |data|
        game = Game.new(data)
      }
    end
    
    def known_cards(file, player)
      f = File.join(@path, file)
      parser = Parser.new(File.open(f))
      parser.parse { |data|
        if hole = data[:known_cards][data[:seats].index(player)]
          print hole.to_s + "\t"
        end
      }
    end

    def calculate_stats(file, player)
      f = File.join(@path, file)
      parser = Parser.new(File.open(f))
      
      total = 0
      put = 0
      pfr = 0
      wtsd = 0
      wsd = 0
      seen_flop = 0
      won = 0
      cc = 0
      aggr = {
        :total => [0, 0],
        :flop => [0, 0],
        :turn => [0, 0],
        :river => [0, 0]
      }

      parser.parse { |data|
        game = Game.new(data)
        if game.in_play?(player)
          put += 1 if game.voluntary_puts.include?(player)
          pfr += 1 if game.preflop_raisers.include?(player)
          wtsd += 1 if game.went_to_showdown?(player)
          wsd += 1 if game.won_at_showdown?(player)
          seen_flop += 1 if game.seen_flop?(player)
          won += 1 if game.won?(player)
          cc += 1 if game.cold_call?(player)
          aggression = game.aggression(player)
          aggression[:total].each_with_index { |n, i|
            aggr[:total][i] += n
          }
          #aggression[:streets][0].each_pair { |street, i|
          #  aggr[street][i] += n
          #}
          total += 1 
        end
      }
      require 'highline/import'
      say "VP$IP <%= color('" + ("%.2f%%" % (put.to_f / total * 100)) + "', :green, BOLD) %>\t" +
        "PFR <%= color('" + ("%.2f%%" % (pfr.to_f / total * 100)) + "', :green) %>\t" +
        "Af <%= color('" +("%.2f" % (Rational(*aggr[:total]).to_f)) + "', :red, BOLD) %>\t" +
        "CC <%= color('" +("%.2f%%" % (cc.to_f / seen_flop * 100)) + "', :red) %>\t" +
        "WTSD <%= color('" +("%.2f%%" % (wtsd.to_f / seen_flop * 100)) + "', :yellow, BOLD) %>\t" +
        "WSD <%= color('" +("%.2f%%" % (wsd.to_f / wtsd * 100)) + "', :yellow) %>\t" +
        "H <%= color('" +("%i" % total) + "', :blue, BOLD) %>\t" +
        "W <%= color('" +("%.2f%%" % (won.to_f / total * 100)) + "', :blue) %>\t" +
        "WWSD <%= color('" +("%.2f%%" % ((won - wsd).to_f / total * 100)) + "', :blue) %>"
      #print "Af:"
      #aggr.each_pair { |street, nn|
      #  print "\t#{street} - %.2f" % Rational(*nn).to_f unless street == :total
      #}
      puts
    end
  end
end
