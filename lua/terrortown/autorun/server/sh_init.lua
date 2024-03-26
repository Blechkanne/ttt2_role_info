include("roleinfo.lua")

-- Functions
function DeleteStoreData(fileName)
    file.Delete(fileName)
end

function SaveStoreData(fileName, roleDescriptions)
    local converted = util.TableToJSON(roleDescriptions)
    file.Write(fileName, converted)
end

function ReadStoreData(fileName)
    local JSONData = file.Read(fileName)

    if (JSONData == nil) then
        return nil
    end

    return util.JSONToTable(JSONData)
end

local function SendRoleDescriptions(ply, data)
    net.Start("ttt2SendRoleDescriptions")
    net.WriteTable(data)
    net.Send(ply)
end

-- Code
local fileName = "role_descriptions_v3.json"
local roleDescriptions = ReadStoreData(fileName)

if (roleDescriptions == nil) then
    roleDescriptions = DEFAULT_ROLE_DESCRIPTIONS
    SaveStoreData(fileName, roleDescriptions)
end

local function SendRoleInfo(steamID, roleName)
    local ply = player.GetBySteamID(steamID)
    local roleData = roles.GetByName(roleName)
    local data = roleDescriptions[roleData.name]

    net.Start("ttt2SendRoleInfoChat")
    if (data == nil) then
        data = {}
    end

    net.WriteString(roleData.name)
    net.WriteTable(data)
    net.Send(ply)
end


-- Networking
util.AddNetworkString("ttt2SendRoleInfoChat")
util.AddNetworkString("ttt2RequestRoleInfoChat")
util.AddNetworkString("ttt2SendRoleDescriptions")
util.AddNetworkString("ttt2RequestRoleDescriptions")
util.AddNetworkString("ttt2RequestRoleDescriptionsChange")
util.AddNetworkString("ttt2RequestRoleDescriptionsDelete")

net.Receive("ttt2RequestRoleInfoChat", function(len, ply)
    data = net.ReadTable()
    SendRoleInfo(data[1], data[2])
end )

net.Receive("ttt2RequestRoleDescriptions", function(len, ply)
    if not ply:IsAdmin() then
        print("Unauthorized Request from " .. ply:GetName())
        return
    end

    roleDescriptions = ReadStoreData(fileName)
    SendRoleDescriptions(ply, roleDescriptions)
end )

net.Receive("ttt2RequestRoleDescriptionsChange", function(len, ply)
    if not ply:IsAdmin() then
        print("Unauthorized Request from " .. ply:GetName())
        return
    end
    
    local newRoleDescriptions = net.ReadTable()
    roleDescriptions = newRoleDescriptions
    SaveStoreData(fileName, roleDescriptions)
end )

net.Receive("ttt2RequestRoleDescriptionsDelete", function(len, ply)
    if not ply:IsAdmin() then
        print("Unauthorized Request from " .. ply:GetName())
        return
    end

    DeleteStoreData(fileName)
    roleDescriptions = DEFAULT_ROLE_DESCRIPTIONS
    SaveStoreData(fileName, roleDescriptions)
end )