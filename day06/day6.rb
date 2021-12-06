file = File.open("input.txt")

shoal = file.read.split(',').map(&:to_i).reduce(Hash.new(0)) do |h, v|
  h.store(v, h[v] + 1); h
end

256.times { |day|
  0.upto(8) do |i|
    next unless shoal.key?(i)
    shoal[i - 1] = shoal.delete i
  end

  if shoal.key?(-1)
    shoal.store(6, shoal[6] + shoal[-1] )
    shoal.store(8, shoal[8] + shoal[-1] )
    shoal.delete(-1)
  end

  if day == 79
       puts "Part 1: %d " % shoal.values.sum()
  end
}

puts "Part 2: %d " % shoal.values.sum()

