const std = @import("std");
const linux = std.os.linux;

pub const Process = struct{
    source: []const u8,
    dest: []const u8,
    pid: u16,

    pub fn init(source: []const u8, dest: []const u8) Process {
        return Rsync_process{
            .source = source,
            .dest = dest,
        };
    }

    pub fn set_pid(self: *Process, process_id: u16) {
        self.pid = process_id;
    }
};


pub fn run_daemon() void {
    // fork from the process
    
}

