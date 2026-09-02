local tools = {}

--- 把 array 从 index 位置开始往后删完（包括 index 项本身）。
---@param target_array table
---@param index number
---@return nil
function tools.remove_items_after_index(target_array, index)
    for i = #target_array, index, -1 do
        target_array[i] = nil
    end
end

--- 对 table 进行 deepcopy , 返回这个新的 table
---@param target table
---@return table
function tools.deepcopy_table(target)
    local output = {}
    for _, v in ipairs(target) do
        table.insert(output, v)
    end
    return output
end

--- 查询一个表格自己的名字本身。
--- 通过地址去存放着全局变量的表格 _G 中查找出来名字
--- 没找到的话， 返回 table not found
---@param target_table any
---@return unknown
function tools.get_table_name(target_table)
    for name, value in pairs(_G) do
        if value == target_table then
            return name
        end
    end
    return " table not found "
end

---调试用, 打印 POSSIBLE_TABLE
function tools.print_POSSIBLE_table()
    print('POSSIBLE_TABLE')
    for index_1, line in ipairs(POSSIBLE_TABLE) do
        for index_2, pos in ipairs(line) do
            io.write(pos[1], '\t', pos[2], '\n')
        end
    end
    print()
end

function tools.print_EATABLE_TABLE()
    print("EATABLE_TABLE")
    for index, pos in ipairs(EATABLE_TABLE) do
        io.write(pos[1], '\t', pos[2], '\n')
    end
    print()
end

--- 调试用
--- 打印出来传入的位置上的棋子的名字
--- 可以传 col 和 row
--- 也可以传入一个 pos table， 打包有 col 和 row
---@param col number | table
---@param row number
function tools.print_piece_type(col, row)
    if type(col) == 'table' then
        row = col[2]
        col = col[1]
    end
    local value = BOARD[col][row]
    if value == 0 then
        print("Empty")
    else
        ---@diagnostic disable-next-line
        print(value:name())
    end
end

return tools