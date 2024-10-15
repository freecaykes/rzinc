const std = @import("std");
const linux = std.os.linux;

// Signal handler for SIGTERM to clear all  
fn handle_sigterm(_:i32) void {
    std.os,exit(0)
}


pub fn main() !void {
    const allocator = std.heap.page_allocator;
 
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
    
    const command = args[1];

    switch (command) {
        "add" => {
            std.debug.print("add \n", .{});
            if (args.len < 4) {
                std.warn.print("Usage: {} add requires a source and destination folder, provided: <folder>\n", .{args[0]});
                return error.InvalidUsage;
            }
        },
        "remove" => {
            std.debug.print("remove \n", .{});
            if (args.len < 3) {
                std.debug.print("Usage: {} remove requires the destination or source folder <name>\n", .{args[0]});
                return error.InvalidUsage;
            }
            const folderToRemove = args[2];

        },
        "stat" =>{
            std.debug.print("stat \n", .{});
            
        // 
        },
        else => {
            std.debug.print("Unknown command: {}\n", .{command});
            std.debug.print("Available commands: add, remove, stat\n", .{});
        },
    }
}


