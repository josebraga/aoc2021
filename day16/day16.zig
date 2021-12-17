const std = @import("std");
const allocator = std.heap.page_allocator;
const assert = std.debug.assert;

// Convert ASCII to an HEX string
fn ASCII2HexString(char: u8) *const [4:0]u8 {
    return switch (char) {
        48 => "0000", // 0
        49 => "0001", // 1
        50 => "0010", // 2
        51 => "0011", // 3
        52 => "0100", // 4
        53 => "0101", // 5
        54 => "0110", // 6
        55 => "0111", // 7
        56 => "1000", // 8
        57 => "1001", // 9
        65 => "1010", // A
        66 => "1011", // B
        67 => "1100", // C
        68 => "1101", // D
        69 => "1110", // E
        70 => "1111", // F
        else => "err!",
    };
}

const Operation = enum(u8) { add, product, min, max, number, greaterThan, lessThan, equalTo };

// Our index will be the current index on the string list plus the next bit
const Index = struct {
    index: u64 = 0,
    bit: u64 = 0,

    fn position(self: Index) u64 {
        return self.index * 4 + self.bit;
    }
};

const Packet = struct {
    version: u64,
    id: Operation,
    packets: ?[]Packet = null,
    value: ?u64 = null,

    fn versions(self: Packet) u64 {
        var total: u64 = self.version;

        if (self.packets) |packets| {
            for (packets) |packet| {
                total += packet.versions();
            }
        }

        return total;
    }

    fn eval(self: Packet) u64 {
        var numbers = std.ArrayList(u64).init(allocator);
        if (self.value) |value| {
            numbers.append(value) catch unreachable;
        } else {
            if (self.packets) |packets| {
                for (packets) |pack| {
                    numbers.append(pack.eval()) catch unreachable;
                }
            }
        }

        var result: u64 = 0;
        switch (self.id) {
            .add => {
                for (numbers.items) |v| result += v;
            },
            .product => {
                result = 1;
                for (numbers.items) |v| result *= v;
            },
            .min => {
                var minimum: u64 = numbers.items[0];
                for (numbers.items) |v| {
                    if (v < minimum) minimum = v;
                }
                return minimum;
            },
            .max => {
                var maximum: u64 = numbers.items[0];
                for (numbers.items) |v| {
                    if (v > maximum) maximum = v;
                }
                return maximum;
            },
            .lessThan => {
                assert(numbers.items.len == 2);
                return if (numbers.items[0] < numbers.items[1]) 1 else 0;
            },
            .greaterThan => {
                assert(numbers.items.len == 2);
                return if (numbers.items[0] > numbers.items[1]) 1 else 0;
            },
            .equalTo => {
                assert(numbers.items.len == 2);
                return if (numbers.items[0] == numbers.items[1]) 1 else 0;
            },
            .number => {
                assert(numbers.items.len == 1);
                return numbers.items[0];
            },
        }

        return result;
    }
};

// Utility to read number from list.
fn grab(binary_sequence: std.ArrayList(*const [4:0]u8), index: *Index, size: u4) u64 {
    var sz: u4 = size;
    var total: u64 = 0;
    var one: u64 = 1;

    while (sz > 0) {
        if (binary_sequence.items[index.*.index][index.*.bit] == '1') {
            total += @shlExact(one, sz - 1);
        }

        next(index, 1);
        sz -= 1;
    }

    return total;
}

// Bump index to ignore bits already read.
fn next(index: *Index, size: u4) void {
    var sz: u4 = size;

    while (sz > 0) {
        index.*.bit += 1;
        if (index.*.bit > 3) {
            index.*.bit = 0;
            index.*.index += 1;
        }
        sz -= 1;
    }
}

fn parse(binary_sequence: std.ArrayList(*const [4:0]u8)) anyerror!Packet {
    var ix: Index = Index{};
    return try parsePacket(binary_sequence, &ix);
}

fn parsePacket(binary_sequence: std.ArrayList(*const [4:0]u8), index: *Index) anyerror!Packet {
    if (binary_sequence.items.len * 4 - index.index * 4 + index.bit < 0) {
        return Packet{ .version = 0, .id = .add, .value = 0 };
    }

    var pack: Packet = undefined;

    pack.version = grab(binary_sequence, index, 3);
    pack.id = @intToEnum(Operation, @intCast(u8, grab(binary_sequence, index, 3)));

    if (pack.id == .number) {
        pack.value = parseNumber(binary_sequence, index);
    } else {
        pack.packets = try parseSubPackets(binary_sequence, index);
    }

    return pack;
}

fn parseNumber(binary_sequence: std.ArrayList(*const [4:0]u8), index: *Index) u64 {
    var bit: u64 = 1;
    var value: u64 = 0;
    var flag: bool = false;
    while (bit == 1) {
        bit = grab(binary_sequence, index, 1);
        const n = grab(binary_sequence, index, 4);

        if (flag) value = @shlExact(value, 4);

        flag = true;
        value += n;
    }

    return value;
}

fn parseSubPackets(binary_sequence: std.ArrayList(*const [4:0]u8), index: *Index) anyerror![]Packet {
    var packets = std.ArrayList(Packet).init(allocator);
    defer packets.deinit();

    const length_type_id = grab(binary_sequence, index, 1);

    if (length_type_id == 0) {
        const bitcount: u64 = grab(binary_sequence, index, 15);
        const start_position = index.position();
        while (bitcount > index.position() - start_position) {
            try packets.append(try parsePacket(binary_sequence, index));
        }
    } else {
        var subpackets: u64 = grab(binary_sequence, index, 11);
        while (subpackets > 0) {
            try packets.append(try parsePacket(binary_sequence, index));
            subpackets -= 1;
        }
    }

    return packets.toOwnedSlice();
}

pub fn main() anyerror!void {
    var file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [2048]u8 = undefined;

    var binary_sequence = std.ArrayList(*const [4:0]u8).init(allocator);
    defer binary_sequence.deinit();

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        for (line) |char| {
            try binary_sequence.append(ASCII2HexString(char));
        }
    }

    const packet = try parse(binary_sequence);

    std.debug.print("Day16, part1: {d}\n", .{packet.versions()});
    std.debug.print("Day16, part2: {d}\n", .{packet.eval()});
}
