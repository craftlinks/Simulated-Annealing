const std = @import("std");
const sa = @import("simulated_annealing.zig");

// User-defined context
const Context = struct {
    cooling_rate: f64,
};

// Energy function: f(x) = x²
fn energy_fn(ctx: Context, x: f64) f64 {
    _ = ctx;
    return x * x;
}

// Neighbor function: Perturb x by a random value scaled by temperature
fn neighbor_fn(ctx: Context, x: f64, temp: f64, rng:  *const std.rand.Random) f64 {
    _ = ctx;
    const perturbation = rng.float(f64) * 2.0 - 1.0; // Random between -1 and 1
    return x + perturbation * temp;
}

// Cooling schedule: Exponential cooling
fn cooling_fn(ctx: Context, current_temp: f64, step: usize) f64 {
    _ = step; // Unused in exponential cooling
    return current_temp * ctx.cooling_rate;
}

// Optional logging function
fn saLog(ctx: Context, state: f64, energy: f64, temp: f64, iterations: usize) void {
    _ = ctx;
    std.debug.print(
        "Iteration: {d:5}, State: {d:8.3}, Energy: {d:8.3}, Temp: {d:8.3}\n",
        .{ iterations, state, energy, temp },
    );
}

pub fn main() !void {
    // Initialize PRNG
    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        seed = @as(u64, @truncate(@as(u128, @bitCast(std.time.nanoTimestamp()))));
        break :blk seed;
    });
    const rng = &prng.random();

    // SA configuration
    const config = sa.SAConfig{
        .initial_temp = 100.0,
        .min_temp = 1e-8,
        .max_iterations = 10_0000,
        .iterations_per_temp = 100,
    };

    // Context with cooling rate
    const ctx = Context{ .cooling_rate = 0.95 };

    // Run SA to minimize f(x) = x²
    const result = sa.simulate(
        f64,
        10.0, // Initial state (x = 10)
        ctx,
        energy_fn,
        neighbor_fn,
        cooling_fn,
        config,
        rng,
        saLog, // Enable logging
    );

    std.debug.print("\nOptimal State: {d:.3}\n", .{result});
}
