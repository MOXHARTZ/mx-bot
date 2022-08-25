const Discord = require('discord.js');
const client = new Discord.Client;
const config = require('./config.json');
let CurrentChannel = false;
let changedMember = [];

client.on('ready', () => {
     console.log('^1 [MOXHA] ^2Bot Is Ready^0')
     exports['mx-servermanbot'].GetConfig(config);
     if (config.discord_whitelist.active) {
          on('playerConnecting', (name, setCallback, deferrals) => {
               memberList = client.guilds.members
               const guild = client.guilds.get(config.discord_whitelist.server_id);
               const src = global.source;
               deferrals.defer();
               const player = exports['mx-servermanbot'].GetDiscordFromId(src)
               deferrals.update('Checking Discord Whitelist Please Wait...')
               setTimeout(() => {
                    const discordId = player[0]
                    if (!discordId) return deferrals.done('Discord was not detected. Login to your Discord.');
                    const existMember = guild.members.get(discordId)
                    if (!existMember) return deferrals.done(`Please Join us discord! ${config.discord_link}`);
                    const existWhitelistRole = existMember.roles.get(config.discord_whitelist.role_id)
                    const checkChangedMember = changedMember.find(member => member === discordId)
                    if (!existWhitelistRole && !checkChangedMember?.exist) return deferrals.done('You do not have the whitelist role.');
                    return deferrals.done();
               }, 1000)
          })
     }
})

client.on('guildMemberUpdate', (oldMember, newMember) => { 
     const existWhitelist = newMember.roles.has(config.discord_whitelist.role_id)
     const existChangedMember = changedMember.find(member => member.id === newMember.user.id)
     if (existChangedMember) return existChangedMember.exist = existWhitelist;
     changedMember.push({
          id: newMember.user.id,
          exist: existWhitelist
     })
})

client.on('message', msg => {
     CurrentChannel = msg.channel;
     const embed = new Discord.MessageEmbed().setFooter('Made By MOXHA')
     if (msg.content.startsWith(config.prefix)) {
          const args = msg.content.substring().split(" ");
          if (msg.member.roles.find((search) => search.id == config.admin_roleid)) {
               if (args[0] == config.prefix + 'ban') {
                    if (args[1] && args[2] && args[3]) {
                         emit('mx-serverman:Ban', msg.member.user, args[1], args, (Number(args[2]) && args[2] || 0))
                         return false;
                    } else {
                         embed
                              .setColor('#ff0000')
                              .addField('id or identifier', '**if player is online use id. Or if player is offline use identifier**', true)
                              .addField('time', '**Second**', true)
                              .addField('reason', '**Write a reason**', true)
                              .setTitle('Example \n!ban `1` `3600` `BYE BYE :)` \n!ban `steam:2131231` `3000` `BYE BYE :)`')
                              .setAuthor('Incorrect Command Usage.')
                         msg.channel.send(embed)
                         return false;
                    }
               } else if (args[0] == config.prefix + 'kick') {
                    if (args[1] && args[2]) {
                         emit('mx-serverman:Kick', msg.member.user, args[1], args)
                         return false;
                    } else {
                         embed
                              .setColor('#ff0000')
                              .setTitle('Usage: !kick `id` `reason`')
                              .setAuthor('Incorrect Command Usage.')
                         msg.channel.send(embed)
                         return false;
                    }
               } else if (args[0] == config.prefix + 'inventory') {
                    if (args[1]) {
                         return exports['mx-servermanbot'].GetInventory(args[1]);
                    } else {
                         embed
                              .setColor('#ff0000')
                              .setTitle('Usage: !inventory `id` or `identifier`')
                              .setAuthor('Incorrect Command Usage.')
                         msg.channel.send(embed)
                         return false;
                    }
               } else if (args[0] == config.prefix + 'start') {
                    if (args[1]) {
                         return exports['mx-servermanbot'].start(args[1]);
                    } else {
                         embed
                              .setColor('#ff0000')
                              .setTitle('Usage: !start `script name`')
                              .setAuthor('Incorrect Command Usage.')
                         msg.channel.send(embed)
                         return false;
                    }
               } else if (args[0] == config.prefix + 'stop') {
                    if (args[1]) {
                         return exports['mx-servermanbot'].stop(args[1]);
                    } else {
                         embed
                              .setColor('#ff0000')
                              .setTitle('Usage: !stop `script name`')
                              .setAuthor('Incorrect Command Usage.')
                         msg.channel.send(embed)
                         return false;
                    }
               } else if (args[0] == config.prefix + 'refresh') {
                    return exports['mx-servermanbot'].refresh(args[1]);
               } else if (args[0] == config.prefix + 'setcoords') {
                    if (args[1] && args[2] && args[3] && args[4] && Number(args[2]) && Number(args[3]) && Number(args[4])) {
                         return exports['mx-servermanbot'].SetCoords(args[1], args[2], args[3], args[4]);
                    } else {
                         embed
                              .setColor('#ff0000')
                              .setTitle('Usage: !setcoords `id` `x` `y` `z` Example !setcoords 1 123 123 462')
                              .setAuthor('Incorrect Command Usage.')
                         msg.channel.send(embed)
                         return false;
                    }
               } else if (args[0] == config.prefix + 'accounts') {
                    if (args[1]) {
                         return exports['mx-servermanbot'].GetMoney(args[1]);
                    } else {
                         embed
                              .setColor('#ff0000')
                              .setTitle('Usage: !accounts `identifier` or `id`')
                              .setAuthor('Incorrect Command Usage.')
                         msg.channel.send(embed)
                         return false;
                    }
               } else if (args[0] == config.prefix + 'addmoney') {
                    if (args[1] && args[2] && args[3]) {
                         if (args[2] == 'money' || args[2] == 'bank' || (args[2] == 'black_money' || args[2] == 'crypto')) {
                              return exports['mx-servermanbot'].AddMoney(args[1], args[2], (Number(args[3]) && args[3] || 0));
                         } else {
                              embed
                                   .setColor('#ff0000')
                                   .addField('id or identifier', '**if player is online use id. Or if player is offline use identifier**', true)
                                   .addField('type', '**bank, money or black_money || crypto**', true)
                                   .addField('amount', '**Write a amount**', true)
                                   .setTitle('Examples \n!addmoney `1` `bank` `3600` \n!addmoney `steam:2131231` `bank` `3600`')
                                   .setAuthor('Incorrect Command Usage.')
                              msg.channel.send(embed)
                              return false;
                         }
                    } else {
                         embed
                              .setColor('#ff0000')
                              .addField('id or identifier', '**if player is online use id. Or if player is offline use identifier**', true)
                              .addField('type', '**bank, money or black_money || crypto**', true)
                              .addField('amount', '**Write a amount**', true)
                              .setTitle('Examples \n!addmoney `1` `bank` `3600` \n!addmoney `steam:2131231` `bank` `3600`')
                              .setAuthor('Incorrect Command Usage.')
                         msg.channel.send(embed)
                         return false;
                    }
               } else if (args[0] == config.prefix + 'giveitem') {
                    if (args[1] && args[2] && args[3]) {
                         if (Number(args[3]) != null) {
                              return exports['mx-servermanbot'].GiveItem(args[1], args[2], Number(args[3]));
                         } else {
                              embed
                                   .setColor('#ff0000')
                                   .setTitle('!giveitem `id or identifier` `item name` `item count` \nExamples \n!giveitem `1` `bread` `3` \n!giveitem `steam:12312321` `bread` `3`')
                                   .setAuthor('Incorrect Command Usage.')
                              msg.channel.send(embed)
                              return false;
                         }
                    } else {
                         embed
                              .setColor('#ff0000')
                              .setTitle('!giveitem `id or identifier` `item name` `item count` \nExamples \n!giveitem `1` `bread` `3` \n!giveitem `steam:12312321` `bread` `3`')
                              .setAuthor('Incorrect Command Usage.')
                         msg.channel.send(embed)
                         return false;
                    }
               } else if (args[0] == config.prefix + 'setjob') {
                    if (args[1] && args[2] && args[3]) {
                         if (Number(args[3]) != null) {
                              return exports['mx-servermanbot'].SetJob(args[1], args[2], Number(args[3]));
                         } else {
                              embed
                                   .setColor('#ff0000')
                                   .setTitle('!setjob `id or identifier` `jobname` `grade` \nExamples \n!setjob `1` `police` `2` \n!setjob `steam:12312321` `police` `2`')
                                   .setAuthor('Incorrect Command Usage.')
                              msg.channel.send(embed)
                              return false;
                         }
                    } else {
                         embed
                              .setColor('#ff0000')
                              .setTitle('!setjob `id or identifier` `jobname` `grade` \nExamples \n!setjob `1` `police` `2` \n!setjob `steam:12312321` `police` `2`')
                              .setAuthor('Incorrect Command Usage.')
                         msg.channel.send(embed)
                         return false;
                    }
               } else if (args[0] == config.prefix + 'removemoney') {
                    if (args[1] && args[2] && args[3]) {
                         if (args[2] == 'money' || args[2] == 'bank' || args[2] == 'black_money') {
                              return exports['mx-servermanbot'].RemoveMoney(args[1], args[2], (Number(args[3]) && args[3] || 0));
                         } else {
                              embed
                                   .setColor('#ff0000')
                                   .addField('id or identifier', '**if player is online use id. Or if player is offline use identifier**', true)
                                   .addField('type', '**bank, money or black_money**', true)
                                   .addField('amount', '**Write a amount**', true)
                                   .setTitle('Examples \n!removemoney `1` `bank` `3600` \n!removemoney `steam:2131231` `bank` `3600`')
                                   .setAuthor('Incorrect Command Usage.')
                              msg.channel.send(embed)
                              return false;
                         }
                    } else {
                         embed
                              .setColor('#ff0000')
                              .addField('id or identifier', '**if player is online use id. Or if player is offline use identifier**', true)
                              .addField('type', '**bank, money or black_money**', true)
                              .addField('amount', '**Write a amount**', true)
                              .setTitle('Examples \n!removemoney `1` `bank` `3600` \n!removemoney `steam:2131231` `bank` `3600`')
                              .setAuthor('Incorrect Command Usage.')
                         msg.channel.send(embed)
                         return false;
                    }
               } else if (args[0] == config.prefix + 'checkban') {
                    if (args[1]) {
                         return exports['mx-servermanbot'].GetBannedPlayer(args[1])
                    } else {
                         embed
                              .setColor('#ff0000')
                              .setTitle('Usage: !checkban `identifier` or `id`')
                              .setAuthor('Incorrect Command Usage.')
                         msg.channel.send(embed)
                         return false;
                    }
               } else if (args[0] == config.prefix + 'playerinfo') {
                    if (args[1]) {
                         return exports['mx-servermanbot'].GetGeneralInformations(args[1]);
                    } else {
                         embed
                              .setColor('#ff0000')
                              .setTitle('Usage: !playerinfo `identifier` or `id`')
                              .setAuthor('Incorrect Command Usage.')
                         msg.channel.send(embed)
                         return false;
                    }
               } else if (args[0] == config.prefix + 'wipe') {
                    if (args[1]) {
                         return exports['mx-servermanbot'].Wipe(args[1]);
                    } else {
                         embed
                              .setColor('#ff0000')
                              .setTitle('Example usage: !wipe `identifier` or `id`')
                              .setAuthor('Incorrect Command Usage.')
                         msg.channel.send(embed)
                         return false;
                    }
               } else if (args[0] == config.prefix + 'unban') {
                    if (args[1]) {
                         emit('mx-serverman:Unban', args[1])
                         return false;
                    } else {
                         embed
                              .setColor('#ff0000')
                              .setTitle('Example usage: !unban `id`')
                              .setAuthor('Incorrect Command Usage.')
                         msg.channel.send(embed)
                         return false;
                    }
               } else if (args[0] == config.prefix + 'reviveall') {
                    return exports['mx-servermanbot'].ReviveAll();
               } else if (args[0] == config.prefix + 'givewl') {
                    const member = msg.mentions.members.first();
                    if (!member) {
                         embed
                         .setColor('#ff0000')
                         .setTitle('Example usage: !givewl `@MOXHA`')
                         .setAuthor('Incorrect Command Usage.')
                         msg.channel.send(embed)
                         return;
                    }
                    const existRole = member.roles.get(config.discord_whitelist.role_id)
                    if (existRole) {
                         embed
                         .setColor('#ff0000')
                         .setTitle('This person already has a whitelist.')
                         .setAuthor('Error.')
                         msg.channel.send(embed)
                         return;
                    }
                    member.roles.add(config.discord_whitelist.role_id)
                    embed
                         .setColor('#0094ff')
                         .setTitle(`Added whitelist to : ${member}`)
                         .setAuthor('Gived whitelist.')
                         msg.channel.send(embed)
                         return;
               } else if (args[0] == config.prefix + 'revive') {
                    if (args[1]) {
                         return exports['mx-servermanbot'].Revive(args[1]);
                    } else {
                         embed
                              .setColor('#ff0000')
                              .setTitle('Example usage: !revive `id`')
                              .setAuthor('Incorrect Command Usage.')
                         msg.channel.send(embed)
                         return false;
                    }
               } else if (args[0] == config.prefix + 'help') {
                    embed.setColor('0094ff')
                         .addField('prefix', '**' + config.prefix + '**', true)
                         .addField('inventory', '**Show Player Inventory**', true)
                         .addField('accounts', '**Show Player Accounts. Money, bank and Black Money**', true)
                         .addField('playerinfo', '**Show Player Identifier, Firstname, Lastname, DateOfBirth, Job and Sex**', true)
                         .addField('ban', '**Ban Player**', true)
                         .addField('kick', '**Kick Player**', true)
                         .addField('wipe', '**Wipe Player**', true)
                         .addField('bannedplayers', '**Show Banned Players**', true)
                         .addField('checkban', '**Check Ban For Player**', true)
                         .addField('addmoney', '**Add Money**', true)
                         .addField('removemoney', '**Remove Money**', true)
                         .addField('players', '**Get Online Players**', true)
                         .addField('setjob', '**Set Job**', true)
                         .addField('revive', '**Revive Player**', true)
                         .addField('reviveall', '**Revive All Players**', true)
                         .addField('unban', '**Unban Player**', true)
                         .addField('giveitem', '**Add Item**', true)
                         .addField('givewl', '**Give whitelist to player**', true)
                         .addField('setcoords', '**Set Player Coords / Teleport**', true)
                         .addField('start', '**Start Script**', true)
                         .addField('stop', '**Stop Script**', true)
                         .addField('refresh', '**Refresh Scripts**', true)
                         .addField('car', '**Give Car**', true)
                         .addField('carAll', '**Give a vehicle to all players**', true)
                         .addField('giveweapon', '**Give Weapon**', true)
                    msg.channel.send(embed);
                    return false;
               } else if (args[0] == config.prefix + 'bannedplayers') {
                    return exports['mx-servermanbot'].GetBannedPlayers();
               } else if (args[0] == config.prefix + 'players') {
                    return exports['mx-servermanbot'].GetPlayers();
               } else if (args[0] == config.prefix + 'car') {
                    if (args[1] && args[2]) {
                         return exports['mx-servermanbot'].spawnCar(args[1], args[2]);
                    } else {
                         embed
                              .setColor('#ff0000')
                              .setTitle('Example usage: !car `id` `name`')
                              .setAuthor('Incorrect Command Usage.')
                         msg.channel.send(embed)
                         return false;
                    }
               } else if (args[0] == config.prefix + 'carAll') {
                    if (args[1]) {
                         return exports['mx-servermanbot'].spawnAllPlayersCar(args[1]);
                    } else {
                         embed
                              .setColor('#ff0000')
                              .setTitle('Example usage: !car `name`')
                              .setAuthor('Incorrect Command Usage.')
                         msg.channel.send(embed)
                         return false;
                    }
               } else if (args[0] == config.prefix + 'giveweapon') {
                    if (args[1] && args[2] && args[3]) {
                         return exports['mx-servermanbot'].giveWeapon(args[1], args[2], args[3]);
                    } else {
                         embed
                              .setColor('#ff0000')
                              .setTitle('Example usage: !giveweapon `id` `name` `ammo || count`')
                              .setAuthor('Incorrect Command Usage.')
                         msg.channel.send(embed)
                         return false;
                    }
               }
          } else {
               embed
                    .setColor('#ff0000')
                    .setDescription('You are not authorized')
                    .setAuthor('WARNING')
               msg.channel.send(embed)
               return false;
          }
     }
})

RegisterNetEvent('mx-serverman:SendEmbed')
on('mx-serverman:SendEmbed', embed => CurrentChannel?.send(SendEmbed(embed)));

SendEmbed = (embed) => {
     const CreateEmbed = new Discord.MessageEmbed().setFooter('Made By MOXHA')
     embed.description && CreateEmbed.setDescription(embed.description)
     embed.author && CreateEmbed.setAuthor(embed.author)
     embed.color && CreateEmbed.setColor(embed.color)
     embed.title && CreateEmbed.setTitle(embed.title)
     if (embed.fields) {
          for (x in embed.fields) CreateEmbed.addField(embed.fields[x].name, embed.fields[x].value, embed.fields[x].inline || false);
     }
     return CreateEmbed
}

(() => {
     if (config.token === '') return console.log('^1Please set the token !^0')
     client.login(config.token)
})()