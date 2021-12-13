using System.IO;

// Aliases
using Point = System.Tuple<int, int>;
using Fold = System.Tuple<char, int>;

var PointList = new List<Point>{};
var FoldList = new List<Fold>{};

// Read the file and display it line by line.  
foreach (string line in File.ReadLines(@"input.txt"))
{
    if (line.Contains(',')) {
        string[] words = line.Split(',');
        PointList.Add(new Point(Int32.Parse(words[0]), Int32.Parse(words[1])));
    }

    if (line.Contains('=')) {
        string[] folds = line.Split(' ')[2].Split('=');
        FoldList.Add(new Fold(folds[0][0], Int32.Parse(folds[1])));
    }

}  

int index = 0;
foreach(Fold f in FoldList) {
    int split = f.Item2;    

    if ( f.Item1 == 'x' ) {
        for(var i = 0; i < PointList.Count; i++)
        {
            if (PointList[i].Item1 > split) {
                PointList[i] = new Point( PointList[i].Item1 - (PointList[i].Item1 - split) * 2, PointList[i].Item2);
            }
        }
    } else {
        for(var i = 0; i < PointList.Count; i++)
        {
            if (PointList[i].Item2 > split) {
                PointList[i] = new Point( PointList[i].Item1, PointList[i].Item2 - (PointList[i].Item2 - split) * 2);
            }
        }
    }

    PointList = PointList.Distinct().ToList();

    index++;

    if (index == 1) {
        System.Console.WriteLine("Day 13, part1: {0}", PointList.Count());
    }
}

var stringList = new List<string>{};
for (var i = 0; i <= PointList.Max(y => y.Item2); i++) {
    stringList.Add(new string(' ', PointList.Max(x => x.Item1) + 1));
}

foreach(Point p in PointList) {
    char[] ch = stringList[p.Item2].ToCharArray();
    ch[p.Item1] = '█';
    stringList[p.Item2] = new string (ch);
}

System.Console.WriteLine("Day 13, part2:");
foreach (var s in stringList) {
    System.Console.WriteLine("{0}", s);
}
