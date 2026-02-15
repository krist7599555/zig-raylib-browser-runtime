const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");

extern fn emscripten_log(flags: i32, msg: [*:0]const u8, ...) void;
extern fn emscripten_console_log(msg: [*:0]const u8) void;

var game_title: [100:0]u8 = undefined;

export fn game_init() void {
    rl.initWindow(720, 480, "");
    rl.setTargetFPS(60);
    game_set_title("Game Title");
}

var time: f32 = 0;
var camera = rl.Camera3D{
    .position = .init(-5, 2, 0),
    .target = .init(0, 0, 0),
    .projection = .perspective,
    .up = .init(0, 1, 0),
    .fovy = 60,
};
var camera_mode: rl.CameraMode = .orbital;
export fn game_update(dt: f32) void {
    time += dt;
    rl.updateCamera(&camera, camera_mode);

    rl.beginDrawing();
    defer rl.endDrawing();

    rl.clearBackground(rl.Color.blue);

    {
        rl.beginMode3D(camera);
        defer rl.endMode3D();

        // DRAW Ground
        rl.drawPlane(.init(0, -0.01, 0), .init(50, 50), .brown);
        rl.drawGrid(50, 1);

        // DRAW Player
        rl.drawCapsule(.init(0, 0.3, 0), .init(0, 1, 0), 0.3, 10, 10, .green);

        {
            const cl: u8 = @as(u8, @intCast(@mod(@as(i32, @intFromFloat(@floor(time * 0.5))), 255)));
            for (2..5) |di| {
                const d = @as(f32, @floatFromInt(di));
                const size = rl.Vector3.init(0.7, d - 1, 0.7);
                rl.drawCubeV(.init(d, 0.5, d), size, .init(cl, 0, 255, 255));
                rl.drawCubeV(.init(-d, 0.5, d), size, .init(0, cl, 255, 255));
                rl.drawCubeV(.init(-d, 0.5, -d), size, .init(0, 255, cl, 255));
                rl.drawCubeV(.init(d, 0.5, -d), size, .init(255, cl, 0, 255));
            }
        }
    }

    // DRAW TITLE
    const screen_height: i32 = rl.getScreenHeight();
    rl.drawText(&game_title, 10, screen_height - 30, 20, .ray_white);

    // DRAW FPS
    rl.drawFPS(10, 10);

    // DRAW DT=???
    var dt_buf: [64:0]u8 = undefined;
    const dt_str = std.fmt.bufPrintZ(&dt_buf, "dt={d:.2}", .{dt}) catch "???";
    rl.drawText(dt_str, 120, 10, 20, .green);

    // DRAW "Change Cam Mode" button
    if (rg.button(
        rl.Rectangle{ .x = 10, .y = 35, .width = 140, .height = 40 },
        "Change Camera Mode",
    )) {
        camera_mode = switch (camera_mode) {
            .orbital => .first_person,
            .first_person => .orbital,
            else => camera_mode,
        };
    }
}

export fn game_set_title(ptr: [*:0]const u8) void {
    const slice = zPointerToZSlice(ptr);
    rl.setWindowTitle(slice);
    copyZSlice(&game_title, slice);
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

pub fn copyZSlice(dest: []u8, src: [:0]const u8) void {
    const n = src.len + 1; // +1 for '\0'
    std.debug.assert(dest.len >= n);
    std.mem.copyForwards(u8, dest[0..n], src[0..n]);
}
pub fn copyZPointer(dest: []u8, src: [*:0]const u8) void {
    copyZSlice(dest, zPointerToZSlice(src));
}
pub fn zPointerToZSlice(src: [*:0]const u8) [:0]const u8 {
    const slice: [:0]const u8 = std.mem.span(src);
    return slice;
}
pub fn zSliceToZPointer(src: [*:0]const u8) [:0]const u8 {
    const slice: [:0]const u8 = std.mem.span(src);
    return slice;
}
