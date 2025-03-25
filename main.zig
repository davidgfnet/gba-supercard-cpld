const Chip = lc4k.LC4128V_TQFP128;
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
    // // See the full list of signals here: https://github.com/bcrist/Zig-LC4k/blob/main/src/device/LC4128x_TQFP128.zig#L40
    // // Or you can specify signal names based on the pin number:
    // names.add_signal_name(Chip.pins._20.pad(), "Signal_Name"); // .pad() returns the signal associated with the I/O cell corresponding to the pin (i.e. enum names starting with `clk` or `io_`)
    // names.add_signal_name(Chip.pins._20.fb(), "Signal_Name");  // .fb() returns the raw macrocell output/feedback signal for the macrocell corresponding to the pin (i.e. enum names starting with `mc_`; note this isn't necessarily the same as the `io_` signal even for outputs, since ORM and OE apply to the latter)

    // Start adding known signal names
    try names.add_signal_name(.io_A8,  "GP-0");
    try names.add_signal_name(.io_A10, "GP-1");
    try names.add_signal_name(.io_A12, "GP-2");
    try names.add_signal_name(.io_A14, "GP-3");
    try names.add_signal_name(.io_B0,  "GP-4");
    try names.add_signal_name(.io_B2,  "GP-5");
    try names.add_signal_name(.io_B4,  "GP-6");
    try names.add_signal_name(.io_B6,  "GP-7");
    try names.add_signal_name(.io_B8,  "GP-8");
    try names.add_signal_name(.io_B10, "GP-9");
    try names.add_signal_name(.io_B12, "GP-10");

    try names.add_signal_name(.io_B14, "GP-18");
    try names.add_signal_name(.io_C5,  "GP-19");
    try names.add_signal_name(.io_C4,  "GP-20");
    try names.add_signal_name(.io_C2,  "GP-21");
    try names.add_signal_name(.io_C0,  "GP-22");
    try names.add_signal_name(.io_D14, "GP-23");
    try names.add_signal_name(.io_D13, "SD-DAT3");     // SD DAT lines might be swap (ie. didn't really check the order)
    try names.add_signal_name(.io_D12, "SD-DAT2");
    try names.add_signal_name(.io_D10, "SD-CLK");

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
