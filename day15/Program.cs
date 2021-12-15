using System;
using System.Collections.Generic;

namespace Dijkstra
{
    using Cell = System.Tuple<int, int>;
    using Weights = Dictionary<System.Tuple<int, int>, int>;

    public static class Constants  {
        public const int inputSize = 100;
        public const int size = 5 * inputSize;
    }

    class Graph {
        Dictionary<Cell, Weights> vertices = new Dictionary<Cell, Weights>();

        public void add_vertex(Cell name, Weights edges) {
            vertices[name] = edges;
        }

        public (List<Cell>, List<Cell>) shortest_path(Cell start, Cell middle, Cell finish) {
            var previous = new Dictionary<Cell, Cell>();
            var allDistances = new Weights();
            var nodes = new Weights();

            var path_middle = new List<Cell>();
            var path_finish = new List<Cell>();

            foreach (var vertex in vertices) {
                if (vertex.Key.Item1 == start.Item1 && vertex.Key.Item2 == start.Item2) {
                    allDistances[vertex.Key] = 0;
                    nodes[vertex.Key] = 0;
                } else {
                    allDistances[vertex.Key] = int.MaxValue;
                    nodes[vertex.Key] = int.MaxValue;
                }
            }

            while (nodes.Count != 0) {
                var smallest = nodes.OrderBy(pair => pair.Value).Take(1).First().Key;
                nodes.Remove(smallest);

                if (smallest.Item1 == middle.Item1 && smallest.Item2 == middle.Item2) {
                    path_middle = new List<Cell>();
                    while (previous.ContainsKey(smallest)) {
                        path_middle.Add(smallest);
                        smallest = previous[smallest];
                    }
                }

                if (smallest.Item1 == finish.Item1 && smallest.Item2 == finish.Item2) {
                    path_finish = new List<Cell>();
                    while (previous.ContainsKey(smallest)) {
                        path_finish.Add(smallest);
                        smallest = previous[smallest];
                    }

                    break;
                }

                if (allDistances[smallest] == int.MaxValue) {
                    break;
                }

                foreach (var neighbor in vertices[smallest]) {
                    var alt = allDistances[smallest] + neighbor.Value;
                    if (alt < allDistances[neighbor.Key]) {
                        if (nodes.ContainsKey(neighbor.Key))
                            nodes[neighbor.Key] = alt;
                        allDistances[neighbor.Key] = alt;
                        previous[neighbor.Key] = smallest;
                    }
                }
            }

            return (path_middle, path_finish);
        }
    }

    class MainClass  {
        // normalize
        private static int nm(int n) {
            if (n < 0) n += Constants.inputSize;
            return n % Constants.inputSize;
        }

        private static int trim(int value) {
            return value > 9 ? value - 9 : value;
        }

        private static int GetExtraValue(int row, int col) {
            return row/Constants.inputSize + col/Constants.inputSize;
        }

        private static int GetWeight(int[,] cave, int row, int col, int x, int y) {
            return trim(cave[nm(nm(row)+x), nm(nm(col)+y)] + GetExtraValue(row+x, col+y));
        }

        public static void Main(string[] args) {
            Graph g = new Graph();

            // Parse file
            int[,] cave = new int[Constants.inputSize, Constants.inputSize];

            int line_number = 0;
            foreach (string line in File.ReadLines(@"input.txt")) {
                char[] arr;
                arr = line.ToCharArray(0, cave.GetLength(0));
                int[] ints = Array.ConvertAll(arr, c => (int)Char.GetNumericValue(c));
                for (int col = 0; col < cave.GetLength(0); col++) {
                    cave[line_number, col] = ints[col];
                }
                line_number++;
            }

            // Solve
            for (int row = 0; row < Constants.size; row++) {
                for (int col = 0; col < Constants.size; col++) {
                    var dict = new Weights();

                    // build dictionary of neighbors
                    if (row > 0)                 dict.Add(new Cell(row-1,col), GetWeight(cave, row, col, -1, 0));
                    if (row < Constants.size-1)  dict.Add(new Cell(row+1,col), GetWeight(cave, row, col, 1, 0));
                    if (col > 0)                 dict.Add(new Cell(row,col-1), GetWeight(cave, row, col, 0, -1));
                    if (col < Constants.size-1)  dict.Add(new Cell(row,col+1), GetWeight(cave, row, col, 0, 1));

                    g.add_vertex(new Cell(row,col), dict);
                }
            }

            // Get shortest path to middle, and finish points
            var (path_p1, path_p2) = g.shortest_path(new Cell(0,0), new Cell(99, 99), new Cell(Constants.size-1, Constants.size-1));

            // Compute path risk
            int risk_p1 = path_p1.Sum(p => GetWeight(cave, p.Item1, p.Item2, 0, 0));
            int risk_p2 = path_p2.Sum(p => GetWeight(cave, p.Item1, p.Item2, 0, 0));

            System.Console.WriteLine("Day 15, part1: {0}", risk_p1);
            System.Console.WriteLine("Day 15, part2: {0}", risk_p2);
        }
    }      
}
