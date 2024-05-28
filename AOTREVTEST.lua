local workspace = game:GetService("Workspace")
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

        local espText = napeObject:FindFirstChild("ESPText")
        if not espText then
            espText = Instance.new("TextLabel")
            espText.Name = "ESPText"
            espText.Text = "Titan"
            espText.Size = UDim2.new(1, 0, 1, 0)
            espText.TextColor3 = HighlightColor
            espText.Font = Enum.Font.SourceSansBold
            espText.TextSize = 20
            espText.BackgroundTransparency = 0.5
            espText.Parent = napeObject
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
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Touched:Connect(RedirectHitToNape)
        end
    end
end

SetupRedirector()

while true do
    local titansBasePart = workspace:FindFirstChild(TitansBasePartName)
    if titansBasePart then
        ExpandAndHighlightNapesInTitans(titansBasePart)
    end
    wait()
end
