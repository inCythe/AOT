repeat
    task.wait()
until game:IsLoaded()

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")
local TitanFolder = game:GetService("Workspace"):FindFirstChild("Titans")

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
        napeObject.Size = Vector3.new(100, 400, 100)
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

local function ESP()
    coroutine.wrap(function()
        while true do
            local titansBasePart = workspace:FindFirstChild("Titans")
            if titansBasePart then
                expandAndHighlightNapesInTitans(titansBasePart)
            end
            wait(3)
        end
    end)
end

local function Parry()
    coroutine.wrap(function()
        for i,v in pairs(game:GetService("Players").LocalPlayer.PlayerGui.Interface.Buttons:GetChildren()) do
            if v ~= nil then
             VIM:SendKeyEvent(true,string.sub(tostring(v), 1, 1),false,game)
            end
            wait(0.1)
        end
    end)
end

while Farm do
    pcall(function()
        Parry()
    end)
    pcall(function()
        ESP()
    end)
    wait()
end