import groovy.transform.EqualsAndHashCode

@EqualsAndHashCode
class Point {
    Integer x, y, z

    Point(x, y, z) {
        this.x = x;
        this.y = y;
        this.z = z;
    }
}

@EqualsAndHashCode
class Cuboid {
    Integer xmin, xmax, ymin, ymax, zmin, zmax
    
    Cuboid(Integer xmin, Integer xmax, Integer ymin, Integer ymax, Integer zmin, Integer zmax) {
        this.xmin = xmin;
        this.xmax = xmax;
        this.ymin = ymin;
        this.ymax = ymax;
        this.zmin = zmin;
        this.zmax = zmax;
    }

    def size() {
        return (Long)(this.xmax - this.xmin + 1) * (this.ymax - this.ymin + 1) * (this.zmax - this.zmin + 1)
    }
}

def bounded(xmin, xmax, ymin, ymax, zmin, zmax) {
    final BOUNDS = 50
    out = xmin > BOUNDS || xmax < -BOUNDS || ymin > BOUNDS || ymax < -BOUNDS || zmin > BOUNDS || zmax < -BOUNDS
    return !out
}


def points_part1 = new HashSet<>();
ArrayList<Cuboid> cuboids = new ArrayList<>();

new File("input.txt").eachLine { line ->
    def matcher = line =~ /^(off|on) x=(-?\d+)..(-?\d+),y=(-?\d+)..(-?\d+),z=(-?\d+)..(-?\d+)/

    xmin=matcher[0][2] as Integer
    xmax=matcher[0][3] as Integer
    ymin=matcher[0][4] as Integer
    ymax=matcher[0][5] as Integer
    zmin=matcher[0][6] as Integer
    zmax=matcher[0][7] as Integer

    if (bounded(xmin, xmax, ymin, ymax, zmin, zmax)) {
        for(Integer x in xmin..xmax) {
            for(Integer y in ymin..ymax) {
                for(Integer z in zmin..zmax) {
                    if (matcher[0][1] == 'on') {
                        points_part1.add(new Point(x, y, z))
                    } else {
                        points_part1.remove(new Point(x, y, z))
                    }
                }
            }
        }
    }

    scannedAll = false
    while (!scannedAll && cuboids.size()) {
        for (Integer index in 0..cuboids.size() - 1) {
            def cuboid = cuboids[index]

            // new cuboid contains existing cuboid and can replace it
            if (xmin <= cuboid.xmin && xmax >= cuboid.xmax &&
                ymin <= cuboid.ymin && ymax >= cuboid.ymax &&
                zmin <= cuboid.zmin && zmax >= cuboid.zmax) {
                cuboids.remove(index)
                break;
            }

            // new cuboid does not intersect with existing cuboid
            if (! (xmin <= cuboid.xmax && xmax >= cuboid.xmin &&
                   ymin <= cuboid.ymax && ymax >= cuboid.ymin &&
                   zmin <= cuboid.zmax && zmax >= cuboid.zmin)) {
                if (index == cuboids.size() - 1) {
                    scannedAll = true
                }
                continue;
            }

            // intersections will split cuboids
            if (xmin >= cuboid.xmin + 1 && xmin <= cuboid.xmax) {
                cuboids[index] = new Cuboid(cuboid.xmin, xmin - 1, cuboid.ymin, cuboid.ymax, cuboid.zmin, cuboid.zmax)
                cuboids.add(new Cuboid(xmin, cuboid.xmax, cuboid.ymin, cuboid.ymax, cuboid.zmin, cuboid.zmax))
                break
            }

            if (xmax >= cuboid.xmin && xmax < cuboid.xmax) {
                cuboids[index] = new Cuboid(xmax + 1, cuboid.xmax, cuboid.ymin, cuboid.ymax, cuboid.zmin, cuboid.zmax)
                cuboids.add(new Cuboid(cuboid.xmin, xmax, cuboid.ymin, cuboid.ymax, cuboid.zmin, cuboid.zmax))
                break
            }

            if (ymin >= cuboid.ymin + 1 && ymin <= cuboid.ymax) {
                cuboids[index] = new Cuboid(cuboid.xmin, cuboid.xmax, cuboid.ymin, ymin - 1, cuboid.zmin, cuboid.zmax)
                cuboids.add(new Cuboid(cuboid.xmin, cuboid.xmax, ymin, cuboid.ymax, cuboid.zmin, cuboid.zmax))
                break
            }

            if (ymax >= cuboid.ymin && ymax < cuboid.ymax) {
                cuboids[index] = new Cuboid(cuboid.xmin, cuboid.xmax, ymax + 1, cuboid.ymax, cuboid.zmin, cuboid.zmax)
                cuboids.add(new Cuboid(cuboid.xmin, cuboid.xmax, cuboid.ymin, ymax, cuboid.zmin, cuboid.zmax))
                break
            }

            if (zmin >= cuboid.zmin + 1 && zmin <= cuboid.zmax) {
                cuboids[index] = new Cuboid(cuboid.xmin, cuboid.xmax, cuboid.ymin, cuboid.ymax, cuboid.zmin, zmin - 1)
                cuboids.add(new Cuboid(cuboid.xmin, cuboid.xmax, cuboid.ymin, cuboid.ymax, zmin, cuboid.zmax))
                break
            }

            if (zmax >= cuboid.zmin && zmax < cuboid.zmax) {
                cuboids[index] = new Cuboid(cuboid.xmin, cuboid.xmax, cuboid.ymin, cuboid.ymax, zmax + 1, cuboid.zmax)
                cuboids.add(new Cuboid(cuboid.xmin, cuboid.xmax, cuboid.ymin, cuboid.ymax, cuboid.zmin, zmax))
                break
            }

            if (index == cuboids.size() - 1) {
                scannedAll = true
            }
        }
    }

    if (matcher[0][1] == 'on') {
        cuboids.add(new Cuboid(xmin, xmax, ymin, ymax, zmin, zmax))
    }
}

long total = 0;
for (c in cuboids) {
    total += c.size()
}

println "Day 22, part 1: ${points_part1.size()}"
println "Day 22, part 2: ${total}"
