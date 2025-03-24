pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "generate_report",
        .root_source_file = b.path("main.zig"),
        .target = b.standardTargetOptions(.{}),
        .optimize = b.standardOptimizeOption(.{}),
    });
    exe.root_module.addImport("lc4k", b.dependency("lc4k", .{}).module("lc4k"));

    b.installArtifact(exe);
    b.getInstallStep().dependOn(&b.addRunArtifact(exe).step);
}

const std = @import("std");
