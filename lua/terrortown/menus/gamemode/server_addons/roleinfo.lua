CLGAMEMODESUBMENU.base = "base_gamemodesubmenu"
CLGAMEMODESUBMENU.title = "roleinfo_addon_info"

function CLGAMEMODESUBMENU:Populate(parent)
	local form = vgui.CreateTTT2Form(parent, "roleinfo_addon_header")

	form:MakeHelp({
		label = "role_info_help_menu"
	})

    local openEditorButton = vgui.Create( "DButton", form )
    openEditorButton:SetText(LANG.GetTranslation("roleinfo_addon_open_editor"))
    openEditorButton:Dock( TOP )
    openEditorButton:SetSize( 250, 30 )
    openEditorButton:DockMargin( 10, 5, 10, 5 )
    openEditorButton.DoClick = function()
        local ply = LocalPlayer()
        if !IsValid(ply) then return end
        ply:ConCommand("role_info_gui")
    end
end
