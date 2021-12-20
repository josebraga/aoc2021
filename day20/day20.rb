
size = 100;

file = File.open("input.txt")

algorithm = file.readline
file.readline

file_image = Array.new
file.each_line do |line|
  file_image.push line.chomp!()
end

def get_bin(input_image, row, col)
  val = input_image[row-1][col-1..col+1] + input_image[row][col-1..col+1] + input_image[row + 1][col-1..col+1]
  val.to_i(2)
end

def run(file_image, algorithm, size, times)
  input_image = Array.new

  (1..times+1).each do
    input_image.push "0" * (size + (times+1) * 2);
  end

  file_image.each do |line|
    input_image.push "0" * (times + 1) + line.gsub(".", "0").gsub("#","1") + "0" * (times + 1)
  end

  (1..times+1).each do
    input_image.push "0" * (size + (times+1) * 2);
  end

  (0..times - 1).each do |index|
    next_image = input_image.map(&:clone)

    (0..size + times * 2 + 1).each do |row|
      (0..size + times * 2 + 1).each do |col|
        if algorithm[0] == "#" && (!row.between?(times - index, size + times + 1 + index) || !col.between?(times - index, size + times + 1 + index))
          next_image[row][col] = index % 2 == 1 ? "0" : "1";
        else
          next_image[row][col] = algorithm[get_bin(input_image, row, col)] == "#" ? "1" : "0"
        end
      end
    end

    input_image = next_image.map(&:clone)
  end

  input_image.map{ |line| line.count("1") }.sum
end

puts "Day 20, part 1: %s" % [run(file_image, algorithm, size, 2)]
puts "Day 20, part 2: %s" % [run(file_image, algorithm, size, 50)]

