const std = @import("std");
const os = std.os;

const commons = @import("../commons/commons.zig");
const daemon = @import("daemon.zig");

pub const Controller = struct {
    const CMD_DELIMITER = " ";
    
    rwLock: std.Thread.RwLock,
    processes: std.StringHashMap(Process),

    const ProcessingError = error {
        AllocationError
    };

    pub fn init(allocator: *std.mem.Allocator) Controller {
        return Controller{
            .processes = std.StringHashMap(daemon.Process).init(allocator),
        };
    }

    pub fn run(self: *const.Controller) void {
        const allocator = std.heap.page_allocator;
        self.read_pipe_loop(allocator);    
    }

    fn read_pipe_loop(self: *const.Controller, allocator: *std.mem.Allocator) ProcessingError!void {
        // Create a named pipe if it doesn't exist
        const res = os.mkfifo(commons.PIPE_PATH, 0o600);
        if (res != 0 and (os.errno() != os.errno().EEXIST)) {
            return ProcessingError.AllocationError;
        }

        // Open the named pipe for reading
        const file = try std.fs.File.openRead(commons.PIPE_PATH);
        defer file.close();

        // Continuously read from the pipe
        while (true) {
            var buffer: [256]u8 = undefined;
            const bytesRead = try file.readAll(buffer[0..]);
            const command = buffer[0..bytesRead];
            
            std.debug.print("Received command: {}\n", .{command});
            const command_parts = split(allocator, command, CMD_DELIMITER);
            const cmd_len = command_parts.len;
            const mainCmd = commons.Cmd.fromStr(command_parts[0]);

            // TODO: add pipe message back to client
            switch (mainCmd) {
                .ADD => {
                    self.rwLock.lockShared();
                    defer self.rwLock.unlockShared(); 
                    self.add_process(allocator, command_parts, command_parts[cmd_len - 2], command_parts[cmd_len - 1]);
                    return;
                },
                .REMOVE => {
                    self.rwLock.lockShared();
                    defer self.rwLock.unlockShared(); 
                    self.remove_process(allocator, command_parts[cmd_len - 1]);
                    return;
                },
                .STAT => {
                    self.rwLock.lockShared();
                    defer self.rwLock.unlockShared(); 
                    const response = stat();
                    return response;
                }
                
            }
        }
    }

    fn add_process(self: *const.Controller, allocator: *std.mem.Allocator, cmd: []const u8, source: []const u8, dest: []const u8,) !void {
        // start the fork and capture it's pid
        // processes[string] = daemon.Process{source, dest, pid } 
        const cmd_slice = split(allocator,cmd, CMD_DELIMITER);
        const pid = daemon.fork_to_daemon(cmd_slice);

        const process = Process.init(source, dest, pid);
        self.processes[dest] = process;
    }

    fn remove_process(self: *const.Controller, dest: []const u8) !void {
        // pid
        const pid = self.processes[dest].pid;
        std.os.kill(pid, std.os.SIG.TERM) catch |err| {
            std.debug.print("Error killing process:{} {}\n", .{pid, err});
            return err;
        };
    }

    fn stat(self: *const.Controller, allocator: *std.mem.Allocator,) []const u8{
        const mem_size = if (self.processes == null) 0 else @sizeOf(@This()) + self.processes.len * @sizeOf(u8); 
        const response = try std.fmt.allocPrint(allocator, "Processes: size: {}, length: {}", .{self.processes.len, mem_size}); 
        return response;
    }
    
};

pub const Process = struct{
    source: []const u8,
    dest: []const u8,
    pid: usize,

    pub fn init(source: []const u8, dest: []const u8, pid: usize) Process {
        return Process{
            .source = source,
            .dest = dest,
            .pid = pid,
        };
    }

    pub fn set_pid(self: *Process, process_id: u16) void {
        self.pid = process_id;
    }
};


fn split(allocator: *std.mem.Allocator, input:[]const u8, delimiter: []const u8) [][]const u8 {
   var num_substrings = 0;

   for (input) |char| {
    if(char == delimiter) {
        num_substrings += 1;
    }
   }

   const result = try allocator.alloc([]const u8, num_substrings + 1);
   
   var result_index = 0;
   var start_index = 0;
   for (input, 0..) |char,i| {
       if(char == delimiter or i == input.len - 1) {
        const substr_end = if (i == input.len - 1 and char != delimiter) i + 1 else i;
        result[result_index] = input[start_index..substr_end];
        start_index = i+1;
        result_index += 1;
       }
   }

   return result;
}
