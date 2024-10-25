const std = @import("std");
const daemon = @import("daemon.zig");

pub const Controller = struct {
    processes: std.StringHashMap(daemon.Process),

    pub fn init(allocator: *std.mem.Allocator) Controller {
        return Controller{
            .processes = std.StringHashMap(daemon.Process).init(allocator),
        };
    }

    pub fn 

    fn read_pipe_loop() void {
        const pipe_path = "/tmp/myfifo";

        // Cvreate a named pipe if it doesn't exist
        const res = os.mkfifo(pipePath, 0o600);
        if (res != 0 && (os.errno() != os.errno().EEXIST)) {
            return error("Failed to create FIFO");
        }

        // Open the named pipe for reading
        const fil e = try std.fs.File.openRead(pipePath);
        defer file.close();

        // Continuously read from the pipe
        while (true) {
            var buffer: [256]u8 = undefined;
            const bytesRead = try file.readAll(buffer[0..]);
            const message = buffer[0..bytesRead];
            
            std.debug.print("Received message: {}\n", .{message});
        }
    }
    
} 

