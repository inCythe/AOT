repeat
    task.wait()
until game:IsLoaded()

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")

local closestTitan = nil
local Farm = true
local TitanFolder = game:GetService("Workspace").Titans

local function GetTitans()
    local titans = {}
    for _, titan in pairs(TitanFolder:GetChildren()) do
        local humanoid = titan:FindFirstChildOfClass("Humanoid")
        local head = titan:FindFirstChild("Head")
        if humanoid and head and head.Position then
            table.insert(titans, {
                Name = titan.Name,
                Head = head,
                Humanoid = humanoid
            })
        end
    end
    return titans
end

local function TweenToPosition(targetPosition)
    local character = Player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local humanoidRootPart = character.HumanoidRootPart

    local duration = 1

    local tweenInfo = TweenInfo.new(
        duration, -- Time to complete the tween
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out,
        0, -- Number of times to repeat (0 means no repeat)
        false, -- Should the tween repeat?
        0 -- Delay before starting the tween
    )

    local goal = {}
    goal.CFrame = CFrame.new(targetPosition)
    
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, goal)
    tween:Play()
    tween.Completed:Wait()
end

local function AttackTitan()
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

local function GetBackOfHeadPosition(head)
    local backOffset = head.CFrame.LookVector * -20
    local targetPosition = head.Position + backOffset
    targetPosition = Vector3.new(targetPosition.X, targetPosition.Y - 2, targetPosition.Z) -- Adjust the Y component to move slightly downwards
    return targetPosition
end

while Farm do
    pcall(function()
        local titansList = GetTitans()

        if #titansList == 0 then
            Farm = false
            return
        end

        local playerPosition = Player.Character.HumanoidRootPart.Position
        local closestDistance = math.huge
        closestTitan = nil

        for _, titan in ipairs(titansList) do
            local headPosition = titan.Head.Position
            local distance = (headPosition - playerPosition).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                closestTitan = titan
            end
        end

        if closestTitan and closestTitan.Head then
            local targetPosition = GetBackOfHeadPosition(closestTitan.Head)
            TweenToPosition(targetPosition)
            AttackTitan()
        end

        wait()
    end)
end
