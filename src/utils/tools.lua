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

return tools