repeat
    task.wait()
until game:IsLoaded()

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local TitanFolder = game:GetService("Workspace").Titans

local closestTitan = nil
local Farm = true

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
        false, -- Should the tween reverse?
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

local function GetTopOfHeadPosition(head)
    local headHeight = head.Size.Y / 2
    local targetPosition = head.Position + Vector3.new(0, headHeight + 20, 0) -- 5 units above the top of the head
    return targetPosition
end

while Farm do
    pcall(function()
        coroutine.wrap(function()
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
                local targetPosition = GetTopOfHeadPosition(closestTitan.Head)
                TweenToPosition(targetPosition)
                AttackTitan()
            end

            wait()
        end)()
    end)
end