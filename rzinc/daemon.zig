const std = @import("std");
const linux = std.os.linux;
const os = std.os;
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
    
    // creates a second child process which intrun will fork again
    // to ensure this proces cannot reacquire terminal 
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    
    // this will create another child process
    const child = try std.ChildProcess.init(.{
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

pub fn daemonize() !usize{
    var pid = try os.fork();
    consolidate_fork(pid);

    if (linux.setsid() == -1) {
        std.debug.print("Failed to setsid: {}\n", .{std.os.linux.errno()});
        std.os.exit(1);
    }
        
    // second fork
    pid = try os.fork();
    consolidate_fork(pid);

    try os.chdir(commons.DEFAULT_RUN_FOLDER);
    
       // Redirect standard streams
    const null_fd = try os.open("/dev/null", .{ .mode = .read_write }, 0);
    defer os.close(null_fd);

    try os.dup2(null_fd, std.io.stdin.handle);
    try os.dup2(null_fd, std.io.stdout.handle);
    try os.dup2(null_fd, std.io.stderr.handle);
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
