-- Textual Battery Widget for Awesome Window Manager

local gears = require("gears")
local textbox = require("wibox.widget.textbox")


-- functions to read from files
-- they will fail (error) if there is an issue, so wrap this in `pcall`.
function read_string_from_file(path)
    local f = assert(io.open(path, "r"))
    local content = f:read()
    f:close()
    return content
end

function read_number_from_file(path)
    local string = read_string_from_file(path)
    local number = tonumber(string)
    assert(number ~= nil) -- conversion failed
    return number
end

-- interpret 0 as false, 1 as true and error if there is no conversion to number
function interpret_boolean_from_file(path)
    local number = read_number_from_file(path)
    if number == 0 then
        return false
    elseif number == 1 then
        return true
    else
        error("Cannot interpret value " .. number .. " as boolean")
    end
end


-- base path to the power information folder(s)
local POWER_SUPPLY_INFORMATION_PATH = "/sys/class/power_supply/"

-- symbol for displaying that power adapter is present
local POWER_ADAPTER_PRESENT_SYMBOL = "+AC"

-- this may still use error
function get_text_for_widget_with_errors(battery_name_in_sys, power_adapter_name_in_sys)
    local text = "|"
    local is_battery_present = interpret_boolean_from_file(POWER_SUPPLY_INFORMATION_PATH .. battery_name_in_sys .. "/present")

    if is_battery_present then
        local current_capacity_in_percent = read_number_from_file(POWER_SUPPLY_INFORMATION_PATH .. battery_name_in_sys .. "/capacity")
        text = text .. "Bat: " .. current_capacity_in_percent .. "%"
    else
        text = text .. "NO Bat"
    end

    local is_power_adapter_present = interpret_boolean_from_file(POWER_SUPPLY_INFORMATION_PATH .. power_adapter_name_in_sys .. "/online")
    if is_power_adapter_present then
        text = text .. " " .. POWER_ADAPTER_PRESENT_SYMBOL
    end

    text = text .. "|"

    return text
end

-- assemble the text for the widget
-- this does not use error
function get_text_for_widget(battery_name_in_sys, power_adapter_name_in_sys)
    local worked, text = pcall(get_text_for_widget_with_errors, battery_name_in_sys, power_adapter_name_in_sys)
    if worked then
        return text
    else
        return " bat error "
    end
end


-- return a widget that will show the current battery status
-- Note: Due the the bug
--           https://bugs.launchpad.net/ubuntu/+source/linux/+bug/971061
--       the charging/discharging is not displayed correctly in ACPI.
--       As a work around, display the status of the power supply.
-- returns a textbox
function textual_battery_widget_factory(battery_name_in_sys, power_adapter_name_in_sys, cycle_duration_in_seconds)
    cycle_duration_in_seconds = cycle_duration_in_seconds or 10 -- default value for cycle_duration_in_seconds

    local textbox_widget = textbox()

    local function update_text_in_textbox()
        local text = get_text_for_widget(battery_name_in_sys, power_adapter_name_in_sys)
        textbox_widget:set_text(text)
    end

    update_text_in_textbox() -- initially set the value

    local timer = gears.timer {
        timeout = cycle_duration_in_seconds,
        autostart = true,
        callback = update_text_in_textbox, -- update the value by the timer
    }

    return textbox_widget
end



return textual_battery_widget_factory
