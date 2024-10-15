const std = @import("std");

pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "rzinc",
        .root_source_file = b.path("rzinc.zig"),
        .target = b.host,
    });

    b.installArtifact(exe);
}
