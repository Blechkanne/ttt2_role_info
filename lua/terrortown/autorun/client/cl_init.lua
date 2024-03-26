local roleDescriptions = { }

-- Functions
local function RequestRoleDescriptionsDelete()
        net.Start("ttt2RequestRoleDescriptionsDelete")
        net.SendToServer()
end

local function RequestRoleDescriptionsChange()
        net.Start("ttt2RequestRoleDescriptionsChange")
        net.WriteTable(roleDescriptions)
        net.SendToServer()
end

local function RequestRoleDescription()
        local ply = LocalPlayer()
        local steamID = ply:SteamID()
        local roleName = ply:GetSubRoleData().name

        net.Start("ttt2RequestRoleInfoChat")
        net.WriteTable({steamID, roleName})
        net.SendToServer()
end

local function RequestRoleDescriptions()
        net.Start("ttt2RequestRoleDescriptions")

        net.SendToServer()
end

local function RoleInfoChat()
        local ply = LocalPlayer()

        if not IsValid(ply) then return end

        local roleString = net.ReadString()
        local roleDescription = net.ReadTable()
        local role = roles.GetByName(roleString)


        if (roleDescription.description == nil || roleDescription.description == "") then
                chat.AddText(
                        role.color, "[" .. string.upper(role.name) .. "]\n",
                        Color(255, 0, 0), LANG.GetTranslation("roleinfo_addon_missing_description") .. "\n",
                        Color(255, 0, 0), LANG.GetTranslation("roleinfo_addon_configure_yourself")
                )

        else
                chat.AddText(
                        role.color, "[" .. string.upper(role.name) .. "]\n",
                        Color( 255, 255, 255), roleDescription.description
                )
        end
end

local function RoleDescription()
        local ply = LocalPlayer()

        if not IsValid(ply) then return end

        roleDescriptions = net.ReadTable()
        local roleList = roles.GetSortedRoles()

        local frame = vgui.Create( "DFrame" )
        frame:SetSize( 400, 600 )
        frame:Center()
        frame:MakePopup()
        frame:SetTitle(LANG.GetTranslation("roleinfo_addon_editor_title"))
        frame:SetBackgroundBlur(true)
        frame:SetPaintShadow(true)
        frame:SetSizable(true)

        local scrollPanel = vgui.Create( "DScrollPanel", frame )
        scrollPanel:Dock( FILL )

        local applyButton = vgui.Create( "DButton", scrollPanel )
        applyButton:SetText( LANG.GetTranslation("roleinfo_addon_apply") )
        applyButton:Dock( TOP )
        applyButton:SetSize( 250, 30 )
        applyButton:DockMargin( 10, 5, 10, 5 )
        applyButton.DoClick = function()
                RequestRoleDescriptionsChange()
                frame:Close()
        end

        local resetButton = vgui.Create( "DButton", scrollPanel )
        resetButton:SetText( LANG.GetTranslation("roleinfo_addon_reset") )
        resetButton:Dock( TOP )
        resetButton:SetSize( 250, 30 )
        resetButton:DockMargin( 10, 5, 10, 15 )

        resetButton.DoClick = function()
                local popup = vgui.Create( "DFrame" )
                popup:SetSize( 200, 100 )
                popup:Center()
                popup:MakePopup()
                popup:SetTitle(LANG.GetTranslation("roleinfo_addon_confirmation_title"))
                popup.OnClose = function (self)
                        frame:Show()
                end

                frame:Hide()

                local confirmButton = vgui.Create( "DButton", popup )
                confirmButton:SetText( LANG.GetTranslation("roleinfo_addon_confirmation") )
                confirmButton:Center()
                confirmButton:Dock( FILL )
                confirmButton.DoClick = function()
                        RequestRoleDescriptionsDelete()
                        frame:Close()
                        popup:Close()
                end
        end

        local describedRoles = {}

        for key, role in pairs(roleList) do
                if roleDescriptions[role.name] ~= nil then
                        table.insert(describedRoles, role)
                        continue
                end
                local label = vgui.Create( "DLabel", scrollPanel )
                label:SetSize(100, 20)
                label:Dock( TOP )
                label:DockMargin( 10, 5, 0, 5 )
                label:SetText(string.upper(role["name"]))
                label:SetFont("Trebuchet24")

                local textEntry = vgui.Create( "DTextEntry", scrollPanel )
                textEntry:SetSize( 50, 100)
                textEntry:Dock( TOP )
                textEntry:DockMargin( 10, 5, 10, 5 )
                textEntry:SetMultiline(true)
                textEntry:SetUpdateOnType(true)

                textEntry:SetPlaceholderText(LANG.GetTranslation("roleinfo_addon_missing_description"))
                textEntry:SetPlaceholderColor(Color(255,139,139))

                textEntry.OnValueChange = function( self )
                        roleDescriptions[role.name] = {description = self:GetValue()}
                end

                textEntry.OnEnter = function( self )
                        RequestRoleDescriptionsChange()
                end
        end

        for key, role in pairs(describedRoles) do
                local label = vgui.Create( "DLabel", scrollPanel )
                label:SetSize(100, 20)
                label:Dock( TOP )
                label:DockMargin( 10, 5, 0, 5 )
                label:SetText(string.upper(role["name"]))
                label:SetFont("Trebuchet24")

                local textEntry = vgui.Create( "DTextEntry", scrollPanel )
                textEntry:SetSize( 50, 100)
                textEntry:Dock( TOP )
                textEntry:DockMargin( 10, 5, 10, 5 )
                textEntry:SetMultiline(true)
                textEntry:SetUpdateOnType(true)
                textEntry:SetText(roleDescriptions[role.name].description)

                textEntry.OnValueChange = function( self )
                        roleDescriptions[role.name] = {description = self:GetValue()}
                end

                textEntry.OnEnter = function( self )
                        RequestRoleDescriptionsChange()
                end
        end
end

-- Console Commands
concommand.Add("role_info_gui", function(ply, cmd, args, argStr)
        RequestRoleDescriptions()
end)

-- Hooks

-- HOOKS
hook.Add("OnPlayerChat", "TTT2RequestRoleInfo", function(ply, txt, teamChat, isDead)
        if not IsValid(ply) then return end

        if txt == "!r" or txt == "!role" then
                if LocalPlayer() ~= ply then return true end
                RequestRoleDescription()
                return true
        end
end)
    
hook.Add("TTT2UpdateSubrole", "TTT2RequestRoleInfoUpdateSubrole", function(ply, oldSubroleID, newSubroleID)
        if not IsValid(ply) then return end
        if LocalPlayer() ~= ply then return end

        RequestRoleDescription()
end)


-- Networking
net.Receive("ttt2SendRoleInfoChat", RoleInfoChat)
net.Receive("ttt2SendRoleDescriptions", RoleDescription)