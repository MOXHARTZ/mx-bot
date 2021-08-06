Config = nil

RegisterNetEvent('mx-serverman:GetConfig')
AddEventHandler('mx-serverman:GetConfig', function (config)
    Config = config
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
            return v
        end
    end
    return false
end

RegisterNetEvent('mx-serverman:GetBannedPlayers')
AddEventHandler('mx-serverman:GetBannedPlayers', function ()
    local fetch = [[SELECT * FROM bannedplayers]]
    local result = MySQL.Sync.fetchAll(fetch)
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

RegisterNetEvent('mx-serverman:GetBannedPlayer')
AddEventHandler('mx-serverman:GetBannedPlayer', function (id)
    if GetPlayerName(id) then
        local fetch = [[SELECT * FROM bannedplayers WHERE identifier = @id;]]
        local fetchData = {['@id'] = Identifier(id)}
        local result = MySQL.Sync.fetchAll(fetch, fetchData)
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
        local result = MySQL.Sync.fetchAll(fetch, fetchData)
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

RegisterNetEvent('mx-serverman:Wipe')
AddEventHandler('mx-serverman:Wipe', function (id)
    if GetPlayerName(id) then
        local fetch = [[SELECT identifier FROM users WHERE identifier = @id]]
        local fetchData = {['@id'] = Identifier(id)}
        if Config['mx-multicharacter'] then
            fetch = [[SELECT identifier FROM users WHERE citizenid = @id;]]
            fetchData = {['@id'] = exports['mx-multicharacter']:GetCitizenId(id)}
        end
        local result = MySQL.Sync.fetchAll(fetch, fetchData)
        if result and result[1] then
            for _, v in pairs(Config.wipe_tables) do
                if not Config['mx-multicharacter'] then
                    MySQL.Sync.execute("DELETE FROM `"..v.table.."` WHERE `"..v.owner.."` = '"..Identifier(id).."'")
                else    
                    MySQL.Sync.execute("DELETE FROM `"..v.table.."` WHERE `"..v.owner.."` = '"..exports['mx-multicharacter']:GetCitizenId(id).."'")
                end 
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
        if Config['mx-multicharacter'] then
            fetch = [[SELECT citizenid FROM users WHERE citizenid = @id;]]
        end
        local fetchData = {['@id'] = id}
        
        local result = MySQL.Sync.fetchAll(fetch, fetchData)
        if result and result[1] then
            for _, v in ipairs(Config.wipe_tables) do
                if not Config['mx-multicharacter'] then
                    MySQL.Sync.execute("DELETE FROM `"..v.table.."` WHERE `"..v.owner.."` = '"..id.."'")
                else    
                    MySQL.Sync.execute("DELETE FROM `"..v.table.."` WHERE `"..v.owner.."` = '"..id.."'")
                end 
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
end)

RegisterNetEvent('mx-serverman:GetInventory')
AddEventHandler('mx-serverman:GetInventory', function (id)
    if GetPlayerName(id) then
        local fetch = [[SELECT inventory FROM users WHERE identifier = @id]]
        local fetchData = {['@id'] = Identifier(id)}
        if Config['mx-multicharacter'] then
            fetch = [[SELECT inventory FROM users WHERE citizenid = @id]]
            fetchData = {['@id'] = exports['mx-multicharacter']:GetCitizenId(id)}
        end
        local result = MySQL.Sync.fetchAll(fetch, fetchData)
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
                embed.description = 'Doesn\t have an item'
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
    else
        local fetch = [[SELECT inventory FROM users WHERE identifier = @id;]]
        local fetchData = {['@id'] = id}
        if Config['mx-multicharacter'] then
            fetch = [[SELECT inventory FROM users WHERE citizenid = @id]]
        end
        local result = MySQL.Sync.fetchAll(fetch, fetchData)
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
                embed.description = 'Doesn\t have an item'
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
end)

RegisterNetEvent('mx-serverman:GetMoney')
AddEventHandler('mx-serverman:GetMoney', function (id)
    if GetPlayerName(id) then
        TriggerEvent('esx:getSharedObject', function(ESX)
            local xPlayer = ESX.GetPlayerFromId(id)
            local embed = {
                fields = {
                    {name = 'Bank', value = xPlayer.getAccount('bank').money},
                    {name = 'Money', value = xPlayer.getAccount('money').money},
                    {name = 'Black Money',  value =  xPlayer.getAccount('black_money').money}
                },
                color = "#0094ff", -- blue
                author = 'SUCCESS'
            }
            TriggerEvent('mx-serverman:SendEmbed', embed)
        end)
    else
        if Config['oldesx'] then
            local embed = {
                color = "#0094ff", -- blue
                title = 'SUCCESS',
                fields = {}
            }
            local fetch = [[SELECT name, money FROM user_accounts WHERE identifier = @id]]
            local fetchData = {['@id'] = id}
            local result = MySQL.Sync.fetchAll(fetch, fetchData)
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
            if Config['mx-multicharacter'] then
                fetch = [[SELECT accounts FROM users WHERE citizenid = @id;]]
            end
            local result = MySQL.Sync.fetchAll(fetch, fetchData)
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
end)

function GetJobProps(name, grade)
    local fetch = [[SELECT label FROM job_grades WHERE job_name = @name AND grade = @grade;]]
    local fetchData = {
        ['@name'] = name,
        ['@grade'] = grade
    }
    local result = MySQL.Sync.fetchAll(fetch, fetchData)
    return result
end

RegisterNetEvent('mx-serverman:GetGeneralInformations')
AddEventHandler('mx-serverman:GetGeneralInformations', function (id)
    if GetPlayerName(id) then
        local fetch = [[SELECT * FROM users WHERE identifier = @id;]]
        local fetchData = {['@id'] = Identifier(id)}
        if Config['mx-multicharacter'] then
            fetch = [[SELECT firstname, lastname, dateofbirth, sex, job FROM users WHERE citizenid = @id;]]
            fetchData = {['@id'] = exports['mx-multicharacter']:GetCitizenId(id)}
        end
        local result = MySQL.Sync.fetchAll(fetch, fetchData)
        local ident = Config['mx-multicharacter'] and exports['mx-multicharacter']:GetCitizenId(id) or Identifier(id)
        if result and result[1] then
            local job = GetJobProps(result[1].job, result[1].job_grade)
            local discord = GetDiscord(id) and string.gsub(GetDiscord(id), 'discord:', '') or 'Not Finded'
            local embed = {
                fields = {
                    {name = 'Identifier', value = ident or '...', inline = true},
                    {name = 'Firstname', value = result[1].firstname or '...', inline = true},
                    {name = 'Lastname', value = result[1].lastname or '...', inline = true},
                    {name = 'DateOfBirth', value = result[1].dateofbirth or '...', inline = true},
                    {name = 'Job', value = result[1].job or '...', inline = true},
                    {name = 'Grade', value = job and job[1] and job[1].label ..' ['..result[1].job_grade..']' or '...', inline = true},
                    {name = 'Group', value = result[1].group or '...', inline = true},
                    {name = 'Sex', value = result[1].sex == 'm' and 'male' or result[1].sex == 'f' and 'female' or result[1].sex or '...', inline = true},
                    {name = 'Discord', value = '<@'..discord..'>', inline = true}
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
        local fetch = [[SELECT * FROM users WHERE identifier = @id]]
        local fetchData = {['@id'] = id}
        if Config['mx-multicharacter'] then
            fetch = [[SELECT * FROM users WHERE citizenid = @id;]]
        end
        local result = MySQL.Sync.fetchAll(fetch, fetchData)
        if result and result[1] then
            local job = GetJobProps(result[1].job, result[1].job_grade)
            local embed = {
                fields = {
                    {name = 'Identifier', value = id, inline = true},
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

RegisterNetEvent('mx-serverman:AddPlayerMoney')
AddEventHandler('mx-serverman:AddPlayerMoney', function (id, type, amount)
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
        if Config['oldesx'] then
            local fetch = [[SELECT name, money FROM user_accounts WHERE identifier = @id]]
            local fetchData = {['@id'] = id}
            local result = MySQL.Sync.fetchAll(fetch, fetchData)
            if result and result[1] then
                for i = 1, #result do
                    if type == result[i].name then
                        local embed = {
                            color = "#0094ff", -- blue
                            title = '`'..id..'` gived `'..amount..'` \nOld Balance: `'..result[i].money..'` \nNew Balance: `'..(math.floor(result[i].money + amount))..'` \nType: `'..type..'`',
                        }
                        TriggerEvent('mx-serverman:SendEmbed', embed)
                        MySQL.Sync.execute('UPDATE user_accounts SET money = @money WHERE identifier = @id AND name = @name', {
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
            if Config['mx-multicharacter'] then
                fetch = [[SELECT accounts FROM users WHERE citizenid = @id;]]
            end
            local result = MySQL.Sync.fetchAll(fetch, fetchData)
            if result and result[1] then
                if result[1].accounts and json.decode(result[1].accounts) then
                    local accounts = json.decode(result[1].accounts)
                    local oldMoney = accounts[type]
                    accounts[type] = math.floor(accounts[type] + tonumber(amount))
                    if not Config['mx-multicharacter'] then
                        MySQL.Sync.execute('UPDATE users SET accounts = @accounts WHERE identifier = @id', {['@accounts'] = json.encode(accounts), ['@id'] = id})
                    else
                        MySQL.Sync.execute('UPDATE users SET accounts = @accounts WHERE citizenid = @id', {['@accounts'] = json.encode(accounts), ['@id'] = id})
                    end
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
end)

RegisterNetEvent('mx-serverman:SetJob')
AddEventHandler('mx-serverman:SetJob', function (id, job, grade)
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
                if Config['mx-multicharacter'] then
                    fetch = [[SELECT job, job_grade FROM users WHERE citizenid = @id;]]
                end
                local result = MySQL.Sync.fetchAll(fetch, fetchData)
                if result and result[1] then
                    if not Config['mx-multicharacter'] then
                        MySQL.Sync.execute('UPDATE users SET job = @job, job_grade = @grade WHERE identifier = @id', {
                            ['@job'] = job,
                            ['@grade'] = grade,
                            ['@id'] = id
                        })
                    else    
                        MySQL.Sync.execute('UPDATE users SET job = @job, job_grade = @grade WHERE citizenid = @id', {
                            ['@job'] = job,
                            ['@grade'] = grade,
                            ['@id'] = id
                        })
                    end
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
end)

RegisterNetEvent('mx-serverman:RemovePlayerMoney')
AddEventHandler('mx-serverman:RemovePlayerMoney', function (id, type, amount)
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
        if Config['oldesx'] then
            local fetch = [[SELECT name, money FROM user_accounts WHERE identifier = @id]]
            local fetchData = {['@id'] = id}
            local result = MySQL.Sync.fetchAll(fetch, fetchData)
            if result and result[1] then
                for i = 1, #result do
                    if type == result[i].name then
                        print(amount, result[i].money, result[i].money + amount, type)
                        local embed = {
                            color = "#0094ff", -- blue
                            title = '`'..id..'` taked `'..amount..'` \nOld Balance: `'..result[i].money..'` \nNew Balance: `'..(math.floor(result[i].money - amount))..'` \nType: `'..type..'`',
                        }
                        TriggerEvent('mx-serverman:SendEmbed', embed)
                        MySQL.Sync.execute('UPDATE user_accounts SET money = @money WHERE identifier = @id AND name = @name', {
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
            if Config['mx-multicharacter'] then
                fetch = [[SELECT accounts FROM users WHERE citizenid = @id;]]
            end
            local result = MySQL.Sync.fetchAll(fetch, fetchData)
            if result and result[1] then
                if result[1].accounts and json.decode(result[1].accounts) then
                    local accounts = json.decode(result[1].accounts)
                    local oldMoney = accounts[type]
                    accounts[type] = math.floor(accounts[type] - tonumber(amount))
                    if not Config['mx-multicharacter'] then
                        MySQL.Sync.execute('UPDATE users SET accounts = @accounts WHERE identifier = @id', {['@accounts'] = json.encode(accounts), ['@id'] = id})
                    else
                        MySQL.Sync.execute('UPDATE users SET accounts = @accounts WHERE citizenid = @id', {['@accounts'] = json.encode(accounts), ['@id'] = id})
                    end
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
end)

RegisterNetEvent('mx-serverman:GiveItem')
AddEventHandler('mx-serverman:GiveItem', function (id, name, count)
    count = tonumber(count)
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
        if Config['mx-multicharacter'] then
            fetch = [[SELECT inventory FROM users WHERE citizenid = @id]]
        end
        local result = MySQL.Sync.fetchAll(fetch, fetchData)
        if result and result[1] then
            if result[1].inventory then
                local inventory = json.decode(result[1].inventory)
                inventory[name] = inventory[name] >= 0 and count + inventory[name]
                if not Config['mx-multicharacter'] then
                    MySQL.Sync.execute('UPDATE users SET inventory = @inv WHERE identifier = @id',  {
                        ['@id'] = id,
                        ['@inv'] = json.encode(inventory)
                    })
                else
                    MySQL.Sync.execute('UPDATE users SET inventory = @inv WHERE citizenid = @id', {
                        ['@id'] = id,
                        ['@inv'] = json.encode(inventory)
                    })
                end
                local embed = {
                    color = "#0094ff", -- blue
                    title = '`'..id..'` gived item. \nItem name:`'..name..'` \nCount: `'..count..'`',
                }
                TriggerEvent('mx-serverman:SendEmbed', embed)
            else
                if not Config['mx-multicharacter'] then
                    MySQL.Sync.execute('UPDATE users SET inventory = @inv WHERE identifier = @id',  {
                        ['@id'] = id,
                        ['@inv'] = json.encode({name = count})
                    })
                else
                    MySQL.Sync.execute('UPDATE users SET inventory = @inv WHERE citizenid = @id', {
                        ['@id'] = id,
                        ['@inv'] = json.encode({name = count})
                    })
                end
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
end)

RegisterNetEvent('mx-serverman:GetPlayers')
AddEventHandler('mx-serverman:GetPlayers', function ()
    local embed = {
        color = "#0094ff", -- blue
        author = 'PLAYERS',
    }
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
                local discord = GetDiscord(players[i]) and string.gsub(GetDiscord(players[i]), 'discord:', '') or 'Not Finded'
                embed.fields[1].value = embed.fields[1].value..GetPlayerName(players[i])..' ['..players[i]..']'
                embed.fields[2].value = embed.fields[2].value..'<@'..discord..'>'
                embed.fields[3].value = Config['mx-multicharacter'] and embed.fields[3].value..xPlayer.citizenid or embed.fields[3].value..xPlayer.identifier
            end
        end
        TriggerEvent('mx-serverman:SendEmbed', embed)
    end)
end)

RegisterNetEvent('mx-serverman:Revive')
AddEventHandler('mx-serverman:Revive', function (id)
    if GetPlayerName(id) then
        TriggerClientEvent('esx_ambulancejob:revive', id)
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

RegisterNetEvent('mx-serverman:ReviveAll')
AddEventHandler('mx-serverman:ReviveAll', function ()
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
end)