const std = @import("std");
const linux = std.os.linux;
const debug = std.debug;

const commons = @import("../commons/commons.zig");

pub fn fork_to_daemon(cmd: *const []const []const u8) !usize {
    // fork creates a copy of the process
    const fork_pid = std.os.fork();
    consolidate_fork(fork_pid);

    // Step 2: Create a new session and detach from controlling terminal
    if (linux.setsid() == -1) {
        std.debug.print("Failed to setsid: {}\n", .{std.os.linux.errno()});
        std.os.exit(1);
    }

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    
    // this will create another child process
    const child = try std.ChildProcess.iinit(.{
        .allocator = allocator,
        .argv = cmd, // Command and its arguments
        .cwd = commons.DEFAULT_RUN_FOLDER, // Current working directory
    });

    try child.spawn();

    const pid = child.pid;

    _ = try child.wait();

    defer {
        allocator.free(child.stdout);
        allocator.free(child.stderr);
    }


    return pid;
}

fn consolidate_fork(pid: usize) void {
    if (pid == -1) {
        std.debug.print("Failed to fork: {}\n", .{std.os.linux.errno()});
        std.os.exit(1);
    } else if (pid > 1) {
        // This is the parent process, exit the parent
        std.os.exit(0);
    }
}
