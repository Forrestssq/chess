-- 在 VS Code 里按 F5 调试时自动挂上调试器
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    ---@diagnostic disable-next-line 
    require("lldebugger").start()
end

Object = require 'libs/classic'
Piece = require 'src/utils/piece_class'

local draw_chessboard = require 'src/utils/chessboard'
PIECES_ICON_DICT = require 'src/utils/load_pieces_icon'
FUNC_DRAW_PIECE = require 'src/utils/draw_piece'

-- 这个 pieces_status 的格式是： 一个 piece 用一个 piece_class 记录。
local load_board = require 'src/utils/load_opening_pieces_status'

-- BOARD 8x8 的 table 负责当前棋盘的状态
BOARD = load_board('w')

local display = require 'src/utils/display'

function love.load()
    love.graphics.setBackgroundColor(0, 0, 0)
    
end

function love.update(dt)

end

function love.draw()
    draw_chessboard() -- 画棋盘
    FUNC_DRAW_PIECE(PIECES_ICON_DICT.wR, 1, 1)
    display()
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

-- 记录是否有棋子被选中
local selected = false


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

