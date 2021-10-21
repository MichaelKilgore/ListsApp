var apn = require('apn');

var options = {
  token: {
    key: "",
    keyId: "",
    teamId: ""
  },
  production: false
};

var apnProvider = new apn.Provider(options);

let deviceToken = "";

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



