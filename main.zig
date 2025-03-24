const Chip = lc4k.LC4128V_TQFP100;
const jedec_data = @embedFile("supercard.jed");

pub fn main() !void {
    const bitstream = try Chip.parse_jed(gpa, jedec_data);
    var names: Chip.Names = .init(gpa);
    defer names.deinit();

    // // TODO Add macrocell names here, for example:
    // names.add_mc_name(.init(0, 4), "Macrocell_Name"); // Assign a name for macrocell A4
    // // Alternatively, the name could be set by referencing the I/O pin instead:
    // names.add_mc_name(Chip.pins._93.mc(), "Macrocell_Name");

    // // TODO Add signal names here, for example:
    // names.add_signal_name(.mc_A5, "Signal_Name");
    // // See the full list of signals here: https://github.com/bcrist/Zig-LC4k/blob/main/src/device/LC4128x_TQFP100.zig#L40
    // // Or you can specify signal names based on the pin number:
    // names.add_signal_name(Chip.pins._20.pad(), "Signal_Name"); // .pad() returns the signal associated with the I/O cell corresponding to the pin (i.e. enum names starting with `clk` or `io_`)
    // names.add_signal_name(Chip.pins._20.fb(), "Signal_Name");  // .fb() returns the raw macrocell output/feedback signal for the macrocell corresponding to the pin (i.e. enum names starting with `mc_`; note this isn't necessarily the same as the `io_` signal even for outputs, since ORM and OE apply to the latter)

    var f = try std.fs.cwd().createFile("report.html", .{});
    defer f.close();

    try Chip.write_report(7, bitstream, f.writer(), .{
        .design_name = "GBA Supercard CPLD",
        .names = &names,
        .skip_timing = true,
    });
}

const gpa = std.heap.smp_allocator;

const lc4k = @import("lc4k");
const std = @import("std");
