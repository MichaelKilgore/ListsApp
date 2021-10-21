const { POST, MSG } = require('./ENUM')

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

async function logoutPushkit(deviceToken) {
	var note = new apn.Notification();	

	note.expiry = Math.floor(Date.now() / 1000) + 3600;
	note.topic = "Michael.List";
	
	note.payload = {
		'msg': MSG.LOGOUT
	}	
	var x = apnProvider.send(note, deviceToken)
				.then(response => response)
				.catch(err => err)
	
	return x
}
exports.logoutPushkit = logoutPushkit

async function inviteUserToListPushkit(deviceToken, email, listID, listName) {
	var note = new apn.Notification();

	note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
   	note.badge = 3;
   	note.sound = "ping.aiff";
  	note.topic = "Michael.List";
   	note.alert = email + " invited you to join their list.";
  	note.payload = {
    	"aps":{
           	"content-available":1
      	},
       	'msg': MSG.INVITE_REQUEST,
    	'listID': listID,
		'listName': listName
  	};

	console.log(note.payload)

	var x = apnProvider.send(note, deviceToken)
		.then(response => response )
		.catch(err => err)

	return x
}
exports.inviteUserToListPushkit = inviteUserToListPushkit

async function userAcceptsInvitePushkit(deviceToken, email, listName, listID) {
	var note = new apn.Notification();

	note.expiry = Math.floor(Date.now() / 1000) + 3600;	
	note.badge = 3;
	note.sound = "ping.aiff";
	note.topic = "Michael.List";

	note.alert = email + " joined " + listName + "."
	note.payload = {
		"aps": {
			"content-available":1
		},
		'msg': MSG.USER_JOINS_LIST,
		'email': email,
		'listID': listID	
	}
	var x = apnProvider.send(note, deviceToken)
				.then(response => response)
				.catch(err => err)

	return x
}
exports.userAcceptsInvitePushkit = userAcceptsInvitePushkit

async function userDeletesListPushkit(deviceToken, username, listID, listName, host, email) {
	var note = new apn.Notification();
	
	note.expiry = Math.floor(Date.now() / 1000) + 3600;
    note.badge = 3;
    note.sound = "ping.aiff";
    note.topic = "Michael.List";

    note.alert = username + " left " + listName + "."
    note.payload = {
        "aps": {
            "content-available":1
        },
        'msg': MSG.USER_LEAVES_LIST,
        'email': email,
        'listID': listID,
		'listName': listName,
		'host': host
    }
    var x = apnProvider.send(note, deviceToken)
                .then(response => response)
                .catch(err => err)

    return x
}
exports.userDeletesListPushkit = userDeletesListPushkit

async function addListItemPushkit(deviceToken, username, listID, listName, bodyObject) {
	var note = new apn.Notification();
	console.log(bodyObject);

    note.expiry = Math.floor(Date.now() / 1000) + 3600;
    note.badge = 3;
    note.sound = "ping.aiff";
    note.topic = "Michael.List";

    note.alert = username + " added " + bodyObject.text + " to " + listName + "."
    note.payload = {
        "aps": {
            "content-available":1
        },
        'msg': MSG.NEW_BODY_ITEM,
        'listID': listID,
        'body': bodyObject
    }
    var x = apnProvider.send(note, deviceToken)
                .then(response => response)
                .catch(err => err)

    return x
}
exports.addListItemPushkit = addListItemPushkit

async function deleteListItemPushkit(deviceToken, listID, bodyID, text, listName) {
	var note = new apn.Notification();

    note.expiry = Math.floor(Date.now() / 1000) + 3600;
    note.badge = 3;
    note.sound = "ping.aiff";
    note.topic = "Michael.List";

    note.alert = "" + " deleted " + text + " from " + listName + "."
    note.payload = {
        "aps": {
            "content-available":1
        },
        'msg': MSG.REMOVE_BODY_ITEM,
        'listID': listID,
		'bodyID': bodyID
    }
    var x = apnProvider.send(note, deviceToken)
                .then(response => response)
                .catch(err => err)

    return x
}
exports.deleteListItemPushkit = deleteListItemPushkit

async function updateListItemPushkit(deviceToken, username, listID, listName, bodyObject) {
	var note = new apn.Notification();

    note.expiry = Math.floor(Date.now() / 1000) + 3600;
    note.badge = 3;
    note.sound = "ping.aiff";
    note.topic = "Michael.List";

    note.alert = username + " made changes to " + listName + "."
    note.payload = {
        "aps": {
            "content-available":1
        },
        'msg': MSG.EDIT_BODY_ITEM,
        'listID': listID,
        'body': bodyObject
    }
    var x = apnProvider.send(note, deviceToken)
                .then(response => response)
                .catch(err => err)

    return x	
}
exports.updateListItemPushkit = updateListItemPushkit





