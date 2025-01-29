const std = @import("std");
const math = std.math;
const Random = std.rand.Random;

// Configuration for the SA algorithm
pub const SAConfig = struct {
    initial_temp: f64,
    min_temp: f64 = 1e-8,
    max_iterations: usize = 100_000,
    iterations_per_temp: usize = 100,
    max_iterations_without_improvement: ?usize = 10000, // New field
    target_energy: ?f64 = 0.0, // New field
};

// Core SA simulation function
pub fn simulate(
    comptime StateType: type,
    initialState: StateType,
    context: anytype,
    energyFn: fn (@TypeOf(context), StateType) f64,
    neighborFn: fn (@TypeOf(context), StateType, f64, *const Random) StateType,
    coolingFn: fn (@TypeOf(context), f64, usize) f64,
    config: SAConfig,
    rng: *const Random,
    logFn: ?fn (@TypeOf(context), StateType, f64, f64, usize) void,
) StateType {
    var current_state = initialState;
    var current_energy = energyFn(context, current_state);
    var current_temp = config.initial_temp;
    var total_iterations: usize = 0;
    var step: usize = 0;

    var best_energy = current_energy;
    var iterations_without_improvement: usize = 0;

    while (current_temp > config.min_temp and total_iterations < config.max_iterations) {
        // Check target energy condition
        if (config.target_energy) |target| {
            if (current_energy <= target) break;
        }

        // Check iterations without improvement condition
        if (config.max_iterations_without_improvement) |max_stagnant| {
            if (iterations_without_improvement >= max_stagnant) break;
        }
        
        for (0..config.iterations_per_temp) |_| {
            if (total_iterations >= config.max_iterations) break;

            const neighbor_state = neighborFn(context, current_state, current_temp, rng);
            const neighbor_energy = energyFn(context, neighbor_state);
            const delta_energy = neighbor_energy - current_energy;

            if (delta_energy < 0) {
                current_state = neighbor_state;
                current_energy = neighbor_energy;
                if (current_energy < best_energy) {
                    best_energy = current_energy;
                    iterations_without_improvement = 0;
                } else {
                    iterations_without_improvement += 1;
                }
            } else {
                const acceptance_prob = math.exp(-delta_energy / current_temp);
                if (rng.float(f64) < acceptance_prob) {
                    current_state = neighbor_state;
                    current_energy = neighbor_energy;
                } else {
                    iterations_without_improvement += 1;
                }
            }

            total_iterations += 1;
        }

        if (logFn) |log| {
            log(context, current_state, current_energy, current_temp, total_iterations);
        }

        current_temp = coolingFn(context, current_temp, step);
        step += 1;
    }

    return current_state;
}