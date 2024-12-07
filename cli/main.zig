const std = @import("std");
const linux = std.os.linux;
const commons = @import("../commons/commons.zig");

const ARGS_DELIMITER: []const u8 = " ";

pub fn main() !void {
    const args = std.process.args();
    if (args.len < 2) {
        std.debug.print("Usage: {} <command>\n", .{args[0]});
        return error.InvalidUsage;
    }

    // Install signal handler for SIGTERM
    const sigterm_callback = linux.Sigaction{
        .handler = handle_sigterm,
        .flags = 0,
        .restorer = null,
        .mask = linux.empty_sigset(),
    };

    linux.sigaction(linux.SIGTERM, &sigterm_callback, null) catch unreachable;

    const allocator = std.heap.page_allocator;

    // Open the named pipe for writing as a file
    const pipe = try std.fs.openFile(commons.PIPE_PATH, .{ .write = true });
    defer pipe.close();

    const mainCmd = commons.Cmd.fromStr(args[1]);
    switch (mainCmd) {
        // $ rzinc add [rsync-args] "$SOURCE" "$DESTINATION"
        .ADD => {
           std.debug.print("add {}\n", .{args});
            if (args.len < 4) {
                std.warn.print("Usage: {} add requires a source and destination folder, provided: <folder>\n", .{args[0]});
                return error.InvalidUsage;
            }

            const source = args[args.len - 2];
            const dest = args[args.len - 1];

            const has_args = (args.len - 4) > 0;
            var trans_args: []const u8 = undefined;
            if (has_args) {
                trans_args = join_string(&allocator, args[2 .. args.len - 3], ARGS_DELIMITER);
            }

            const command = try std.fmt.allocPrint(allocator, "add {s} {s} {s}", .{ trans_args, source, dest });
            defer allocator.free(command);

            try pipe.writer(command);
     
        },
        .REMOVE => {
            std.debug.print("delete {}\n", .{args});
            if (args.len < 3) {
                std.debug.print("Usage: {} remove requires the destination or source folder <name>\n", .{args[0]});
                return error.InvalidUsage;
            }

            const dest: []const u8 = args[args.len - 1];

            const command: []const u8 = try std.fmt.allocPrint("del {s}", .{dest});

            try pipe.writer(command); 
        },
        .STAT => {
            std.debug.print("stat {} \n", .{args});

            try pipe.writer("stat");
        }
    }
}

// Signal handler for SIGTERM to clear all
fn handle_sigterm(_: i32) void {
    std.os.exit(0);
}

fn join_string(allocator: *std.mem.Allocator, strings: [][]const u8, delimiter: []const u8) ![]const u8 {
    var total_len: usize = 0;

    // Calculate the total length needed for the resulting string (including spaces)
    for (strings) |s| {
        total_len += s.len;
    }

    total_len += strings.len - 1;

    // Allocate memory for the joined string
    var result = try allocator.alloc(u8, total_len);

    var current_pos: usize = 0;
    for (strings) |s| {
        // Copy the string into the result
        std.mem.copy(u8, result[current_pos..], s);
        current_pos += s.len;

        // Add a space if it's not the last string
        result[current_pos] = delimiter;
        current_pos += 1;
    }

    return result[0 .. result.len - 1];
}
