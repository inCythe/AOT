repeat
    task.wait()
until game:IsLoaded()

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local TitanFolder = game:GetService("Workspace"):FindFirstChild("Titans")

local closestTitan = nil
local Farm = true

local workspace = game:GetService("Workspace")

local function findNape(hitFolder)
    return hitFolder:FindFirstChild("Nape")
end

local function applyDamageToNape(napeObject)
    if napeObject then
        local humanoid = napeObject.Parent:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:TakeDamage(10)
        end
    end
end

local function expandAndHighlightNape(hitFolder)
    local napeObject = findNape(hitFolder)
    if napeObject then
        napeObject.Size = Vector3.new(100, 300, 100)
        napeObject.Transparency = 0.8
        napeObject.Color = Color3.new(1, 1, 1)
        napeObject.Material = Enum.Material.Neon
        napeObject.CanCollide = false
        napeObject.Anchored = false
    end
end

local function expandAndHighlightNapesInTitans(titansBasePart)
    for _, titan in ipairs(titansBasePart:GetChildren()) do
        local hitboxesFolder = titan:FindFirstChild("Hitboxes")
        if hitboxesFolder then
            local hitFolder = hitboxesFolder:FindFirstChild("Hit")
            if hitFolder then
                expandAndHighlightNape(hitFolder)
            end
        end
    end
end

local function redirectHitToNape(hitPart)
    local titan = hitPart.Parent
    if titan then
        local hitboxesFolder = titan:FindFirstChild("Hitboxes")
        if hitboxesFolder then
            local hitFolder = hitboxesFolder:FindFirstChild("Hit")
            if hitFolder then
                applyDamageToNape(findNape(hitFolder))
            end
        end
    end
end

local function setupRedirector()
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Touched:Connect(redirectHitToNape)
        end
    end
end

setupRedirector()

coroutine.wrap(function()
    while true do
        local titansBasePart = workspace:FindFirstChild("Titans")
        if titansBasePart then
            expandAndHighlightNapesInTitans(titansBasePart)
        end
        wait()
    end
end)()

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
    tween.Completed:Wait()
end

local function AttackTitan()
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

local function GetTopOfHeadPosition(head)
    local headHeight = head.Size.Y / 2
    local targetPosition = head.Position + Vector3.new(0, headHeight + 20, 0)
    return targetPosition
end

local function Parry()
  for i,v in pairs(game:GetService("Players").LocalPlayer.PlayerGui.Interface.Buttons:GetChildren()) do
    if v ~= nil then
      VIM:SendKeyEvent(true,string.sub(tostring(v), 1, 1),false,game)
    end
  end
end

while Farm do
    pcall(function()
        Parry()

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

        task.wait()
    end)
end