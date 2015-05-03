--------------------------------
-- HIGHLANDER2
-- version 0.1
-- by bcho
--------------------------------

-----------
-- 0.1
-----------

-- concept test

HedgewarsScriptLoad("/Scripts/Locale.lua")
HedgewarsScriptLoad("/Scripts/Tracker.lua")

local airWeapons = {amAirAttack, amMineStrike, amNapalm, amDrillStrike --[[,amPiano]]}

local atkArray = {
    amBazooka, amBee, amMortar, amDrill, amSnowball,
    amClusterBomb, amMolotov, amWatermelon, amHellishBomb, amGasBomb,
    amShotgun, amDEagle, amFlamethrower, amSniperRifle, amSineGun, amIceGun,
    amFirePunch, amWhip, amBaseballBat, --[[amKamikaze,]] amSeduction, amHammer,
    amMine, amDynamite, amCake, amBallgun, amRCPlane, amSMine,
    amRCPlane, amSMine,
    amBirdy
}

local utilArray = {
    amBlowTorch, amPickHammer, amGirder, amPortalGun,
    amParachute, amTeleport, amJetpack,
    amInvulnerable, amLaserSight, --[[amVampiric,]]
    amLowGravity, amExtraDamage, --[[amExtraTime,]]
    amLandGun
    --[[,amTardis, amResurrector, amSwitch]]
}

-- Basic wepaons.
local basicWepArray = {
    {amKamikaze, 100},
    {amSkip, 100},
    {amGrenade, 1},
    {amRope, 1}
}

local wepArray = {
}

local currHog
local lastHog
local started = false
local switchStage = 0

local lastWep = amNothing
local shotsFired = 0

function CheckForWeaponSwap()
    if GetCurAmmoType() ~= lastWep then
        shotsFired = 0
    end
    lastWep = GetCurAmmoType()
end

function onSlot()
    CheckForWeaponSwap()
end

function onSetWeapon()
    CheckForWeaponSwap()
end

function onHogAttack()
    CheckForWeaponSwap()
    shotsFired = shotsFired + 1
end

function StartingSetUp(gear)
    for i = 1, #wepArray do
        setGearValue(gear, wepArray[i], 0)
    end

    for i = 1, #basicWepArray do
        setGearValue(gear, basicWepArray[i][1], basicWepArray[i][2])
    end

    i = 1 + GetRandom(#atkArray)
    setGearValue(gear, atkArray[i], 1)

    i = 1 + GetRandom(#utilArray)
    setGearValue(gear, utilArray[i], 1)

end

--[[function SaveWeapons(gear)
-- er, this has no 0 check so presumably if you use a weapon then when it saves  you wont have it

    for i = 1, (#wepArray) do
        setGearValue(gear, wepArray[i], GetAmmoCount(gear, wepArray[i]) )
         --AddAmmo(gear, wepArray[i], getGearValue(gear,wepArray[i]) )
    end

end]]

function ConvertValues(gear)

    for i = 1, #wepArray do
        AddAmmo(gear, wepArray[i], getGearValue(gear,wepArray[i]) )
    end

end

function TransferWeps(gear)

    if CurrentHedgehog == nil then
        return
    end

    for i = 1, #wepArray do
        val = getGearValue(gear,wepArray[i])
        -- TODO don't add basic weapons
        if val ~= 0 then

            setGearValue(CurrentHedgehog, wepArray[i], val)

            -- if you are using multi-shot weapon, gimme one more
            if (GetCurAmmoType() == wepArray[i]) and (shotsFired ~= 0) then
                AddAmmo(CurrentHedgehog, wepArray[i], val+1)
            -- assign ammo as per normal
            else
                AddAmmo(CurrentHedgehog, wepArray[i], val)
            end

        end
    end

end

function onGameInit()
    GameFlags = bor(GameFlags,gfInfAttack + gfRandomOrder + gfPerHogAmmo + gfVampiric)
    HealthCaseProb = 100
end

function onGameStart()

    ShowMission    (
                loc("HIGHLANDER2"),
                loc("Not all hogs are born equal."),

                "- " .. loc("Eliminate enemy hogs and take their weapons.") .. "|" ..
                "- " .. loc("Per-Hog Ammo") .. "|" ..
                "- " .. loc("Weapons reset") .. "|" ..
                "- " .. loc("Unlimited Attacks") .. "|" ..
                "- " .. loc("Vampire Mode") .. "|" ..
                "", 4, 4000
                )

    if MapHasBorder() == false then
           for i, w in pairs(airWeapons) do
            table.insert(atkArray, w)
        end
    end

    for i, w in pairs(atkArray) do
        table.insert(wepArray, w)
    end

    for i, w in pairs(utilArray) do
        table.insert(wepArray, w)
    end

    for i = 1, #basicWepArray do
        table.insert(wepArray, basicWepArray[i][1])
    end

    runOnGears(StartingSetUp)
    runOnGears(ConvertValues)


end

function CheckForHogSwitch()

    if (CurrentHedgehog ~= nil) then

        currHog = CurrentHedgehog

        if currHog ~= lastHog then

            -- re-assign ammo to this guy, so that his entire ammo set will
            -- be visible during another player's turn
            if lastHog ~= nil then
                ConvertValues(lastHog)
            end

            -- give the new hog what he is supposed to have, too
            ConvertValues(CurrentHedgehog)

        end

        lastHog = currHog

    end

end

function onNewTurn()
    CheckForHogSwitch()
end

--function onGameTick20()
--CheckForHogSwitch()
-- if we use gfPerHogAmmo is this even needed? Err, well, weapons reset, so... yes?
-- orrrr, should we rather call the re-assignment of weapons onNewTurn()? probably not because
-- then you cant switch hogs... unless we add a thing in onSwitch or whatever
-- ye, that is probably better actually, but I'll add that when/if I add switch
--end

--[[function onHogHide(gear)
    -- waiting for Henek
end

function onHogRestore(gear)
    -- waiting for Henek
end]]

function onGearAdd(gear)

    --if GetGearType(gear) == gtSwitcher then
    --    SaveWeapons(CurrentHedgehog)
    --end

    if (GetGearType(gear) == gtHedgehog) then
        trackGear(gear)
    end

end

function onGearDelete(gear)

    if (GetGearType(gear) == gtHedgehog) then --or (GetGearType(gear) == gtResurrector) then
        TransferWeps(gear)
        trackDeletion(gear)
    end

end

function onAmmoStoreInit()
    -- no, you can't set your own ammo scheme
end
