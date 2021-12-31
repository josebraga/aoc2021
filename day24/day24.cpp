#include <array>
#include <iostream>
#include <fstream>
#include <functional>
#include <string>
#include <variant>
#include <vector>

constexpr std::size_t c_size = 14;
constexpr std::size_t c_ops_per_block = 18;

// tuned after seeing typical z values on the first runs
constexpr int c_max_expected_z = 320000;
constexpr int c_min_bound_z = 17;
constexpr int c_max_bound_z = 26;

// to be updated after parsing file with a closer expected z entry value.
constinit std::array<int, c_size> g_expected_z {0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1};

// model will be an array with unsigned values
using model_t = std::array<unsigned, c_size>;

struct Registers
{
  int w = 0;
  int x = 0;
  int y = 0;
  int z = 0;

  void reset() {
    w = x = y = z = 0;
  }
} g_registers;

// holds one instruction
struct Instruction
{
  std::function<void (int)> func;

  // argument is optional, only needed for 'inp'
  void operator()(int arg) const {
    return func(arg);
  }
};

void print(const model_t& model)
{
  for (auto e : model) {
    std::cout << e;
  }
  std::cout << '\n';
}

void back_propagate(const std::vector<Instruction>& monad, std::vector<model_t>& list_models, model_t model, int target_z, std::size_t index)
{
  for (int w = 9; w >= 1; --w) {
    for (int z = c_min_bound_z * g_expected_z[index]; z <= c_max_bound_z * g_expected_z[index]; ++z) {
      g_registers.reset();
      g_registers.z = z;

      for (std::size_t i = c_ops_per_block*index; i < c_ops_per_block*(index+1); ++i) {
        monad[i](w);
      }

      if (target_z == g_registers.z) {
        model[index] = w;
        if (index > 0) {
          back_propagate(monad, list_models, model, z, index - 1);
        } else {
          list_models.push_back(model);
        }
      }
    }
  }
}

void calc(const std::vector<Instruction>& monad)
{
  std::vector<model_t> list_models;

  model_t model;
  std::fill(model.begin(), model.end(), 0);
  back_propagate(monad, list_models, model, 0, c_size - 1);

  std::cout << "Total valid model versions: " << list_models.size() << '\n';
  std::cout << "Day 24, part 1: ";
  print(list_models.front());
  std::cout << "Day 24, part 2: ";
  print(list_models.back());
}

std::vector<Instruction> read(std::ifstream& input)
{
  std::vector<Instruction> monad;

  std::size_t block = 0;
  std::string line;
  while (std::getline(input, line)) {
    if (line == "div z 1") {
      if (block > 0 && block < c_size - 1) {
        g_expected_z[block + 1] = g_expected_z[block] * 26;
      }
      ++block;
    } else if (line == "div z 26") {
      if (block > 0 && block < c_size - 1) {
        g_expected_z[block + 1] = g_expected_z[block] / 26;
      }
      ++block;
    }

    int* ptr = nullptr;
    switch (line[4])
    {
      case 'w':
        ptr = &g_registers.w;
        break;
      case 'x':
        ptr = &g_registers.x;
        break;
      case 'y':
        ptr = &g_registers.y;
        break;
      case 'z':
        ptr = &g_registers.z;
        break;
    }

    std::variant<int, int*> input_value;
    if (line.size() > 5) {
      const std::string operand = line.substr(6, line.size() - 6);
      if (operand == "w") {
        input_value = &g_registers.w;
      } else if (operand == "x") {
        input_value = &g_registers.x;
      } else if (operand == "y") {
        input_value = &g_registers.y;
      } else if (operand == "z") {
        input_value = &g_registers.z;
      } else {
        input_value = static_cast<int>(std::stoi(operand));
      }
    }

    std::string cmd = line.substr(0, 3);
    if (cmd == "inp") {
      monad.emplace_back([=](int input) {
        *ptr = input;
      });
    } else if (cmd == "add") {
      monad.emplace_back([=](int) {
        if (std::holds_alternative<int>(input_value)) {
          *ptr += std::get<int>(input_value);
        } else {
          *ptr += *(std::get<int*>(input_value));
        }
      });
    } else if (cmd == "mul") {
      monad.emplace_back([=](int) {
        if (std::holds_alternative<int>(input_value)) {
          *ptr *= std::get<int>(input_value);
        } else {
          *ptr *= *(std::get<int*>(input_value));
        }
      });
    } else if (cmd == "div") {
      monad.emplace_back([=](int) {
        // either divided by 1 or 26
        *ptr /= std::get<int>(input_value);
      });
    } else if (cmd == "mod") {
      monad.emplace_back([=](int) {
        // always mod 26
        *ptr %= std::get<int>(input_value);
      });
    } else if (cmd == "eql") {
      monad.emplace_back([=](int) {
        if (std::holds_alternative<int>(input_value)) {
          *ptr = *ptr == std::get<int>(input_value) ? 1 : 0;
        } else {
          *ptr = *ptr == *(std::get<int*>(input_value)) ? 1 : 0;
        }
      });
    }
  }

  return monad;
}

int main()
{
  std::ifstream input{ "input.txt" };
  calc(read(input));
  input.close();
}
