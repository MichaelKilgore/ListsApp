var apn = require('apn');

var options = {
  token: {
    key: "AuthKey_92STV2HA6D.p8",
    keyId: "92STV2HA6D",
    teamId: "QBFL489WJL"
  },
  production: false
};

var apnProvider = new apn.Provider(options);

let deviceToken = "04f8e9df9214390d6885ab634418553b78c59cd40e02b25eddff6ef5b41cc4ba";

var note = new apn.Notification();

note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
note.badge = 3;
note.sound = "ping.aiff";
note.alert = "You have a new message";
note.payload = {
	'messageFrom': 'John Appleseed',
	'food': 'water melon'
};
note.topic = "Michael.ShoppingLists";

apnProvider.send(note, deviceToken).then( (result) => {
	console.log(result);
});



