const std = @import("std");

pub const Process = struct{
    source: []const u8,
    dest: []const u8,
    pid: u16,

    pub fn init(source: []const u8, dest: []const u8) Process {
        return Process{
            .source = source,
            .dest = dest,
        };
    }

    pub fn set_pid(self: *Process, process_id: u16) void {
        self.pid = process_id;
    }
};


pub fn run_daemon() void {
    // fork from the process
    
}

fn fork() !void {
    const pid = std.os.fork();
    // fork creates a copy of the process 
    switch (pid) {
        0 => {
            // This is the child process
        },
        -1 => {
            std.debug.print("Failed to fork: {}\n", .{std.os.linux.errno()});
            std.os.exit(1);
        },
        else => {
            // This is the parent process, exit the parent
            std.os.exit(0);
        }
    }

    // Step 2: Create a new session and detach from controlling terminal
    if (linux.setsid() == -1) {
        std.debug.print("Failed to setsid: {}\n", .{std.os.linux.errno()});
        std.os.exit(1);
    }

    // Step 3: Fork again to ensure we can't reacquire a controlling terminal
    const pid2 = linux.fork();
    switch (pid2) {
        0 => {
            // Child continues execution
        },
        -1 => {
            std.debug.print("Failed to fork again: {}\n", .{std.os.linux.errno()});
            std.os.exit(1);
        },
        else => {
            std.os.exit(0);
        }
    }

}
