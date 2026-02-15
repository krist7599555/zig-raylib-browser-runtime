const std = @import("std");

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});

    // OUTPUT: zig-out/lib/libgame.a
    const lib = b.addLibrary(.{
        .name = "game",
        .linkage = .static,

        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = b.resolveTargetQuery(.{
                .cpu_arch = .wasm32,
                .os_tag = .emscripten,
            }),
            .optimize = optimize,
        }),
    });
    b.installArtifact(lib);

    // 2) emcc step
    const export_func = .{
        "_game_init",
        "_game_update",
        "_game_test_logging",
        "_game_test_return_str",
        "_game_test_a",
        "_game_test_b",
        "_game_test_c",
        "_game_test_d",
    };

    const export_str = comptime blk: {
        var str: []const u8 = "";
        for (export_func, 0..) |name, i| {
            str = str ++ "'" ++ name ++ "'";
            if (i < export_func.len - 1) str = str ++ ",";
        }
        break :blk "EXPORTED_FUNCTIONS=[" ++ str ++ "]";
    };
    const emcc = b.addSystemCommand(&.{
        "emcc",
        "zig-out/lib/libgame.a",
        "-o",
        "zig-out/lib/game.js",
        "-s",
        export_str,
        "-s",
        "STANDALONE_WASM=1",
        "--no-entry",
    });

    // 3) บอกว่า emcc ต้องรอ lib เสร็จก่อน
    emcc.step.dependOn(&lib.step);

    // 4) ผูกเข้ากับ `zig build`
    b.getInstallStep().dependOn(&emcc.step);
}
