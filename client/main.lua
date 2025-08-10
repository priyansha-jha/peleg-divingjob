local _print = print
function print(...)
    if Config.Debug then
        _print(...)
    end
end

local isDiving = false

local function GetNearestZoneIndex()
    if not Config.DivingZones or #Config.DivingZones == 0 then return nil end
    local playerCoords = GetEntityCoords(PlayerPedId())
    local nearestIndex, nearestDist = nil, 1e9
    for i, zone in ipairs(Config.DivingZones) do
        local d = #(playerCoords - zone.coords)
        if d < nearestDist then
            nearestDist = d
            nearestIndex = i
        end
    end
    return nearestIndex
end

function ShowDivingJobMenu(zoneIndex)
    local playerStats = Bridge.GetPlayerStats()
    local stats = Bridge.GetDivingStats(playerStats.divingXP, playerStats.divingLevel)
   
    if not zoneIndex then
        local playerCoords = GetEntityCoords(PlayerPedId())
        for i, zone in ipairs(Config.DivingZones) do
            local distance = #(playerCoords - zone.coords)
            if distance <= zone.radius then
                zoneIndex = i
                break
            end
        end
        if not zoneIndex then
            zoneIndex = GetNearestZoneIndex()
        end
    end
   
    local level = stats.level or 1
    local nextIn = stats.nextIn or 0
    local exp = stats.exp or 0
    local levelColor = Config.LevelColors[level] and Config.LevelColors[level].color or '#ffffff'
    local levelName = Config.LevelColors[level] and Config.LevelColors[level].name or 'Unknown'
    local levelThresholds = Config.Levels
    
    local progress = 0
    if level >= #levelThresholds then
        progress = 100
    else
        local currentLevelXP = levelThresholds[level] or 0
        local nextLevelXP = levelThresholds[level + 1] or 0
        local xpNeededForNextLevel = nextLevelXP - currentLevelXP
        if xpNeededForNextLevel > 0 then
            progress = math.floor((exp / xpNeededForNextLevel) * 100)
        else
            progress = 100
        end
        progress = math.max(0, math.min(100, progress))
    end

    lib.registerContext({
        id = 'diving_job_menu',
        title = 'Diving Job',
        options = {
            {
                title = string.format('Level %d %s', level, levelName),
                description = string.format('Current Experience: %s XP | Progress: %d%%',
                    math.groupdigits and math.groupdigits(exp) or exp, progress),
                icon = 'fas fa-chart-line',
                iconColor = levelColor,
                progress = progress,
                colorScheme = levelColor,
                readOnly = true,
                metadata = {
                    { label = 'Next Level',    value = level < #levelThresholds and string.format('%d XP needed', nextIn) or 'Max Level' },
                    { label = 'Current Level', value = string.format('%s (%d)', levelName, level) },
                    { label = 'Progress',      value = string.format('%d%%', progress) }
                }
            },
            {
                title = 'Diving Shop',
                description = 'Purchase diving equipment',
                icon = 'fas fa-shopping-cart',
                iconColor = '66bb6a',
                onSelect = function()
                    OpenDivingShop(zoneIndex)
                end
            },
            {
                title = 'Diving Zones',
                description = 'View available diving locations',
                icon = 'fas fa-map-marker-alt',
                iconColor = 'ff9800',
                onSelect = function()
                    ShowDivingZones()
                end
            },
            {
                title = 'Vehicle Rental',
                description = 'Rent boats and jet skis',
                icon = 'fas fa-ship',
                iconColor = '2196f3',
                onSelect = function()
                    local zi = zoneIndex or GetNearestZoneIndex()
                    OpenVehicleRental(zi)
                end
            }
        }
    })
    lib.showContext('diving_job_menu')
end

function StartDiving()
    if isDiving then
        lib.notify({ title = 'Diving Job', description = 'You are already diving', type = 'error' })
        return
    end

    isDiving = true
    TriggerEvent('peleg-diving:client:StartOxygenSystem')

    lib.notify({ title = 'Diving Job', description = 'Diving session started! Watch your oxygen levels', type = 'success' })
end

function StopDiving()
    if not isDiving then
        lib.notify({ title = 'Diving Job', description = 'You are not currently diving', type = 'error' })
        return
    end

    isDiving = false
    TriggerEvent('peleg-diving:client:StopOxygenSystem')

    lib.notify({ title = 'Diving Job', description = 'Diving session ended', type = 'inform' })
end

function ShowDivingZones()
    local options = {}

    for i, zone in ipairs(Config.DivingZones) do
        table.insert(options, {
            title = zone.name,
            description = string.format('Depth: %dm | Radius: %dm', zone.depth, zone.radius),
            icon = 'fas fa-map-marker-alt',
            iconColor = '#42a5f5',
            onSelect = function()
                SetNewWaypoint(zone.coords.x, zone.coords.y)
                lib.notify({
                    title = 'Diving Job',
                    description = string.format('Waypoint set to %s', zone.name),
                    type = 'success'
                })
            end
        })
    end

    lib.registerContext({
        id = 'diving_zones_menu',
        title = 'Diving Zones',
        menu = 'diving_job_menu',
        options = options
    })

    lib.showContext('diving_zones_menu')
end

RegisterNetEvent('peleg-diving:client:ShowJobMenu', function()
    ShowDivingJobMenu(nil)
end)

RegisterNetEvent('peleg-diving:client:notify', function(payload)
    if type(payload) == 'string' then
        lib.notify({ title = 'Diving', description = payload, type = 'inform' })
    else
        lib.notify(payload)
    end
end)
