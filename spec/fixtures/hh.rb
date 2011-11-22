f = File.open('hh.txt')
won = nil
current = ''
while line = f.gets
  if line.start_with?('PokerStars Game')
    if won
      puts current
    end
    current = ''
    won = false
  elsif line =~ /malik_msk collected (\d+) from pot/
    won = true if $1.to_i > 1000
  end
  current += line
end
