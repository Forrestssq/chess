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

-- 记录轮到谁了
TURN = START_WITH

-- 轮到对方了的时候调用。 会改变 TURN 的值(black or white)
function TURN_TURN()
    TURN = (TURN == 'white') and 'black' or 'white'
end

-- 记录是不是可以吃过路兵。 这个记录的是可以吃过路兵所走的格子。 
-- 比如记录有 { 3, 3 } 则表示 对方可以下 { 3, 3 } 这个格子来吃掉白方的过路兵。
-- 如果没有 ，则为 nil 
EN_PASSANT_TARGET = nil

-- render 函数模块（local的）
local render = require 'src.utils.render'

local coord = require("src.utils.coord")
local BOARD_adjust = require("src.utils.BOARD_adjust")

-- 记录是否有棋子被选中
local selected = false
local selected_col, selected_row = nil, nil
function love.load()
    love.graphics.setBackgroundColor(0, 0, 0)
end

-- 记录选中的棋子 可以吃掉的棋子位置（用来高亮）
EATABLE_PIECES_POS_TABLE = {}

function love.update(dt)

end

function love.draw()
    if not selected then
        selected_col = nil
        selected_row = nil
        EATABLE_PIECES_POS_TABLE = {}
    end

    render.draw_chessboard() -- 画棋盘
    if selected and selected_row and selected_col then
        for _, pos in ipairs(EATABLE_PIECES_POS_TABLE) do
            render.highlight_eatable_pieces(pos[1], pos[2])
        end
        render.highlight_selected_pieces(selected_col, selected_row)
        ---@diagnostic disable-next-line
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
    
    -- 单击选中棋子
    if coord.is_click_valid(col, row) then
        -- 如果在点击了一个 valid 的棋子之后， 再次点击另一个 valid 的棋子，
        -- 其他的逻辑照常， 只是需要将 EATABLE_PIECES_POS_TABLE 这个 table 清空
        -- 否则， 连续选中多个 valid 的棋子， EATABLE_PIECES_POS_TABLE 中的东西将 “叠加”
        -- 判断方法就是， 如果之前已经选中了， 而现在又进入了这个 if 语句（即， 又有一个 is_click_valid ）
        -- 那么就表明是上述情景
        if selected then
            EATABLE_PIECES_POS_TABLE = {}
        end
        
        if (col == selected_col) and (row == selected_row) then 
        -- 两次点击同一个棋子， 当作取消。
        -- 若先前未选中棋子， 则 selected_col 和 selected_row 都是 nil ，不会进入这个逻辑
        -- 若已经 selected 的话， 则表示已经进入过 下面的 else 逻辑 。然后你就知道怎么回事了
            selected = false
        else
            selected = true
            selected_col = col
            selected_row = row            
        end
    end

    -- 移动棋子
    ---@diagnostic disable: need-check-nil
    if selected and ((col ~= selected_col) or (row ~= selected_row)) then
        local unified_input = {selected_col, selected_row, col, row} -- 把位置打包传给他

        if coord.is_en_passant_move() then
            BOARD_adjust.en_passant(unified_input)
        elseif coord.is_queenside_castling_move() then
            BOARD_adjust.castle_queenside(unified_input)
        elseif coord.is_rookside_castling_move() then
            BOARD_adjust.castle_rookside(unified_input)
        else -- 正常的移动棋子的情况
            if BOARD[col][row] ~= 0 then
                BOARD_adjust.eat_piece(unified_input)
            else
                BOARD_adjust.move_piece(unified_input)
            end
        end
        coord.has_moved(col, row) -- 要用 col 而不是 selected_col 因为上面的 BOARD_adjust 函数门已经把棋盘上的棋子改过了
        selected = false    -- 下一步棋之后取消选中
        -- TURN_TURN() -- 轮到对面下棋了
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    
end

function love.mousemoved(x, y, dx, dy, istouch)
    
end

function love.wheelmoved(dx, dy)
    
end
