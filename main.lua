-- 在 VS Code 里按 F5 调试时自动挂上调试器
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    ---@diagnostic disable-next-line 
    require("lldebugger").start()
end

Object = require 'libs.classic'
Piece = require 'src.utils.piece_class'

-- 这个 pieces_status 的格式是： 一个 piece 用一个 piece_class 记录。BOARD 8x8 的 table 负责当前棋盘的状态
local load_board = require 'src.utils.load_opening_pieces_status'

START_WITH = 'black'
BOARD = load_board(START_WITH)

render = require 'src.utils.render'

local coord = require("src.utils.coord")

-- 记录是否有棋子被选中
local selected = false
local selected_col, selected_row = nil, nil
function love.load()
    love.graphics.setBackgroundColor(0, 0, 0)
end

function love.update(dt)

end

function love.draw()
    render.draw_chessboard() -- 画棋盘
    if selected then
        render.highlight_piece(selected_col, selected_row)
        render.render_possible_pos(BOARD[selected_col][selected_row], selected_col, selected_row)
    end
    render.display()
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    -- x, y: 按下位置(像素)
    -- button: 1=左键, 2=右键, 3=中键

    -- 用左键点击才有效
    if not coord.is_left_button_click(button) then return end

    local col, row = coord.pixel_to_cell(x, y)
    
    if coord.is_click_valid(col, row) then
        print("______I'm in_______")
        -- 两次点击的话， 当作取消
        if (col == selected_col) and (row == selected_row) then
            selected = false
            selected_col = nil
            selected_row = nil
        else
            selected = true
            selected_col = col
            selected_row = row            
        end
    end

    -- 移动棋子
    if selected and ((col ~= selected_col) or (row ~= selected_row)) then
        ---@diagnostic disable-next-line
        local piece = BOARD[selected_col][selected_row]
        ---@diagnostic disable-next-line
        BOARD[selected_col][selected_row] = 0
        ---@diagnostic disable-next-line
        BOARD[col][row] = piece
        selected_col = col
        selected_row = row
        selected = false    -- 下一步棋之后取消选中
    end
    print('\n')

end

function love.mousereleased(x, y, button, istouch, presses)
    
end

function love.mousemoved(x, y, dx, dy, istouch)
    
end

function love.wheelmoved(dx, dy)
    
end
