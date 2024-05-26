local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local TitansBasePartName = "Titans"
local DamageAmount = 10
local HighlightColor = Color3.fromRGB(255, 0, 0)

local function FindNape(hitFolder)
    return hitFolder:FindFirstChild("Nape")
end

local function ApplyDamageToNape(napeObject)
    if napeObject then
        local humanoid = napeObject.Parent:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:TakeDamage(DamageAmount)
        end
    end
end

local function ExpandAndHighlightNape(napeObject)
    if napeObject then
        napeObject.Size = Vector3.new(100, 150, 100)
        napeObject.Transparency = 0.8
        napeObject.Color = HighlightColor
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
            espText.TextColor3 = HighlightColor
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
                ExpandAndHighlightNape(FindNape(hitFolder))
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
                ApplyDamageToNape(FindNape(hitFolder))
            end
        end
    end
end

local function SetupRedirector()
    for _, part in ipairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Touched:Connect(RedirectHitToNape)
        end
    end
end

SetupRedirector()

while true do
    local titansBasePart = Workspace:FindFirstChild(TitansBasePartName)
    if titansBasePart then
        ExpandAndHighlightNapesInTitans(titansBasePart)
    end
    wait(3)
end
