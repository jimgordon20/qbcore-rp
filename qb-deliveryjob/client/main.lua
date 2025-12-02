local IsWorking = false
local HoldingPackage = false
local CurrentLocation = {
    TimerId = nil,
    Cone = nil,
    Coords = nil,
}
require('locales/en')

function onShutdown()
    if CurrentLocation.TimerId then
        Timer.ClearInterval(CurrentLocation.TimerId)
    end
end

local function setupPeds(peds)
    for i = 1, #peds do
        exports['qb-target']:AddTargetEntity(peds[i].Ped, {
            distance = 1500,
            options = {
                {
                    label = Lang:t('info.start_delivering'),
                    icon = 'fas fa-boxes-stacked',
                    job = Config.Job,
                    type = 'server',
                    event = 'qb-deliveryjob:server:startDelivering',
                    depot = peds[i].Index,
                },
                {
                    label = Lang:t('info.finish_delivering'),
                    icon = 'fas fa-boxes-stacked',
                    job = Config.Job,
                    type = 'client',
                    event = 'qb-deliveryjob:client:finishDelivering',
                }
            }
        })
    end
end

local function deliverPackage()
    local Pawn = GetPlayerPawn(HPlayer)
    local PawnCoords = GetEntityCoords(Pawn)
    if PawnCoords and PawnCoords:Dist(CurrentLocation.Coords) > 1000 then
        exports['qb-core']:Notify(Lang:t('error.too_far'), 'error')
        return
    end
    TriggerServerEvent('qb-deliveryjob:server:deliverPackage', CurrentLocation.jobId)
end

RegisterClientEvent('QBCore:Client:OnPlayerLoaded', function()
    local Console = GetActorByTag('HConsole')
    local Delegate = {
        HWorld,
        function(_, Inst, Args)
            local VehicleName = Args[1]
            if not VehicleName then return end

            TriggerServerEvent('qb-deliveryjob:server:spawnVehicle', VehicleName)
        end,
    }
    Console:RegisterCommand('car', 'Spawns a Car', nil, Delegate)

    --@TODO Revert to one time registration
    TriggerCallback('getJobPeds', function(peds)
        setupPeds(peds)
    end)
end)

RegisterClientEvent('qb-deliveryjob:client:pickupBox', function(targetData)
    CurrentLocation.jobId = targetData.jobId
    TriggerCallback('server.pickupBox', function(success)
        if not success then return end
        exports['qb-core']:DrawText(Lang:t('info.deliver_package'))
        HoldingPackage = true
    end, targetData.jobId)
end)

RegisterClientEvent('qb-deliveryjob:client:setupVehicleTarget', function(Vehicle, Job)
    exports['qb-target']:AddTargetEntity(Vehicle.Object, {
        distance = 4000,
        options = {
            {
                label = Lang:t('info.pickup_box'),
                icon = 'fas fa-boxes-stacked',
                job = Config.Job,
                type = 'client',
                event = 'qb-deliveryjob:client:pickupBox',
                jobId = Job
            }
        }
    })
end)

RegisterClientEvent('qb-deliveryjob:client:setCurrentLocation', function(Location, Vehicle, CurrentStop, MaxStops)
    -- Reset states
    if CurrentLocation.TimerId then Timer.ClearInterval(CurrentLocation.TimerId) end
    if CurrentLocation.Cone and CurrentLocation.Cone:IsValid() then DestroyEntity(CurrentLocation.Cone) end
    if not Location then
        exports['qb-core']:HideText()
        if CurrentLocation.TimerId then Timer.ClearInterval(CurrentLocation.TimerId) end
        CurrentLocation = {}
        return
    end

    -- Create cone, attach, calculate rotation
    local FindRotation = UE.UKismetMathLibrary.FindLookAtRotation
    local Pawn = GetPlayerPawn(HPlayer)
    local Cone = StaticMesh(GetEntityCoords(Pawn), Rotator(), '/QuietRuntimeEditor/UserContent/StaticMeshes/Primitives/SM_Cone.SM_Cone')
    CurrentLocation.Cone = Cone
    local Root = Cone:K2_GetRootComponent()
    Root:SetSimulatePhysics(false)
    Root:SetCollisionEnabled(UE.ECollisionEnabled.NoCollision)
    Root:SetCollisionResponseToAllChannels(UE.ECollisionResponse.ECR_Ignore)
    AttachActorToComponent(Cone.Object, Vehicle:GetComponentByClass(UE.UStaticMeshComponent), Vector(0, 0, 500), nil, '', {
        Location = AttachmentRule.SnapToTarget,
        Rotation = AttachmentRule.KeepWorld
    }, true)
    Cone:GetComponentByClass(UE.UStaticMeshComponent):K2_SetRelativeLocation(Vector(0, 0, 500), false, nil, true)
    print(Cone:K2_GetRootComponent():GetRelativeTransform().Translation)
    CurrentLocation.TimerId = Timer.SetInterval(function()
        local targetRotation = FindRotation(GetEntityCoords(Pawn), Location)
        targetRotation.Roll = 0
        targetRotation.Pitch = 90
        targetRotation.Yaw = targetRotation.Yaw + 180
        SetEntityRotation(Cone, targetRotation)
    end, 50)
    CurrentLocation.Coords = Location

    -- Update UI
    exports['qb-core']:DrawText(Lang:t('status.location_info', {Current = CurrentStop, Max = MaxStops}))
end)

RegisterClientEvent('qb-deliveryjob:client:finishDelivering', function()
    TriggerServerEvent('qb-deliveryjob:server:finishDelivering', CurrentLocation.jobId)
    HoldingPackage = false
end)

Input.BindKey('E', function()
    if HoldingPackage then
        deliverPackage()
        return
    end
end)