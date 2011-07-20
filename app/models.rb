class Table
  include Mongoid::Document

  field :name
  field :limits
  field :game

  references_many :hands

  validates_uniqueness_of :name
end

class Hand
  include Mongoid::Document

  referenced_in :table

  field :gid, :type => Integer
  field :dealt_at, :type => DateTime
  field :tournament, :type => Integer

  # position
  field :button, :type => Integer
  field :sb
  field :bb

  # money
  field :pot, :type => Float
  field :rake, :type => Float

  # players
  field :seats, :type => Hash
  field :stacks, :type => Hash
  field :players, :type => Array
  field :winners, :type => Hash
  field :went_to_showdown, :type => Array
  field :won_at_showdown, :type => Array
  field :lost_at_showdown, :type => Array
  field :folded_before_flop, :type => Array

  # cards
  field :flop
  field :turn
  field :river
  field :known_cards, :type => Hash

  # bets
  field :bets, :type => Hash

  def tbl=(t)
    t = Table.where(:name => t[:name], :limits => t[:limits]).first
    unless t
      t = Table.create(t)
    end
    self.table = t
  end

  validates_uniqueness_of :gid
end


class Player
  include Mongoid::Document

  field :nickname

  # VP$IP
  field :vpip, :type => Float
  field :vpip_by_position, :type => Hash

  # Preflop raises
  field :pfr, :type => Float
  field :pfr_by_position, :type => Hash

  # Aggression factor
  field :af, :type => Float
  field :af_by_street, :type => Hash
  
  # 3-bets, bets out of position, continuation bets
  field :three_bets, :type => Float
  field :donk_bets, :type => Float
  field :cont_bets, :type => Float

  # showdown, winning/losing
  field :went_to_showdown, :type => Float
  field :won_at_showdown, :type => Float
  field :won_without_showdown, :type => Float
  
  field :hands, :type => Integer
end
