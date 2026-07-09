-- Tắt script cũ nếu đang chạy để tránh xung đột
if _G.MailScriptRunning then
    warn("[WARNING] Script đang chạy! Đang dừng phiên bản cũ...")
    _G.MailScriptRunning = false
    task.wait(0.5)
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- ================= BẢNG DỊCH NGÔN NGỮ (LOCALIZATION DICTIONARY) =================
local translations = {
    ["VI"] = {
        WindowTitle = "Gửi Thư Tự Động",
        GiftingTab = "Gửi thư",
        SettingsTab = "Cài đặt",
        RecipientsTitle = "Tên người nhận",
        RecipientsPlaceholder = "VD: user1, user2 (ngăn cách bằng dấu ,)",
        NoteTitle = "Ghi chú gửi thư",
        NotePlaceholder = "VD: hi, qua tang...",
        ItemDropdownTitle = "Chọn vật phẩm từ túi đồ",
        SelectedItemLabelTitle = "Thông tin vật phẩm",
        SelectedItemLabelNotSelected = "Chưa chọn vật phẩm.",
        SelectedItemLabelSelected = "Đang chọn: %s\nSố lượng hiện có: %s",
        RefreshBtnTitle = "Làm mới danh sách túi đồ",
        RefreshBtnDesc = "Quét lại Replica RAM và cập nhật danh sách chọn vật phẩm",
        QtyTitle = "Số lượng gửi",
        QtyPlaceholder = "Số nguyên hoặc 'all'",
        AddQueueBtnTitle = "Thêm vật phẩm vào đơn hàng (Queue)",
        AddQueueBtnDesc = "Đưa vật phẩm và số lượng đã cấu hình vào danh sách gửi",
        ClearQueueBtnTitle = "Xóa toàn bộ đơn hàng",
        ClearQueueBtnDesc = "Xóa sạch danh sách gửi hiện tại",
        StatusTitle = "Trạng thái tiến trình",
        StatusIdle = "Đang rảnh (Idle)",
        ActiveOrderTitle = "Chi tiết tiến độ đơn hàng (Order Progress)",
        ActiveOrderRecipients = "👥 Tài khoản người nhận:\n",
        ActiveOrderStatusWaiting = "⏳ Chờ...",
        ActiveOrderStatusSending = "⚡ Đang tiến hành gửi...",
        ActiveOrderStatusDone = "✅ Đã gửi xong",
        ActiveOrderStatusFailed = "❌ Thất bại/Bị dừng",
        ActiveOrderItems = "📦 Chi tiết đơn hàng:\n",
        ActiveOrderEmpty = "  (Hàng đợi gửi đang trống)\n",
        StartBtnTitle = "Bắt đầu gửi thư (Start Gifting)",
        StartBtnDesc = "Bắt đầu chu trình dịch chuyển và gửi thư xác thực",
        StopBtnTitle = "Dừng gửi thư (Stop Gifting)",
        StopBtnDesc = "Hủy bỏ và ngắt chu trình gửi thư đang chạy ngay lập tức",
        BatchSizeTitle = "Lô gửi tối đa (Batch Size)",
        BatchSizePlaceholder = "Mặc định: 9999",
        CooldownTitle = "Thời gian chờ (Cooldown)",
        CooldownPlaceholder = "Mặc định: 4.0",
        FastSendTitle = "Chế độ gửi nhanh (Fast Send)",
        FastSendDesc = "Bỏ qua xác thực trừ đồ để gửi liên tục (Spam Remote)",
        SaveConfigTitle = "Lưu cấu hình (Save Config)",
        SaveConfigDesc = "Lưu lại danh sách gửi, người nhận và cài đặt hiện tại",
        LoadConfigTitle = "Tải cấu hình (Load Config)",
        LoadConfigDesc = "Tải lại cấu hình đã lưu từ tệp tin",
        LanguageTitle = "Ngôn ngữ (Language)",
        NotifySaved = "Đã lưu cấu hình",
        NotifySavedDesc = "Cấu hình hiện tại đã được lưu thành công.",
        NotifyLoaded = "Đã tải cấu hình",
        NotifyLoadedDesc = "Cấu hình đã lưu đã được khôi phục thành công.",
        NotifyRefresh = "Làm mới thành công",
        NotifyRefreshDesc = "Đã cập nhật danh sách vật phẩm trong túi đồ của bạn.",
        StatusResolving = "[PROCESS] Đang tìm kiếm nhân vật và hòm thư...",
        StatusCharErr = "Lỗi: Không thể tải được HumanoidRootPart của nhân vật!",
        StatusSearchPlot = "[PROCESS] Đang tìm hòm thư trên plot...",
        StatusMailboxErr = "Lỗi: Không tìm thấy hòm thư GreyMailBox trên Plot của bạn!",
        StatusCFrameErr = "Lỗi: Không thể tìm tọa độ hòm thư!",
        StatusNetworkErr = "Lỗi: Không thể tải mô-đun mạng (Networking Module) của game!",
        StatusTeleporting = "[PROCESS] Đang dịch chuyển đến cạnh hòm thư...",
        StatusResolvingUser = "[%d/%d] Đang xác thực tài khoản: %s...",
        StatusUserSkip = "Bỏ qua tài khoản",
        StatusUserSkipDesc = "Không tìm thấy UserId của %s",
        StatusSendingTo = "[%d/%d] Đang gửi quà cho: %s (ID: %d)",
        StatusReadInvErr = "Lỗi: Không thể đọc bộ nhớ túi đồ client!",
        StatusInvEmpty = "[INFO] Bỏ qua vật phẩm '%s' cho %s do số dư bằng 0.",
        StatusInvMissing = "Vật phẩm '%s' không tồn tại trong túi đồ. Bỏ qua.",
        StatusInvLimit = "Không đủ số lượng '%s': Có %d, cần %d. Gửi số lượng tối đa hiện có (%d).",
        StatusNoItemsToSend = "[INFO] Không còn vật phẩm nào để gửi cho %s. Chuyển tài khoản tiếp theo.",
        StatusSendingBatchInfo = "-> [%s] Gửi: %s (Tổng %d đợt)",
        StatusSendingBatchCurrent = "-> [%s] Đang gửi đợt %d/%d (Số lượng %d)...",
        StatusSendBatchSuccess = "-> [%s] Đợt %d/%d đã gửi và xác thực thành công!",
        StatusSendBatchRetry = "-> [%s] Đợt %d/%d gửi lỗi hoặc không xác thực được đồ. Đang thử lại (%d/%d)...",
        StatusSendBatchErr = "Lỗi: Gửi đợt %d/%d thất bại quá số lần thử lại cho %s!",
        StatusSendBatchAborted = "Dừng vòng lặp gửi do phát hiện lỗi hàng đợi.",
        StatusCooldownBetween = "Đã gửi xong cho %s. Chờ cooldown %.1fs...",
        StatusStoppedByUser = "Tiến trình đã bị dừng bởi người dùng.",
        StatusFinishedSuccess = "Hoàn thành! Toàn bộ thư và quà đã được gửi ổn định.",
        NotifyFinishedTitle = "Hoàn thành gửi thư",
        NotifyFinishedDesc = "Tất cả các tài khoản nhận trong danh sách đã được xử lý xong.",
        WarningTitle = "Cảnh báo",
        WarningRunning = "Hệ thống đang chạy! Nhấp 'Dừng gửi thư' trước nếu muốn thiết lập lại.",
        ErrorNoRecipients = "Lỗi: Không tìm thấy tên người nhận hợp lệ!",
        ErrorEmptyQueue = "Lỗi: Danh sách đơn hàng gửi đang trống!"
    },
    ["EN"] = {
        WindowTitle = "Auto Mail Gifting",
        GiftingTab = "Gifting",
        SettingsTab = "Settings",
        RecipientsTitle = "Recipient Name",
        RecipientsPlaceholder = "e.g. user1, user2 (separated by commas)",
        NoteTitle = "Mail Note",
        NotePlaceholder = "e.g. hi, gifts...",
        ItemDropdownTitle = "Select Item from Inventory",
        SelectedItemLabelTitle = "Item Information",
        SelectedItemLabelNotSelected = "No item selected.",
        SelectedItemLabelSelected = "Selected: %s\nCurrently owned: %s",
        RefreshBtnTitle = "Refresh Inventory List",
        RefreshBtnDesc = "Scans replica RAM and updates the item selection list",
        QtyTitle = "Quantity to Send",
        QtyPlaceholder = "Integer or 'all'",
        AddQueueBtnTitle = "Add Item to Order (Queue)",
        AddQueueBtnDesc = "Queue the selected item and quantity for mailing",
        ClearQueueBtnTitle = "Clear All Orders",
        ClearQueueBtnDesc = "Clear the current mailing list",
        StatusTitle = "Process Status",
        StatusIdle = "Idle",
        ActiveOrderTitle = "Order Progress Details",
        ActiveOrderRecipients = "👥 Recipient Accounts:\n",
        ActiveOrderStatusWaiting = "⏳ Waiting...",
        ActiveOrderStatusSending = "⚡ Sending...",
        ActiveOrderStatusDone = "✅ Sent successfully",
        ActiveOrderStatusFailed = "❌ Failed/Stopped",
        ActiveOrderItems = "📦 Order Details:\n",
        ActiveOrderEmpty = "  (Mailing queue is empty)\n",
        StartBtnTitle = "Start Gifting",
        StartBtnDesc = "Start teleportation and sending process",
        StopBtnTitle = "Stop Gifting",
        StopBtnDesc = "Abort and stop the running mail process immediately",
        BatchSizeTitle = "Max Batch Size",
        BatchSizePlaceholder = "Default: 9999",
        CooldownTitle = "Cooldown Delay",
        CooldownPlaceholder = "Default: 4.0",
        FastSendTitle = "Fast Send Mode",
        FastSendDesc = "Bypass replica verification to send continuously (Spam Remote)",
        SaveConfigTitle = "Save Config",
        SaveConfigDesc = "Save current mailing list, recipients, and settings",
        LoadConfigTitle = "Load Config",
        LoadConfigDesc = "Reload saved configuration from file",
        LanguageTitle = "Language",
        NotifySaved = "Config Saved",
        NotifySavedDesc = "Current configuration saved successfully.",
        NotifyLoaded = "Config Loaded",
        NotifyLoadedDesc = "Saved configuration restored successfully.",
        NotifyRefresh = "Refresh Success",
        NotifyRefreshDesc = "Updated inventory item list from client replica.",
        StatusResolving = "[PROCESS] Locating player character and mailbox...",
        StatusCharErr = "Error: Could not load character's HumanoidRootPart!",
        StatusSearchPlot = "[PROCESS] Searching for plot mailbox...",
        StatusMailboxErr = "Error: Could not locate plot mailbox in workspace!",
        StatusCFrameErr = "Error: Could not resolve mailbox coordinates!",
        StatusNetworkErr = "Error: Failed to load game's Networking Module!",
        StatusTeleporting = "[PROCESS] Teleporting to mailbox...",
        StatusResolvingUser = "[%d/%d] Resolving recipient account: %s...",
        StatusUserSkip = "Skip Account",
        StatusUserSkipDesc = "Could not resolve UserId for %s",
        StatusSendingTo = "[%d/%d] Gifting to: %s (ID: %d)",
        StatusReadInvErr = "Error: Failed to read inventory from Replica Client!",
        StatusInvEmpty = "[INFO] Skipped item '%s' for %s (0 remaining in inventory).",
        StatusInvMissing = "Item '%s' does not exist in inventory. Skipping.",
        StatusInvLimit = "Insufficient quantity for '%s': Owned %d, needed %d. Sending max available (%d).",
        StatusNoItemsToSend = "[INFO] No items left to send to %s. Skipping to next account.",
        StatusSendingBatchInfo = "-> [%s] Sending: %s (Total %d batch(es))",
        StatusSendingBatchCurrent = "-> [%s] Sending batch %d/%d (Size %d)...",
        StatusSendBatchSuccess = "-> [%s] Batch %d/%d successfully sent and verified!",
        StatusSendBatchRetry = "-> [%s] Batch %d/%d failed verification. Retrying (%d/%d)...",
        StatusSendBatchErr = "Error: Batch %d/%d failed verification after maximum retries for %s!",
        StatusSendBatchAborted = "Aborted gifting loop due to verification failure.",
        StatusCooldownBetween = "Batch completed for %s. Waiting cooldown %.1fs...",
        StatusStoppedByUser = "Gifting process stopped by user.",
        StatusFinishedSuccess = "All items have been processed successfully!",
        NotifyFinishedTitle = "Gifting Process Finished",
        NotifyFinishedDesc = "All recipient accounts in the list have been processed.",
        WarningTitle = "Warning",
        WarningRunning = "Gifting loop is already running! Stop it first if you want to re-run.",
        ErrorNoRecipients = "Error: No valid recipients found!",
        ErrorEmptyQueue = "Error: Mail order list is empty!"
    }
}

local currentLang = "VI"

-- Load Fluent UI library
local successFluent, Fluent = pcall(function()
    return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
end)

if not successFluent or not Fluent then
    warn("[ERROR] Failed to load Fluent UI library! Hãy kiểm tra kết nối mạng hoặc Executor.")
    return
end

-- Khởi tạo Window UI
local Window = Fluent:CreateWindow({
    Title = "Auto Mail Gifting",
    SubTitle = "by vhh",
    TabWidth = 150,
    Size = UDim2.new(0, 580, 0, 480),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Gifting", Icon = "mail" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Quản lý danh sách gửi cục bộ
local mailQueue = {}

-- Biến lưu trữ phần tử được chọn
local currentSelectedItem = nil
local currentSelectedQty = "all"

-- Bảng hiển thị thông tin đơn hàng và tiến trình gửi
local ActiveOrderParagraph = Tabs.Main:AddParagraph({
    Title = "Chi tiết tiến độ đơn hàng (Order Progress)",
    Content = "Chưa bắt đầu tiến trình."
})

local function updateActiveOrderProgress(currentRecipientIdx)
    local t = translations[currentLang]
    local usernamesString = RecipientsInput and RecipientsInput.Value or ""
    local recipients = {}
    for username in string.gmatch(usernamesString, "[^,%s]+") do
        table.insert(recipients, username)
    end
    
    local content = ""
    
    if #recipients > 0 then
        content = content .. t.ActiveOrderRecipients
        for idx, name in ipairs(recipients) do
            local status = t.ActiveOrderStatusWaiting
            if currentRecipientIdx and currentRecipientIdx > 0 then
                if idx < currentRecipientIdx then
                    status = t.ActiveOrderStatusDone
                elseif idx == currentRecipientIdx then
                    if _G.MailScriptRunning then
                        status = t.ActiveOrderStatusSending
                    else
                        status = t.ActiveOrderStatusFailed
                    end
                end
            end
            content = content .. string.format("  %d. %s (%s)\n", idx, name, status)
        end
        content = content .. "\n"
    end
    
    content = content .. t.ActiveOrderItems
    local count = 0
    for item, qty in pairs(mailQueue) do
        count = count + 1
        content = content .. string.format("  • %s: %s\n", item, tostring(qty))
    end
    if count == 0 then
        content = content .. t.ActiveOrderEmpty
    end
    
    ActiveOrderParagraph:SetDesc(content)
end

local function updateQueueText()
    updateActiveOrderProgress(0)
end

-- Nhập danh sách tài khoản nhận
local RecipientsInput = Tabs.Main:AddInput("Recipients", {
    Title = "Tên người nhận",
    Default = "",
    Placeholder = "VD: user1, user2 (ngăn cách bằng dấu ,)",
    Numeric = false,
    Finished = false
})

RecipientsInput:OnChanged(function()
    updateActiveOrderProgress(0)
end)

-- Nhập tin nhắn thư
local NoteInput = Tabs.Main:AddInput("Note", {
    Title = "Ghi chú gửi thư",
    Default = "hi",
    Placeholder = "VD: hi, qua tang...",
    Numeric = false,
    Finished = false
})

-- Dynamic Inventory Detection
local function getActiveReplicas()
    local clientModules = ReplicatedStorage:FindFirstChild("ClientModules")
    local replicaClientModule = clientModules and clientModules:FindFirstChild("ReplicaClient")
    if not replicaClientModule then return nil end
    
    local success, ReplicaClient = pcall(function() return require(replicaClientModule) end)
    if not success or type(ReplicaClient) ~= "table" then return nil end
    
    local fromId = ReplicaClient.FromId
    if not fromId then return nil end
    
    local getUpvalSuccess, arg1, arg2 = pcall(function()
        return debug.getupvalue(fromId, 1)
    end)
    
    if getUpvalSuccess then
        if type(arg1) == "table" then return arg1 end
        if type(arg2) == "table" then return arg2 end
    end
    return nil
end

local function getPlayerDataReplica()
    local replicas = getActiveReplicas()
    if replicas then
        for _, r in pairs(replicas) do
            if type(r) == "table" and r.Data and r.Data.Inventory then
                return r
            end
        end
    end
    return nil
end

local function getReplicaInventory()
    local inventory = {}
    local dbToUserMapping = {}
    
    local replica = getPlayerDataReplica()
    local replicaInv = replica and replica.Data and replica.Data.Inventory
    if not replicaInv then return inventory, dbToUserMapping end
    
    for categoryName, categoryTable in pairs(replicaInv) do
        if type(categoryTable) == "table" then
            for itemKey, itemVal in pairs(categoryTable) do
                if type(itemVal) == "table" then
                    local itemName = itemVal.Name
                    if itemName then
                        inventory[itemName] = (inventory[itemName] or 0) + 1
                        dbToUserMapping[itemName] = itemName
                    end
                else
                    local dbName = tostring(itemKey)
                    if categoryName == "Seeds" then
                        local friendlyName = dbName .. " Seed"
                        inventory[friendlyName] = itemVal
                        dbToUserMapping[friendlyName] = dbName
                        inventory[dbName] = itemVal
                        dbToUserMapping[dbName] = dbName
                    else
                        inventory[dbName] = itemVal
                        dbToUserMapping[dbName] = dbName
                    end
                end
            end
        end
    end
    return inventory, dbToUserMapping
end

local function getReplicaItemCount(category, itemKey)
    local replica = getPlayerDataReplica()
    local replicaInv = replica and replica.Data and replica.Data.Inventory
    if not replicaInv then return nil end
    
    local catTable = replicaInv[category]
    if catTable then
        local val = catTable[itemKey]
        if type(val) == "table" then
            return val and 1 or 0
        else
            return tonumber(val) or 0
        end
    end
    return 0
end

-- Dropdown vật phẩm, Nhãn số lượng và Nút Refresh
local ItemDropdown = Tabs.Main:AddDropdown("ItemDropdown", {
    Title = "Chọn vật phẩm từ túi đồ",
    Values = {},
    Multi = false,
    Default = nil
})

local SelectedItemLabel = Tabs.Main:AddParagraph({
    Title = "Thông tin vật phẩm",
    Content = "Chưa chọn vật phẩm."
})

ItemDropdown:OnChanged(function(Value)
    currentSelectedItem = Value
    local t = translations[currentLang]
    if Value and Value ~= "" then
        local cleanName = Value:gsub("%s*%(x%d+%)", "")
        local myInventory, nameMapping = getReplicaInventory()
        local count = myInventory[cleanName] or 0
        SelectedItemLabel:SetDesc(string.format(t.SelectedItemLabelSelected, cleanName, tostring(count)))
    else
        SelectedItemLabel:SetDesc(t.SelectedItemLabelNotSelected)
    end
end)

local function refreshInventoryDropdown()
    local myInventory, nameMapping = getReplicaInventory()
    local itemNames = {}
    for itemName, count in pairs(myInventory) do
        table.insert(itemNames, string.format("%s (x%s)", itemName, tostring(count)))
    end
    table.sort(itemNames)
    ItemDropdown:SetValues(itemNames)
    
    local t = translations[currentLang]
    -- Cập nhật lại nhãn hiển thị số lượng nếu có vật phẩm đang được chọn
    if currentSelectedItem then
        local cleanName = currentSelectedItem:gsub("%s*%(x%d+%)", "")
        local count = myInventory[cleanName] or 0
        SelectedItemLabel:SetDesc(string.format(t.SelectedItemLabelSelected, cleanName, tostring(count)))
    end
end

local RefreshBtn = Tabs.Main:AddButton({
    Title = "Làm mới danh sách túi đồ",
    Description = "Quét lại Replica RAM và cập nhật danh sách chọn vật phẩm",
    Callback = function()
        refreshInventoryDropdown()
        local t = translations[currentLang]
        Fluent:Notify({
            Title = t.NotifyRefresh,
            Content = t.NotifyRefreshDesc,
            Duration = 3
        })
    end
})

-- Nhập số lượng gửi
local QtyInput = Tabs.Main:AddInput("QtyInput", {
    Title = "Số lượng gửi",
    Default = "all",
    Placeholder = "Số nguyên hoặc 'all'",
    Numeric = false,
    Finished = false
})

QtyInput:OnChanged(function()
    currentSelectedQty = QtyInput.Value
end)

-- Nút Thêm và Xóa đơn hàng
local AddQueueBtn = Tabs.Main:AddButton({
    Title = "Thêm vật phẩm vào đơn hàng (Queue)",
    Description = "Đưa vật phẩm và số lượng đã cấu hình vào danh sách gửi",
    Callback = function()
        local t = translations[currentLang]
        if not currentSelectedItem or currentSelectedItem == "" then
            Fluent:Notify({
                Title = t.WarningTitle,
                Content = t.SelectedItemLabelNotSelected,
                Duration = 3
            })
            return
        end
        
        local cleanItem = currentSelectedItem:gsub("%s*%(x%d+%)", "")
        
        local qtyVal = currentSelectedQty
        if tostring(qtyVal):lower() == "all" then
            qtyVal = "all"
        else
            local num = tonumber(qtyVal)
            if not num or num <= 0 then
                Fluent:Notify({
                    Title = t.WarningTitle,
                    Content = t.QtyTitle .. " " .. t.QtyPlaceholder,
                    Duration = 3
                })
                return
            end
            qtyVal = math.floor(num)
        end
        
        mailQueue[cleanItem] = qtyVal
        updateQueueText()
        Fluent:Notify({
            Title = t.NotifyLoaded,
            Content = string.format("%s (x%s)", cleanItem, tostring(qtyVal)),
            Duration = 2
        })
    end
})

local ClearQueueBtn = Tabs.Main:AddButton({
    Title = "Xóa toàn bộ đơn hàng",
    Description = "Xóa sạch danh sách gửi hiện tại",
    Callback = function()
        mailQueue = {}
        updateQueueText()
        local t = translations[currentLang]
        Fluent:Notify({
            Title = t.ClearQueueBtnTitle,
            Content = t.ActiveOrderEmpty,
            Duration = 2
        })
    end
})

-- Hiển thị trạng thái tiến trình gửi
local StatusParagraph = Tabs.Main:AddParagraph({
    Title = "Trạng thái tiến trình",
    Content = "Đang rảnh (Idle)"
})

local function updateStatus(text, isError)
    StatusParagraph:SetDesc(text)
    print(text)
    if isError then
        local t = translations[currentLang]
        Fluent:Notify({
            Title = t.StatusTitle,
            Content = text,
            Duration = 5
        })
    end
end

-- Cài đặt tham số mạng
local BatchSizeInput = Tabs.Settings:AddInput("BatchSize", {
    Title = "Lô gửi tối đa (Batch Size)",
    Default = "9999",
    Placeholder = "Mặc định: 9999",
    Numeric = true,
    Finished = false
})

local CooldownInput = Tabs.Settings:AddInput("Cooldown", {
    Title = "Thời gian chờ (Cooldown)",
    Default = "4.0",
    Placeholder = "Mặc định: 4.0",
    Numeric = false,
    Finished = false
})

local FastSendToggle = Tabs.Settings:AddToggle("FastSend", {
    Title = "Chế độ gửi nhanh (Fast Send)",
    Default = false,
    Description = "Bỏ qua xác thực trừ đồ để gửi liên tục (Spam Remote)"
})

-- ================= HỆ THỐNG LƯU/TẢI CẤU HÌNH (CONFIG SYSTEM) =================
local function saveConfig()
    local config = {
        Language = currentLang,
        Recipients = RecipientsInput.Value,
        Note = NoteInput.Value,
        BatchSize = BatchSizeInput.Value,
        Cooldown = CooldownInput.Value,
        FastSend = FastSendToggle.Value,
        MailQueue = mailQueue
    }
    local success, json = pcall(function()
        return HttpService:JSONEncode(config)
    end)
    if success and json then
        local successWrite = pcall(function()
            writefile("AutoMailGifting_Config.json", json)
        end)
        local t = translations[currentLang]
        if successWrite then
            Fluent:Notify({
                Title = t.NotifySaved,
                Content = t.NotifySavedDesc,
                Duration = 3
            })
        else
            warn("[ERROR] Không thể ghi file cấu hình!")
        end
    end
end

local function loadConfig()
    local hasFile = false
    pcall(function()
        hasFile = isfile("AutoMailGifting_Config.json")
    end)
    if not hasFile then return end
    
    local successRead, content = pcall(function()
        return readfile("AutoMailGifting_Config.json")
    end)
    if successRead and content then
        local successDecode, config = pcall(function()
            return HttpService:JSONDecode(content)
        end)
        if successDecode and type(config) == "table" then
            if config.Language then
                currentLang = config.Language
            end
            if config.Recipients then
                RecipientsInput:SetValue(config.Recipients)
            end
            if config.Note then
                NoteInput:SetValue(config.Note)
            end
            if config.BatchSize then
                BatchSizeInput:SetValue(config.BatchSize)
            end
            if config.Cooldown then
                CooldownInput:SetValue(config.Cooldown)
            end
            if config.FastSend ~= nil then
                FastSendToggle:SetValue(config.FastSend)
            end
            if config.MailQueue then
                mailQueue = config.MailQueue
            end
            
            -- Cập nhật đồng bộ UI dịch sau khi load
            updateQueueText()
        end
    end
end

local SaveConfigBtn = Tabs.Settings:AddButton({
    Title = "Lưu cấu hình (Save Config)",
    Description = "Lưu lại danh sách gửi, người nhận và cài đặt hiện tại",
    Callback = function()
        saveConfig()
    end
})

local LoadConfigBtn = Tabs.Settings:AddButton({
    Title = "Tải cấu hình (Load Config)",
    Description = "Tải lại cấu hình đã lưu từ tệp tin",
    Callback = function()
        loadConfig()
    end
})

-- Resolver tìm UserId từ Username an toàn
local function resolveUserId(username)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower() == username:lower() or p.DisplayName:lower() == username:lower() then
            return p.UserId, p.Name
        end
    end

    local success, id = pcall(function()
        return Players:GetUserIdFromNameAsync(username)
    end)
    if success and id then
        return id, username
    end

    local encodedUsername = HttpService:UrlEncode(username)

    local function executeGet(url)
        local successGet, body = pcall(function() return game:HttpGet(url) end)
        if successGet and body then return body end
        
        local req = (syn and syn.request) or request or (http and http.request) or http_request
        if req then
            local successReq, res = pcall(function()
                return req({ Url = url, Method = "GET" })
            end)
            if successReq and res.StatusCode == 200 then
                return res.Body
            end
        end
        return nil
    end

    local body = executeGet("https://users.roproxy.com/v1/users/search?keyword=" .. encodedUsername .. "&limit=1")
    if body then
        local successDecode, data = pcall(function() return HttpService:JSONDecode(body) end)
        if successDecode and data and data.data and data.data[1] then
            return data.data[1].id, data.data[1].name
        end
    end

    local body2 = executeGet("https://api.roproxy.com/users/get-by-username?username=" .. encodedUsername)
    if body2 then
        local successDecode, data = pcall(function() return HttpService:JSONDecode(body2) end)
        if successDecode and data and data.Id then
            return data.Id, data.Username or username
        end
    end

    return nil, nil
end

-- Nút Bắt đầu và Dừng gửi
local StartBtn = Tabs.Main:AddButton({
    Title = "Bắt đầu gửi thư (Start Gifting)",
    Description = "Bắt đầu chu trình dịch chuyển và gửi thư xác thực",
    Callback = function()
        local t = translations[currentLang]
        if _G.MailScriptRunning then
            Fluent:Notify({
                Title = t.WarningTitle,
                Content = t.WarningRunning,
                Duration = 3
            })
            return
        end
        
        local usernamesString = RecipientsInput.Value
        local mailNote = NoteInput.Value
        local batchSize = tonumber(BatchSizeInput.Value) or 2000
        local cooldown = tonumber(CooldownInput.Value) or 4.0
        
        batchSize = math.max(1, batchSize)
        
        local recipients = {}
        for username in string.gmatch(usernamesString, "[^,%s]+") do
            table.insert(recipients, username)
        end
        
        if #recipients == 0 then
            updateStatus(t.ErrorNoRecipients, true)
            return
        end
        
        local hasItems = false
        for _, _ in pairs(mailQueue) do
            hasItems = true
            break
        end
        
        if not hasItems then
            updateStatus(t.ErrorEmptyQueue, true)
            return
        end
        
        _G.MailScriptRunning = true
        
        task.spawn(function()
            updateStatus(t.StatusResolving)
            
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart", 10)
            
            if not hrp then
                updateStatus(t.StatusCharErr, true)
                _G.MailScriptRunning = false
                return
            end
            
            local myMailbox = nil
            local startSearch = os.clock()
            while os.clock() - startSearch < 15 do
                if not _G.MailScriptRunning then return end
                local Gardens = workspace:FindFirstChild("Gardens")
                if Gardens then
                    for _, plot in ipairs(Gardens:GetChildren()) do
                        local isOwner = (tostring(plot:GetAttribute("OwnerUserId")) == tostring(LocalPlayer.UserId)) or (plot:GetAttribute("Owner") == LocalPlayer.Name)
                        if isOwner then
                            local signs = plot:FindFirstChild("Signs")
                            local mailbox = signs and signs:FindFirstChild("GreyMailBox")
                            if mailbox then
                                myMailbox = mailbox
                                break
                            end
                        end
                    end
                end
                if myMailbox then break end
                task.wait(1)
            end
            
            if not myMailbox then
                updateStatus(t.StatusMailboxErr, true)
                _G.MailScriptRunning = false
                return
            end
            
            local mailboxCFrame = nil
            local mailboxPart = myMailbox:FindFirstChild("ProximityPromptPart") or myMailbox:FindFirstChild("HitBox") or myMailbox.PrimaryPart
            if mailboxPart and mailboxPart:IsA("BasePart") then
                mailboxCFrame = mailboxPart.CFrame
            else
                mailboxCFrame = myMailbox:GetPivot()
            end
            
            if not mailboxCFrame then
                updateStatus(t.StatusCFrameErr, true)
                _G.MailScriptRunning = false
                return
            end
            
            local sharedModules = ReplicatedStorage:WaitForChild("SharedModules", 5)
            local networkModule = sharedModules and sharedModules:FindFirstChild("Networking")
            local successLoad, Networking = pcall(function()
                return require(networkModule)
            end)
            
            if not successLoad or type(Networking) ~= "table" then
                updateStatus(t.StatusNetworkErr, true)
                _G.MailScriptRunning = false
                return
            end
            
            updateStatus(t.StatusTeleporting)
            hrp.CFrame = mailboxCFrame * CFrame.new(0, 3, 3)
            task.wait(0.5)
            
            -- Lặp qua từng người nhận
            for idx, recipientUsername in ipairs(recipients) do
                if not _G.MailScriptRunning then break end
                
                updateActiveOrderProgress(idx)
                updateStatus(string.format(t.StatusResolvingUser, idx, #recipients, recipientUsername))
                local recipientUserId, exactUsername = resolveUserId(recipientUsername)
                
                if not recipientUserId then
                    warn("Không thể tìm UserId của " .. recipientUsername)
                    Fluent:Notify({
                        Title = t.StatusUserSkip,
                        Content = string.format(t.StatusUserSkipDesc, recipientUsername),
                        Duration = 4
                    })
                    continue
                end
                
                updateStatus(string.format(t.StatusSendingTo, idx, #recipients, exactUsername, recipientUserId))
                
                local myInventory, nameMapping = getReplicaInventory()
                local replica = getPlayerDataReplica()
                local replicaInv = replica and replica.Data and replica.Data.Inventory
                
                if not replicaInv then
                    updateStatus(t.StatusReadInvErr, true)
                    break
                end
                
                local flatItemList = {}
                local packSummary = {}
                
                for userItemName, requestedQty in pairs(mailQueue) do
                    local qtyFound = 0
                    local categoryMatched = nil
                    local itemKeyMatched = nil
                    local isStructuredItem = false
                    local availableSubItems = {}
                    
                    local qtyNeeded = requestedQty
                    if qtyNeeded == "all" then
                        qtyNeeded = myInventory[userItemName] or 0
                        if qtyNeeded <= 0 then
                            print(string.format(t.StatusInvEmpty, userItemName, exactUsername))
                            continue
                        end
                    end
                    
                    for categoryName, categoryTable in pairs(replicaInv) do
                        if type(categoryTable) == "table" then
                            local searchName = userItemName
                            if categoryName == "Seeds" and userItemName:find("Seed") then
                                searchName = userItemName:gsub("%s*Seed%s*", "")
                            end
                            
                            for itemKey, itemVal in pairs(categoryTable) do
                                if type(itemVal) == "table" then
                                    if itemVal.Name == searchName then
                                        qtyFound = qtyFound + 1
                                        categoryMatched = categoryName
                                        isStructuredItem = true
                                        table.insert(availableSubItems, itemKey)
                                    end
                                else
                                    if tostring(itemKey) == searchName or tostring(itemKey) == userItemName then
                                        qtyFound = itemVal
                                        categoryMatched = categoryName
                                        itemKeyMatched = tostring(itemKey)
                                        break
                                    end
                                end
                            end
                        end
                        if categoryMatched and not isStructuredItem then break end
                    end
                    
                    if qtyFound == 0 then
                        warn(string.format(t.StatusInvMissing, userItemName))
                        continue
                    elseif qtyFound < qtyNeeded then
                        warn(string.format(t.StatusInvLimit, userItemName, qtyFound, qtyNeeded, qtyFound))
                        qtyNeeded = qtyFound
                    end
                    
                    if qtyNeeded > 0 then
                        table.insert(packSummary, string.format("%s x%d", userItemName, qtyNeeded))
                        if isStructuredItem then
                            for i = 1, qtyNeeded do
                                local uniqueId = availableSubItems[i]
                                table.insert(flatItemList, {
                                    Category = categoryMatched,
                                    ItemKey = uniqueId,
                                    Count = 1
                                })
                            end
                        else
                            table.insert(flatItemList, {
                                Category = categoryMatched,
                                ItemKey = itemKeyMatched,
                                Count = qtyNeeded
                            })
                        end
                    end
                end
                
                if #flatItemList == 0 then
                    print(string.format(t.StatusNoItemsToSend, exactUsername))
                    continue
                end
                
                -- Chia lô
                local batches = {}
                local currentBatch = {}
                local currentBatchSize = 0
                
                for _, itemEntry in ipairs(flatItemList) do
                    local remaining = itemEntry.Count
                    local category = itemEntry.Category
                    local itemKey = itemEntry.ItemKey
                    
                    while remaining > 0 do
                        local spaceLeft = batchSize - currentBatchSize
                        local toAdd = math.min(remaining, spaceLeft)
                        
                        table.insert(currentBatch, {
                            Category = category,
                            ItemKey = itemKey,
                            Count = toAdd
                        })
                        
                        currentBatchSize = currentBatchSize + toAdd
                        remaining = remaining - toAdd
                        
                        if currentBatchSize >= batchSize then
                            table.insert(batches, currentBatch)
                            currentBatch = {}
                            currentBatchSize = 0
                        end
                    end
                end
                
                if currentBatchSize > 0 then
                    table.insert(batches, currentBatch)
                end
                
                -- Thực hiện gửi
                local totalBatches = #batches
                updateStatus(string.format(t.StatusSendingBatchInfo, exactUsername, table.concat(packSummary, ", "), totalBatches))
                
                local allSuccess = true
                for bIdx, batch in ipairs(batches) do
                    if not _G.MailScriptRunning then
                        allSuccess = false
                        break
                    end
                    
                    local currentBatchItemsCount = 0
                    for _, entry in ipairs(batch) do currentBatchItemsCount = currentBatchItemsCount + entry.Count end
                    
                    local startingCounts = {}
                    for _, entry in ipairs(batch) do
                        local startVal = getReplicaItemCount(entry.Category, entry.ItemKey)
                        table.insert(startingCounts, {
                            Entry = entry,
                            StartVal = startVal
                        })
                    end
                    
                    local successDeduct = false
                    local retryLimit = 3
                    local currentAttempt = 1
                    
                    while currentAttempt <= retryLimit and not successDeduct do
                        if not _G.MailScriptRunning then break end
                        
                        updateStatus(string.format(t.StatusSendingBatchCurrent, exactUsername, bIdx, totalBatches, currentBatchItemsCount))
                        
                        local fireSuccess, response = pcall(function()
                            Networking.Mailbox.SendBatch:Fire(recipientUserId, batch, mailNote)
                        end)
                        
                        if FastSendToggle.Value then
                            successDeduct = true
                        else
                            if not fireSuccess then
                                warn("-> [WARNING] Lệnh mạng SendBatch lỗi: " .. tostring(response))
                            else
                                local startPoll = os.clock()
                                while os.clock() - startPoll < 4.0 do
                                    task.wait(0.1)
                                    if not _G.MailScriptRunning then break end
                                    
                                    local allDeducted = true
                                    for _, info in ipairs(startingCounts) do
                                        local entry = info.Entry
                                        local startVal = info.StartVal
                                        local currentVal = getReplicaItemCount(entry.Category, entry.ItemKey)
                                        if startVal == nil or currentVal == nil or currentVal > (startVal - entry.Count) then
                                            allDeducted = false
                                            break
                                        end
                                    end
                                    
                                    if allDeducted then
                                        successDeduct = true
                                        break
                                    end
                                end
                            end
                        end
                        
                        if successDeduct then
                            print(string.format(t.StatusSendBatchSuccess, exactUsername, bIdx, totalBatches))
                        else
                            warn(string.format(t.StatusSendBatchRetry, exactUsername, bIdx, totalBatches, currentAttempt, retryLimit))
                            currentAttempt = currentAttempt + 1
                            if currentAttempt <= retryLimit then
                                task.wait(cooldown)
                            end
                        end
                    end
                    
                    if not successDeduct then
                        allSuccess = false
                        updateStatus(string.format(t.StatusSendBatchErr, bIdx, totalBatches, exactUsername), true)
                        break
                    end
                    
                    if bIdx < totalBatches then
                        task.wait(cooldown)
                    end
                end
                
                if not allSuccess then
                    updateStatus(t.StatusSendBatchAborted, true)
                    break
                end
                
                if idx < #recipients then
                    updateStatus(string.format(t.StatusCooldownBetween, exactUsername, cooldown))
                    task.wait(cooldown)
                end
            end
            
            if not _G.MailScriptRunning then
                updateStatus(t.StatusStoppedByUser)
                updateActiveOrderProgress(0)
            else
                updateStatus(t.StatusFinishedSuccess)
                updateActiveOrderProgress(#recipients + 1)
                Fluent:Notify({
                    Title = t.NotifyFinishedTitle,
                    Content = t.NotifyFinishedDesc,
                    Duration = 5
                })
            end
            
            _G.MailScriptRunning = false
        end)
    end
})

local StopBtn = Tabs.Main:AddButton({
    Title = "Dừng gửi thư (Stop Gifting)",
    Description = "Hủy bỏ và ngắt chu trình gửi thư đang chạy ngay lập tức",
    Callback = function()
        local t = translations[currentLang]
        if _G.MailScriptRunning then
            _G.MailScriptRunning = false
            updateStatus(t.StatusStoppedByUser)
            Fluent:Notify({
                Title = t.StopBtnTitle,
                Content = t.StatusStoppedByUser,
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = t.WarningTitle,
                Content = t.StatusIdle,
                Duration = 2
            })
        end
    end
})

-- ================= HÀM DỊCH CHUYỂN NGÔN NGỮ ĐỘNG (DYNAMIC I18N EXECUTION) =================
local function updateUIStrings()
    local t = translations[currentLang]
    
    pcall(function()
        -- Tab Gifting Inputs
        RecipientsInput.Title.Text = t.RecipientsTitle
        RecipientsInput.InputFrame.Input.PlaceholderText = t.RecipientsPlaceholder
        
        NoteInput.Title.Text = t.NoteTitle
        NoteInput.InputFrame.Input.PlaceholderText = t.NotePlaceholder
        
        -- Dropdown & Quantity
        ItemDropdown.Title.Text = t.ItemDropdownTitle
        QtyInput.Title.Text = t.QtyTitle
        QtyInput.InputFrame.Input.PlaceholderText = t.QtyPlaceholder
        
        -- Selected Label & Status Paragraphs
        SelectedItemLabel:SetTitle(t.SelectedItemLabelTitle)
        if currentSelectedItem then
            local cleanName = currentSelectedItem:gsub("%s*%(x%d+%)", "")
            local myInventory, nameMapping = getReplicaInventory()
            local count = myInventory[cleanName] or 0
            SelectedItemLabel:SetDesc(string.format(t.SelectedItemLabelSelected, cleanName, tostring(count)))
        else
            SelectedItemLabel:SetDesc(t.SelectedItemLabelNotSelected)
        end
        
        ActiveOrderParagraph:SetTitle(t.ActiveOrderTitle)
        StatusParagraph:SetTitle(t.StatusTitle)
        
        -- Settings Tab Elements
        BatchSizeInput.Title.Text = t.BatchSizeTitle
        BatchSizeInput.InputFrame.Input.PlaceholderText = t.BatchSizePlaceholder
        
        CooldownInput.Title.Text = t.CooldownTitle
        CooldownInput.InputFrame.Input.PlaceholderText = t.CooldownPlaceholder
        
        FastSendToggle.Title.Text = t.FastSendTitle
        FastSendToggle.Description.Text = t.FastSendDesc
        
        -- Buttons Text
        RefreshBtn.Title.Text = t.RefreshBtnTitle
        RefreshBtn.Description.Text = t.RefreshBtnDesc
        
        AddQueueBtn.Title.Text = t.AddQueueBtnTitle
        AddQueueBtn.Description.Text = t.AddQueueBtnDesc
        
        ClearQueueBtn.Title.Text = t.ClearQueueBtnTitle
        ClearQueueBtn.Description.Text = t.ClearQueueBtnDesc
        
        StartBtn.Title.Text = t.StartBtnTitle
        StartBtn.Description.Text = t.StartBtnDesc
        
        StopBtn.Title.Text = t.StopBtnTitle
        StopBtn.Description.Text = t.StopBtnDesc
        
        SaveConfigBtn.Title.Text = t.SaveConfigBtnTitle
        SaveConfigBtn.Description.Text = t.SaveConfigBtnDesc
        
        LoadConfigBtn.Title.Text = t.LoadConfigBtnTitle
        LoadConfigBtn.Description.Text = t.LoadConfigBtnDesc
    end)
end

-- Bộ chọn Ngôn ngữ (Language Dropdown)
local LanguageDropdown = Tabs.Settings:AddDropdown("Language", {
    Title = "Ngôn ngữ (Language)",
    Values = {"Tiếng Việt (VI)", "English (EN)"},
    Multi = false,
    Default = 1
})

LanguageDropdown:OnChanged(function(Value)
    if Value == "Tiếng Việt (VI)" then
        currentLang = "VI"
    else
        currentLang = "EN"
    end
    updateUIStrings()
    updateActiveOrderProgress(0)
end)

-- Khởi tạo danh sách vật phẩm lần đầu và tải cấu hình
task.spawn(function()
    task.wait(1)
    refreshInventoryDropdown()
    loadConfig()
    
    -- Sync language after load
    if currentLang == "VI" then
        LanguageDropdown:SetValue("Tiếng Việt (VI)")
    else
        LanguageDropdown:SetValue("English (EN)")
    end
    updateUIStrings()
end)
