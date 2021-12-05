package main

import (
        "bufio"
        "fmt"
        "log"
        "os"
)

const c_size int = 1000

func countOverlaps(data *[c_size][c_size]int) int {
        var count int
        for x := 0; x < c_size; x++ {
                for y := 0; y < c_size; y++ {
                        if data[x][y] > 1 {
                                count++
                        }
                }
        }

        return count
}

func addLine(data *[c_size][c_size]int, x1 int, y1 int, x2 int, y2 int, use_diagonal bool) {
        // diagonal lines
        if x1 != x2 && y1 != y2 {
                if !use_diagonal {
                        return
                }
                if x2 < x1 {
                        x1,x2 = x2,x1
                        y1,y2 = y2,y1
                }

                inc := 1
                if y2 < y1 {
                        inc = -1;
                }

                for x, y := x1, y1; x <= x2; x, y = x+1, y+inc {
                        data[x][y]++
                }
        } /* straight lines */ else {
                if x2 < x1 {
                        x1,x2 = x2,x1
                }

                if y2 < y1 {
                        y1,y2 = y2,y1
                }

                for x := x1; x <= x2; x++ {
                        for y := y1; y <= y2; y++ {
                                data[x][y]++
                        }
                }
        }
}

func main() {
        file, err := os.Open("input.txt")
        if err != nil {
                log.Fatal(err)
        }
        defer file.Close()

        var data1 [c_size][c_size]int
        var data2 [c_size][c_size]int

        var x1, y1, x2, y2 int
        scanner := bufio.NewScanner(file)

        for scanner.Scan() {
                fmt.Sscanf(scanner.Text(), "%d,%d -> %d,%d",
                        &x1, &y1, &x2, &y2)


                addLine(&data1, x1, y1, x2, y2, false)
                addLine(&data2, x1, y1, x2, y2, true)

        }

        fmt.Println("Day 5, part1:", countOverlaps(&data1))
        fmt.Println("Day 5, part2:", countOverlaps(&data2))
}
