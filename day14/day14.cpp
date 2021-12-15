#include <climits>
#include <algorithm>
#include <fstream>
#include <iostream>
#include <string>
#include <unordered_map>
#include <unordered_set>

using pairs_t = std::unordered_map<std::string, long long unsigned>;
using rules_t = std::unordered_map<std::string, char>;

template<typename T>
void print(const std::string& str, const T& container) {
  std::cout << str << '\n';
  for (const auto& p : container) {
    std::cout << p.first << " ----> " << p.second << '\n';
  }
}

long long unsigned get_diff_most_least_char_count(const pairs_t& polymer) {
  char max_char;
  char min_char;
  long long unsigned max = 0;
  long long unsigned min = ULLONG_MAX;

  for (char c = 'A'; c <= 'Z'; ++c) {
    long long unsigned count = 0;

    for (const auto& p : polymer) {
      // a given char can show up 0, 1 or 2 times in a pair,
      // and a pair can appear multiple times in the polymer
      count += std::count(p.first.begin(), p.first.end(), c) * p.second;
    }

    count = (count + 1) / 2;

    if (count > max) {
      max_char = c;
      max = count;
    }

    if (count > 0 && count < min) {
      min_char = c;
      min = count;
    }
  }

  return max - min;
}

void add_to_new_polymer(pairs_t& new_polymer, long long unsigned pairs_count, std::string&& new_pair) {
  if (new_polymer.find(new_pair) == new_polymer.end()) {
    new_polymer.insert({ new_pair, pairs_count });
  } else {
    new_polymer.find(new_pair)->second += pairs_count;
  }
}

pairs_t solve(const rules_t& insertion_rules, pairs_t&& polymer_template) {
  pairs_t last_polymer = std::move(polymer_template);

  for (int i = 0; i < 40; ++i) {
    pairs_t new_polymer = last_polymer;

    // go through all insertion rules pairs
    for (const auto& rule_entry : insertion_rules) {

      // if we find a rule pair in the last polymer, split into new pairs and add to new polymer
      const auto pos = last_polymer.find(rule_entry.first);
      if (pos != last_polymer.end()) {
        const auto pairs_count = pos->second;

        // if AB -> C, then add AC, then CB
        add_to_new_polymer(new_polymer, pairs_count, std::string(1, rule_entry.first[0]) + std::string(1, rule_entry.second));
        add_to_new_polymer(new_polymer, pairs_count, std::string(1, rule_entry.second) + std::string(1, rule_entry.first[1]));

        // decrement the pair that was split
        new_polymer.find(rule_entry.first)->second -= pairs_count;
      }
    }

    last_polymer = std::move(new_polymer);

    if (i == 9) std::cout << "Day 14, part 1: " << get_diff_most_least_char_count(last_polymer) << '\n';
  }

  return last_polymer;
}

void read(std::ifstream& input)
{
  pairs_t polymer_template;

  std::string line;
  getline(input, line);

  for (unsigned i = 0; i < line.size() - 1; ++i) {
    const std::string pair = line.substr(i, 2);
    const auto pos = polymer_template.find(pair);
    if (pos == polymer_template.end()) {
      polymer_template.insert({ pair, 1 });
    } else {
      ++(pos->second);
    }
  }

  getline(input, line); // ignore empty line

  rules_t insertion_rules;
  while(getline(input, line)) {
    insertion_rules.insert({ line.substr(0, 2), line[6] });
  }

  pairs_t last_polymer = solve(insertion_rules, std::move(polymer_template));
  std::cout << "Day 14, part 2: " << get_diff_most_least_char_count(last_polymer) << '\n';
}

int main() {
  std::ifstream input{ "input.txt" };
  read(input);
  input.close();
}
