#include <algorithm>
#include <fstream>
#include <iostream>
#include <string>
#include <unordered_map>
#include <unordered_set>

using cave_type = std::unordered_multimap<std::string, std::string>;

std::size_t count_part1(const cave_type& my_cave, const std::string& node, std::unordered_set<std::string> visited = {})
{
  if (node == "end") return 1;

  bool lowercase = std::all_of(node.begin(), node.end(), []( const char& c ) { return islower(c); });

  if (lowercase) {
    if (visited.contains(node)) return 0;
    visited.insert(node);
  }

  // keep tracking
  std::size_t total{};
  for (const auto& path : my_cave)
  {
    if (path.first == node)
      total += count_part1(my_cave, path.second, visited);
  }

  return total;
}

std::size_t count_part2(const cave_type& my_cave, const std::string& node, std::unordered_set<std::string> visited = {}, bool repeated = false)
{
  if (node == "end") return 1;

  bool lowercase = std::all_of(node.begin(), node.end(), []( const char& c ) { return islower(c); });

  if (lowercase) {
    if (visited.contains(node)) {
      if (node == "start" || repeated) return 0;
      repeated = true;
    }

    visited.insert(node);
  }

  // keep tracking
  std::size_t total{};
  for (const auto& path : my_cave)
  {
    if (path.first == node)
      total += count_part2(my_cave, path.second, visited, repeated);
  }

  return total;
}

void solve(std::ifstream& input)
{
  cave_type my_cave;

  std::string delimiter = "-";

  std::string line;
  while(getline(input, line)) {
    size_t pos = line.find(delimiter);
    std::string source = line.substr(0, pos);
    std::string sink = line.substr(pos + 1, line.size() - pos);
    my_cave.insert({ source, sink });
    my_cave.insert({ sink, source });
  }

  std::cout << "Day 12, part 1: " << count_part1(my_cave, "start") << '\n';
  std::cout << "Day 12, part 2: " << count_part2(my_cave, "start") << '\n';
}

int main() {
  std::ifstream input{ "input.txt" };
  solve(input);
  input.close();
}
