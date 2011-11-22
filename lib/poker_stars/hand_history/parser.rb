require 'active_support/all'

module PokerStars
  class HandHistory::Parser
    def initialize(file)
      @file = file
      @game = nil
      @state = nil
    end

    def player_index(n)
      @game[:seats].index(n)
    end

    def parse_preflop(line)
      # hole cards
      if line.start_with?('Dealt')
        line =~ /Dealt to (.*?) \[(.*)\]/
        @game[:known_cards][player_index($1)] = $2
      end
      parse_street(line)
    end

    def parse_action(a)
      if a =~ /calls \$?([\d.]+)/
        return 'call' => $1.to_f
      end
      if a =~ /bets \$?([\d.]+)/
        return 'bet' => $1.to_f
      end
      if a =~ /raises \$?([\d.]+) to \$?([\d.]+)/
        return 'raise' => [$1.to_f, $2.to_f]
      end
      return 'sb' if a =~ /small bind/
      return 'bb' if a =~ /big bind/
      return 'fold' if a =~ /folds/
      return 'check' if a =~ /checks/
    end

    def parse_game(line)
      @game = {
        :stacks => {},
        :seats => {},
        :players => [],
        :winners => {},
        :went_to_showdown => [],
        :won_at_showdown => [],
        :lost_at_showdown => [],
        :folded_before_flop => [],
        :known_cards => {},
        :bets => {'preflop' => {}, 'flop' => {}, 'turn' => {}, 'river' => {}}
      }
      g, i = line.split(/:\s+/, 2)
      g =~ /#(\d+)/
      @game[:gid] = $1.to_i
      

      @game[:table] = {}
      if i =~ /Tournament #(\d+)/
        @game[:tournament] = {
          :id => $1.to_i
        }
        if false
          tt, kk = i.split(', ', 2)
          kkk, level = kk.split(' - ')
          bi, type = kkk.split(/ USD|EUR /)
          @game[:tournament][:buy_in] = $1
          #Tournament #410072429, $3.00+$0.30 USD Hold'em No Limit - Level I (10/20)
        end
      else
        t, a = i.split(/\s+-\s+/, 2)
        t =~ /(.*) \((.*?)\)/
        @game[:tbl] = {:type => $1, :limits => $2.split('/').map(&:to_i)}
        a =~ /\[(.*?)\]/
        @game[:dealt_at] = DateTime.strptime($1, '%Y/%m/%d %H:%M:%S ET')
      end
    end

    def parse_headers(line)
      # table information
      if line.start_with?('Table')

        line =~ /Table (.*?) Seat #(\d+) is the button/
        @game[:table]['name'] = $1
        @game[:button] = $2.to_i

      # seats information
      elsif line.start_with?('Seat')

        line =~ /Seat (\d+): (.*?) \(\$?([\d.]+) in chips\)/
        @game[:seats][$1] = $2
        @game[:stacks][player_index($2)] = $3.to_f
        @game[:players] << $2

      elsif line.index(':')

        p, a = line.split(/:\s+/, 2)

        if a.start_with?('posts small blind')
          @game[:sb] = p
        elsif a.start_with?('posts big blind')
          @game[:bb] = p
        end

      end
    end

    def parse_summary(line)
      if line =~ /Total pot \$?(\d+) | Rake \$?(\d+)/
        @game[:pot] = $1.to_i
        @game[:rake] = $2.to_i
      end

      if line.start_with?('Seat')
        line.gsub!(/\((small blind|big blind|button)\)\s+/, '')
        line =~ /^Seat \d+: (.*?) (showed|folded|mucked|collected)/
        p = player_index($1)
        
        if line =~ /won \(\$?([\d.]+?)\)/
          @game[:winners][p] = $1.to_f
          @game[:won_at_showdown] << p
          if line =~ /showed \[(.+?)\]/
            @game[:known_cards][p] = $1
          end
        elsif line =~ /collected \(\$?([\d.]+?)\)/
          @game[:winners][p] = $1.to_f
        elsif line =~ /lost|mucked/
          @game[:lost_at_showdown] << p
          if line =~ /mucked \[(.+?)\]/
            @game[:known_cards][p] = $1
          end
        elsif line =~ /folded before flop/
          @game[:folded_before_flop] << p
        end
      end
    end

    def parse_showdown(line)
      if line =~ /^(.*?):/
        @game[:went_to_showdown] << $1
      end
    end

    def parse_street(line)
      if line.index(':')
        p, a = line.split(/:\s+/, 2)
        p = player_index(p)
        if a.start_with?('shows')
          a =~ /\[(.*)\]/
          @game[:known_cards][p] = $1
        else
          @game[:bets][@state][p] ||= []
          @game[:bets][@state][p] << parse_action(a)
        end
      end
    end

    def parse
      while line = @file.gets
        line.chomp!

        # game header
        if line =~ /PokerStars Game/

          if @game
            yield @game if block_given?
          end

          parse_game(line)
          @state = :headers

        elsif line =~ /said/ # chat message
        elsif line =~ /\*\*\* (.*) \*\*\*/

          case $1
          when 'FLOP'
            line =~ /\[(.*)\]/
            @game[:flop] = $1
            @state = 'flop'
          when 'TURN'
            line =~ /\[([^\[]*?)\]$/
            @game[:turn] = $1
            @state = 'turn'
          when 'RIVER'
            line =~ /\[([^\[]*?)\]$/
            @game[:river] = $1
            @state = 'river'
          when 'SHOW DOWN'
            @state = :showdown
          when 'HOLE CARDS'
            @state = 'preflop'
          when 'SUMMARY'
            @state = :summary
          end

        else

          case @state
          when :headers
            parse_headers(line)
          when :summary
            parse_summary(line)
          when :showdown
            parse_showdown(line)
          when 'preflop'
            parse_preflop(line)
          else
            parse_street(line)
          end
        end
      end
    end
  end
end
