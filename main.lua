-- 在 VS Code 里按 F5 调试时自动挂上调试器
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

Object = require 'libs/classic'
Piece = require 'src/utils/piece_class'

draw_chessboard = require 'src/utils/chessboard'
pieces_table = require 'src/utils/load_pieces'
draw_piece = require 'src/utils/draw_piece'

-- 这个 pieces_status 的格式是： 一个 piece 用一个 piece_class 记录。
load_board = require 'src/utils/load_opening_pieces_status'
display = require 'src/utils/display'
function love.load()
    love.graphics.setBackgroundColor(0, 0, 0)
    board = load_board('w')
end

function love.update(dt)

end

function love.draw()
    draw_chessboard() -- 画棋盘
    draw_piece(pieces_table.wR, 1, 1)
    display()
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    -- x, y: 按下位置(像素)
    -- button: 1=左键, 2=右键, 3=中键
end

function love.mousereleased(x, y, button, istouch, presses)
    
end

function love.mousemoved(x, y, dx, dy, istouch)
    
end

function love.wheelmoved(dx, dy)
    
end

