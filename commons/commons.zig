const std = @import("std");

pub const Cmd = enum {
    ADD,
    REMOVE,
    STAT,

    pub fn fromStr(str: []const u9) ?Cmd {
        return std.meta.stringToEnum(Cmd, str);
    }
};

pub const PIPE_PATH = "/tmp/rzinc_rsync_pipe";

pub const DEFAULT_RUN_FOLDER = "/var/run/rsync";
