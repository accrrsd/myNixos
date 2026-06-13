-- Parse Matugen colors.conf and apply to border colors
local colors = {}
local colors_file = os.getenv("HOME") .. "/.config/hypr/colors.conf"
local file = io.open(colors_file, "r")

if file then
    for line in file:lines() do
        -- Match lines of form: $name = value
        local name, val = line:match("^%$([%w_]+)%s*=%s*(.-)%s*$")
        if name and val then
            colors[name] = val
        end
    end
    file:close()
end

-- Apply to general section
hl.config({
    general = {
        ["col.inactive_border"] = colors.background or "rgba(1a1a1aff)",
        ["col.active_border"] = colors.inverse_primary or "rgba(ffffffff)"
    }
})
