file = File.open("input.txt")

seafloor = Array.new
file.each_line do |line|
  seafloor.push line.chomp!()
end

rowSize = seafloor.size()
colSize = seafloor[0].size()

step = 0
while true
  east_seafloor = seafloor.map(&:clone)
  (0..rowSize - 1).each do |row|
    (0..colSize - 1).each do |col|
      if seafloor[row][col] == ">" and seafloor[row][(col + 1) % colSize] == "."
        east_seafloor[row][col] = "."
        east_seafloor[row][(col + 1) % colSize] = ">"
      end

    end
  end

  south_seafloor = east_seafloor.map(&:clone)
  (0..rowSize - 1).each do |row|
    (0..colSize - 1).each do |col|
      if seafloor[row][col] == "v" and east_seafloor[(row + 1) % rowSize][col] == "."
        south_seafloor[row][col] = "."
        south_seafloor[(row + 1) % rowSize][col] = "v"
      end
    end
  end

  step += 1

  if (south_seafloor == seafloor)
    break
  end

  seafloor = south_seafloor.map(&:clone)
end

puts "Day 25, part 1: %d" % [step]
