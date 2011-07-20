class PokerStars::HandHistory::Game
  attr_reader :players
  attr_reader :data
  
  def initialize(data)
    @data = data
    pos = @data[:seats].keys.map(&:to_i).sort
    dealer = pos.index(@data[:button])
    cutoff = dealer + 3
    cutoff = cutoff - pos.size if cutoff > pos.size
    normalized = pos.slice(cutoff..-1) + pos.slice(0, cutoff)
    @players = normalized.collect { |i| @data[:seats][i.to_s] }
  end

  def preflop_action
    @data[:bets]['preflop']
  end

  def in_play?(p)
    preflop_action.has_key?(p)
  end

  def raised?(p)
    preflop_raisers.include?(p)
  end
  
  def open_raiser?(p)
    preflop_raisers.first == p
  end

  def last_raiser?(p)
    preflop_raisers.last == p
  end

  def preflop_raisers
    @players.select { |p|
      next unless in_play?(p)
      m = preflop_action[p][0]
      m.is_a?(Hash) && (m.has_key?('raise') || m.has_key?('bet'))
    }
  end

  def voluntary_puts
    @players.select { |p|
      next unless in_play?(p)
      m = preflop_action[p][0]
      if p == @data[:bb] # except check on big blind
        m != 'check'
      else
        m != 'fold'
      end
    }
  end
  
  def went_to_showdown?(player)
    @data[:went_to_showdown].include?(player)
  end

  def won_at_showdown?(player)
    @data[:won_at_showdown].include?(player)
  end

  def won?(p)
    @data[:winners].has_key?(p)
  end

  def openraiser
    preflop_raisers[0]
  end

  def second_raiser
    preflop_raisers[1]
  end

  def three_bet_pot?
    openraiser && second_raiser
  end

  def folded_preflop?(p)
    preflop_action[p].last == 'fold'
  end

  def seen_flop?(p)
    !folded_preflop?(p)
  end

  def cold_call?(p)
    preflop_action[p].all? { |a| a.is_a?(Hash) && a.has_key?('call') }
  end

  def aggression(player)
    b = 0; c = 0
    bb = {'flop' => 0, 'turn' => 0, 'river' => 0, 'preflop' => 0}
    cc = {'flop' => 0, 'turn' => 0, 'river' => 0, 'preflop' => 0}
    @data[:bets].each_pair do |street, bets|
      next unless bets[player]
      bets[player].each { |bet|
        if bet.is_a?(Hash) && (bet.has_key?('raise') || bet.has_key?('bet'))
          b += 1
          bb[street] += 1
        end
        if bet.is_a?(Hash) && bet.has_key?('call')
          c += 1
          cc[street] += 1
        end
      }
    end
    return :total => [b, c],
      :flop => [bb['flop'], cc['flop']],
      :turn => [bb['turn'], cc['turn']],
      :river => [bb['river'], cc['river']]
  end

  def folded_to_steal # doesnt work
    b = []
    if openraiser
      if folded_preflop?(@data[:sb])
        b << @data[:sb]
      end
      if folded_preflop?(@data[:bb])
        b << @data[:bb]
      end
    end
    return b
  end
end
