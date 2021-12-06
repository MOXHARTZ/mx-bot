Config = nil
exports('GetConfig', function (config)
    Config = config
end)
exports('GetBannedPlayers', function()
    local fetch = [[SELECT * FROM bannedplayers]]
    local result = FetchAll(fetch)
    local embed = {
        fields = {},
        color = "#0094ff", -- blue
        author = 'PLAYERS',
    }
    if #result > 0 then
        for i = 1, #result do
            local admin
            if result[i].admin then
                admin = tonumber(result[i].admin) and '<@'..result[i].admin..'>' or result[i].admin
            else
                admin = '...'
            end
            table.insert(embed.fields, {name = 'Player', value = result[i].identifier or '...', inline = true})
            table.insert(embed.fields, {name = 'Admin', value = admin, inline = true})
            table.insert(embed.fields, {name = 'Reason', value = result[i].reason or '...', inline = true})
            if #embed.fields >= 24 then
                TriggerEvent('mx-serverman:SendEmbed', embed)
                embed.fields = {}
            end
        end
        TriggerEvent('mx-serverman:SendEmbed', embed)
    else
        local embed = {
            description = "Not banned players found",
            color = "#ff0000",
            author = 'WARNING'
        }
        TriggerEvent('mx-serverman:SendEmbed', embed)
    end
end)
exports('GetBannedPlayer', function(id)
    if GetPlayerName(id) then
        id = tonumber(id)
        local fetch = [[SELECT * FROM bannedplayers WHERE identifier = @id;]]
        local fetchData = {['@id'] = Identifier(id)}
        local result = FetchAll(fetch, fetchData)
        if result and result[1] then
            local admin
            if result[1].admin then
                admin = tonumber(result[1].admin) and '<@'..result[1].admin..'>' or result[1].admin
            else
                admin = '...'
            end
            local embed = {
                fields = {
                    {name = 'identifier', value = result[1].identifier or '...', inline = true},
                    {name = 'admin', value = admin, inline = true},
                    {name = 'discord', value = result[1].discord and '<@'..string.gsub(result[1].discord, 'discord:', '')..'>' or '...', inline = true},
                    {name = 'rockstar', value = result[1].rockstar or '...', inline = true},
                    {name = 'steam', value = result[1].steam or '...', inline = true},
                    {name = 'xbox', value = result[1].xbox or '...', inline = true},
                    {name = 'live', value = result[1].live or '...', inline = true},
                    {name = 'ip', value = result[1].ip or '...', inline = true},
                    {name = 'reason', value = result[1].reason or '...', inline = true},
                    {name = 'time', value = os.date('%d.%m.%Y %H:%M', result[1].time), inline = true}
                },
                color = "#0094ff", -- blue
                author = result[1].name or 'Name Is NULL'
            }
            TriggerEvent('mx-serverman:SendEmbed', embed)
        else
            local embed = {
                description = "Not finded player",
                color = "#ff0000",
                author = 'WARNING'
            }
            TriggerEvent('mx-serverman:SendEmbed', embed)
        end
    else
        local fetch = [[SELECT * FROM bannedplayers WHERE identifier = @id;]]
        local fetchData = {['@id'] = id}
        local result = FetchAll(fetch, fetchData)
        if result and result[1] then
            local admin
            if result[1].admin then
                admin = string.match(result[1].admin, 'discord:') and '<@'..result[1].admin..'>' or result[1].admin
            else
                admin = '...'
            end
            local embed = {
                fields = {
                    {name = 'identifier', value = result[1].identifier or '...', inline = true},
                    {name = 'admin', value = admin, inline = true},
                    {name = 'discord', value = result[1].discord and '<@'..string.gsub(result[1].discord, 'discord:', '')..'>' or '...', inline = true},
                    {name = 'rockstar', value = result[1].rockstar or '...', inline = true},
                    {name = 'xbox', value = result[1].xbox or '...', inline = true},
                    {name = 'steam', value = result[1].steam or '...', inline = true},
                    {name = 'live', value = result[1].live or '...', inline = true},
                    {name = 'ip', value = result[1].ip or '...', inline = true},
                    {name = 'reason', value = result[1].reason or '...', inline = true},
                    {name = 'time', value = os.date('%d.%m.%Y %H:%M', result[1].time), inline = true}
                },
                color = "#0094ff", -- blue
                author = result[1].name or 'Name Is NULL'
            }
            TriggerEvent('mx-serverman:SendEmbed', embed)
        else
            local embed = {
                description = "Player is not banned.",
                color = "#33ff00",
                author = 'INFORM'
            }
            TriggerEvent('mx-serverman:SendEmbed', embed)
        end
    end
end)
exports('GetDiscordFromId', function (id)
    id = tonumber(id)
    for _,v in ipairs(GetPlayerIdentifiers(id)) do
        if string.match(v, 'discord:') then
            return string.gsub(v, 'discord:', '')
        end
    end
    return false
end)
exports('Wipe', function (id)
    if Config.useQB then
        if GetPlayerName(id) then
            id = tonumber(id)
            local QBCore = exports['qb-core']:GetCoreObject()
            local xPlayer = QBCore.Functions.GetPlayer(id)
            local fetch = [[SELECT citizenid FROM players WHERE citizenid = ?]]
            local fetchData = {xPlayer.PlayerData.citizenid}
            local result = FetchAll(fetch, fetchData)
            if result and result[1] then
                for _, v in pairs(Config.wipe_tables) do
                    Execute("DELETE FROM `"..v.table.."` WHERE `"..v.owner.."` = '"..xPlayer.PlayerData.citizenid.."'")
                end
                local embed = {
                    description = GetPlayerName(id).." Wiped",
                    color = "#33ff00",
                    author = 'SUCCESS'
                }
                TriggerEvent('mx-serverman:SendEmbed', embed)
                DropPlayer(id, 'Your character has been deleted.') 
            else
                local embed = {
                    description = "Not finded player",
                    color = "#ff0000",
                    author = 'WARNING'
                }
                TriggerEvent('mx-serverman:SendEmbed', embed)
            end
        else
            local fetch = [[SELECT citizenid FROM players WHERE citizenid = ?]]
            local fetchData = {id}
            local result = FetchAll(fetch, fetchData)
            if result and result[1] then
                for _, v in ipairs(Config.wipe_tables) do
                    Execute("DELETE FROM `"..v.table.."` WHERE `"..v.owner.."` = '"..id.."'")
                end
                local embed = {
                    description = id.." Wiped",
                    color = "#33ff00",
                    author = 'SUCCESS'
                }
                TriggerEvent('mx-serverman:SendEmbed', embed)
            else
                local embed = {
                    description = "Not finded player",
                    color = "#ff0000",
                    author = 'WARNING'
                }
                TriggerEvent('mx-serverman:SendEmbed', embed)
            end
        end
    else
        if GetPlayerName(id) then
            local fetch = [[SELECT identifier FROM users WHERE identifier = @id]]
            local fetchData = {['@id'] = Identifier(id)}
            local result = FetchAll(fetch, fetchData)
            if result and result[1] then
                for _, v in pairs(Config.wipe_tables) do
                    Execute("DELETE FROM `"..v.table.."` WHERE `"..v.owner.."` = '"..Identifier(id).."'")
                end
                local embed = {
                    description = GetPlayerName(id).." Wiped",
                    color = "#33ff00",
                    author = 'SUCCESS'
                }
                TriggerEvent('mx-serverman:SendEmbed', embed)
                DropPlayer(id, 'Your character has been deleted.') 
            else
                local embed = {
                    description = "Not finded player",
                    color = "#ff0000",
                    author = 'WARNING'
                }
                TriggerEvent('mx-serverman:SendEmbed', embed)
            end
        else
            local fetch = [[SELECT identifier FROM users WHERE identifier = @id;]]
            local fetchData = {['@id'] = id}
            local result = FetchAll(fetch, fetchData)
            if result and result[1] then
                for _, v in ipairs(Config.wipe_tables) do
                    Execute("DELETE FROM `"..v.table.."` WHERE `"..v.owner.."` = '"..id.."'")
                end
                local embed = {
                    description = id.." Wiped",
                    color = "#33ff00",
                    author = 'SUCCESS'
                }
                TriggerEvent('mx-serverman:SendEmbed', embed)
            else
                local embed = {
                    description = "Not finded player",
                    color = "#ff0000",
                    author = 'WARNING'
                }
                TriggerEvent('mx-serverman:SendEmbed', embed)
            end
        end
    end
end)
exports('GetInventory', function (id)
    if Config.useQB then
        id = tonumber(id)
        local QBCore = exports['qb-core']:GetCoreObject()
        if GetPlayerName(id) and QBCore.Functions.GetPlayer(tonumber(id)) then
            local embed = {
                fields = {},
                color = "#0094ff", -- blue
                author = 'SUCCESS'
            }
            print('hü amk çocugu')
            local inventory = QBCore.Functions.GetPlayer(tonumber(id)).PlayerData.items
            if inventory and next(inventory) then
                for _,v in ipairs(inventory) do
                    table.insert(embed.fields, {name = v.label, value = v.amount, inline = true})
                    if #embed.fields >= 24 then
                        TriggerEvent('mx-serverman:SendEmbed', embed)
                        embed.fields = {}
                    end
                end
            else
                embed.description = 'Doesn\'t have an item'
            end
            if #embed.fields == 0 then
                embed.description = 'Doesn\'t have an item'
            end
            TriggerEvent('mx-serverman:SendEmbed', embed)
        else
            local fetch = [[SELECT inventory FROM players WHERE citizenid = ?]]
            local fetchData = {id}
            local result = FetchAll(fetch, fetchData)
            local embed = {
                fields = {},
                color = "#0094ff", -- blue
                author = 'SUCCESS'
            }
            if result and #result > 0 then
                local items = json.decode(result[1].inventory)
                if items then
                    for i = 1, #items do
                        table.insert(embed.fields, {name = items[i].name, value = items[i].amount, inline = true})
                        if #embed.fields >= 24 then
                            TriggerEvent('mx-serverman:SendEmbed', embed)
                            embed.fields = {}
                        end
                    end
                end
            else
                embed.description = 'Doesn\'t have an item'
            end
            TriggerEvent('mx-serverman:SendEmbed', embed)
        end
    else
        if GetPlayerName(id) then
            id = tonumber(id)
            local embed = {
                fields = {},
                color = "#0094ff", -- blue
                author = 'SUCCESS'
            }
            TriggerEvent('esx:getSharedObject', function(ESX)
                local inventory = ESX.GetPlayerFromId(id).inventory
                if inventory and next(inventory) then
                    for i = 1, #inventory do
                        if inventory[i].count > 0 then
                            table.insert(embed.fields, {name = ESX.Items[inventory[i].name] and ESX.Items[inventory[i].name].label or inventory[i].name, value = inventory[i].count, inline = true})
                            if #embed.fields >= 24 then
                                TriggerEvent('mx-serverman:SendEmbed', embed)
                                embed.fields = {}
                            end
                        end
                    end
                else
                    embed.description = 'Doesn\'t have an item'
                end
                if #embed.fields == 0 then
                    embed.description = 'Doesn\'t have an item'
                end
                TriggerEvent('mx-serverman:SendEmbed', embed)
            end)
        else
            if Config['old_esx'].user_inventory then
                local fetch = [[SELECT item, count FROM user_inventory WHERE identifier = @id AND count > 0;]]
                local fetchData = {['@id'] = id}
                local result = FetchAll(fetch, fetchData)
                local embed = {
                    fields = {},
                    color = "#0094ff", -- blue
                    author = 'SUCCESS'
                }
                if result and #result > 0 then
                    for i = 1, #result do
                        table.insert(embed.fields, {name = result[i].item, value = result[i].count, inline = true})
                        if #embed.fields >= 24 then
                            TriggerEvent('mx-serverman:SendEmbed', embed)
                            embed.fields = {}
                        end
                    end
                else
                    embed.description = 'Doesn\'t have an item'
                end
                TriggerEvent('mx-serverman:SendEmbed', embed)
            else
                local fetch = [[SELECT inventory FROM users WHERE identifier = @id;]]
                local fetchData = {['@id'] = id}
                local result = FetchAll(fetch, fetchData)
                if result and result[1] then
                    local embed = {
                        fields = {},
                        color = "#0094ff", -- blue
                        author = 'SUCCESS'
                    }
                    local inventory = json.decode(result[1].inventory)
                    if next(inventory) then
                        for k,v in pairs(inventory) do
                            embed.fields[#embed.fields+1] = {name = k, value = v, inline = true}
                            if #embed.fields >= 24 then
                                TriggerEvent('mx-serverman:SendEmbed', embed)
                                embed.fields = {}
                            end
                        end
                    else    
                        embed.description = 'Doesn\'t have an item'
                    end
                    TriggerEvent('mx-serverman:SendEmbed', embed)
                else
                    local embed = {
                        description = "Not finded player",
                        color = "#ff0000",
                        author = 'WARNING'
                    }
                    TriggerEvent('mx-serverman:SendEmbed', embed)
                end
            end
        end
    end
end)
exports('SetCoords', function (id, x, y, z)
    if GetPlayerName(id) then
        if Config.useQB then
            id = tonumber(id)
            TriggerClientEvent('QBCore:Command:TeleportToCoords', id, tonumber(x), tonumber(y), tonumber(z))
        else
            TriggerClientEvent('esx:teleport', id, {x = tonumber(x), y = tonumber(y), z = tonumber(z)})
        end
        local embed = {
            color = "#0094ff", -- blue
            author = 'SUCCESS',
            title = '`'..GetPlayerName(id)..'` Coords has been set. \n**Teleported coords** \nx = `'..x..'` \ny = `'..y..'` \nz = `'..z..'`'
        }
        TriggerEvent('mx-serverman:SendEmbed', embed)
    else
        local embed = {
            description = "Player Is Not Online",
            color = "#ff0000",
            author = 'WARNING'
        }
        TriggerEvent('mx-serverman:SendEmbed', embed)
    end
end)
exports('GetMoney', function (id)
    if Config.useQB then
        id = tonumber(id)
        if GetPlayerName(id) then
            local QBCore = exports['qb-core']:GetCoreObject()
            local xPlayer = QBCore.Functions.GetPlayer(id)
            local embed = {
                fields = {
                    {name = 'Bank', value = xPlayer.PlayerData.money['bank'], inline = true},
                    {name = 'Money', value = xPlayer.PlayerData.money['cash'], inline = true},
                    {name = 'Crypto', value = xPlayer.PlayerData.money['crypto'], inline = true},
                },
                color = "#0094ff", -- blue
                author = 'SUCCESS'
            }
            TriggerEvent('mx-serverman:SendEmbed', embed)
        else
            local fetch = [[SELECT money FROM players WHERE citizenid = ?]]
            local fetchData = {id}
            local result = FetchAll(fetch, fetchData)
            if result and result[1] then
                local embed = {
                    fields = {},
                    color = "#0094ff", -- blue
                    author = 'SUCCESS'
                }
                if result[1].money and json.decode(result[1].money) then
                    local accounts = json.decode(result[1].money)
                    if accounts.bank then
                        table.insert(embed.fields, {
                            name = 'Bank',
                            value = accounts.bank
                        })
                    end
                    if accounts.crypto then
                        table.insert(embed.fields, {
                            name = 'Crypto',
                            value = accounts.crypto
                        })
                    end
                    if accounts.cash then
                        table.insert(embed.fields, {
                            name = 'Cash',
                            value = accounts.cash
                        })
                    end
                    TriggerEvent('mx-serverman:SendEmbed', embed)
                else
                    local embed = {
                        description = "[DATABASE] Not finded accounts",
                        color = "#ff0000",
                        author = 'WARNING'
                    }
                    TriggerEvent('mx-serverman:SendEmbed', embed)
                end
            else
                local embed = {
                    description = "Not finded player",
                    color = "#ff0000",
                    author = 'WARNING'
                }
                TriggerEvent('mx-serverman:SendEmbed', embed)
            end
        end
    else
        if GetPlayerName(id) then
            id = tonumber(id)
            TriggerEvent('esx:getSharedObject', function(ESX)
                local xPlayer = ESX.GetPlayerFromId(id)
                local embed = {
                    fields = {
                        {name = 'Bank', value = xPlayer.getAccount('bank').money, inline = true},
                        {name = 'Money', value = xPlayer.getAccount('money').money, inline = true},
                        {name = 'Black Money', value = xPlayer.getAccount('black_money').money, inline = true}
                    },
                    color = "#0094ff", -- blue
                    author = 'SUCCESS'
                }
                TriggerEvent('mx-serverman:SendEmbed', embed)
            end)
        else
            if Config['old_esx'].user_accounts then
                local embed = {
                    color = "#0094ff", -- blue
                    title = 'SUCCESS',
                    fields = {}
                }
                local fetch = [[SELECT name, money FROM user_accounts WHERE identifier = @id]]
                local fetchData = {['@id'] = id}
                local result = FetchAll(fetch, fetchData)
                if result and result[1] then
                    for i = 1, #result do
                        table.insert(embed.fields, {name = result[i].name, value = result[i].money})
                    end
                    TriggerEvent('mx-serverman:SendEmbed', embed)
                else
                    local embed = {
                        description = "Not finded player accounts",
                        color = "#ff0000",
                        author = 'WARNING'
                    }
                    TriggerEvent('mx-serverman:SendEmbed', embed)
                end
            else
                local fetch = [[SELECT accounts FROM users WHERE identifier = @id;]]
                local fetchData = {['@id'] = id}
                local result = FetchAll(fetch, fetchData)
                if result and result[1] then
                    local embed = {
                        fields = {},
                        color = "#0094ff", -- blue
                        author = 'SUCCESS'
                    }
                    if result[1].accounts and json.decode(result[1].accounts) then
                        local accounts = json.decode(result[1].accounts)
                        if accounts.bank then
                            table.insert(embed.fields, {
                                name = 'Bank',
                                value = accounts.bank
                            })
                        end
                        if accounts.black_money then
                            table.insert(embed.fields, {
                                name = 'Black Money',
                                value = accounts.black_money
                            })
                        end
                        if accounts.money then
                            table.insert(embed.fields, {
                                name = 'Cash',
                                value = accounts.money
                            })
                        end
                        TriggerEvent('mx-serverman:SendEmbed', embed)
                    else
                        local embed = {
                            description = "[DATABASE] Not finded accounts",
                            color = "#ff0000",
                            author = 'WARNING'
                        }
                        TriggerEvent('mx-serverman:SendEmbed', embed)
                    end
                else
                    local embed = {
                        description = "Not finded player",
                        color = "#ff0000",
                        author = 'WARNING'
                    }
                    TriggerEvent('mx-serverman:SendEmbed', embed)
                end
            end
        end
    end
end)
exports('GetGeneralInformations', function (id)
    local QBCore, xPlayer, fetch, fetchData, result, ident, customDiscord
    if Config.useQB then
        if GetPlayerName(id) then
            id = tonumber(id)
             QBCore = exports['qb-core']:GetCoreObject()
             xPlayer = QBCore.Functions.GetPlayer(id)
             fetch = [[SELECT * FROM players WHERE citizenid = ?;]]
             fetchData = {xPlayer.PlayerData.citizenid}
             result = FetchAll(fetch, fetchData)
             ident = xPlayer.PlayerData.citizenid
        else
            fetch = [[SELECT * FROM players WHERE citizenid = ?;]]
            fetchData = {id}
            result = FetchAll(fetch, fetchData)
            ident = id
        end
        if result and result[1] then
            local job = json.decode(result[1].job)
            local inf = json.decode(result[1].charinfo)
            local embed = {
                fields = {
                    {name = 'Identifier', value = ident or '...', inline = true},
                    {name = 'Firstname', value = inf.firstname or '...', inline = true},
                    {name = 'Lastname', value = inf.lastname or '...', inline = true},
                    {name = 'DateOfBirth', value = inf.birthdate or '...', inline = true},
                    {name = 'Phone Number', value = inf.phone or '...', inline = true},
                    {name = 'Job', value = job.name or '...', inline = true},
                    {name = 'Grade', value = job.label ..' ['..job.grade.name..']', inline = true},
                    {name = 'Sex', value = inf.gender == 1 and 'female' or 'male', inline = true},
                },
                color = "#0094ff", -- blue
                author = 'SUCCESS'
            }
            TriggerEvent('mx-serverman:SendEmbed', embed)
        else
            local embed = {
                description = "Not finded player",
                color = "#ff0000",
                author = 'WARNING'
            }
            TriggerEvent('mx-serverman:SendEmbed', embed)
        end
    else
        if GetPlayerName(id) then
            id = tonumber(id)
            fetch = [[SELECT * FROM users WHERE identifier = @id]]
            fetchData = {['@id'] = Identifier(id)}
            result = FetchAll(fetch, fetchData)
            ident = Identifier(id)
        else
            fetch = [[SELECT * FROM users WHERE identifier = @id]]
            fetchData = {['@id'] = id}
            result = FetchAll(fetch, fetchData)
            ident = id
        end
        if result and result[1] then
            local job = GetJobProps(result[1].job, result[1].job_grade)
            local embed = {
                fields = {
                    {name = 'Identifier', value = ident, inline = true},
                    {name = 'Firstname', value = result[1].firstname, inline = true},
                    {name = 'Lastname', value = result[1].lastname, inline = true},
                    {name = 'DateOfBirth', value = result[1].dateofbirth, inline = true},
                    {name = 'Job', value = result[1].job, inline = true},
                    {name = 'Grade', value = job and job[1] and job[1].label ..' ['..result[1].job_grade..']' or '...', inline = true},
                    {name = 'Group', value = result[1].group or '...', inline = true},
                    {name = 'Sex', value = result[1].sex, inline = true}
                },
                color = "#0094ff", -- blue
                author = 'SUCCESS'
            }
            TriggerEvent('mx-serverman:SendEmbed', embed)
        else
            local embed = {
                description = "Not finded player",
                color = "#ff0000",
                author = 'WARNING'
            }
            TriggerEvent('mx-serverman:SendEmbed', embed)
        end
    end
end)
exports('AddMoney', function (id, type, amount)
    if Config.useQB then
        if type == 'money' then type = 'cash' end
        if GetPlayerName(id) then
            id = tonumber(id)
            local QBCore = exports['qb-core']:GetCoreObject()
            local xPlayer = QBCore.Functions.GetPlayer(id)
            if xPlayer then
                
                local oldMoney = xPlayer.PlayerData.money[type]
                xPlayer.Functions.AddMoney(type, tonumber(amount))
                local embed = {
                    color = "#0094ff", -- blue
                    title = '`'..GetPlayerName(id)..'` gived `'..amount..'` \nOld Balance: `'..oldMoney..'` \nNew Balance: `'..xPlayer.PlayerData.money[type]..'` \nType: `'..type..'`',
                }
                TriggerEvent('mx-serverman:SendEmbed', embed)
            else   
                local embed = {
                    description = "[ESX] Not Finded Player",
                    color = "#ff0000",
                    author = 'WARNING'
                }
                TriggerEvent('mx-serverman:SendEmbed', embed)
            end
        else    
            local fetch = [[SELECT money FROM players WHERE citizenid = ?]]
            local fetchData = {id}
            local result = FetchAll(fetch, fetchData)
            if result and result[1] then
                if result[1].money and json.decode(result[1].money) then
                    local accounts = json.decode(result[1].money)
                    local oldMoney = accounts[type]
                    accounts[type] = math.floor(accounts[type] + tonumber(amount))
                    Execute('UPDATE players SET money = ? WHERE citizenid = ?', {json.encode(accounts), id})
                    local embed = {
                        color = "#0094ff", -- blue
                        title = '`'..id..'` gived `'..amount..'` \nOld Balance: `'..oldMoney..'` \nNew Balance: `'..accounts[type]..'` \nType: `'..type..'`',
                    }
                    TriggerEvent('mx-serverman:SendEmbed', embed)
                else
                    local embed = {
                        description = "[DATABASE] Not finded accounts",
                        color = "#ff0000",
                        author = 'WARNING'
                    }
                    TriggerEvent('mx-serverman:SendEmbed', embed)
                end
            else
                local embed = {
                    description = "Not finded player",
                    color = "#ff0000",
                    author = 'WARNING'
                }
                TriggerEvent('mx-serverman:SendEmbed', embed)
            end
        end 
    else
        if GetPlayerName(id) then
            TriggerEvent('esx:getSharedObject', function(ESX)
                local xPlayer = ESX.GetPlayerFromId(id)
                if xPlayer then
                    local oldMoney = xPlayer.getAccount(type).money
                    xPlayer.addAccountMoney(type, tonumber(amount))
                    local embed = {
                        color = "#0094ff", -- blue
                        title = '`'..GetPlayerName(id)..'` gived `'..amount..'` \nOld Balance: `'..oldMoney..'` \nNew Balance: `'..xPlayer.getAccount(type).money..'` \nType: `'..type..'`',
                    }
                    TriggerEvent('mx-serverman:SendEmbed', embed)
                else   
                   local embed = {
                       description = "[ESX] Not Finded Player",
                       color = "#ff0000",
                       author = 'WARNING'
                   }
                   TriggerEvent('mx-serverman:SendEmbed', embed)
                end
            end)
        else    
            if Config['old_esx'].user_accounts then
                local fetch = [[SELECT name, money FROM user_accounts WHERE identifier = @id]]
                local fetchData = {['@id'] = id}
                local result = FetchAll(fetch, fetchData)
                if result and result[1] then
                    for i = 1, #result do
                        if type == result[i].name then
                            local embed = {
                                color = "#0094ff", -- blue
                                title = '`'..id..'` gived `'..amount..'` \nOld Balance: `'..result[i].money..'` \nNew Balance: `'..(math.floor(result[i].money + amount))..'` \nType: `'..type..'`',
                            }
                            TriggerEvent('mx-serverman:SendEmbed', embed)
                            Execute('UPDATE user_accounts SET money = @money WHERE identifier = @id AND name = @name', {
                                ['@money'] = result[i].money + math.floor(tonumber(amount)),
                                ['@id'] = id,
                                ['@name'] = type
                            })
                            break
                        end
                    end
                else
                    local embed = {
                        description = "Not finded player accounts",
                        color = "#ff0000",
                        author = 'WARNING'
                    }
                    TriggerEvent('mx-serverman:SendEmbed', embed)
                end
            else
                local fetch = [[SELECT accounts FROM users WHERE identifier = @id]]
                local fetchData = {['@id'] = id}
                local result = FetchAll(fetch, fetchData)
                if result and result[1] then
                    if result[1].accounts and json.decode(result[1].accounts) then
                        local accounts = json.decode(result[1].accounts)
                        local oldMoney = accounts[type]
                        accounts[type] = math.floor(accounts[type] + tonumber(amount))
                        Execute('UPDATE users SET accounts = @accounts WHERE identifier = @id', {['@accounts'] = json.encode(accounts), ['@id'] = id})
                        local embed = {
                            color = "#0094ff", -- blue
                            title = '`'..GetPlayerName(id)..'` gived `'..amount..'` \nOld Balance: `'..oldMoney..'` \nNew Balance: `'..accounts[type]..'` \nType: `'..type..'`',
                        }
                        TriggerEvent('mx-serverman:SendEmbed', embed)
                    else
                        local embed = {
                            description = "[DATABASE] Not finded accounts",
                            color = "#ff0000",
                            author = 'WARNING'
                        }
                        TriggerEvent('mx-serverman:SendEmbed', embed)
                    end
                else
                    local embed = {
                        description = "Not finded player",
                        color = "#ff0000",
                        author = 'WARNING'
                    }
                    TriggerEvent('mx-serverman:SendEmbed', embed)
                end
            end
        end 
    end
end)
exports('SetJob', function(id, job, grade)
    if Config.useQB then
        if GetPlayerName(id) then
            id = tonumber(id)
            local QBCore = exports['qb-core']:GetCoreObject()
            local xPlayer = QBCore.Functions.GetPlayer(id)
            if xPlayer then
                local beforeJob = xPlayer.PlayerData.job.name
                local beforeJobGrade = xPlayer.PlayerData.job.grade.name
                xPlayer.Functions.SetJob(job, grade)
                local embed = {
                    color = "#0094ff", -- blue
                    title = GetPlayerName(id)..' setted job \nOld Job: `'..beforeJob..'`\nNew Job: `'..job..'` \nOld Grade: `'..beforeJobGrade..'` \nNew Grade: `'..grade..'`',
                }
                TriggerEvent('mx-serverman:SendEmbed', embed)
            else   
                local embed = {
                    description = "QBCORE Not Finded Player",
                    color = "#ff0000",
                    author = 'WARNING'
                }
                TriggerEvent('mx-serverman:SendEmbed', embed)
            end
        else    
            local embed = {
                description = "Not finded player",
                color = "#ff0000",
                author = 'WARNING'
            }
            TriggerEvent('mx-serverman:SendEmbed', embed)
        end 
    else
        TriggerEvent('esx:getSharedObject', function(ESX)
            if ESX.DoesJobExist(job, grade) then
                if GetPlayerName(id) then
                    local xPlayer = ESX.GetPlayerFromId(id)
                    if xPlayer then
                        local beforeJob = xPlayer.getJob().name
                        local beforeJobGrade = xPlayer.getJob().grade
                        xPlayer.setJob(job, grade)
                        local embed = {
                            color = "#0094ff", -- blue
                            title = GetPlayerName(id)..' setted job \nOld Job: `'..beforeJob..'`\nNew Job: `'..job..'` \nOld Grade: `'..beforeJobGrade..'` \nNew Grade: `'..grade..'`',
                        }
                        TriggerEvent('mx-serverman:SendEmbed', embed)
                    else   
                       local embed = {
                           description = "[ESX] Not Finded Player",
                           color = "#ff0000",
                           author = 'WARNING'
                       }
                       TriggerEvent('mx-serverman:SendEmbed', embed)
                    end
                else    
                    local fetch = [[SELECT job, job_grade FROM users WHERE identifier = @id]]
                    local fetchData = {['@id'] = id}
                    local result = FetchAll(fetch, fetchData)
                    if result and result[1] then
                        Execute('UPDATE users SET job = @job, job_grade = @grade WHERE identifier = @id', {
                            ['@job'] = job,
                            ['@grade'] = grade,
                            ['@id'] = id
                        })
                        local embed = {
                            color = "#0094ff", -- blue
                            title = id..' setted job \nOld Job: `'..result[1].job..'`\nNew Job: `'..job..'` \nOld Grade: `'..result[1].job_grade..'` \nNew Grade: `'..grade..'`',
                        }
                        TriggerEvent('mx-serverman:SendEmbed', embed)
                    else
                        local embed = {
                            description = "Not finded player",
                            color = "#ff0000",
                            author = 'WARNING'
                        }
                        TriggerEvent('mx-serverman:SendEmbed', embed)
                    end
                end 
            else    
                local embed = {
                    description = "[ESX] The job, grade or both are invalid",
                    color = "#ff0000",
                    author = 'WARNING'
                }
                TriggerEvent('mx-serverman:SendEmbed', embed)
            end
        end)
    end

end)
exports('RemoveMoney', function (id, type, amount)
    if Config.useQB then
        if type == 'money' then type = 'cash' end
        if GetPlayerName(id) then
            id = tonumber(id)
            local QBCore = exports['qb-core']:GetCoreObject()
            local xPlayer = QBCore.Functions.GetPlayer(id)
            if xPlayer then
                local oldMoney = xPlayer.PlayerData.money[type]
                xPlayer.Functions.RemoveMoney(type, tonumber(amount))
                local embed = {
                    color = "#0094ff", -- blue
                    title = '`'..GetPlayerName(id)..'` taked `'..amount..'` \nOld Balance: `'..oldMoney..'` \nNew Balance: `'..xPlayer.PlayerData.money[type]..'` \nType: `'..type..'`',
                }
                TriggerEvent('mx-serverman:SendEmbed', embed)
            else   
                local embed = {
                    description = "[QBCORE] Not Finded Player",
                    color = "#ff0000",
                    author = 'WARNING'
                }
                TriggerEvent('mx-serverman:SendEmbed', embed)
            end
        else    
            local fetch = [[SELECT money FROM players WHERE citizenid = ?]]
            local fetchData = {id}
            local result = FetchAll(fetch, fetchData)
            if result and result[1] then
                if result[1].money and json.decode(result[1].money) then
                    local accounts = json.decode(result[1].money)
                    local oldMoney = accounts[type]
                    accounts[type] = math.floor(accounts[type] - tonumber(amount))
                    Execute('UPDATE players SET money = ? WHERE citizenid = ?', {json.encode(accounts), id})
                    local embed = {
                        color = "#0094ff", -- blue
                        title = '`'..id..'` taked `'..tonumber(amount)..'` \nOld Balance: `'..oldMoney..'` \nNew Balance: `'..accounts[type]..'` \nType: `'..type..'`',
                    }
                    TriggerEvent('mx-serverman:SendEmbed', embed)
                else    
                    local embed = {
                        description = "[DATABASE] Not finded accounts",
                        color = "#ff0000",
                        author = 'WARNING'
                    }
                    TriggerEvent('mx-serverman:SendEmbed', embed)
                end
            else
                local embed = {
                    description = "Not finded player",
                    color = "#ff0000",
                    author = 'WARNING'
                }
                TriggerEvent('mx-serverman:SendEmbed', embed)
            end
        end 
    else
        if GetPlayerName(id) then
            TriggerEvent('esx:getSharedObject', function(ESX)
                local xPlayer = ESX.GetPlayerFromId(id)
                if xPlayer then
                    local oldMoney = xPlayer.getAccount(type).money
                    xPlayer.removeAccountMoney(type, tonumber(amount))
                    local embed = {
                        color = "#0094ff", -- blue
                        title = '`'..GetPlayerName(id)..'` taked `'..amount..'` \nOld Balance: `'..oldMoney..'` \nNew Balance: `'..xPlayer.getAccount(type).money..'` \nType: `'..type..'`',
                    }
                    TriggerEvent('mx-serverman:SendEmbed', embed)
                else   
                   local embed = {
                       description = "[ESX] Not Finded Player",
                       color = "#ff0000",
                       author = 'WARNING'
                   }
                   TriggerEvent('mx-serverman:SendEmbed', embed)
                end
            end)
        else    
            if Config['old_esx'].user_accounts then
                local fetch = [[SELECT name, money FROM user_accounts WHERE identifier = @id]]
                local fetchData = {['@id'] = id}
                local result = FetchAll(fetch, fetchData)
                if result and result[1] then
                    for i = 1, #result do
                        if type == result[i].name then
                            local embed = {
                                color = "#0094ff", -- blue
                                title = '`'..id..'` taked `'..amount..'` \nOld Balance: `'..result[i].money..'` \nNew Balance: `'..(math.floor(result[i].money - amount))..'` \nType: `'..type..'`',
                            }
                            TriggerEvent('mx-serverman:SendEmbed', embed)
                            Execute('UPDATE user_accounts SET money = @money WHERE identifier = @id AND name = @name', {
                                ['@money'] = result[i].money - math.floor(tonumber(amount)),
                                ['@id'] = id,
                                ['@name'] = type
                            })
                            break
                        end
                    end
                else
                    local embed = {
                        description = "Not finded player accounts",
                        color = "#ff0000",
                        author = 'WARNING'
                    }
                    TriggerEvent('mx-serverman:SendEmbed', embed)
                end
            else
                local fetch = [[SELECT accounts FROM users WHERE identifier = @id]]
                local fetchData = {['@id'] = id}
                local result = FetchAll(fetch, fetchData)
                if result and result[1] then
                    if result[1].accounts and json.decode(result[1].accounts) then
                        local accounts = json.decode(result[1].accounts)
                        local oldMoney = accounts[type]
                        accounts[type] = math.floor(accounts[type] - tonumber(amount))
                        Execute('UPDATE users SET accounts = @accounts WHERE identifier = @id', {['@accounts'] = json.encode(accounts), ['@id'] = id})
                        local embed = {
                            color = "#0094ff", -- blue
                            title = '`'..id..'` taked `'..tonumber(amount)..'` \nOld Balance: `'..oldMoney..'` \nNew Balance: `'..accounts[type]..'` \nType: `'..type..'`',
                        }
                        TriggerEvent('mx-serverman:SendEmbed', embed)
                    else    
                        local embed = {
                            description = "[DATABASE] Not finded accounts",
                            color = "#ff0000",
                            author = 'WARNING'
                        }
                        TriggerEvent('mx-serverman:SendEmbed', embed)
                    end
                else
                    local embed = {
                        description = "Not finded player",
                        color = "#ff0000",
                        author = 'WARNING'
                    }
                    TriggerEvent('mx-serverman:SendEmbed', embed)
                end
            end
        end 
    end
end)
exports('GiveItem', function (id, name, count)
    count = tonumber(count)
    if Config.useQB then
        if GetPlayerName(id) then
            id = tonumber(id)
            local QBCore = exports['qb-core']:GetCoreObject()
            QBCore.Functions.GetPlayer(id).Functions.AddItem(name, count)
            local embed = {
                color = "#0094ff", -- blue
                title = '`'..GetPlayerName(id)..'` gived item. \nItem name:`'..name..'` \nCount: `'..count..'`',
            }
            TriggerEvent('mx-serverman:SendEmbed', embed)
        else
            local embed = {
                description = "Not finded player",
                color = "#ff0000",
                author = 'WARNING'
            }
            TriggerEvent('mx-serverman:SendEmbed', embed)
        end
    else
        if GetPlayerName(id) then
            TriggerEvent('esx:getSharedObject', function(ESX)
                ESX.GetPlayerFromId(id).addInventoryItem(name, count)
                local embed = {
                    color = "#0094ff", -- blue
                    title = '`'..GetPlayerName(id)..'` gived item. \nItem name:`'..name..'` \nCount: `'..count..'`',
                }
                TriggerEvent('mx-serverman:SendEmbed', embed)
            end)
        else
            local fetch = [[SELECT inventory FROM users WHERE identifier = @id]]
            local fetchData = {['@id'] = id}
            local result = FetchAll(fetch, fetchData)
            if result and result[1] then
                if result[1].inventory then
                    local inventory = json.decode(result[1].inventory)
                    inventory[name] = inventory[name] >= 0 and count + inventory[name]
                    Execute('UPDATE users SET inventory = @inv WHERE identifier = @id',  {
                        ['@id'] = id,
                        ['@inv'] = json.encode(inventory)
                    })
                    local embed = {
                        color = "#0094ff", -- blue
                        title = '`'..id..'` gived item. \nItem name:`'..name..'` \nCount: `'..count..'`',
                    }
                    TriggerEvent('mx-serverman:SendEmbed', embed)
                else
                    Execute('UPDATE users SET inventory = @inv WHERE identifier = @id',  {
                        ['@id'] = id,
                        ['@inv'] = json.encode({name = count})
                    })
                    local embed = {
                        color = "#0094ff", -- blue
                        title = '`'..id..'` gived item. \nItem name:`'..name..'` \nCount: `'..count..'`',
                    }
                    TriggerEvent('mx-serverman:SendEmbed', embed)
                end
            else
                local embed = {
                    description = "Not finded player",
                    color = "#ff0000",
                    author = 'WARNING'
                }
                TriggerEvent('mx-serverman:SendEmbed', embed)
            end
        end
    end
end)
exports('GetPlayers', function ()
    local embed = {
        color = "#0094ff", -- blue
        author = 'PLAYERS',
    }
    if Config.useQB then
        local QBCore = exports['qb-core']:GetCoreObject()
        local players = QBCore.Functions.GetPlayers()
        embed.title = '`'..#players..'` Online Player(s)'
        if next(players) then
            embed.fields = {
                {name = 'NAME [ID]', inline = true, value = ''},
                {name = 'DISCORD', inline = true, value = ''},
                {name = 'IDENTIFIER', inline = true, value = ''}
            }
            for i = 1, #players do
                local xPlayer = QBCore.Functions.GetPlayer(players[i])
                local discord = GetDiscord(players[i]) or 'Not Finded'
                embed.fields[1].value = embed.fields[1].value..GetPlayerName(players[i])..' ['..players[i]..']'
                embed.fields[2].value = embed.fields[2].value..'<@'..discord..'>'
                embed.fields[3].value = embed.fields[3].value..xPlayer.PlayerData.citizenid
            end
        end
        TriggerEvent('mx-serverman:SendEmbed', embed)
    else
        TriggerEvent('esx:getSharedObject', function(ESX)
            local players = ESX.GetPlayers()
            embed.title = '`'..#players..'` Online Player(s)'
            if next(players) then
                embed.fields = {
                    {name = 'NAME [ID]', inline = true, value = ''},
                    {name = 'DISCORD', inline = true, value = ''},
                    {name = 'IDENTIFIER', inline = true, value = ''}
                }
                for i = 1, #players do
                    local xPlayer = ESX.GetPlayerFromId(players[i])
                    local discord = GetDiscord(players[i]) or 'Not Finded'
                    embed.fields[1].value = embed.fields[1].value..GetPlayerName(players[i])..' ['..players[i]..']'
                    embed.fields[2].value = embed.fields[2].value..'<@'..discord..'>'
                    embed.fields[3].value = embed.fields[3].value..xPlayer.identifier
                end
            end
            TriggerEvent('mx-serverman:SendEmbed', embed)
        end)
    end
    
end)
exports('Revive', function (id)    
    if GetPlayerName(id) then
        if Config.useQB then
            id = tonumber(id)
            TriggerClientEvent('hospital:client:Revive', id)
        else
            TriggerClientEvent('esx_ambulancejob:revive', id)
        end
        local embed = {
            color = "#0094ff", -- blue
            title = '`'..GetPlayerName(id)..'` Revived.',
        }
        TriggerEvent('mx-serverman:SendEmbed', embed)
    else    
        local embed = {
            description = "Player is not ingame",
            color = "#ff0000",
            author = 'WARNING'
        }
        TriggerEvent('mx-serverman:SendEmbed', embed)
    end
end)
exports('start', function(name)
    local find = false
    for i = 1, GetNumResources() do
        local resource_id = i - 1
		local resource_name = GetResourceByFindIndex(resource_id)
        if name == resource_name then
            find = true
            break
        end
    end
    if find then
        local embed = {
            color = "#0094ff", -- blue
            title = name..' Started.',
        }
        ExecuteCommand('ensure '..name)
        TriggerEvent('mx-serverman:SendEmbed', embed)
    else
        local embed = {
            color = "#0094ff", -- blue
            title = 'Script not found!',
        }
        TriggerEvent('mx-serverman:SendEmbed', embed)
    end
end)
exports('stop', function(name)
    local find = false
    for i = 1, GetNumResources() do
        local resource_id = i - 1
		local resource_name = GetResourceByFindIndex(resource_id)
        if name == resource_name then
            find = true
            break
        end
    end
    if find then
        if GetResourceState(name) ~= 'stopped' then
            local embed = {
                color = "#0094ff", -- blue
                title = name..' Stopped.',
            }
            ExecuteCommand('stop '..name)
            TriggerEvent('mx-serverman:SendEmbed', embed)
        else
            local embed = {
                color = "#0094ff", -- blue
                title = 'The script is already closed!',
            }
            TriggerEvent('mx-serverman:SendEmbed', embed)
        end
    else
        local embed = {
            color = "#0094ff", -- blue
            title = 'Script not found!',
        }
        TriggerEvent('mx-serverman:SendEmbed', embed)
    end
end)
exports('refresh', function ()
    local embed = {
        color = "#0094ff", -- blue
        title = 'Scripts have been refreshed.',
    }
    ExecuteCommand('refresh')
    TriggerEvent('mx-serverman:SendEmbed', embed)
end)
exports('ReviveAll', function ()
    if Config.useQB then
        local QBCore = exports['qb-core']:GetCoreObject()
        local players = QBCore.Functions.GetPlayers()
        for i = 1, #players do
            TriggerClientEvent('hospital:client:Revive', players[i])
        end
        if next(players) then
            local embed = {
                color = "#0094ff", -- blue
                title = 'All Players Revived. Total:`'..#players..'`',
            }
            TriggerEvent('mx-serverman:SendEmbed', embed)
        else    
            local embed = {
                color = "#0094ff", -- blue
                title = 'Not player found.',
            }
            TriggerEvent('mx-serverman:SendEmbed', embed)
        end
    else
        TriggerEvent('esx:getSharedObject', function(ESX)
            local players = ESX.GetPlayers()
            for i = 1, #players do
                TriggerClientEvent('esx_ambulancejob:revive', players[i])
            end
            if next(players) then
                local embed = {
                    color = "#0094ff", -- blue
                    title = 'All Players Revived. Total:`'..#players..'`',
                }
                TriggerEvent('mx-serverman:SendEmbed', embed)
            else    
                local embed = {
                    color = "#0094ff", -- blue
                    title = 'Not player found.',
                }
                TriggerEvent('mx-serverman:SendEmbed', embed)
            end
        end)
    end
end)
exports('spawnCar', function (id, name)
    if GetPlayerName(id) then
        if Config.useQB then
            id = tonumber(id)
            TriggerClientEvent('QBCore:Command:SpawnVehicle', id, name)
        else
            TriggerClientEvent('esx:spawnVehicle', id, name)
        end
        local embed = {
            color = "#0094ff", -- blue
            title = ' `'..name..'` given to `'..GetPlayerName(id)..'`',
        }
        TriggerEvent('mx-serverman:SendEmbed', embed)
    else    
        local embed = {
            description = "Player is not ingame",
            color = "#ff0000",
            author = 'WARNING'
        }
        TriggerEvent('mx-serverman:SendEmbed', embed)
    end
end)
exports('spawnAllPlayersCar', function (name)
    if Config.useQB then
        local QBCore = exports['qb-core']:GetCoreObject()
        local players = QBCore.Functions.GetPlayers()
        if #players > 0 then
            for i = 1, #players do
                TriggerClientEvent('QBCore:Command:SpawnVehicle', players[i], name)
            end
            local embed = {
                color = "#0094ff", -- blue
                title = ' Total Gived Vehicle: `'..#players..'`',
            }
            TriggerEvent('mx-serverman:SendEmbed', embed)
        else    
            local embed = {
                description = "Player No player found on the server.",
                color = "#ff0000",
                author = 'WARNING'
            }
            TriggerEvent('mx-serverman:SendEmbed', embed)
        end
    else
        TriggerEvent('esx:getSharedObject', function(ESX)
            local players = ESX.GetPlayers()
            if #players > 0 then
                for i = 1, #players do
                    TriggerClientEvent('esx:spawnVehicle', players[i], name)
                end
                local embed = {
                    color = "#0094ff", -- blue
                    title = ' Total Gived Vehicle: `'..#players..'`',
                }
                TriggerEvent('mx-serverman:SendEmbed', embed)
            else    
                local embed = {
                    description = "Player No player found on the server.",
                    color = "#ff0000",
                    author = 'WARNING'
                }
                TriggerEvent('mx-serverman:SendEmbed', embed)
            end
        end)
    end
    
end)
exports('giveWeapon', function (id, name, ammo)
    ammo = tonumber(ammo)
    if Config.useQB then
        id = tonumber(id)
        local QBCore = exports['qb-core']:GetCoreObject()
        local xPlayer = QBCore.Functions.GetPlayer(id)
        if xPlayer then
            local StringCharset = {}
            local NumberCharset = {}
            for i = 48,  57 do table.insert(NumberCharset, string.char(i)) end
            for i = 65,  90 do table.insert(StringCharset, string.char(i)) end
            for i = 97, 122 do table.insert(StringCharset, string.char(i)) end
            local function RandomStr(length)
                if length > 0 then
                    return RandomStr(length-1) .. StringCharset[math.random(1, #StringCharset)]
                else
                    return ''
                end
            end
            local function RandomInt(length)
                if length > 0 then
                    return RandomInt(length-1) .. NumberCharset[math.random(1, #NumberCharset)]
                else
                    return ''
                end
            end
            -- QBCORE
            local info = {
                serie = tostring(RandomInt(2) .. RandomStr(3) .. RandomInt(1) .. RandomStr(2) .. RandomInt(3) .. RandomStr(4))
            }
            xPlayer.Functions.AddItem(name, ammo, false, info)
            local embed = {
                color = "#0094ff", -- blue
                title = ' `'..name..'` given to `'..GetPlayerName(id)..'`',
            }
            TriggerEvent('mx-serverman:SendEmbed', embed)
        else    
            local embed = {
                description = "Player is not ingame",
                color = "#ff0000",
                author = 'WARNING'
            }
            TriggerEvent('mx-serverman:SendEmbed', embed)
        end  
    else
        TriggerEvent('esx:getSharedObject', function(ESX)
            local xPlayer = ESX.GetPlayerFromId(id)
            if xPlayer then
                xPlayer.addWeapon(name, ammo)
                local embed = {
                    color = "#0094ff", -- blue
                    title = ' `'..name..'` given to `'..GetPlayerName(id)..'`',
                }
                TriggerEvent('mx-serverman:SendEmbed', embed)
            else    
                local embed = {
                    description = "Player is not ingame",
                    color = "#ff0000",
                    author = 'WARNING'
                }
                TriggerEvent('mx-serverman:SendEmbed', embed)
            end  
        end)
    end
end)
function Identifier(player)
    for _,v in ipairs(GetPlayerIdentifiers(player)) do
        if Config.identifier == 'steam' then  
             if string.match(v, 'steam') then
                  return v
             end
        elseif Config.identifier == 'license' then
             if string.match(v, 'license:') then
                  return string.sub(v, 9)
             end
        end
    end
    return ''
end
function GetDiscord(id)
    for _,v in ipairs(GetPlayerIdentifiers(id)) do
        if string.match(v, 'discord:') then
            return string.gsub(v, 'discord:', '')
        end
    end
    return false
end
function GetJobProps(name, grade)
    local fetch = [[SELECT label FROM job_grades WHERE job_name = @name AND grade = @grade;]]
    local fetchData = {
        ['@name'] = name,
        ['@grade'] = grade
    }
    local result = FetchAll(fetch, fetchData)
    return result
end
function FetchAll(query, params)
    if Config.useQB then
        return exports.oxmysql:fetchSync(query, params)
    else
        return MySQL.Sync.fetchAll(query, params)
    end
end
function Execute(query, params)
    if Config.useQB then
        return exports.oxmysql:executeSync(query, params)
    else
        return MySQL.Sync.execute(query, params)
    end
end