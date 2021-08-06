// const MySQL = require('mysql');
// const connect = MySQL.createConnection(Library.GetConnectionString());
// connect.connect();
// connect.query('SELECT * FROM users WHERE citizenid = ?', 'DtkY6289', function(error, result, fields) {
//      if (error) throw error;
//      console.log(`SELECTED BTW `, result[0].citizenid)
// })
// var inProgress = false;
// Delay = (ms) => new Promise(res => setTimeout(res, ms));
// module.exports = {
//      ExistIdentifier: (identifier) => {
//           inProgress = false;
//           var selected = null;
//           // connect.query('SELECT identifier FROM users WHERE identifier = ?', identifier, function(e, result, f) {
//           //      selected = true;
//           // })
//           emit('mx-serverman:GetIdentifier', identifier)
//           while (!inProgress) {
//                console.log('...')
//           }
//           console.log('finished')
//           return selected;
//      }
// }