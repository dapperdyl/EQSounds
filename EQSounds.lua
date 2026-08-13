--[[
    EQSounds v1.0
    Classic EverQuest UI sounds for WoW 3.3.5a
    ding | bag/bank | loot | equip/unequip
    By DapperDyl
]]

local ADDON = "EQSounds"
local BASE  = "Interface\\AddOns\\EQSounds\\Sounds\\"

local SOUNDS = {
    ding  = BASE .. "eqding.ogg",
    bag   = BASE .. "bag.ogg",
    loot  = BASE .. "loot.ogg",
    equip = BASE .. "equip.ogg",
}

local defaults = {
    ding  = true,
    bag   = true,
    loot  = true,
    equip = true,
}

local db

local function Play(key)
    if not db or db[key] == false then return end
    local path = SOUNDS[key]
    if path then pcall(PlaySoundFile, path) end
end

local lastBagSound, lastEquipSound = 0, 0

local function PlayBagThrottled()
    local now = GetTime()
    if now - lastBagSound < 0.15 then return end
    lastBagSound = now
    Play("bag")
end

local function PlayEquipThrottled()
    local now = GetTime()
    if now - lastEquipSound < 0.20 then return end
    lastEquipSound = now
    Play("equip")
end

-- Snapshot equipped gear to detect real equip changes
local equipped = {}
local function SnapshotGear()
    for slot = 1, 19 do
        equipped[slot] = GetInventoryItemLink("player", slot)
    end
end

local function GearChanged()
    local changed = false
    for slot = 1, 19 do
        local link = GetInventoryItemLink("player", slot)
        if link ~= equipped[slot] then
            changed = true
            equipped[slot] = link
        end
    end
    return changed
end

-- Loot session (autoloot = one sound)
local lootSession = { active = false, lastTake = 0 }

local function IsAutoLoot()
    local cvar = false
    if GetCVar then
        local v = GetCVar("autoLootDefault")
        if v == "1" or v == 1 then cvar = true end
    end
    local shift = IsShiftKeyDown and IsShiftKeyDown() or false
    if cvar then return not shift end
    if shift then return true end
    return false
end

local function PlayLootOpen()
    lootSession.active = true
    lootSession.lastTake = GetTime()
    Play("loot")
end

local function PlayLootTake()
    if IsAutoLoot() and lootSession.active then return end
    local now = GetTime()
    if now - (lootSession.lastTake or 0) < 0.12 then return end
    lootSession.lastTake = now
    Play("loot")
end

-- ===================== EVENTS =====================
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LEVEL_UP")
f:RegisterEvent("LOOT_OPENED")
f:RegisterEvent("LOOT_SLOT_CLEARED")
f:RegisterEvent("LOOT_CLOSED")
f:RegisterEvent("BANKFRAME_OPENED")
f:RegisterEvent("BANKFRAME_CLOSED")
f:RegisterEvent("UNIT_INVENTORY_CHANGED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_LOGIN")

f:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON then
        if not EQSoundsDB then EQSoundsDB = {} end
        for k, v in pairs(defaults) do
            if EQSoundsDB[k] == nil then EQSoundsDB[k] = v end
        end
        -- drop any old merchant key from earlier builds
        EQSoundsDB.merchant = nil
        db = EQSoundsDB
        self:UnregisterEvent("ADDON_LOADED")
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00EQSounds|r v1.0 loaded. /eqsounds help")
        return
    end

    if event == "PLAYER_ENTERING_WORLD" then
        SnapshotGear()
        return
    end

    if event == "PLAYER_LEVEL_UP" then
        Play("ding")
        DEFAULT_CHAT_FRAME:AddMessage("|cffffff00DING!|r")
        return
    end

    if event == "LOOT_OPENED" then
        if arg1 == true or arg1 == 1 then
            lootSession.active = true
            lootSession.lastTake = GetTime()
            Play("loot")
            return
        end
        PlayLootOpen()
        return
    end

    if event == "LOOT_SLOT_CLEARED" then
        PlayLootTake()
        return
    end

    if event == "LOOT_CLOSED" then
        lootSession.active = false
        return
    end

    if event == "BANKFRAME_OPENED" or event == "BANKFRAME_CLOSED" then
        PlayBagThrottled()
        return
    end

    if event == "UNIT_INVENTORY_CHANGED" and arg1 == "player" then
        if GearChanged() then
            PlayEquipThrottled()
        end
        return
    end

    if event == "PLAYER_LOGIN" then
        SnapshotGear()

        local function HookContainer(frame)
            if not frame or frame.eqsounds_hooked then return end
            frame.eqsounds_hooked = true
            frame:HookScript("OnShow", function() PlayBagThrottled() end)
            frame:HookScript("OnHide", function() PlayBagThrottled() end)
        end
        for i = 1, NUM_CONTAINER_FRAMES or 13 do
            HookContainer(_G["ContainerFrame" .. i])
        end

        local function wrap(name)
            local fn = _G[name]
            if type(fn) == "function" and not fn.eqsounds then
                local orig = fn
                _G[name] = function(...)
                    PlayBagThrottled()
                    return orig(...)
                end
                _G[name].eqsounds = true
            end
        end
        wrap("OpenAllBags")
        wrap("CloseAllBags")
        wrap("ToggleBackpack")
        wrap("ToggleBag")

        if type(EquipCursorItem) == "function" and not EquipCursorItem.eqsounds then
            local orig = EquipCursorItem
            EquipCursorItem = function(...)
                PlayEquipThrottled()
                return orig(...)
            end
            EquipCursorItem.eqsounds = true
        end
        if type(AutoEquipCursorItem) == "function" and not AutoEquipCursorItem.eqsounds then
            local orig = AutoEquipCursorItem
            AutoEquipCursorItem = function(...)
                PlayEquipThrottled()
                return orig(...)
            end
            AutoEquipCursorItem.eqsounds = true
        end
    end
end)

-- ===================== SLASH =====================
SLASH_EQSOUNDS1 = "/eqsounds"
SLASH_EQSOUNDS2 = "/eqsound"
SlashCmdList["EQSOUNDS"] = function(msg)
    msg = strtrim(strlower(msg or ""))
    if not db then db = EQSoundsDB or defaults end

    if msg == "" or msg == "help" then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00EQSounds|r v1.0 — when sounds play:")
        DEFAULT_CHAT_FRAME:AddMessage("  |cffffff00ding|r   level up")
        DEFAULT_CHAT_FRAME:AddMessage("  |cffffff00bag|r    B / bags / bank")
        DEFAULT_CHAT_FRAME:AddMessage("  |cffffff00loot|r   loot open / take (once if autoloot)")
        DEFAULT_CHAT_FRAME:AddMessage("  |cffffff00equip|r  equip or unequip gear")
        DEFAULT_CHAT_FRAME:AddMessage("  /eqsounds ding|bag|loot|equip  (test)")
        DEFAULT_CHAT_FRAME:AddMessage("  /eqsounds <name> on|off | status")
        return
    end

    if msg == "status" then
        DEFAULT_CHAT_FRAME:AddMessage(string.format(
            "|cff00ff00EQSounds|r: ding=%s bag=%s loot=%s equip=%s",
            db.ding and "ON" or "OFF",
            db.bag and "ON" or "OFF",
            db.loot and "ON" or "OFF",
            db.equip and "ON" or "OFF"
        ))
        return
    end

    local key, state = msg:match("^(%w+)%s+(on|off)$")
    if key and state and defaults[key] ~= nil then
        db[key] = (state == "on")
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00EQSounds|r: " .. key .. " " .. string.upper(state))
        return
    end

    if SOUNDS[msg] then
        pcall(PlaySoundFile, SOUNDS[msg])
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00EQSounds|r: playing " .. msg)
        return
    end

    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00EQSounds|r: unknown. /eqsounds help")
end

SLASH_EQDING1 = "/eqding"
SLASH_EQDING2 = "/ding"
SlashCmdList["EQDING"] = function()
    pcall(PlaySoundFile, SOUNDS.ding)
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00EQSounds|r: playing ding")
end
