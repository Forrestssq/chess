-- 在 VS Code 里按 F5 调试时自动挂上调试器
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

Object = require 'libs/classic'
Piece = require 'piece_class'

draw_chessboard = require 'chessboard'
pieces_table = require 'load_pieces'
draw_piece = require 'draw_piece'

-- 这个 pieces_status 的格式是： 一个 piece 用一个 piece_class 记录。
board = require 'load_opening_pieces_status'
display = require 'display'
function love.load()
    love.graphics.setBackgroundColor(0, 0, 0)
    board = board('w')
    
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
