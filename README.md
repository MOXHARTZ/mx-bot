# Fivem Server Management Bot 

# Features
- Discord Whitelist
- Ban, kick system
- Give / take money
- Can pull the player's information [identifier, firstname, dateofbirth, job and sex]
- Can delete player
- Can show banned players
- Can show the money in the player's account
- Can show the player inventory.
- Can control the ban.
- Can revive
- Can revive for all players
- Can give job
- Can give item
- Can show active players
- Can setcoords for player
- Can start script
- Can stop script
- Can refresh scripts
- Can give a vehicle
- All players can be given vehicles
- Can give a weapon
# Images
<a href="https://ibb.co/PcHQrvk"><img src="https://i.ibb.co/7nm4Sdh/image.png" alt="image" border="0"></a>
![image](https://user-images.githubusercontent.com/70913098/144917663-b27d9827-84e1-4583-901e-fe6cfe97595c.png)
![image](https://user-images.githubusercontent.com/70913098/128532692-4a4902ab-760d-4a79-92ba-d6a38cb215ec.png)

## Requirements
- node.js (https://nodejs.org/en/)
- mx-bansystem (https://github.com/MOXHAFOREVA/mx-bansystem)
- git (https://git-scm.com/downloads)

### How To Install
- install `https://nodejs.org/en/` and `https://github.com/MOXHAFOREVA/mx-bansystem`
- server.cfg > `ensure mx-servermanbot` `mx-bansystem`
- Shift + right click on the `mx-servermanbot` folder and click `Open PowerShell window here`
- write `npm i`
- For start, refresh, stop commands add ur server.cfg >
```
# MX-SERVERMAN
add_ace resource.mx-servermanbot command.start allow
add_ace resource.mx-servermanbot command.ensure allow
add_ace resource.mx-servermanbot command.stop allow
add_ace resource.mx-servermanbot command.refresh allow
```

## Config.json
- Discord Application: https://discord.com/developers/applications/
- Discord Bot Invite: 

- Go to `https://discord.com/developers/applications/` Join ur account click New Application
![image](https://user-images.githubusercontent.com/70913098/128538836-7680535a-0794-4c7e-b2d3-a8b829425cac.png)

- Select `bot`

- Select admin
![image](https://user-images.githubusercontent.com/70913098/128539041-77597fe7-80ce-4ba8-9335-87c7d0554911.png)

- Copy token and go to config.json > token = `ur token` 

- Select `OAuth2`

- Copy client id and invite bot https://discord.com/oauth2/authorize?clientid=your_client_id&scope=bot&permissions=8
![image](https://user-images.githubusercontent.com/70913098/128540238-9a9e4282-94c2-4f11-8eb7-3a47db8768c0.png)

- Go to discord > settings > Advanced > Open Developer Mode

- Copy the id of the admin role and whitelist role
![image](https://user-images.githubusercontent.com/70913098/128539612-f6bcd309-d129-4d08-a2bb-5c291087ed53.png)

- Copy ur discord server id 
![image](https://user-images.githubusercontent.com/70913098/128539849-ce3effd8-1708-4fbe-90d6-396a3b37152b.png)

And invite your bot !

# How To Install [Video]: https://www.youtube.com/watch?v=zuse0Etmoqc

