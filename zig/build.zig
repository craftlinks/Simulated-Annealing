const std = @import("std");


pub const examples = struct {
    pub const simple_quadratic = @import("src/examples/simple_quadratic/build.zig");
};


pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const options = .{
        .target = target,
        .optimize = optimize,
    };

    buildAndInstallSamples(b,  options, examples);
}


fn buildAndInstallSamples(b: *std.Build, options: anytype, comptime samples: anytype) void {
    inline for (comptime std.meta.declarations(samples)) |d| {
        const exe = @field(samples, d.name).build(b, options);
        const install_exe = b.addInstallArtifact(exe, .{});
        b.getInstallStep().dependOn(&install_exe.step);
        b.step(d.name, "Build the " ++ d.name ++ " example").dependOn(&install_exe.step);

        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(&install_exe.step);
        b.step( "run_" ++ d.name, "Run the " ++ d.name ++ " example").dependOn(&run_cmd.step);
    }
}
