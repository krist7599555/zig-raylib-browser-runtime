const std = @import("std");

extern fn emscripten_log(flags: i32, msg: [*:0]const u8, ...) void;
extern fn emscripten_console_log(msg: [*:0]const u8) void;

export fn game_init() void {}
export fn game_update(dt: f32) void {
    _ = dt;
}

export fn game_test_logging() i32 {
    emscripten_log(1, "Test log 1\x00");
    emscripten_console_log("Test console.log");
    return 775;
}

export fn game_test_return_str() [*:0]const u8 {
    return "Test Return Str";
}

export fn game_test_a() f32 {
    return 3.14;
}
export fn game_test_b() f32 {
    return 3.14;
}
export fn game_test_c() f32 {
    return 3.14;
}
export fn game_test_d() f32 {
    return 3.14;
}
