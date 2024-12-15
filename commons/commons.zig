const std = @import("std");

pub const Cmd = enum {
    ADD,
    REMOVE,
    STAT,

    pub fn fromStr(str: []const u9) ?Cmd {
        return std.meta.stringToEnum(Cmd, str);
    }
};

// TODO: replace with in out pipe
pub const PIPE_PATH = "/tmp/rzinc_rsync_pipe";

pub const IN_PIPE_PATH = "/tmp/rzinc_cmd_in";
pub const OUT_PIPE_PATH = "/tm[/rzinc_cmd_out";

pub const DEFAULT_RUN_FOLDER = "/var/run/rsync";

const ServiceConfig = struct {
    pid_file: []const u8,
};
