---@class hmultiBoard 多面板/多列榜
hmultiBoard = {}

--- 根据玩家创建多面板
--- 多面板是可以每个玩家看到的都不一样的
--- yourData会返回当前的多面板和玩家索引
--- 你需要设置数据传回到create中来，拼凑多面板数据，二维数组，行列模式
---@alias hmultiBoard fun(whichBoard: userdata,playerIndex:number):void
---@param key string 多面板唯一key
---@param refreshFrequency number 刷新频率
---@param yourData hmultiBoard | "function(whichBoard,playerIndex) return {{value = '标题',icon = '图标'}} end"
hmultiBoard.create = function(key, refreshFrequency, yourData)
    --判断玩家各自的多面板属性
    for pi = 1, hplayer.qty_max, 1 do
        local p = hplayer.players[pi]
        if (his.playing(p)) then
            if (hRuntime.multiBoard[pi] == nil) then
                hRuntime.multiBoard[pi] = {
                    visible = true,
                    timer = nil,
                    borads = {}
                }
            end
            if (hRuntime.multiBoard[pi].borads[key] ~= nil) then
                cj.DestroyMultiboard(hRuntime.multiBoard[pi].borads[key])
            end
            hRuntime.multiBoard[pi].borads[key] = cj.CreateMultiboard()
            --title
            cj.MultiboardSetTitleText(hRuntime.multiBoard[pi].borads[key], "多面板")
            --
            hRuntime.multiBoard[pi].timer = htime.setInterval(
                refreshFrequency,
                function()
                    --检查玩家是否隐藏了多面板 -mbv
                    if (hRuntime.multiBoard[pi].visible ~= true) then
                        if (cj.GetLocalPlayer() == p) then
                            cj.MultiboardDisplay(hRuntime.multiBoard[pi].borads[key], false)
                        end
                        --而且隐藏就没必要展示数据了，后续流程中止
                        return
                    end
                    local data = yourData(hRuntime.multiBoard[pi].borads[key], pi)
                    local totalRow = #data
                    local totalCol = 0
                    if (totalRow > 0) then
                        totalCol = #data[1]
                    end
                    if (totalRow <= 0 or totalCol <= 0) then
                        print_err("Multiboard:-totalRow -totalCol")
                        return
                    end
                    --设置行列数
                    cj.MultiboardSetRowCount(hRuntime.multiBoard[pi].borads[key], totalRow)
                    cj.MultiboardSetColumnCount(hRuntime.multiBoard[pi].borads[key], totalCol)
                    local widthCol = {}
                    for row = 1, totalRow, 1 do
                        for col = 1, totalCol, 1 do
                            local item = cj.MultiboardGetItem(hRuntime.multiBoard[pi].borads[key], row - 1, col - 1)
                            local isSetValue = false
                            local isSetIcon = false
                            local width = 0
                            local valueType = type(data[row][col].value)
                            if (valueType == "string" or valueType == "number") then
                                isSetValue = true
                                if (valueType == "number") then
                                    data[row][col].value = tostring(data[row][col].value)
                                end
                                width = width + string.mb_len(data[row][col].value)
                                if ((row - 1) == pi) then
                                    data[row][col].value = hColor.yellow(data[row][col].value)
                                end
                                cj.MultiboardSetItemValue(item, data[row][col].value)
                            end
                            if (type(data[row][col].icon) == "string") then
                                isSetIcon = true
                                cj.MultiboardSetItemIcon(item, data[row][col].icon)
                                width = width + 3
                            end
                            cj.MultiboardSetItemStyle(item, isSetValue, isSetIcon)
                            if (widthCol[col] == nil) then
                                widthCol[col] = 0
                            end
                            if (width > widthCol[col]) then
                                widthCol[col] = width
                            end
                        end
                    end
                    for row = 1, totalRow, 1 do
                        for col = 1, totalCol, 1 do
                            cj.MultiboardSetItemWidth(
                                cj.MultiboardGetItem(hRuntime.multiBoard[pi].borads[key], row - 1, col - 1),
                                widthCol[col] / 140
                            )
                        end
                    end
                    --显示
                    if (cj.GetLocalPlayer() == p) then
                        cj.MultiboardDisplay(hRuntime.multiBoard[pi].borads[key], true)
                    end
                end
            )
        end
    end
end

--- 设置标题
---@param whichBoard userdata
---@param title string
hmultiBoard.setTitle = function(whichBoard, title)
    cj.MultiboardSetTitleText(whichBoard, title)
end
