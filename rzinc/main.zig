const std = @import("std");
const os = std.os;
const daemon = @import("daemon.zig");
const controller = @import("controller.zig");
const commons = @import("../commons/commons.zig");

pub fn main() !void {
    try daemon.daemonize();
    
    try writePidFile(); 

    try run();
}

fn writePidFile() !void {
    const pid = os.getpid();

    const pid_file = try std.fs.createFileAbsolute(
        commons.ServiceConfig.pid_file, 
        .{ .mode = 0o644 }
    );
    defer pid_file.close();

    try pid_file.writer().print("{d}", .{pid});
}

// Graceful shutdown handler
pub fn sigHandler(signal: c_int) callconv(.C) void {
    _ = signal;
    // Perform cleanup
    std.debug.print("Received shutdown signal, cleaning up...\n", .{});
    
    // Remove PID file
    std.fs.deleteFileAbsolute(commons.ServiceConfig.pid_file) catch {};
    
    os.exit(0);
}

fn run() !void {
    // Setup allocator with safety checks
    var gpa = std.heap.GeneralPurposeAllocator(.{
        .safety = true,
        .stack_trace_frames = 10
    }){};
    defer {
        const leaked = gpa.deinit();
        if (leaked) std.debug.print("Memory leak detected!\n", .{});
    }

    // Get the allocator
    const allocator = gpa.allocator();

    controller.Controller control_pane = controller.Controller.init(allocator);

    control_plane.run();
}


