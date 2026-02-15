const std = @import("std");
const rlz = @import("raylib_zig");

pub fn build(b: *std.Build) void {
    // TARGET
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .wasm32,
        .os_tag = .emscripten,
    });
    const optimize = b.standardOptimizeOption(.{
        .preferred_optimize_mode = .ReleaseFast,
    });

    const raylib_mod = b.dependency("raylib_zig", .{
        .target = target,
        .optimize = optimize,
    });

    const lib_raylib: *std.Build.Step.Compile = raylib_mod.artifact("raylib");
    {
        lib_raylib.root_module.addCMacro("PLATFORM_WEB", "1"); // fix raylib shader opengl -> webgl
        lib_raylib.root_module.addCMacro("GRAPHICS_API_OPENGL_ES2", "1"); // fix raylib shader opengl -> webgl
    }

    const lib_main: *std.Build.Step.Compile = b.addLibrary(.{
        .name = "main",
        .linkage = .static,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{
                    // when @import("raylib") will look to raylib.h
                    .name = "raylib",
                    .module = raylib_mod.module("raylib"),
                },
            },
        }),
    });

    // OUT: .js + .wasm FROM .a + raylib.a
    const emcc_linker: *std.Build.Step.Run = b.addSystemCommand(&.{"emcc"});
    {
        emcc_linker.addArgs(&.{ "-o", "zig-out/lib/game.mjs" });
        emcc_linker.addArgs(&.{ "-o", "zig-out/lib/game.js" });
        emcc_linker.addFileArg(lib_main.getEmittedBin());
        emcc_linker.addFileArg(lib_raylib.getEmittedBin());
        emcc_linker.addArgs(&.{"--no-entry"}); // no `fn main()`
        emcc_linker.addArgs(&.{ "-s", "STANDALONE_WASM=1" });
        emcc_linker.addArgs(&.{ "-s", "USE_GLFW=3" });
        emcc_linker.addArgs(&.{ "-s", "USE_WEBGL2=1" });
        emcc_linker.addArgs(&.{ "-s", "FULL_ES2=1" });
        emcc_linker.addArgs(&.{ "-s", "MAX_WEBGL_VERSION=2" });
        emcc_linker.addArgs(&.{
            "-s",
            join_list("EXPORTED_FUNCTIONS", &.{
                "_game_init",
                "_game_update",
                "_game_test_logging",
                "_game_test_return_str",
                "_game_test_a",
                "_game_test_b",
                "_game_test_c",
                "_game_test_d",
            }),
        });
    }

    // GRAPH
    // .js+.wasm require libgame.a, require raylib.a
    emcc_linker.step.dependOn(&lib_raylib.step);
    emcc_linker.step.dependOn(&lib_main.step);

    // WRITE (Optional)
    b.installArtifact(lib_main); // lib/libapp.a
    b.installArtifact(lib_raylib); // lib/libraylib.a

    // install = require .js+.wams
    b.getInstallStep().dependOn(&emcc_linker.step);
}

pub fn join_list(
    comptime key: []const u8,
    comptime list: []const []const u8,
) []const u8 {
    comptime var str: []const u8 = "";
    inline for (list, 0..) |name, i| {
        str = str ++ "'" ++ name ++ "'";
        if (i < list.len - 1) str = str ++ ",";
    }
    return key ++ "=[" ++ str ++ "]";
}
