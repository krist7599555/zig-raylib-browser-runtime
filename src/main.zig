const std = @import("std");
const rl = @import("raylib");

extern fn emscripten_log(flags: i32, msg: [*:0]const u8, ...) void;
extern fn emscripten_console_log(msg: [*:0]const u8) void;

var game_title: [100:0]u8 = undefined;

export fn game_init() void {

    // rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    // ขนาดอะไรก็ได้ canvas จะ scale เอง
    rl.initWindow(1024, 720, "raylib + zig + wasm");

    // บนเว็บ SetTargetFPS ไม่มีผล แต่ไม่ใส่ก็โดนมองแรง
    rl.setTargetFPS(60);

    @memmove(game_title[0..11], "Game Title\x00");
}

var time: f32 = 0;
export fn game_update(dt: f32) void {
    time += dt;
    // _ = dt;
    rl.beginDrawing();
    defer rl.endDrawing();

    rl.clearBackground(rl.Color.blue);

    const w: i32 = rl.getScreenWidth();
    const h: i32 = rl.getScreenHeight();

    rl.drawText(
        &game_title,
        @mod(@as(i32, @intFromFloat(@ceil(time * 0.3))), w),
        @divFloor(h, 2),
        20,
        rl.Color.ray_white,
    );

    var buf: [64:0]u8 = undefined;
    const text = std.fmt.bufPrintZ(&buf, "dt = {d:.5}", .{dt}) catch "???";

    rl.drawText(text, 10, 10, 20, .green);
    rl.drawFPS(50, 50);
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
