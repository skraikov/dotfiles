-- {{{ Markup functions
function setBg(bgcolor, text)
    if text ~= nil then
        return string.format('<bg color="%s" />%s', bgcolor, text)
    end
end

function setFg(fgcolor, text)
    if text ~= nil then
        return string.format('<span color="%s">%s</span>', fgcolor, text)
    end
end

function setBgFg(bgcolor, fgcolor, text)
    if text ~= nil then
        return string.format('<bg color="%s"/><span color="%s">%s</span>', bgcolor, fgcolor, text)
    end
end

function setFont(font, text)
    if text ~= nil then
        return string.format('<span font_desc="%s">%s</span>', font, text)
    end
end
-- }}}

-- {{{ getlayouticon(layout)
function getlayouticon(s)
   if not awful.layout.get(s) then return "   " end
   layoutname = awful.layout.getname(awful.layout.get(s))
   layouticon = layout_icons[layoutname]
   if not layouticon then return layoutname end
   return layouticon
end
-- }}}

-- {{{ Calendar
local calendar = nil
local offset = 0

function remove_calendar()
    if calendar ~= nil then
        naughty.destroy(calendar)
        calendar = nil
        offset = 0
    end
end

function add_calendar(inc_offset)
    local save_offset = offset
    remove_calendar()
    offset = save_offset + inc_offset
    local datespec = os.date("*t")
    datespec = datespec.year * 12 + datespec.month - 1 + offset
    datespec = (datespec % 12 + 1) .. " " .. math.floor(datespec / 12)
    local cal = awful.util.pread("cal -m " .. datespec)
    cal = string.gsub(cal, "^%s*(.-)%s*$", "%1")
    calendar = naughty.notify({
        text     = cal,  --string.format('<span font_desc="%s">%s</span>', "Terminus",
                   --setFg(beautiful.fg_focus, os.date("%a, %d %B %Y")) .. "\n" .. setFg(beautiful.fg_widg, cal)),
        timeout  = 0, hover_timeout = 0.5,
        width    = 145,
        position = "top_right",
        bg       = beautiful.bg_focus
    })
end
-- }}}
