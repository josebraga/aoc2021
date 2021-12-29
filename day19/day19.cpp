#include <cmath>
#include <compare>
#include <cstdio>
#include <fstream>
#include <iostream>
#include <map>
#include <set>
#include <string>
#include <vector>

struct Point
{
  int x, y, z;

  Point(int x_, int y_, int z_):
    x(x_), y(y_), z(z_)
  { }

  auto operator<=>(const Point&) const = default;
};

unsigned manhattan_distance(const Point& l, const Point& r)
{
  return std::abs(l.x - r.x) + std::abs(l.y - r.y) + std::abs(l.z - r.z);
}

Point get_rotated_point(const Point&p, unsigned type)
{
  switch (type)
  {
    case 0:
      return Point{p.x, p.y, p.z};
    case 1:
      return Point{p.x, -p.z, p.y};
    case 2:
      return Point{p.x, -p.y, -p.z};
    case 3:
      return Point{p.x, p.z, -p.y};
    case 4:
      return Point{-p.x, -p.y, p.z};
    case 5:
      return Point{-p.x, -p.z, -p.y};
    case 6:
      return Point{-p.x, p.y, -p.z};
    case 7:
      return Point{-p.x, p.z, p.y};
    case 8:
      return Point{p.y, p.x, -p.z};
    case 9:
      return Point{p.y, -p.x, p.z};
    case 10:
      return Point{p.y, p.z, p.x};
    case 11:
      return Point{p.y, -p.z, -p.x};
    case 12:
      return Point{-p.y, p.x, p.z};
    case 13:
      return Point{-p.y, -p.x, -p.z};
    case 14:
      return Point{-p.y, -p.z, p.x};
    case 15:
      return Point{-p.y, p.z, -p.x};
    case 16:
      return Point{p.z, p.x, p.y};
    case 17:
      return Point{p.z, -p.x, -p.y};
    case 18:
      return Point{p.z, -p.y, p.x};
    case 19:
      return Point{p.z, p.y, -p.x};
    case 20:
      return Point{-p.z, p.x, -p.y};
    case 21:
      return Point{-p.z, -p.x, p.y};
    case 22:
      return Point{-p.z, p.y, p.x};
    case 23:
      return Point{-p.z, -p.y, -p.x};
    default:
      return Point{p.x, p.y, p.z};
  }
}

class Scanner
{
  unsigned m_id;
  std::vector<Point> m_detections;

public:
  Scanner(unsigned id):
    m_id(id)
  { }

  void add(int x, int y, int z)
  {
    m_detections.emplace_back(x, y, z);
  }

  std::size_t size() const
  {
    return m_detections.size();
  }

  unsigned id() const
  {
    return m_id;
  }

  const std::vector<Point>& get() const
  {
    return m_detections;
  }
};

std::vector<Scanner> read(std::ifstream& input)
{
  std::vector<Scanner> scanners;

  std::string line;
  unsigned id;
  int x, y, z;

  while (std::getline(input, line))
  {
    if (line.empty()) continue;

    if (std::sscanf(line.c_str(), "--- scanner %u ---", &id) == 1)
    {
      scanners.emplace_back(id);
      continue;
    }

    if (std::sscanf(line.c_str(), "%d,%d,%d", &x, &y, &z) == 3)
    {
      scanners.back().add(x, y, z);
    }
  }

  return scanners;
}

void calc(const std::vector<Scanner>& scanners)
{
  std::set<Point> ocean{scanners[0].get().begin(), scanners[0].get().end()};
  std::vector<Point> scanners_locations{ {0, 0, 0} };
  std::set<unsigned> added_ids{ scanners[0].id() };

  while (added_ids.size() < scanners.size())
  {
    for (const Scanner& s : scanners)
    {
      if (added_ids.contains(s.id())) continue;

      for (unsigned rot = 0; rot < 24; ++rot)
      {
        std::map<Point, unsigned> offset_count;
        for (const Point& beacon : ocean)
        {
          for (const Point& point : s.get())
          {
            const Point rpoint = get_rotated_point(point, rot);
            const Point offset = Point{rpoint.x - beacon.x,
              rpoint.y - beacon.y,
              rpoint.z - beacon.z};

            offset_count[offset] += 1;
          }
        }

        for (const auto& [offset, count] : offset_count)
        {
          if (count >= 12)
          {
            scanners_locations.push_back({-offset.x, -offset.y, -offset.z});
            added_ids.insert(s.id());
            for (const Point& point : s.get())
            {
              const Point rpoint = get_rotated_point(point, rot);
              const Point new_beacon = Point{rpoint.x - offset.x,
                rpoint.y - offset.y, rpoint.z - offset.z};
              ocean.insert(new_beacon);
            }
          }
        }
      }
    }
  }

  std::cout << "Day 19, part1: " << ocean.size() << '\n';

  unsigned max = 0;
  for (unsigned first = 0; first < scanners_locations.size(); ++first)
  {
    for (unsigned second = first+1; second < scanners_locations.size(); ++second)
    {
      unsigned distance = manhattan_distance(scanners_locations[first], scanners_locations[second]);
      if (distance > max)
      {
        max = distance;
      }
    }
  }

  std::cout << "Day 19, part2: " << max << '\n';
}

int main()
{
  std::ifstream input{ "input.txt" };
  calc(read(input));
  input.close();
}
