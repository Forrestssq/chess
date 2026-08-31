local tools = {}

--- 把 array 从 index 位置开始往后删完（包括 index 项本身）。 返回删完的 table
---@param target_array table
---@param index number
---@return table
function tools.remove_items_after_index(target_array, index)
    for i = #target_array, index, -1 do
        target_array[i] = nil
    end
    return target_array
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

---调试用的
---@param t table
function tools.print_table(t)
    for index, value in ipairs(t) do
        if type(value) == 'table' then
            tools.print_table(value)
        else
            print(index .. '\t' .. tostring(value))
        end
    end
end

--- 调试用
--- 打印出来传入的位置上的棋子的名字
--- 可以传 col 和 row
--- 也可以传入一个 pos table， 打包有 col 和 row
---@param col number | table
---@param row number
function tools.print_piece_type(col, row)
    if type(col) == 'table' then
        col = col[1]
        row = col[2]
    end
    local value = BOARD[col][row]
    if value == 0 then
        print("Empty")
    else
        print(value:name())
    end
end

return tools