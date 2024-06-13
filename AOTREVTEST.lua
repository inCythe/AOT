repeat
    task.wait()
until game:IsLoaded()

wait(5)

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local workspace = game:GetService("Workspace")

local Farm = true
local TitanFolder = workspace.Titans
local tweenInProgress = false

local function Anchored()
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        Player.Character.HumanoidRootPart.Anchored = Farm
    end
end

local function Parry()
    for i, v in pairs(Player.PlayerGui.Interface.Buttons:GetChildren()) do
        if v ~= nil then
            VIM:SendKeyEvent(true, string.sub(tostring(v), 1, 1), false, game)
        end
    end
end

local function GetTitans()
    local titans = {}
    for _, titan in pairs(TitanFolder:GetChildren()) do
        local humanoid = titan:FindFirstChildOfClass("Humanoid")
        local head = titan:FindFirstChild("Head")
        local nape = titan:FindFirstChild("Hitboxes") and titan.Hitboxes:FindFirstChild("Hit") and titan.Hitboxes.Hit:FindFirstChild("Nape")
        if humanoid and head and nape then
            table.insert(titans, {
                Name = titan.Name,
                Head = head,
                Humanoid = humanoid,
                Nape = nape
            })
        end
    end
    return titans
end

local function TweenToPosition(targetPosition, duration, callback)
    if tweenInProgress then
        return
    end

    tweenInProgress = true

    local character = Player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        tweenInProgress = false
        return
    end

    local humanoidRootPart = character.HumanoidRootPart

    local tweenInfo = TweenInfo.new(
        duration,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out,
        0,
        false,
        0
    )

    local goal = {}
    goal.CFrame = CFrame.new(targetPosition)
    
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, goal)
    tween:Play()
    tween.Completed:Connect(function()
        tweenInProgress = false
        if callback then callback() end
    end)
end

local function AttackTitan()
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.1) -- Adjusted wait time between press and release
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

local function GetAboveHeadPosition(head)
    local aboveOffset = head.CFrame.LookVector * -15 + Vector3.new(0, 100, 0)
    local targetPosition = head.Position + aboveOffset
    return targetPosition
end

local function expandNapeHitbox(napeObject)
    if napeObject then
        napeObject.Size = Vector3.new(105, 120, 100)
        napeObject.Transparency = 0.96
        napeObject.Color = Color3.new(1, 1, 1)
        napeObject.Material = Enum.Material.Neon
        napeObject.CanCollide = false
        napeObject.Anchored = false
    end
end

local function processTitans(titansBasePart)
    for _, titan in ipairs(titansBasePart:GetChildren()) do
        local hitboxesFolder = titan:FindFirstChild("Hitboxes")
        if hitboxesFolder then
            local hitFolder = hitboxesFolder:FindFirstChild("Hit")
            if hitFolder then
                local napeObject = hitFolder:FindFirstChild("Nape")
                expandNapeHitbox(napeObject)
            end
        end
    end
end

while true do
    Parry()
    Anchored()
    
    if Farm then
        local titansList = GetTitans()

        if #titansList == 0 then
            Farm = false
            return
        end

        processTitans(TitanFolder)

        local playerPosition = Player.Character.HumanoidRootPart.Position
        local closestDistance = math.huge
        local closestTitan = nil

        for _, titan in ipairs(titansList) do
            local headPosition = titan.Head.Position
            local distance = (headPosition - playerPosition).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                closestTitan = titan
            end
        end

        if closestTitan and closestTitan.Head then
            local aboveHeadPosition = GetAboveHeadPosition(closestTitan.Head)

            TweenToPosition(aboveHeadPosition, 0, function()
                task.wait(2)
                local targetPosition = closestTitan.Nape.Position
                TweenToPosition(targetPosition, 0.5, function()
                    AttackTitan()
                    task.wait(0.1)
                end)
            end)
        end
    end
    
    task.wait()
end
