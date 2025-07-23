const rl = @import("raylib");
const std = @import("std");

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 800;
    const screenHeight = 450;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var bullet_list = std.ArrayList(Bullet).init(arena.allocator());

    rl.initWindow(screenWidth, screenHeight, "raylib-zig [core] example - basic window");
    defer rl.closeWindow(); // Close window and OpenGL context
    //
    //

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    var p = Player.init(0, 0);

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        if (rl.isKeyDown(rl.KeyboardKey.down)) {
            p.down();
        }
        if (rl.isKeyDown(rl.KeyboardKey.up)) {
            p.up();
        }
        if (rl.isKeyDown(rl.KeyboardKey.left)) {
            p.left();
        }
        if (rl.isKeyDown(rl.KeyboardKey.right)) {
            p.right();
        }

        if (rl.isKeyPressed(rl.KeyboardKey.space)) {
            try p.shoot(&bullet_list);
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.white);

        p.draw();
        for (bullet_list.items) |*bullet| {
            bullet.update();
            bullet.draw();
        }
        //----------------------------------------------------------------------------------
    }
}

const Player = struct {
    x: i32,
    y: i32,
    moveBy: i8,
    size: i8,

    pub fn init(x: i32, y: i32) Player {
        return Player{ .x = x, .y = y, .moveBy = 10, .size = 20 };
    }

    pub fn down(self: *Player) void {
        self.y += self.moveBy;
    }

    pub fn up(self: *Player) void {
        self.y -= self.moveBy;
    }

    pub fn left(self: *Player) void {
        self.x -= self.moveBy;
    }

    pub fn right(self: *Player) void {
        self.x += self.moveBy;
    }

    pub fn shoot(self: *Player, list: *std.ArrayList(Bullet)) !void {
        try list.append(Bullet.init(self.x, self.y, UP, self));
        try list.append(Bullet.init(self.x, self.y, DOWN, self));
        try list.append(Bullet.init(self.x, self.y, LEFT, self));
        try list.append(Bullet.init(self.x, self.y, RIGHT, self));
    }

    pub fn draw(self: *Player) void {
        rl.drawRectangle(self.x, self.y, self.size, self.size, rl.Color.red);
    }
};

const Bullet = struct {
    x: i32,
    y: i32,
    moveBy: i8,
    direction: [2]i32,

    pub fn init(x: i32, y: i32, direction: [2]i32, player: *Player) Bullet {
        return Bullet{ .x = x + @divTrunc(player.size, 2), .y = y + @divTrunc(player.size, 2), .direction = direction, .moveBy = 4 };
    }

    pub fn draw(self: *Bullet) void {
        rl.drawCircle(self.x, self.y, 4, rl.Color.red);
    }

    pub fn update(self: *Bullet) void {
        self.x += self.direction[0] * self.moveBy;
        self.y += self.direction[1] * self.moveBy;
    }
};

const UP = [2]i32{ 0, -1 };
const DOWN = [2]i32{ 0, 1 };
const LEFT = [2]i32{ -1, 0 };
const RIGHT = [2]i32{ 1, 0 };
