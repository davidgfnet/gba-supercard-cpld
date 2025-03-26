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


    // davidgf:
    // General overview
    //
    // The SRAM chip is mostly driven by the bus using 16 wires as addr and another 8 as data.
    // The flash chip is driven by the CPLD (lower 16 bits).


    // Start adding known signal names
    try names.add_signal_name(Chip.pins._23.pad(),  "SRAM-A16");

    // CPLD connections to FLASH (address bus + control)
    try names.add_signal_name(Chip.pins._100.pad(), "FLASH-A0");
    try names.add_signal_name(Chip.pins._84.pad(),  "FLASH-A1");
    try names.add_signal_name(Chip.pins._91.pad(),  "FLASH-A2");
    try names.add_signal_name(Chip.pins._85.pad(),  "FLASH-A3");
    try names.add_signal_name(Chip.pins._90.pad(),  "FLASH-A4");
    try names.add_signal_name(Chip.pins._92.pad(),  "FLASH-A5");
    try names.add_signal_name(Chip.pins._87.pad(),  "FLASH-A6");
    try names.add_signal_name(Chip.pins._99.pad(),  "FLASH-A7");
    try names.add_signal_name(Chip.pins._108.pad(), "FLASH-A8");
    try names.add_signal_name(Chip.pins._116.pad(), "FLASH-A9");
    try names.add_signal_name(Chip.pins._101.pad(), "FLASH-A10");
    try names.add_signal_name(Chip.pins._109.pad(), "FLASH-A11");
    try names.add_signal_name(Chip.pins._103.pad(), "FLASH-A12");
    try names.add_signal_name(Chip.pins._106.pad(), "FLASH-A13");
    try names.add_signal_name(Chip.pins._89.pad(),  "FLASH-A14");
    try names.add_signal_name(Chip.pins._111.pad(), "FLASH-A15");
    try names.add_signal_name(Chip.pins._80.pad(),  "FLASH-A16");   // This actually an input (A16 and A17 are driven by the bus directly!)

    // Flash CE signal (independent from SRAM!)
    try names.add_signal_name(Chip.pins._118.pad(),  "FLASH-NCE");


    // SRAM signals (TODO)
    // /CS is directly connected to cart's CS2 (assume CS and CS2 are never simultaneously asserted :P)

    // Some shared signals

    // Flash and SRAM chip /WE are tied toghether!
    try names.add_signal_name(Chip.pins._119.pad(), "FLASH-SRAM-NWE");
    // Same for /OE signal
    try names.add_signal_name(Chip.pins._121.pad(), "FLASH-SRAM-NOE");

    // Main oscillator (50MHz)
    // Connected to the SRAM CLK input as well as CPLD (clk2)
    try names.add_signal_name(Chip.pins._50.pad(), "CLK50MHz");    // CLK2 pin

    // Bus control signals
    try names.add_signal_name(Chip.pins._112.pad(), "GP-CS");    // CLK3 pin
    try names.add_signal_name(Chip.pins._98.pad(), "GP-RD");
    try names.add_signal_name(Chip.pins._114.pad(), "GP-WR");    // CLK0 pin

//    try names.add_signal_name(Chip.pins._9.pad(),  "GP-0");
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
