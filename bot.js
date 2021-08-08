const Discord = require('discord.js');
var client = new Discord.Client;
global.config = require('./config.json');
const Library = require("./utils/library");
var CurrentChannel = false;
var RefreshBot = false;

RefreshWhitelist = () => {
     print('^1 [MOXHA] ^4Refreshing BOT^0')
     CurrentChannel && CurrentChannel.send(SendEmbed({
          description: 'Refreshing Bot',
          color : "#47ff00",
          author: 'Refresh Whitelist'
     }))
     client.destroy(config.token);
     setTimeout(() => {}, 0);
     client = new Discord.Client;
     RefreshBot = true;
     StartBot();
} 

StartBot = () => {
     client.on('ready', () => {
          !RefreshBot && console.log('^1 [MOXHA] ^2Bot Is Ready^0')
          if (RefreshBot) {
               print('^1 [MOXHA] ^6Refreshed Bot^0')
               CurrentChannel && CurrentChannel.send(SendEmbed({
                    description: 'Refreshed Bot',
                    color : "#0094ff",
                    author: 'SUCCESS'
               }))
               RefreshBot = false;               
          }
          emit('mx-serverman:GetConfig', config)
          if (config.discord_whitelist.active) {
               !RefreshBot && console.log('^1 [MOXHA] ^3Discord Whitelist Active ^0')
               on('playerConnecting', (name, setCallback, deferrals) => {
                    var src = global.source;
                    deferrals.defer();
                    var player = GetDiscordFromId(src);
                    deferrals.update('Checking Discord Whitelist Please Wait...')
                    
                    setTimeout(() => {
                         if (player) {
                              const guild = client.guilds.get(config.discord_whitelist.server_id)
                              guild.members.fetch(player)
                              .then(result => {
                                   if (result.roles.find(search => search.id == config.discord_whitelist.role_id)) {
                                        deferrals.done();
                                   }else {
                                        return deferrals.done('You do not have the whitelist role.');
                                   }
                              })
                         }else {
                              return deferrals.done('Discord was not detected. Login to your Discord.');
                         }
                    }, 1000)
               })
          }
     })

     client.on('message', msg => {
          CurrentChannel = msg.channel;
          var embed = new Discord.MessageEmbed()
          .setFooter('Made By MOXHA')
          if (msg.content.startsWith(config.prefix)) {
               var args = msg.content.substring().split(" ");
               if (msg.member.roles.find((search) => search.id == config.admin_roleid)) {
                    if (args[0] == config.prefix + 'ban') {
                         if (args[1] && args[2] && args[3]) {               
                              Library.Ban(msg.member.user, args[1], args, (Number(args[2]) && args[2] || 0))
                              return false;
                         }else {
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
                    }else if (args[0] == config.prefix + 'kick') {
                         if (args[1] && args[2]) {
                              Library.Kick(msg.member.user, args[1], args)
                              return false;
                         }else {
                              embed
                              .setColor('#ff0000')
                              .setTitle('Usage: !kick `id` `reason`')
                              .setAuthor('Incorrect Command Usage.')
                              msg.channel.send(embed)
                              return false;
                         }
                    }else if (args[0] == config.prefix + 'inventory') {
                         if (args[1]) {
                              Library.GetInventory(args[1])
                              return false;
                         }else {
                              embed
                              .setColor('#ff0000')
                              .setTitle('Usage: !inventory `id` or `identifier`')
                              .setAuthor('Incorrect Command Usage.')
                              msg.channel.send(embed)
                              return false;
                         }
                    }else if (args[0] == config.prefix + 'setcoords') {
                         if (args[1] && args[2] && args[3] && args[4] && Number(args[2]) && Number(args[3]) && Number(args[4])) {
                              Library.SetCoords(args[1], args[2], args[3], args[4])
                         }else {
                              embed
                              .setColor('#ff0000')
                              .setTitle('Usage: !setcoords `id` `x` `y` `z` Example !setcoords 1 123 123 462')
                              .setAuthor('Incorrect Command Usage.')
                              msg.channel.send(embed)
                              return false;
                         }
                    }else if (args[0] == config.prefix + 'accounts') {
                         if (args[1]) {
                              Library.  GetMoney(args[1])
                              return false;
                         }else {
                              embed
                              .setColor('#ff0000')
                              .setTitle('Usage: !accounts `identifier` or `id`')
                              .setAuthor('Incorrect Command Usage.')
                              msg.channel.send(embed)
                              return false;
                         }
                    }else if (args[0] == config.prefix + 'addmoney') {
                              if (args[1] && args[2] && args[3]) { 
                                   if (args[2] == 'money' || args[2] == 'bank' || args[2] == 'black_money') {
                                        Library.AddMoney(args[1], args[2], (Number(args[3]) && args[3] || 0))
                                        return false;
                                   }else {
                                        embed
                                        .setColor('#ff0000')
                                        .addField('id or identifier', '**if player is online use id. Or if player is offline use identifier**', true)
                                        .addField('type', '**bank, money or black_money**', true)
                                        .addField('amount', '**Write a amount**', true)
                                        .setTitle('Examples \n!addmoney `1` `bank` `3600` \n!addmoney `steam:2131231` `bank` `3600`')
                                        .setAuthor('Incorrect Command Usage.')
                                        msg.channel.send(embed)
                                        return false;
                                   }
                              }else {
                                   embed
                                   .setColor('#ff0000')
                                   .addField('id or identifier', '**if player is online use id. Or if player is offline use identifier**', true)
                                   .addField('type', '**bank, money or black_money**', true)
                                   .addField('amount', '**Write a amount**', true)
                                   .setTitle('Examples \n!addmoney `1` `bank` `3600` \n!addmoney `steam:2131231` `bank` `3600`')
                                   .setAuthor('Incorrect Command Usage.')
                                   msg.channel.send(embed)
                                   return false;
                              }
                         }else if (args[0] == config.prefix + 'giveitem') {
                              if (args[1] && args[2] && args[3]) { 
                                   if (Number(args[3]) != null) {
                                        Library.GiveItem(args[1], args[2], Number(args[3]))
                                        return false;
                                   }else {
                                        embed
                                        .setColor('#ff0000')
                                        .setTitle('!giveitem `id or identifier` `item name` `item count` \nExamples \n!giveitem `1` `bread` `3` \n!giveitem `steam:12312321` `bread` `3`')
                                        .setAuthor('Incorrect Command Usage.')
                                        msg.channel.send(embed)
                                        return false; 
                                   }
                              }else {
                                   embed
                                   .setColor('#ff0000')
                                   .setTitle('!giveitem `id or identifier` `item name` `item count` \nExamples \n!giveitem `1` `bread` `3` \n!giveitem `steam:12312321` `bread` `3`')
                                   .setAuthor('Incorrect Command Usage.')
                                   msg.channel.send(embed)
                                   return false;
                              }
                         }else if (args[0] == config.prefix + 'setjob') {
                              if (args[1] && args[2] && args[3]) { 
                                   if (Number(args[3]) != null) {
                                        Library.SetJob(args[1], args[2], Number(args[3]))
                                        return false;
                                   }else {
                                        embed
                                        .setColor('#ff0000')
                                        .setTitle('!setjob `id or identifier` `jobname` `grade` \nExamples \n!setjob `1` `police` `2` \n!setjob `steam:12312321` `police` `2`')
                                        .setAuthor('Incorrect Command Usage.')
                                        msg.channel.send(embed)
                                        return false; 
                                   }
                              }else {
                                   embed
                                   .setColor('#ff0000')
                                   .setTitle('!setjob `id or identifier` `jobname` `grade` \nExamples \n!setjob `1` `police` `2` \n!setjob `steam:12312321` `police` `2`')
                                   .setAuthor('Incorrect Command Usage.')
                                   msg.channel.send(embed)
                                   return false;
                              }
                         }else if (args[0] == config.prefix + 'removemoney') {
                              if (args[1] && args[2] && args[3]) { 
                                   if (args[2] == 'money' || args[2] == 'bank' || args[2] == 'black_money') {
                                        Library.RemoveMoney(args[1], args[2], (Number(args[3]) && args[3] || 0))
                                        return false;
                                   }else {
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
                              }else {
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
                    }else if (args[0] == config.prefix + 'checkban') {
                         if (args[1]) {
                              Library.GetBannedPlayer(args[1]);
                              return false;
                         }else {
                              embed
                              .setColor('#ff0000')
                              .setTitle('Usage: !checkban `identifier` or `id`')
                              .setAuthor('Incorrect Command Usage.')
                              msg.channel.send(embed)
                              return false;
                         }
                    }else if (args[0] == config.prefix + 'playerinfo') {
                         if (args[1]) {
                              Library.GetGeneralInformations(args[1])
                              return false;
                         }else {
                              embed
                              .setColor('#ff0000')
                              .setTitle('Usage: !playerinfo `identifier` or `id`')
                              .setAuthor('Incorrect Command Usage.')
                              msg.channel.send(embed)
                              return false;
                         }
                    }else if (args[0] == config.prefix + 'wipe') {
                         if (args[1]) {
                              Library.Wipe(args[1])
                              return false;
                         }else {
                              embed
                              .setColor('#ff0000')
                              .setTitle('Example usage: !wipe `identifier` or `id`')
                              .setAuthor('Incorrect Command Usage.')
                              msg.channel.send(embed)
                              return false;
                         }
                    }else if (args[0] == config.prefix + 'unban') {
                         if (args[1]) {
                              Library.Unban(args[1])
                              return false;
                         }else {
                              embed
                              .setColor('#ff0000')
                              .setTitle('Example usage: !unban `id`')
                              .setAuthor('Incorrect Command Usage.')
                              msg.channel.send(embed)
                              return false;
                         }
                    }else if (args[0] == config.prefix + 'reviveall') {
                         Library.ReviveAll()
                         return false;
                    }else if (args[0] == config.prefix + 'refreshwhitelist') {
                         RefreshWhitelist()
                         return false;
                    }else if (args[0] == config.prefix + 'revive') {
                         if (args[1]) {
                              Library.Revive(args[1])
                              return false;
                         }else {
                              embed
                              .setColor('#ff0000')
                              .setTitle('Example usage: !revive `id`')
                              .setAuthor('Incorrect Command Usage.')
                              msg.channel.send(embed)
                              return false;
                         }
                    }else if (args[0] == config.prefix + 'help') {
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
                         .addField('refreshwhitelist', '**Refresh Whitelist**', true)
                         .addField('setcoords', '**Set Player Coords / Teleport**', true)
                         msg.channel.send(embed);
                         return false;
                    }else if (args[0] == config.prefix + 'bannedplayers') {
                         Library.GetBannedPlayers();
                         return false;
                    }else if (args[0] == config.prefix + 'players') {
                         Library.GetOnlinePlayers();
                         return false;
                    }
               }else {
                    embed
                    .setColor('#ff0000')
                    .setDescription('You are not authorized')
                    .setAuthor('WARNING')
                    msg.channel.send(embed)
                    return false;
               }
          }
     })
     client.login(config.token)
}

GetDiscordFromId = (id) => {
     if (!GetPlayerName(id)) {return false};
     for (var i = 0; i <= GetNumPlayerIdentifiers(id); i++) {
          if (GetPlayerIdentifier(id, i).indexOf('discord:') !== -1) {
               return GetPlayerIdentifier(id, i).replace('discord:', '');
          } 
     }
     return false
} 

RegisterNetEvent('mx-serverman:SendEmbed')
on('mx-serverman:SendEmbed', embed => {
     (CurrentChannel && CurrentChannel.send(SendEmbed(embed)))
});

SendEmbed = (embed) => {
     var CreateEmbed = new Discord.MessageEmbed()
     .setFooter('Made By MOXHA')
     embed.description && CreateEmbed.setDescription(embed.description)
     embed.author && CreateEmbed.setAuthor(embed.author)
     embed.color && CreateEmbed.setColor(embed.color)
     embed.title && CreateEmbed.setTitle(embed.title)
     if (embed.fields) {
          for (x in embed.fields) {
               CreateEmbed.addField(embed.fields[x].name, embed.fields[x].value, embed.fields[x].inline || false)
          }
     }
     return CreateEmbed
}

StartBot()