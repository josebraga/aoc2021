import std.algorithm;
import std.conv;
import std.stdio;
import std.string;

const string filename = "input.txt";

struct FileContent {
  uint[] lines;
  ulong line_length;
}

FileContent fetch() {
  FileContent content;

  File file = File(filename, "r");

  while (!file.eof()) {
    string line = strip(file.readln());

    if (content.line_length == 0)
      content.line_length = line.length;

    if (!line.empty())
      content.lines ~= to!uint(line, 2);
  }

  return content;
}

void part1() {
  FileContent content = fetch();
  uint[] bitset_count;
  bitset_count.length = content.line_length;

  uint gamma_rate;
  uint epsilon;
  for (uint i = 0; i < bitset_count.length; ++i) {
    ulong shift = bitset_count.length - i - 1;
    foreach(element; content.lines) {
      bitset_count[i] += (element >> shift) & 0b_1;
    }

    if (bitset_count[i] > content.lines.length / 2) 
      gamma_rate |= 0b_1 << shift;
    else
      epsilon |= 0b_1 << shift;
  }

  writeln("--- Part OneTwo ---");
  writeln("Gamma Rate ", gamma_rate);
  writeln("Epsilon: ", epsilon);
  writeln("Power Consumption: ", gamma_rate * epsilon);

}

uint filter(ref FileContent content, bool function(uint, ulong) func) {
  uint[] bitset_count;
  bitset_count.length = content.line_length;

  uint[] copy = content.lines.dup;
  for (uint i = 0; i < content.line_length; ++i) {
    if (copy.length > 1) {
      ulong shift = bitset_count.length - i - 1;
      foreach(element; copy) {
        bitset_count[i] += (element >> shift) & 0b_1;
      }

      if (func(bitset_count[i], copy.length))
        copy = copy.remove!(elem => elem & (0b_1 << shift));
      else
        copy = copy.remove!(elem => ~elem & (0b_1 << shift));
    }
  }

  return copy[0];
}

void part2() {
  FileContent content = fetch();
  
  auto oxygen = filter(content, (count, total_length) => count >= total_length / 2);
  auto co2 = filter(content, (count, total_length) => count < total_length / 2);

  writeln("\n--- Part Two ---");
  writeln("Oxygen Generator Rating: ", oxygen);
  writeln("CO2 Scrubber Rating: ", co2);
  writeln("Life Support Rating: ", oxygen * co2);
}

void main() {
  part1();
  part2();
}
