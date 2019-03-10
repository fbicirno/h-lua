hweather = {
    --天气ID
    sun = hsystem.getObjId('LRaa'), --日光
    moon = hsystem.getObjId('LRma'), --月光
    shield = hsystem.getObjId('MEds'), --紫光盾
    rain = hsystem.getObjId('RAlr'), --雨
    rainstorm = hsystem.getObjId('RAhr'), --大雨
    snow = hsystem.getObjId('SNls'), --雪
    snowstorm = hsystem.getObjId('SNhs'), --大雪
    wind = hsystem.getObjId('WOlw'), --风
    windstorm = hsystem.getObjId('WNcw'), --大风
    mistwhite = hsystem.getObjId('FDwh'), --白雾
    mistgreen = hsystem.getObjId('FDgh'), --绿雾
    mistblue = hsystem.getObjId('FDbh'), --蓝雾
    mistred = hsystem.getObjId('FDrh'), --红雾

    --删除天气
    del = function(w, during)
        if (during <= 0) then
            cj.EnableWeatherEffect(w, false)
            cj.RemoveWeatherEffect(w)
        else
            htime.setTimeout(during, nil, function(t, td)
                htime.delDialog(td)
                htime.delTimer(t)
                cj.EnableWeatherEffect(w, false)
                cj.RemoveWeatherEffect(w)
            end)
        end
    end,
    --[[
        创建天气
        options = {
            x=0,y=0, 坐标
            w=0,h=0, 长宽
            type=hweather.sun 天气类型
            during=10 持续时间小于等于0=无限
        }
    ]]--
    create = function(bean)
        if (bean.w == nil or bean.h == nil or bean.w <= 0 or bean.h <= 0) then
            print("hweather.create -w-h")
            return nil
        end
        if (bean.x == nil or bean.y == nil) then
            print("hweather.create -x-y")
            return nil
        end
        if (bean.type == nil) then
            print("hweather.create -type")
            return nil
        end
        local r = hrect.createLoc(bean.x, bean.y, bean.w, bean.h)
        local w = cj.AddWeatherEffect(r, bean.type)
        if (bean.during > 0) then
            htime.setTimeout(bean.during, nil, function(t, td)
                htime.delDialog(td)
                htime.delTimer(t)
                cj.RemoveRect(r)
                cj.EnableWeatherEffect(w, false)
                cj.RemoveWeatherEffect(w)
            end)
        end
    end,
}
