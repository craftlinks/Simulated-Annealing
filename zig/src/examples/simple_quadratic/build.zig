const std = @import("std");


const example_name = "simple_quadratic";

pub fn build(b: *std.Build, options: anytype) *std.Build.Step.Compile {
    const exe = b.addExecutable(.{
        .name = example_name,
        .root_source_file = b.path("src/examples/simple_quadratic/main.zig"),
        .target = options.target,
        .optimize = options.optimize,
    });

    const simulated_annealing = b.dependency("simulated_annealing", .{.target = options.target, .optimize = options.optimize});
    exe.root_module.addImport("simulated_annealing", simulated_annealing.module("root"));

    return exe;
}
