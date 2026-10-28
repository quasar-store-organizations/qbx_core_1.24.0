local qbShared = require 'shared.main'
-- qs-inventory registers the items made in its in-game creator a moment after
-- it starts, and can add or change them at any time. The lists are read once
-- those are in, and again whenever qs-inventory reports a change.
local isServer = IsDuplicityVersion()

local function syncItems()
    local ok, items = pcall(function() return exports['qs-inventory']:GetItemList() end)
    if ok and type(items) == 'table' then qbShared.Items = items end
    local okWeapons, weapons = pcall(function() return exports['qs-inventory']:GetWeaponList() end)
    if okWeapons and type(weapons) == 'table' then qbShared.Weapons = weapons end
end

local function waitForItemList()
    if not isServer then return end
    local deadline = GetGameTimer() + 30000
    while GetGameTimer() < deadline do
        if GetResourceState('qs-inventory') == 'started' then
            local ok, ready = pcall(function() return exports['qs-inventory']:ItemListReady() end)
            -- An older qs-inventory has no such export: its list is complete as it is.
            if not ok or ready then return end
        end
        Wait(250)
    end
end

CreateThread(function()
    syncItems()
    waitForItemList()
    syncItems()
end)

-- No QBCore:*:UpdateObject here: qs-inventory answers that event by applying its
-- creator items again, which would fire this one again.
AddEventHandler('qs-inventory:itemListUpdated', syncItems)

local starterItems = require 'config.shared'.starterItems
---@deprecated use starterItems in config/shared.lua
qbShared.StarterItems = {}

if type(starterItems) == 'table' then
    for i = 1, #starterItems do
        local item = starterItems[i]

        ---@diagnostic disable-next-line: deprecated
        qbShared.StarterItems[item.name] = {
            amount = item.amount,
            item = item.name,
        }
    end
end

---@deprecated use lib.math.groupdigits from ox_lib
qbShared.CommaValue = lib.math.groupdigits

---@deprecated use lib.string.random from ox_lib
qbShared.RandomStr = function(length)
    if length <= 0 then return '' end
    local pattern = math.random(2) == 1 and 'a' or 'A'

    ---@diagnostic disable-next-line: deprecated
    return qbShared.RandomStr(length - 1) .. lib.string.random(pattern)
end

---@deprecated use lib.string.random from ox_lib
qbShared.RandomInt = function(length)
    if length <= 0 then return '' end

    ---@diagnostic disable-next-line: deprecated
    return qbShared.RandomInt(length - 1) .. lib.string.random('1')
end

---@deprecated use string.strsplit with CfxLua 5.4
qbShared.SplitStr = function(str, delimiter)
    local result = table.pack(string.strsplit(delimiter, str))
    result.n = nil
    return result
end

---@deprecated use qbx.string.trim from modules/lib.lua
qbShared.Trim = function(str)
    if not str then return nil end
    return qbx.string.trim(str)
end

---@deprecated use qbx.string.capitalize from modules/lib.lua
qbShared.FirstToUpper = function(str)
    if not str then return nil end
    return qbx.string.capitalize(str)
end

---@deprecated use qbx.math.round from modules/lib.lua
qbShared.Round = qbx.math.round

---@deprecated use qbx.setVehicleExtra from modules/lib.lua
qbShared.ChangeVehicleExtra = qbx.setVehicleExtras

---@deprecated use qbx.setVehicleExtra from modules/lib.lua
qbShared.SetDefaultVehicleExtras = qbx.setVehicleExtras

---@deprecated use qbx.armsWithoutGloves.male from modules/lib.lua
qbShared.MaleNoGloves = qbx.armsWithoutGloves.male

---@deprecated use qbx.armsWithoutGloves.female from modules/lib.lua
qbShared.FemaleNoGloves = qbx.armsWithoutGloves.female

return qbShared
