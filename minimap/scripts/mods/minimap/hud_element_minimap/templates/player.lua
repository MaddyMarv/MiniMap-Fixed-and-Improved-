local UIWidget = require("scripts/managers/ui/ui_widget")
local mod = get_mod("minimap")

local template = {}
local settings = mod:io_dofile("minimap/scripts/mods/minimap/hud_element_minimap/hud_element_minimap_settings")

template.create_widget_definition = function(settings, scenegraph_id)
    return UIWidget.create_definition({
        {
            style_id = "icon",
            pass_type = "text",
            value_id = "icon_text",
            value = "",
            style = {
                horizontal_alignment = "center",
                vertical_alignment = "center",
                text_vertical_alignment = "center",
                text_horizontal_alignment = "center",
                drop_shadow = false,
                font_type = "proxima_nova_bold",
                font_size = 20,
                text_color = Color.ui_hud_green_light(255, true),
                default_text_color = Color.ui_hud_green_light(255, true),
                size = settings.icon_size
            }
        },
        {
            style_id = "distance_text",
            pass_type = "text",
            value_id = "distance_text",
            value = "",
            style = {
                horizontal_alignment = "center",
                vertical_alignment = "center",
                text_vertical_alignment = "center",
                text_horizontal_alignment = "center",
                drop_shadow = true,
                font_type = "proxima_nova_bold",
                font_size = 12,
                text_color = Color.white(255, true),
                offset = { 0, 0, 1 },
                size = { 100, 20 }
            }
        },
    }, scenegraph_id)
end

template.update_function = function(widget, marker, x, y, vertical_distance, range, is_out_of_range)
    local icon = widget.style.icon
    local distance_text_style = widget.style.distance_text
    icon.offset[1] = x
    icon.offset[2] = y
    distance_text_style.offset[1] = x
    distance_text_style.offset[2] = y + (settings.icon_size[2] * 0.5) + 12

    local show_distance = mod.settings and mod.settings.distance_markers and mod.settings.distance_markers.players
    local only_out_of_range = mod.settings and mod.settings.distance_markers and mod.settings.distance_markers.only_out_of_range
    local icon_visible = icon.visible ~= false
    local should_show_distance = show_distance and range and (not only_out_of_range or is_out_of_range) and icon_visible
    local show_name = mod.settings and mod.settings.display_names and mod.settings.display_names.display_name_players
    local should_show_name = show_name and icon_visible

    widget.content.distance_text = ""
    distance_text_style.visible = false

    local texts = {}
    if should_show_distance then
        local distance_m = math.floor(range * 10) / 10
        texts[#texts+1] = string.format("%.1fm", distance_m)
    end
    if should_show_name then
        if mod and mod.get_player_display_name then
            local name = mod.get_player_display_name(marker)
            if name then
                texts[#texts+1] = name
            end
        end
    end

    if #texts > 0 then
        widget.content.distance_text = table.concat(texts, "\n")
        distance_text_style.visible = true
    end
end

return template
