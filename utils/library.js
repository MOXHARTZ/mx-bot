// FiveM Functions
module.exports = {
      Ban: (admin, identifier, reason, time) => {
            emit('mx-serverman:Ban', admin, identifier, reason, time)
      },
      Kick: (admin, identifier, reason) => {
            emit('mx-serverman:Kick', admin, identifier, reason)
      },
      GetInventory: (identifier) => {
            emit('mx-serverman:GetInventory', identifier)
      },
      GetMoney: (identifier) => {
            emit('mx-serverman:GetMoney', identifier)
      },
      GetGeneralInformations: (identifier) => {
            emit('mx-serverman:GetGeneralInformations', identifier)
      },
      GetBannedPlayers: () => {
            emit('mx-serverman:GetBannedPlayers')
      },
      GetBannedPlayer: (identifier) => {
            emit('mx-serverman:GetBannedPlayer', identifier)
      },
      Wipe: (identifier) => {
            emit('mx-serverman:Wipe', identifier)
      },
      AddMoney: (identifier, type, amount) => {
            emit('mx-serverman:AddPlayerMoney', identifier, type, amount)
      },
      RemoveMoney: (identifier, type, amount) => {
            emit('mx-serverman:RemovePlayerMoney', identifier, type, amount)
      },
      GetOnlinePlayers: () => {
            emit('mx-serverman:GetPlayers')   
      },
      SetJob: (id, name, grade) => {
            emit('mx-serverman:SetJob', id, name, grade)
      },
      Revive: (id) => {
            emit('mx-serverman:Revive', id)
      },
      ReviveAll: (id) => {
            emit('mx-serverman:ReviveAll', id)
      },
      Unban: (id) => {
            emit('mx-serverman:Unban', id)
      },
      GiveItem: (id, name, count) => {
            emit('mx-serverman:GiveItem', id, name, count)
      },
      SetCoords: (id, x, y, z) => {
            emit('mx-serverman:SetCoords', id, x, y, z)
      }
}