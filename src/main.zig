const rl = @import("raylib");

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 800;
    const screenHeight = 450;

    rl.initWindow(screenWidth, screenHeight, "raylib-zig [core] example - basic window");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    var startX: i32 = 0;
    var startY: i32 = 0;

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        if (rl.isKeyDown(rl.KeyboardKey.down)) {
            startY += 10;
        }
        if (rl.isKeyDown(rl.KeyboardKey.up)) {
            startY -= 10;
        }
        if (rl.isKeyDown(rl.KeyboardKey.left)) {
            startX -= 10;
        }
        if (rl.isKeyDown(rl.KeyboardKey.right)) {
            startX += 10;
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.white);

        rl.drawRectangle(startX, startY, 50, 50, rl.Color.red);
        //----------------------------------------------------------------------------------
    }
}
