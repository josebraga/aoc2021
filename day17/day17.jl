using Printf
using Scanf

line = readline("input.txt");
_, x1, x2, y1, y2 = @scanf(line, "target area: x=%d..%d, y=%d..%d", Int, Int, Int, Int)

function inTarget(x, y)
    return x >= x1 && x <= x2 && y >= y1 && y <= y2
end

function outOfBounds(x, y)
    return x > x2 || y < y1
end

function step(x, y, vx, vy)
    return x+vx, y+vy, vx > 0 ? vx - 1 : 0, vy - 1
end

max_height = 0;
hits = 0;
for vx=1:x2, vy=abs(y1)*2:-1:y1
    global max_height, hits
    x = 0
    y = 0
    height = y;

    while true
        # one simulation step
        x, y, vx, vy = step(x, y, vx, vy)

        # save current flight max height
        if y > height
            height = y
        end

        if inTarget(x, y)
            if height > max_height
                max_height = height
            end

            hits += 1
            break;
        end

        if outOfBounds(x, y)
            break;
        end
    end
end

@printf("Day 17, part1: %d\n", max_height);
@printf("Day 17, part2: %d\n", hits);




