local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")

local closestTitan = nil
local Farm = true
local TitanFolder = game:GetService("Workspace").Titans
local initialOrientation = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character.HumanoidRootPart.Orientation or Vector3.new()

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

    local currentPos = humanoidRootPart.Position
    local distance = (targetPosition - currentPos).Magnitude
    local walkSpeed = Player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed
    local duration = distance / walkSpeed -- Adjusting duration based on distance and walk speed

    local tweenInfo = TweenInfo.new(
        duration, -- Time to complete the tween
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out,
        0, -- Number of times to repeat (0 means no repeat)
        false, -- Should the tween repeat?
        0 -- Delay before starting the tween
    )

    local goal = {}
    goal.Position = targetPosition
    
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, goal)
    tween:Play()
    tween.Completed:Wait()
end

local function AttackTitan()
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

local function GetBackOfHeadPosition(head)
    local backOffset = head.CFrame.LookVector * -15
    local targetPosition = head.Position + backOffset
    targetPosition = Vector3.new(targetPosition.X, targetPosition.Y - 2, targetPosition.Z) -- Adjust the Y component to move slightly downwards
    return targetPosition
end

local function GetNape(hitFolder)
    return hitFolder:FindFirstChild("Nape")
end

local function ApplyDamageToNape(napeObject)
    if napeObject then
        local humanoid = napeObject.Parent:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:TakeDamage(10)
        end
    end
end

local function ExpandAndHighlightNape(hitFolder)
    local napeObject = GetNape(hitFolder)
    if napeObject then
        napeObject.Size = Vector3.new(100, 150, 100)
        napeObject.Transparency = 0.8
        napeObject.Color = Color3.new(1, 1, 1)
        napeObject.Material = Enum.Material.Neon
        napeObject.CanCollide = false
        napeObject.Anchored = false

        local billboardGui = napeObject:FindFirstChild("BillboardGui")
        if not billboardGui then
            billboardGui = Instance.new("BillboardGui")
            billboardGui.Name = "BillboardGui"
            billboardGui.AlwaysOnTop = true
            billboardGui.Size = UDim2.new(2, 0, 2, 0)
            billboardGui.StudsOffset = Vector3.new(0, 3, 0)
            billboardGui.MaxDistance = math.huge
            billboardGui.Adornee = napeObject
            billboardGui.Parent = napeObject

            local espText = Instance.new("TextLabel")
            espText.Text = "Titan"
            espText.Size = UDim2.new(1, 0, 1, 0)
            espText.TextColor3 = Color3.new(255, 0, 0)
            espText.Font = Enum.Font.SourceSansBold
            espText.TextSize = 20
            espText.BackgroundTransparency = 0.5
            espText.Parent = billboardGui
        end
    end
end

local function ExpandAndHighlightNapesInTitans(titansBasePart)
    for _, titan in ipairs(titansBasePart:GetChildren()) do
        local hitboxesFolder = titan:FindFirstChild("Hitboxes")
        if hitboxesFolder then
            local hitFolder = hitboxesFolder:FindFirstChild("Hit")
            if hitFolder then
                ExpandAndHighlightNape(hitFolder)
            end
        end
    end
end

local function RedirectHitToNape(hitPart)
    local titan = hitPart.Parent
    if titan then
        local hitboxesFolder = titan:FindFirstChild("Hitboxes")
        if hitboxesFolder then
            local hitFolder = hitboxesFolder:FindFirstChild("Hit")
            if hitFolder then
                ApplyDamageToNape(GetNape(hitFolder))
            end
        end
    end
end

local function Noclip()
    local character = Player.Character
    if not character then return end

    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("BasePart") then
            child.CanCollide = false
        end
    end
end

local function SetupRedirector()
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Touched:Connect(RedirectHitToNape)
        end
    end
end

print("Loaded Nape Extender")

SetupRedirector()

while true do
    local titansBasePart = workspace:FindFirstChild("Titans")
    if titansBasePart then
        ExpandAndHighlightNapesInTitans(titansBasePart)
    end
    wait(3)
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
