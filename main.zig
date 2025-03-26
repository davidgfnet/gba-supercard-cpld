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
    //   Its CS is wired to CS2 and OE/WE are driven by the CPLD.
    // The flash chip is driven by the CPLD (lower 16 bits, its higher bits are connected to the bus)
    //   Supports a bigger chip (at least 4MiB or so, since it wires many NC addr pins)


    // Start adding known signal names
    try names.add_signal_name(Chip.pins._23.pad(),  "SRAM-A16");

    // PSRAM address wiring to CPLD
    try names.add_signal_name(Chip.pins._60.pad(),  "DDR-A0");
    try names.add_signal_name(Chip.pins._55.pad(),  "DDR-A1");
    try names.add_signal_name(Chip.pins._52.pad(),  "DDR-A2");
    try names.add_signal_name(Chip.pins._45.pad(),  "DDR-A3");
    try names.add_signal_name(Chip.pins._47.pad(),  "DDR-A4");
    try names.add_signal_name(Chip.pins._54.pad(),  "DDR-A5");
    try names.add_signal_name(Chip.pins._57.pad(),  "DDR-A6");
    try names.add_signal_name(Chip.pins._62.pad(),  "DDR-A7");
    try names.add_signal_name(Chip.pins._64.pad(),  "DDR-A8");
    try names.add_signal_name(Chip.pins._78.pad(),  "DDR-A9");
    try names.add_signal_name(Chip.pins._63.pad(),  "DDR-A10");
    try names.add_signal_name(Chip.pins._79.pad(),  "DDR-A11");
    try names.add_signal_name(Chip.pins._82.pad(),  "DDR-A12");

    try names.add_signal_name(Chip.pins._70.pad(),  "DDR-BA0");
    try names.add_signal_name(Chip.pins._68.pad(),  "DDR-BA1");

    // Output/input data signals (DQ15..0) are connected to the GP-XX bus as well (GP15-GP-0)

    // /CS is always asserted, DQML & DQMH are always asserted (always write a full 16 bit word)
    try names.add_signal_name(Chip.pins._73.pad(),  "DDR-NRAS");
    try names.add_signal_name(Chip.pins._75.pad(),  "DDR-NCAS");
    try names.add_signal_name(Chip.pins._77.pad(),  "DDR-NWE");
    try names.add_signal_name(Chip.pins._71.pad(),  "DDR-CKE");      // Clock enable is actually wired? LOL

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
    // Flash A16 and A17 are directly connected to the bus (GP-16 and GP-17)

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

    try names.add_signal_name(Chip.pins._124.pad(), "GP-0");
    try names.add_signal_name(Chip.pins._126.pad(), "GP-1");
    try names.add_signal_name(Chip.pins._127.pad(), "GP-2");
    try names.add_signal_name(Chip.pins._128.pad(), "GP-3");
    try names.add_signal_name(Chip.pins._4.pad(),   "GP-4");
    try names.add_signal_name(Chip.pins._6.pad(),   "GP-5");
    try names.add_signal_name(Chip.pins._7.pad(),   "GP-6");
    try names.add_signal_name(Chip.pins._9.pad(),   "GP-7");
    try names.add_signal_name(Chip.pins._11.pad(),  "GP-8");
    try names.add_signal_name(Chip.pins._13.pad(),  "GP-9");
    try names.add_signal_name(Chip.pins._14.pad(),  "GP-10");
    try names.add_signal_name(Chip.pins._15.pad(),  "GP-11");
    try names.add_signal_name(Chip.pins._18.pad(),  "GP-12");
    try names.add_signal_name(Chip.pins._20.pad(),  "GP-13");
    try names.add_signal_name(Chip.pins._21.pad(),  "GP-14");
    try names.add_signal_name(Chip.pins._25.pad(),  "GP-15");
    try names.add_signal_name(Chip.pins._80.pad(),  "GP-16");
    try names.add_signal_name(Chip.pins._93.pad(),  "GP-17");
    try names.add_signal_name(Chip.pins._16.pad(),  "GP-18");
    try names.add_signal_name(Chip.pins._26.pad(),  "GP-19");
    try names.add_signal_name(Chip.pins._27.pad(),  "GP-20");
    try names.add_signal_name(Chip.pins._28.pad(),  "GP-21");
    try names.add_signal_name(Chip.pins._29.pad(),  "GP-22");
    try names.add_signal_name(Chip.pins._34.pad(),  "GP-23");

    // SD connections
    try names.add_signal_name(Chip.pins._35.pad(), "SD-DAT3");     // SD DAT lines might be swap (ie. didn't really check the order)
    try names.add_signal_name(Chip.pins._36.pad(), "SD-DAT2");
    try names.add_signal_name(Chip.pins._42.pad(), "SD-DAT1");
    try names.add_signal_name(Chip.pins._44.pad(), "SD-DAT0");
    try names.add_signal_name(Chip.pins._37.pad(), "SD-CLK");
    try names.add_signal_name(Chip.pins._39.pad(), "SD-CMD");

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
