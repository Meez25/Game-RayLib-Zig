const rl = @import("raylib");
const std = @import("std");

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const SCREENWIDTH = 1600;
    const SCREENHEIGHT = 900;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    // var bullet_list = std.ArrayList(Bullet).init(arena.allocator());
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.initWindow(SCREENWIDTH, SCREENHEIGHT, "raylib-zig [core] example - basic window");

    var img = try rl.loadImage("src/mael.png"); // Peut échouer → on met try
    defer rl.unloadImage(img); // Libère l'image CPU

    rl.imageResize(&img, 80, 80);

    const playerTexture = try rl.loadTextureFromImage(img); // Peut échouer aussi
    defer rl.unloadTexture(playerTexture); // Libère la texture GPU
    //
    //

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    var p = Player.init(SCREENHEIGHT, SCREENWIDTH, playerTexture);
    const platform = Platform.init(100, SCREENHEIGHT - 100, 100, 20);
    const platform2 = Platform.init(200, SCREENHEIGHT - 200, 100, 20);
    const platform3 = Platform.init(300, SCREENHEIGHT - 300, 100, 20);
    const PlatformArray = [_]Platform{ platform, platform2, platform3 };
    p.spawn();

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        if (rl.isKeyDown(rl.KeyboardKey.left)) {
            p.left();
        }
        if (rl.isKeyDown(rl.KeyboardKey.right)) {
            p.right();
        }

        if (rl.isKeyPressed(rl.KeyboardKey.space)) {
            p.jump();
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.white);

        p.update(&PlatformArray);
        p.draw();
        for (PlatformArray) |platformItem| {
            platformItem.draw();
        }
    }
}

const Platform = struct {
    height: i32,
    width: i32,
    x: i32,
    y: i32,

    pub fn init(x: i32, y: i32, width: i32, height: i32) Platform {
        return Platform{ .height = height, .width = width, .x = x, .y = y };
    }

    pub fn draw(self: *const Platform) void {
        rl.drawRectangle(self.x, self.y, self.width, self.height, rl.Color.blue);
    }
};

const Player = struct {
    x: i32,
    y: i32,
    moveBy: i8,
    size: i8,
    speedY: i8,
    SCREENHEIGHT: i32,
    SCREENWIDTH: i32,
    onGround: bool,
    gravity: i8,
    texture: rl.Texture2D,

    pub fn init(SCREENHEIGHT: i32, SCREENWIDTH: i32, texture: rl.Texture2D) Player {
        return Player{ .x = 0, .y = 0, .moveBy = 10, .size = 80, .SCREENHEIGHT = SCREENHEIGHT, .SCREENWIDTH = SCREENWIDTH, .speedY = 0, .onGround = true, .gravity = 1, .texture = texture };
    }

    pub fn jump(self: *Player) void {
        if (!self.onGround) {
            return;
        }
        self.speedY = -20;
        self.onGround = false;
    }

    pub fn spawn(self: *Player) void {
        self.y = self.SCREENHEIGHT - self.size;
        self.x = @divFloor(self.SCREENWIDTH, 2);
    }

    pub fn left(self: *Player) void {
        self.x -= self.moveBy;
        if (self.x < 0) {
            self.x = 0;
        }
    }

    pub fn right(self: *Player) void {
        self.x += self.moveBy;
        if (self.x > self.SCREENWIDTH - self.size) {
            self.x = self.SCREENWIDTH - self.size;
        }
    }

    pub fn update(self: *Player, platforms: []const Platform) void {
        self.speedY += self.gravity;
        self.y += self.speedY;
        self.onGround = false;

        for (platforms) |platform| {
            const collisionX = self.x + self.size > platform.x and self.x < platform.x + platform.width;
            const collisionY = self.y + self.size >= platform.y and self.y + self.size <= platform.y + platform.height;

            // On ne corrige que si on descend
            if (collisionX and collisionY and self.speedY > 0) {
                self.y = platform.y - self.size;
                self.onGround = true;
                self.speedY = 0;
            }
        }

        // Collision avec le sol
        if (self.y > self.SCREENHEIGHT - self.size) {
            self.y = self.SCREENHEIGHT - self.size;
            self.onGround = true;
            self.speedY = 0;
        }
    }

    pub fn draw(self: *Player) void {
        rl.drawTexture(self.texture, self.x, self.y, rl.Color.white);
    }
};
