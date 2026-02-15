const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");

const EmscriptenLogFlag = enum(i32) {
    console = 1, // EM_LOG_CONSOLE (1): Log to console.log.
    warn    = 2, // EM_LOG_WARN (2): Log to console.warn.
    err     = 4, // EM_LOG_ERROR (4): Log to console.error.
    c_stack = 8, // EM_LOG_C_STACK (8): Include the C/C++ callstack.
    js_stack = 16, // EM_LOG_JS_STACK (16): Include the JavaScript callstack.
    demangle = 32, // EM_LOG_DEMANGLE (32): Demangle C++ function names.
    _, // allow merge bitmask
};
extern fn emscripten_log(flags: EmscriptenLogFlag, msg: [*:0]const u8, ...) void;
extern fn emscripten_console_log(msg: [*:0]const u8) void;

// Global Mutable Var
var camera = rl.Camera3D{
    .position = .init(-5, 2, 0),
    .target = .init(0, 0, 0),
    .projection = .perspective,
    .up = .init(0, 1, 0),
    .fovy = 60,
};
var camera_mode: rl.CameraMode = .orbital;
var game_title: [100:0]u8 = undefined;
var is_initialized = false;

// Function

export fn game_init() void {
    if (is_initialized) return;
    rl.initWindow(720, 480, "");
    rl.setTargetFPS(60);
    game_set_title("Game Title");
    is_initialized = true;
}

export fn game_update() void {
    if (!is_initialized) {
        emscripten_log(.err, "Please Init Raylib before update");
        return;
    }
    const dt = rl.getFrameTime();
    const time = rl.getTime();

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
            const color = @as(u8, @intFromFloat(time * 1000)) % 255;
            for (2..5) |di| {
                const ring = @as(f32, @floatFromInt(di));
                const size = rl.Vector3.init(0.7, ring - 1, 0.7);
                rl.drawCubeV(.init(ring, 0.5, ring), size, .init(color, 0, 255, 255));
                rl.drawCubeV(.init(-ring, 0.5, ring), size, .init(0, color, 255, 255));
                rl.drawCubeV(.init(-ring, 0.5, -ring), size, .init(0, 255, color, 255));
                rl.drawCubeV(.init(ring, 0.5, -ring), size, .init(255, color, 0, 255));
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
    const dt_str = std.fmt.bufPrintZ(&dt_buf, "dt={d:.2} t={d:.2}", .{ dt, time }) catch "???";
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

export fn game_set_title(in: [*:0]const u8) void {
    const slice = zPointerToZSlice(in);
    rl.setWindowTitle(slice);
    copyZSlice(&game_title, slice);
}
export fn game_get_title(out: [*:0]u8) void {
    const slice = zPointerToZSlice(&game_title);
    copyZSlice(out, slice);
}

export fn game_log_info() void {
    emscripten_log(.console, "Log from Zig");
    emscripten_log(.warn, "This is POC. API might change.");
    emscripten_console_log("Main Point to execute raylib logic and event loop");
}

// Untility for \0 c_str convertion with slice
// convert + copy

fn copyZSlice(dest: [*]u8, src: [:0]const u8) void {
    const n = src.len + 1; // +1 for '\0'
    std.mem.copyForwards(u8, dest[0..n], src[0..n]);
    if (dest[n] != '\x00') unreachable;
}
fn copyZPointer(dest: []u8, src: [*:0]const u8) void {
    copyZSlice(dest, zPointerToZSlice(src));
}
fn zPointerToZSlice(src: [*:0]const u8) [:0]const u8 {
    const slice: [:0]const u8 = std.mem.span(src);
    return slice;
}
fn zSliceToZPointer(src: [*:0]const u8) [:0]const u8 {
    const slice: [:0]const u8 = std.mem.span(src);
    return slice;
}
