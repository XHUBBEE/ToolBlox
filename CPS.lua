local LogService = game:GetService("LogService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

-- ====================== การตั้งค่า ======================
local MAX_LOGS = 500
local TITLE_HEIGHT = 44
local BUTTON_HEIGHT = 46

-- ====================== ตัวแปรหลัก ======================
local logs = {}
local isPaused = false
local currentFilter = "All"
local isDragging = false
local dragStart, startPos
local floatDragging = false
local floatDragStart, floatStartPos

-- ====================== สร้าง ScreenGui ======================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MobileConsoleUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = CoreGui

-- ====================== ปุ่มลอย (Console Icon) ======================
local floatBtn = Instance.new("ImageButton")
floatBtn.Name = "FloatButton"
floatBtn.Size = UDim2.new(0, 52, 0, 52)
floatBtn.Position = UDim2.new(1, -68, 0.6, -26)
floatBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
floatBtn.Image = "rbxassetid://6031280882" -- Console / Terminal
floatBtn.ImageColor3 = Color3.fromRGB(220, 220, 230)
floatBtn.ScaleType = Enum.ScaleType.Fit
floatBtn.Parent = screenGui
floatBtn.ZIndex = 10

local floatCorner = Instance.new("UICorner")
floatCorner.CornerRadius = UDim.new(0, 14)
floatCorner.Parent = floatBtn

local floatStroke = Instance.new("UIStroke")
floatStroke.Color = Color3.fromRGB(70, 70, 80)
floatStroke.Thickness = 1
floatStroke.Parent = floatBtn

-- ====================== หน้าต่างหลัก ======================
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0.9, 0, 0.9, 0)
frame.Position = UDim2.new(0.05, 0, 0.05, 0)
frame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
frame.BorderSizePixel = 0
frame.Visible = false
frame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 14)
frameCorner.Parent = frame

-- ====================== Title Bar ======================
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, TITLE_HEIGHT)
titleBar.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
titleBar.BorderSizePixel = 0
titleBar.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 14)
titleCorner.Parent = titleBar

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0, 16)
titleFix.Position = UDim2.new(0, 0, 1, -16)
titleFix.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -110, 1, 0)
titleLabel.Position = UDim2.new(0, 14, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Console"
titleLabel.TextColor3 = Color3.fromRGB(230, 230, 235)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- ปุ่มปิด (X)
local closeBtn = Instance.new("ImageButton")
closeBtn.Size = UDim2.new(0, 36, 0, 30)
closeBtn.Position = UDim2.new(1, -46, 0.5, -15)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
closeBtn.Image = "rbxassetid://6031094678"
closeBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.ScaleType = Enum.ScaleType.Fit
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

-- ปุ่มย่อ
local minBtn = Instance.new("ImageButton")
minBtn.Size = UDim2.new(0, 36, 0, 30)
minBtn.Position = UDim2.new(1, -90, 0.5, -15)
minBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
minBtn.Image = "rbxassetid://6031090990"
minBtn.ImageColor3 = Color3.fromRGB(255, 255, 255)
minBtn.ScaleType = Enum.ScaleType.Fit
minBtn.Parent = titleBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 8)
minCorner.Parent = minBtn

-- ====================== แถบ Filter ======================
local filterBar = Instance.new("Frame")
filterBar.Size = UDim2.new(1, -20, 0, 36)
filterBar.Position = UDim2.new(0, 10, 0, TITLE_HEIGHT + 8)
filterBar.BackgroundTransparency = 1
filterBar.Parent = frame

local filters = {"All", "Error", "Warning", "Info", "Output"}
local filterButtons = {}

for i, name in ipairs(filters) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.18, -4, 1, 0)
	btn.Position = UDim2.new((i-1) * 0.18, 0, 0, 0)
	btn.BackgroundColor3 = name == "All" and Color3.fromRGB(45, 110, 190) or Color3.fromRGB(38, 38, 44)
	btn.Text = name
	btn.TextSize = 12
	btn.Font = Enum.Font.GothamBold
	btn.TextColor3 = Color3.fromRGB(240, 240, 245)
	btn.Parent = filterBar

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn

	filterButtons[name] = btn
end

-- ปุ่ม Pause
local pauseBtn = Instance.new("ImageButton")
pauseBtn.Size = UDim2.new(0.1, 0, 1, 0)
pauseBtn.Position = UDim2.new(0.9, 0, 0, 0)
pauseBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
pauseBtn.Image = "rbxassetid://6031068420" -- Pause
pauseBtn.ImageColor3 = Color3.fromRGB(240, 240, 245)
pauseBtn.ScaleType = Enum.ScaleType.Fit
pauseBtn.Parent = filterBar

local pauseCorner = Instance.new("UICorner")
pauseCorner.CornerRadius = UDim.new(0, 8)
pauseCorner.Parent = pauseBtn

-- ====================== พื้นที่แสดง Log (แก้ไม่ให้ทับ) ======================
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -(TITLE_HEIGHT + 130)) -- เพิ่มพื้นที่ด้านล่าง
scroll.Position = UDim2.new(0, 10, 0, TITLE_HEIGHT + 52)
scroll.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = Color3.fromRGB(90, 90, 100)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = frame

local scrollCorner = Instance.new("UICorner")
scrollCorner.CornerRadius = UDim.new(0, 10)
scrollCorner.Parent = scroll

local logLabel = Instance.new("TextLabel")
logLabel.Size = UDim2.new(1, -14, 0, 0)
logLabel.Position = UDim2.new(0, 8, 0, 6)
logLabel.BackgroundTransparency = 1
logLabel.Text = ""
logLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
logLabel.TextSize = 13
logLabel.Font = Enum.Font.Code
logLabel.TextXAlignment = Enum.TextXAlignment.Left
logLabel.TextYAlignment = Enum.TextYAlignment.Top
logLabel.TextWrapped = true
logLabel.RichText = true
logLabel.AutomaticSize = Enum.AutomaticSize.Y
logLabel.Parent = scroll

-- ====================== ปุ่มด้านล่าง ======================
local bottomBar = Instance.new("Frame")
bottomBar.Size = UDim2.new(1, -20, 0, BUTTON_HEIGHT)
bottomBar.Position = UDim2.new(0, 10, 1, -BUTTON_HEIGHT - 12)
bottomBar.BackgroundTransparency = 1
bottomBar.Parent = frame

local function createBottomButton(text, position, bgColor)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.32, -6, 1, 0)
	btn.Position = position
	btn.BackgroundColor3 = bgColor
	btn.Text = text
	btn.TextSize = 14
	btn.Font = Enum.Font.GothamBold
	btn.TextColor3 = Color3.fromRGB(245, 245, 250)
	btn.Parent = bottomBar

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = btn

	return btn
end

local copyAllBtn  = createBottomButton("Copy All",  UDim2.new(0, 0, 0, 0),     Color3.fromRGB(40, 90, 160))
local copyLastBtn = createBottomButton("Copy Last", UDim2.new(0.34, 0, 0, 0),  Color3.fromRGB(40, 90, 160))
local clearBtn    = createBottomButton("Clear",     UDim2.new(0.68, 0, 0, 0),  Color3.fromRGB(140, 45, 45))

-- ====================== ฟังก์ชันหลัก ======================
local function getColor(msgType)
	if msgType == Enum.MessageType.MessageError then
		return "#FF5C5C"
	elseif msgType == Enum.MessageType.MessageWarning then
		return "#FFB84D"
	elseif msgType == Enum.MessageType.MessageInfo then
		return "#5CAEFF"
	else
		return "#CCCCCC"
	end
end

local function getPrefix(msgType)
	if msgType == Enum.MessageType.MessageError then return "[Error]"
	elseif msgType == Enum.MessageType.MessageWarning then return "[Warn]"
	elseif msgType == Enum.MessageType.MessageInfo then return "[Info]"
	else return "[Output]" end
end

local function refreshDisplay()
	local result = {}
	for _, log in ipairs(logs) do
		local show = currentFilter == "All"
			or (currentFilter == "Error" and log.msgType == Enum.MessageType.MessageError)
			or (currentFilter == "Warning" and log.msgType == Enum.MessageType.MessageWarning)
			or (currentFilter == "Info" and log.msgType == Enum.MessageType.MessageInfo)
			or (currentFilter == "Output" and log.msgType == Enum.MessageType.MessageOutput)

		if show then
			local color = getColor(log.msgType)
			table.insert(result, string.format(
				'<font color="%s">[%s] %s %s</font>',
				color, log.time, getPrefix(log.msgType), log.message
			))
		end
	end
	logLabel.Text = table.concat(result, "\n")

	task.defer(function()
		scroll.CanvasPosition = Vector2.new(0, math.max(0, logLabel.AbsoluteSize.Y - scroll.AbsoluteSize.Y + 16))
	end)
end

local function addLog(message, msgType)
	if isPaused then return end

	table.insert(logs, {
		message = message,
		msgType = msgType,
		time = os.date("%H:%M:%S")
	})

	if #logs > MAX_LOGS then
		table.remove(logs, 1)
	end

	refreshDisplay()
end

-- ====================== เชื่อมต่อ Log ======================
LogService.MessageOut:Connect(function(message, messageType)
	addLog(message, messageType)
end)

-- ====================== ปุ่มต่าง ๆ ======================
-- Filter
for name, btn in pairs(filterButtons) do
	btn.MouseButton1Click:Connect(function()
		currentFilter = name
		for n, b in pairs(filterButtons) do
			b.BackgroundColor3 = (n == name) and Color3.fromRGB(45, 110, 190) or Color3.fromRGB(38, 38, 44)
		end
		refreshDisplay()
	end)
end

-- Pause
pauseBtn.MouseButton1Click:Connect(function()
	isPaused = not isPaused
	if isPaused then
		pauseBtn.Image = "rbxassetid://6031229348" -- Play
		pauseBtn.BackgroundColor3 = Color3.fromRGB(40, 130, 70)
	else
		pauseBtn.Image = "rbxassetid://6031068420" -- Pause
		pauseBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
	end
end)

-- Copy All
copyAllBtn.MouseButton1Click:Connect(function()
	local text = logLabel.Text:gsub("<.->", "")
	setclipboard(text)
end)

-- Copy Last
copyLastBtn.MouseButton1Click:Connect(function()
	if #logs > 0 then
		local last = logs[#logs]
		setclipboard(string.format("[%s] %s %s", last.time, getPrefix(last.msgType), last.message))
	end
end)

-- Clear
clearBtn.MouseButton1Click:Connect(function()
	logs = {}
	refreshDisplay()
end)

-- ปิด (X) → ลบทุกอย่าง
closeBtn.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

-- ย่อ → เหลือแค่ปุ่มลอย
minBtn.MouseButton1Click:Connect(function()
	frame.Visible = false
end)

-- ปุ่มลอย → เปิด/ปิด
floatBtn.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
end)

-- ====================== ระบบลากหน้าต่าง ======================
titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		isDragging = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)

titleBar.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		isDragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- ====================== ระบบลากปุ่มลอย ======================
floatBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		floatDragging = true
		floatDragStart = input.Position
		floatStartPos = floatBtn.Position
	end
end)

floatBtn.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		floatDragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if floatDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - floatDragStart
		local newX = floatStartPos.X.Offset + delta.X
		local newY = floatStartPos.Y.Offset + delta.Y

		local screenSize = workspace.CurrentCamera.ViewportSize
		newX = math.clamp(newX, 8, screenSize.X - 60)
		newY = math.clamp(newY, 8, screenSize.Y - 60)

		floatBtn.Position = UDim2.new(0, newX, 0, newY)
	end
end)

print("[Mobile Console] Ready")