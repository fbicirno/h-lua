-- 漂浮字
local htextTag = {}

-- 删除漂浮字
htextTag.del = function(ttg)
    cj.DestroyTextTag(ttg)
end
-- 创建漂浮字
-- 设置during为0则永久显示
-- opacity设置为0则不可见(0.0~1.0)
-- color为6位颜色代码 http://www.atool.org/colorpicker.php
htextTag.create = function(msg, size, color, opacity, during)
    if (string.len(msg) <= 0 or during < 0) then
        return nil
    end
    if (opacity >= 1) then
        opacity = 1
    elseif (opacity < 0) then
        opacity = 0
    end
    local ttg = cj.CreateTextTag()
    if (color ~= nil and string.len(color) == 6) then
        msg = "|cff" .. color .. msg .. "|r"
    end
    hRuntime.textTag[ttg] = {
        msg = msg,
        size = size,
        color = color,
        opacity = opacity,
        during = during
    }
    cj.SetTextTagText(ttg, msg, size * 0.023 / 10)
    cj.SetTextTagColor(ttg, 255, 255, 255, math.floor(255 * opacity))
    if (during == 0) then
        cj.SetTextTagPermanent(ttg, true)
    else
        cj.SetTextTagPermanent(ttg, false)
        cj.SetTextTagLifespan(ttg, during)
        cj.SetTextTagFadepoint(ttg, during)
    end
    return ttg
end
-- 漂浮文字 - 默认 (在x,y)
htextTag.create2XY = function(x, y, msg, size, color, opacity, during, zOffset)
    local ttg = htextTag.create(msg, size, color, opacity, during)
    cj.SetTextTagPos(ttg, x - cj.StringLength(msg) * size * 0.5, y, zOffset)
    return ttg
end
-- 漂浮文字 - 默认 (在某单位头上)
htextTag.create2Unit = function(u, msg, size, color, opacity, during, zOffset)
    return htextTag.create2XY(cj.GetUnitX(u), cj.GetUnitY(u), msg, size, color, opacity, during, zOffset)
end
-- 漂浮文字 - 默认 (在某点上)
htextTag.create2Loc = function(loc, msg, size, color, opacity, during, zOffset)
    return htextTag.create2XY(cj.GetLocationX(u), cj.GetLocationY(u), msg, size, color, opacity, during, zOffset)
end
-- 漂浮文字 - 默认 (绑定在某单位头上，跟随移动)
htextTag.createFollowUnit = function(u, msg, size, color, opacity, during, zOffset)
    local ttg = htextTag.create2Unit(u, msg, size, color, opacity, during, zOffset)
    local txt = htextTag.getMsg(ttg)
    local scale = 0.5
    htime.setInterval(
        0.03,
        function()
            if (hcamera.model == "zoomin") then
                scale = 0.25
            elseif (hcamera.model == "zoomout") then
                scale = 1
            end
            cj.SetTextTagPos(ttg, cj.GetUnitX(u) - cj.StringLength(txt) * size * scale, cj.GetUnitY(u), zOffset)
            if (his.alive(u) == true) then
                cj.SetTextTagVisibility(ttg, true)
            else
                cj.SetTextTagVisibility(ttg, false)
            end
        end
    )
    return ttg
end
-- 获取漂浮字大小
htextTag.getSize = function(ttg)
    return hRuntime.textTag[ttg].size
end
-- 获取漂浮字颜色
htextTag.getColor = function(ttg)
    return hRuntime.textTag[ttg].color
end
-- 获取漂浮字内容
htextTag.getMsg = function(ttg)
    return hRuntime.textTag[ttg].msg
end
-- 获取漂浮字透明度
htextTag.getOpacity = function(ttg)
    return hRuntime.textTag[ttg].opacity
end
-- 获取漂浮字持续时间
htextTag.getDuring = function(ttg)
    return hRuntime.textTag[ttg].during
end
-- 风格特效
htextTag.style = function(ttg, showtype, xspeed, yspeed)
    cj.SetTextTagVelocity(ttg, xspeed, yspeed)
    if (showtype == "scale") then
        -- 放大
        local size = htextTag.getSize(ttg)
        local tnow = 0
        local tend = 0.5
        htime.setInterval(
            0.03,
            function(t, td)
                tnow = tnow + cj.TimerGetTimeout(t)
                if (tnow >= tend) then
                    htime.delDialog(td)
                    htime.delTimer(t)
                    return
                end
                cj.SetTextTagText(ttg, htextTag.getMsg(ttg), (size * (1 + tnow * 0.5 / tend)) * 0.023 / 10)
            end
        )
    elseif (showtype == "shrink") then
        -- 缩小
        local size = htextTag.getSize(ttg)
        local tnow = 0
        local tend = 0.5
        htime.setInterval(
            0.03,
            function(t, td)
                tnow = tnow + cj.TimerGetTimeout(t)
                if (tnow >= tend) then
                    htime.delDialog(td)
                    htime.delTimer(t)
                    return
                end
                cj.SetTextTagText(ttg, htextTag.getMsg(ttg), (size * (1 - tnow * 0.5 / tend)) * 0.023 / 10)
            end
        )
    elseif (showtype == "toggle") then
        -- 放大再缩小
        local size = htextTag.getSize(ttg)
        local tnow = 0
        local tend1 = 0.2
        local tend2 = 0.2
        local during = 0.7
        htime.setInterval(
            0.03,
            function(t, td)
                tnow = tnow + cj.TimerGetTimeout(t)
                if (tnow >= tend1 + tend2 + during) then
                    htime.delDialog(td)
                    htime.delTimer(t)
                    return
                end
                if (tnow <= tend1) then
                    cj.SetTextTagText(ttg, htextTag.getMsg(ttg), (size * (1 + tnow / tend1)) * 0.023 / 10)
                elseif (tnow > tend1 + during) then
                    cj.SetTextTagText(
                        ttg,
                        htextTag.getMsg(ttg),
                        (size * 2 - (5 * (tnow - tend1 - during) / tend2)) * 0.023 / 10
                    )
                end
            end
        )
    end
end

return htextTag
