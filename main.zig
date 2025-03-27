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
    // names.add_signal_name(Chip.pins._84.pad(), "Signal_Name"); // .pad() returns the signal associated with the I/O cell corresponding to the pin (i.e. enum names starting with `clk` or `io_`)
    // names.add_signal_name(Chip.pins._20.fb(), "Signal_Name");  // .fb() returns the raw macrocell output/feedback signal for the macrocell corresponding to the pin (i.e. enum names starting with `mc_`; note this isn't necessarily the same as the `io_` signal even for outputs, since ORM and OE apply to the latter)


    // davidgf:
    // General overview
    //
    // The SRAM chip is mostly driven by the bus using 16 wires as addr and another 8 as data.
    //   Its CS is wired to CS2 and OE/WE are driven by the CPLD.
    // The flash chip is driven by the CPLD (lower 16 bits, its higher bits are connected to the bus)
    //   Supports a bigger chip (at least 4MiB or so, since it wires many NC addr pins)


    // Start adding known signal names
    try names.add_signal_name(Chip.pins._87.pad(),  "SRAM-A16");

    // PSRAM address wiring to CPLD
    try names.add_signal_name(Chip.pins._124.pad(), "DDR-A0");
    try names.add_signal_name(Chip.pins._119.pad(), "DDR-A1");
    try names.add_signal_name(Chip.pins._116.pad(), "DDR-A2");
    try names.add_signal_name(Chip.pins._109.pad(), "DDR-A3");
    try names.add_signal_name(Chip.pins._111.pad(), "DDR-A4");
    try names.add_signal_name(Chip.pins._118.pad(), "DDR-A5");
    try names.add_signal_name(Chip.pins._121.pad(), "DDR-A6");
    try names.add_signal_name(Chip.pins._126.pad(), "DDR-A7");
    try names.add_signal_name(Chip.pins._128.pad(), "DDR-A8");
    try names.add_signal_name(Chip.pins._14.pad(),  "DDR-A9");
    try names.add_signal_name(Chip.pins._127.pad(), "DDR-A10");
    try names.add_signal_name(Chip.pins._15.pad(),  "DDR-A11");
    try names.add_signal_name(Chip.pins._18.pad(),  "DDR-A12");

    try names.add_signal_name(Chip.pins._6.pad(),  "DDR-BA0");
    try names.add_signal_name(Chip.pins._4.pad(),  "DDR-BA1");

    // Output/input data signals (DQ15..0) are connected to the GP-XX bus as well (GP15-GP-0)

    // /CS is always asserted, DQML & DQMH are always asserted (always write a full 16 bit word)
    try names.add_signal_name(Chip.pins._9.pad(),  "DDR-NRAS");
    try names.add_signal_name(Chip.pins._11.pad(), "DDR-NCAS");
    try names.add_signal_name(Chip.pins._13.pad(), "DDR-NWE");
    try names.add_signal_name(Chip.pins._7.pad(),  "DDR-CKE");      // Clock enable is actually wired? LOL

    // CPLD connections to FLASH (address bus + control)
    try names.add_signal_name(Chip.pins._36.pad(), "FLASH-A0");
    try names.add_signal_name(Chip.pins._20.pad(), "FLASH-A1");
    try names.add_signal_name(Chip.pins._27.pad(), "FLASH-A2");
    try names.add_signal_name(Chip.pins._21.pad(), "FLASH-A3");
    try names.add_signal_name(Chip.pins._26.pad(), "FLASH-A4");
    try names.add_signal_name(Chip.pins._28.pad(), "FLASH-A5");
    try names.add_signal_name(Chip.pins._23.pad(), "FLASH-A6");
    try names.add_signal_name(Chip.pins._35.pad(), "FLASH-A7");
    try names.add_signal_name(Chip.pins._44.pad(), "FLASH-A8");
    try names.add_signal_name(Chip.pins._52.pad(), "FLASH-A9");
    try names.add_signal_name(Chip.pins._37.pad(), "FLASH-A10");
    try names.add_signal_name(Chip.pins._45.pad(), "FLASH-A11");
    try names.add_signal_name(Chip.pins._39.pad(), "FLASH-A12");
    try names.add_signal_name(Chip.pins._42.pad(), "FLASH-A13");
    try names.add_signal_name(Chip.pins._25.pad(), "FLASH-A14");
    try names.add_signal_name(Chip.pins._47.pad(), "FLASH-A15");
    // Flash A16 and A17 are directly connected to the bus (GP-16 and GP-17)

    // Flash CE signal (independent from SRAM!)
    try names.add_signal_name(Chip.pins._54.pad(),  "FLASH-NCE");


    // SRAM signals (TODO)
    // /CS is directly connected to cart's CS2 (assume CS and CS2 are never simultaneously asserted :P)

    // Some shared signals

    // Flash and SRAM chip /WE are tied toghether!
    try names.add_signal_name(Chip.pins._55.pad(), "FLASH-SRAM-NWE");
    // Same for /OE signal
    try names.add_signal_name(Chip.pins._57.pad(), "FLASH-SRAM-NOE");

    // Main oscillator (50MHz)
    // Connected to the SRAM CLK input as well as CPLD (clk2)
    try names.add_signal_name(Chip.pins._114.pad(), "CLK50MHz");    // CLK2 pin

    // Bus control signals
    try names.add_signal_name(Chip.pins._48.pad(), "GP_NCS");    // CLK pins
    try names.add_signal_name(Chip.pins._34.pad(), "GP_NRD");
    try names.add_signal_name(Chip.pins._50.pad(), "GP_NWR");

    try names.add_signal_name(Chip.pins._60.pad(), "GP-0");
    try names.add_signal_name(Chip.pins._62.pad(), "GP-1");
    try names.add_signal_name(Chip.pins._63.pad(), "GP-2");
    try names.add_signal_name(Chip.pins._64.pad(), "GP-3");
    try names.add_signal_name(Chip.pins._68.pad(), "GP-4");
    try names.add_signal_name(Chip.pins._70.pad(), "GP-5");
    try names.add_signal_name(Chip.pins._71.pad(), "GP-6");
    try names.add_signal_name(Chip.pins._73.pad(), "GP-7");
    try names.add_signal_name(Chip.pins._75.pad(), "GP-8");
    try names.add_signal_name(Chip.pins._77.pad(), "GP-9");
    try names.add_signal_name(Chip.pins._78.pad(), "GP-10");
    try names.add_signal_name(Chip.pins._79.pad(), "GP-11");
    try names.add_signal_name(Chip.pins._82.pad(), "GP-12");
    try names.add_signal_name(Chip.pins._84.pad(), "GP-13");
    try names.add_signal_name(Chip.pins._85.pad(), "GP-14");
    try names.add_signal_name(Chip.pins._89.pad(), "GP-15");
    try names.add_signal_name(Chip.pins._16.pad(), "GP-16");
    try names.add_signal_name(Chip.pins._29.pad(), "GP-17");
    try names.add_signal_name(Chip.pins._80.pad(), "GP-18");
    try names.add_signal_name(Chip.pins._90.pad(), "GP-19");
    try names.add_signal_name(Chip.pins._91.pad(), "GP-20");
    try names.add_signal_name(Chip.pins._92.pad(), "GP-21");
    try names.add_signal_name(Chip.pins._93.pad(), "GP-22");
    try names.add_signal_name(Chip.pins._98.pad(), "GP-23");

    // SD connections
    try names.add_signal_name(Chip.pins._99.pad(),  "SD-DAT1");
    try names.add_signal_name(Chip.pins._100.pad(), "SD-DAT0");
    try names.add_signal_name(Chip.pins._106.pad(), "SD-DAT3");
    try names.add_signal_name(Chip.pins._108.pad(), "SD-DAT2");
    try names.add_signal_name(Chip.pins._101.pad(), "SD-CLK");
    try names.add_signal_name(Chip.pins._103.pad(), "SD-CMD");


    // Internal connections!

    // Internal wires that are sometimes reused
    try names.add_signal_name(.mc_C11, "MAGICADDR");       // Goes high when the 0xFFFFFF address goes in the bus (combinational)
    try names.add_signal_name(.mc_C12, "LOAD_IREG");       // Signal to load the magic reg. Checks for magic sequence.

    // DDR related logic
    try names.add_signal_name(.mc_E4, "N_DDR_SEL");        // (N) The DDR is selected, asserted for the lower space or when the SD is disabled (and the DDR is mapped)

    // SD specific logic
    try names.add_signal_name(.mc_E1,  "N_SDOUT");         // negative signal that goes down when the SD card driver is enabled

    // Internal Flash/SDRAM address generation (auto-increment adder magic)
    // Note there are some weird remappings here (the memory is not really linear), see diagram below [1]
    try names.add_signal_name(.mc_D15, "iaddr-a7");    // FLASH-A0
    try names.add_signal_name(.mc_D3,  "iaddr-a1");    // FLASH-A1
    try names.add_signal_name(.mc_C4,  "iaddr-a6");    // FLASH-A2
    try names.add_signal_name(.mc_C7,  "iaddr-a5");    // FLASH-A3
    try names.add_signal_name(.mc_C5,  "iaddr-a0");    // FLASH-A4
    try names.add_signal_name(.mc_C2,  "iaddr-a2");    // FLASH-A5
    try names.add_signal_name(.mc_D4,  "iaddr-a8");    // FLASH-A6
    try names.add_signal_name(.mc_C3,  "iaddr-a4");    // FLASH-A7
    try names.add_signal_name(.mc_D11, "iaddr-a3");    // FLASH-A8
    try names.add_signal_name(.mc_D5,  "iaddr-a9");    // FLASH-A9
    try names.add_signal_name(.mc_D14, "iaddr-a10");   // FLASH-A10
    try names.add_signal_name(.mc_D6,  "iaddr-a11");   // FLASH-A11
    try names.add_signal_name(.mc_D13, "iaddr-a12");   // FLASH-A12
    try names.add_signal_name(.mc_D12, "iaddr-a13");   // FLASH-A13
    try names.add_signal_name(.mc_D7,  "iaddr-a14");   // FLASH-A14
    try names.add_signal_name(.mc_D8,  "iaddr-a15");   // FLASH-A15

    try names.add_signal_name(.mc_H12, "addr-load");       // Used to load address (instead of incrementing it)

    // Internal magic reg (0x1FFFFFE), has 3 bits (LSB) plus some other weird/complex bits too
    try names.add_signal_name(.mc_B12, "MAP-REG");         // 1 for SDRAM, 0 for flash
    try names.add_signal_name(.mc_B11, "SDENABLE");        // Enable SD driver via the top mem space
    try names.add_signal_name(.mc_G8,  "WRITEENABLE");     // Bit that enables writing to DDR (and other stuff?) as well as SRAM bankswitch?

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


// Diagram 1
// Gamepak interface side
// A17 A16 A15 A14 A13 A12 A11 A10  A9  A8  A7  A6  A5  A4  A3  A2  A1  A0
//  |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
//  |   |   |   |   |   |   |   |   |   |   |   \---|---|---|---|---|---|---;
//  |   |   |   |   |   |   |   |   |   |   |       |   |   |   |   |   |   |
//  |   |   |   |   |   |   |   |   |   \---|---\   |   |   |   |   |   |   |
//  |   |   |   |   |   |   |   |   |       |   |   |   |   |   |   |   |   |
//  |   |   |   |   |   |   |   |   |   /---|---|---|---|---/   |   |   |   |
//  |   |   |   |   |   |   |   |   |   |   |   |   |   |       |   |   |   |
//  |   |   |   |   |   |   |   |   |   |   \---|---|---|---\   |   |   |   |
//  |   |   |   |   |   |   |   |   |   |       |   |   |   |   |   |   |   |
//  |   |   |   |   |   |   |   |   |   |   /---|---|---/   |   |   |   |   |
//  |   |   |   |   |   |   |   |   |   |   |   |   |       |   |   |   |   |
//  |   |   |   |   |   |   |   |   |   |   |   |   |   /---|---|---|---/   |
//  |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |       |
//  |   |   |   |   |   |   |   |   |   |   |   |   |   |   \---|---|---\   |
//  |   |   |   |   |   |   |   |   |   |   |   |   |   |       |   |   |   |
//  |   |   |   |   |   |   |   |   |   |   |   |   \---|---\   |   |   |   |
//  |   |   |   |   |   |   |   |   |   |   |   |       |   |   |   |   |   |
//  |   |   |   |   |   |   |   |   |   |   |   |   /---|---|---/   |   |   |
//  |   |   |   |   |   |   |   |   |   |   |   |   |   |   |       |   |   |
//  |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   /---|---|---/
//  |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
// A17 A16 A15 A14 A13 A12 A11 A10  A9  A8  A7  A6  A5  A4  A3  A2  A1  A0
// Flash IC interface side




