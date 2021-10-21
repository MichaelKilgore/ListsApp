//connecting to app
var express = require('express');
var app = express();
//can i just make this https?
var server = require('http').createServer(app);
var io = require('socket.io')(server);

connections = [];

server.listen(6311, function(err) {
	console.log(
    "nodejs running url"+ window.location.href
  	);
});
console.log('Server is running...');

/////////////////

//connecting to mongodb//
var CRUD = require('./CRUDandQuery');

const MongoClient = require('mongodb').MongoClient;
const uri = 'mongodb://127.0.0.1:27017';
const client = new MongoClient(uri);
connection = client.connect();
var uuid = require('uuid');
////////////////////////////

//PUSH notifications////////
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

/*
var note = new apn.Notification();

note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
note.badge = 3;
note.sound = "ping.aiff";
note.topic = "Michael.ShoppingLists";
*/
///////////////////////////

////JSON FUNCTION//////////////
function IsJsonString(str) {
    try {
        JSON.parse(str);
    } catch (e) {
        return false;
    }
    return true;
}

/////////////////////////////

//////keeping track of users that are logged in//////////
var Users = {};
////////////////////////////////////////////

io.sockets.on('connection', function(socket) {
	//connection established
	connections.push(socket, "");
	console.log('Connect: %s sockets are connected', connections.length);

	//User sends login credentials
	socket.on('User Login', function(data) {
		//server checks if users credentials are correct
			//if credentials are correct then send the user the lists that he/she is a part of.	
			//else send a message saying users credentials are incorrect.
		if (IsJsonString(data)) {
			const obj = JSON.parse(data);
			console.log(obj.email, " logged in.");
			//first verify the user exists, then update his deviceToken, finally send all the users information
			CRUD.FindUser(connection, client, obj.email, (err, res) => {
				if (err) {
					socket.emit('User Login', {msg: "Fail"});
				} else { // user found
					if (res == null) {
						socket.emit('User Login', {msg: "Fail"});
					} else if (res.password == obj.password) { //users login credentials are correct
						//logging in user
						if (Users.hasOwnProperty(obj.email) == true) {
							//this means the user is being logged in from another spot and the previous spot needs to be sent a push notification that the user logged out and this old user will be forced to log out.
							CRUD.FindUser(connection, client, obj.email, (err, res) => {
								let deviceToken = res.deviceToken;		
			
								var note = new apn.Notification();
		
								note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
                        		note.badge = 3;
                        		note.sound = "ping.aiff";
                        		note.topic = "Michael.ShoppingLists";

								//hopefully i don't need an alert? idk.
                        		//note.alert = obj.email + " joined " + obj.ListUniqueName.split("-")[0]
		
								note.payload = {
									'msg': 'logOut'
								}
								apnProvider.send(note, deviceToken).then( (result) => {
									console.log(obj.email, " was logged out by a log in from a new location.");
								});
							});

						} else {
							Users[obj.email] = 1;
						}

						const resData = res;
						//update deviceToken
						CRUD.UpdateTokenURL(connection, client, obj.email, obj.deviceToken, (err, res) => {});
						//send all the users data to him
						//find all the lists the user is in.
    					CRUD.GetListsForUser(connection, client, obj.email, (err, res) => {
							const data = {
								msg: "Success",
								email: resData._id,
                            	firstName: resData.firstName,
                            	lastName: resData.lastName,
                            	password: resData.password,
                            	invites: resData.invites,
                            	deviceToken: resData.deviceToken,
                            	lists: res
							}
							socket.emit('User Login', data);
						});
					} else {
						socket.emit('User Login', {msg: "Fail"});
					}
				}
			});
		}
	});

	socket.on('Update Everything', function(data) {
        //server checks if users credentials are correct
            //if credentials are correct then send the user the lists that he/she is a part of.
            //else send a message saying users credentials are incorrect.
        if (IsJsonString(data)) {
            const obj = JSON.parse(data);
            console.log(obj.email, " logged in.");
            //first verify the user exists, then update his deviceToken, finally send all the users information
            CRUD.FindUser(connection, client, obj.email, (err, res) => {
                if (err) {
                    socket.emit('Update Everything', {msg: "Fail"});
                } else { // user found
                    if (res == null) {
                        socket.emit('Update Everything', {msg: "Fail"});
                    } else if (res.password == obj.password) { //users login credentials are correct
                        const resData = res;
                        //update deviceToken
                        CRUD.UpdateTokenURL(connection, client, obj.email, obj.deviceToken, (err, res) => {});
                        //send all the users data to him
                        //find all the lists the user is in.
                        CRUD.GetListsForUser(connection, client, obj.email, (err, res) => {
                            const data = {
                                msg: "Success",
                                email: resData._id,
                                firstName: resData.firstName,
                                lastName: resData.lastName,
                                password: resData.password,
                                invites: resData.invites,
                                deviceToken: resData.deviceToken,
                                lists: res
                            }
                            socket.emit('Update Everything', data);
                        });
                    } else {
                        socket.emit('Update Everything', {msg: "Fail"});
                    }
                }
            });
        }
    });

	socket.on('New User Login', function(data) {
		//attempt to create new user with the given credentials.
			//if it succeeds then send the user a message saying user was created
			//other wise tell the user that the email was not unique.
		if (IsJsonString(data)) {
			const obj = JSON.parse(data);
			console.log("new user created: ", obj.email);
			CRUD.InsertUser(connection, client, obj.email, obj.firstName, obj.lastName, obj.password, obj.deviceToken, (err, res) => {
				if (err) {
					socket.emit('New User Login', {msg: "Fail"});
				} else {
					socket.emit('New User Login', {msg: "Success"});
				}
			});
		} else {
			socket.emit('New User Login', {msg: "Fail"});
		}
	});

	socket.on('Create New List', function(data) {
		//call the Insert New List command, this will fail if the list name is not unique and succeed otherwise. This will also input the user into the user-lists collection.
		if (IsJsonString(data)) {
			const obj = JSON.parse(data);
			CRUD.InsertNewList(connection, client, obj.email, obj.ListName, (err, res) => {
				console.log("new list created by", obj.email);
				if (err) {
					socket.emit('New User Login', {msg: "Fail"});
				} else {
					socket.emit('New User Login', {msg: "Success"});
				}
			});
		} else {
			console.log("Inproper JSON form");
			socket.emit('New User Login', {msg: "Fail"});
		}
	});
	
	socket.on('Delete List', function(data) {
		//calls the delete list function which should also delete for all other users. Should notify all other users that are connected that the database changed.
	});

	//
	socket.on('Invite User To List', function(data) {
		//should send a notification to a user.
		//i.e add a notification to the users notifications.
		if (IsJsonString(data)) {
			const obj = JSON.parse(data);
			const ListUniqueName = obj.host + "-" + obj.ListName
			CRUD.SendUserInviteRequest(connection, client, ListUniqueName, obj.email, (err, res) => { });
			//TODO: Use pushkit to send user invite request to user.
			CRUD.FindUser(connection, client, obj.email, (err, res) => {
				let deviceToken = res.deviceToken;

				var note = new apn.Notification();

				note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
				note.badge = 3;
				note.sound = "ping.aiff";
				note.topic = "Michael.ShoppingLists";			
		
				note.alert = obj.email + " invited you to join their list.";
				note.payload = {
					"aps":{
                        "content-available":1
                    },
    				'msg': 'invite',
    				'UniqueListName': ListUniqueName
				};				
				apnProvider.send(note, deviceToken).then( (result) => {
    				console.log("invite request sent to ", obj.email)
				});
			});
		}	
	});

	socket.on('User Accepts Invite', function(data) {
		//user accepts notification i.e delete notification from users list of notifications and add him to the list under users.
		if (IsJsonString(data)) {
			const obj = JSON.parse(data);
			CRUD.RemoveUserInviteRequest(connection, client, obj.email, obj.ListUniqueName, (err, res) => { });
			//add user to list and then notify all users of the list that a user was added to the list.
			CRUD.InsertUserToList(connection, client, obj.ListUniqueName, obj.email, (err, res) => { 
				console.log(obj.email, " accepted the invite to join ", obj.ListUniqueName)
				//send new list to user
				CRUD.getList(connection, client, obj.ListUniqueName, (err, res) => {
					if (err) {
						socket.emit('User Accepts Invite', {msg: "Fail"});
					} else {
						var x = res;
						x['msg'] = "Success";
						socket.emit('User Accepts Invite', x);
					}
				});
			});
			CRUD.GetUsersForList(connection, client, obj.ListUniqueName, (err, res) => {
				for (const user of res) {
					CRUD.FindUser(connection, client, user, (err, res) => {
						let deviceToken = res.deviceToken;

                		var note = new apn.Notification();

                		note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
                		note.badge = 3;
                		note.sound = "ping.aiff";
                		note.topic = "Michael.ShoppingLists";

						note.alert = obj.email + " joined " + obj.ListUniqueName.split("-")[0]
						note.payload = {
							'msg': 'newUserToList',
							'email': obj.email,
							'UniqueListName': obj.ListUniqueName,
							"aps":{
                        		"content-available":1
                    		}
						}
						apnProvider.send(note, deviceToken).then( (result) => {
							console.log("user was sent notified of ", obj.email, " joining the list ", obj.ListUniqueName)
						});
					});	
				}
			});
				
		}
	});

	socket.on('User Declines Invite', function(data) {
		//just delete notification from the users list of notifications.
		if (IsJsonString(data)) {
			const obj = JSON.parse(data);
			CRUD.RemoveUserInviteRequest(connection, client, obj.email, obj.ListUniqueName, (err, res) => { });
		}
	});

	socket.on('Add List Item', function(data) {
		//should add the item to the list body and search the tree of users currently connected to the server and let all users that are a part of this list know that the list was updated.
		if (IsJsonString(data)) {
			const obj = JSON.parse(data);
			//add list item, then send push notification to users in list.
			CRUD.InsertRowIntoListStringID(connection, client, obj.body.id, obj.ListUniqueName, obj.body.text, obj.body.user, (err, res) => { });
			console.log("item added to ", obj.ListUniqueName)

			CRUD.GetUsersForList(connection, client, obj.ListUniqueName, (err, res) => {
				for (const user of res) {
					CRUD.FindUser(connection, client, user, (err, res) => {
                        let deviceToken = res.deviceToken;

                		var note = new apn.Notification();

                		note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
                		note.badge = 3;
                		note.sound = "ping.aiff";
                		note.topic = "Michael.ShoppingLists";

                        note.alert = obj.email + " added " + obj.body.text + " to " + obj.ListUniqueName.split("-")[1]

						console.log("user notified of new list item added to ", obj.ListUniqueName)

                        note.payload = {
                            'msg': 'newBodyItem',
                            'email': obj.email,
                            'UniqueListName': obj.ListUniqueName,
							'body':
								{
									'id': obj.body.id,
									'user': obj.body.user,
									'text': obj.body.text	
								},
							"aps":{
                        		"content-available":1
                    		}
                        }
                        apnProvider.send(note, deviceToken).then( (result) => {
                        });
                    });	
				}
			});
		}
	});

	socket.on('Delete List Item', function(data) {
		//should delete a list item and notify all users connected to the server of the change.
		if (IsJsonString(data)) {
			const obj = JSON.parse(data);
			console.log("item deleted from list")
	    //DeleteRowFromList: function(connection, client, ListUniqueName, id, cb) {
			CRUD.DeleteRowFromList(connection, client, obj.ListUniqueName, obj.bodyID, (err, res) => { });
			CRUD.GetUsersForList(connection, client, obj.ListUniqueName, (err, res) => {
				for (const user of res) {
					CRUD.FindUser(connection, client, user, (err, res) => {
						//console.log(res)
						let deviceToken = res.deviceToken;

	                	var note = new apn.Notification();

                		note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
                		note.badge = 3;
                		note.sound = "ping.aiff";
                		note.topic = "Michael.ShoppingLists";

						note.alert = obj.email + " deleted something from " + obj.ListUniqueName.split("-")[0]	
						note.payload = {
							'msg': 'deleteListItem',
							'UniqueListName': obj.ListUniqueName,
							'id': obj.bodyID,
							"aps":{
                        		"content-available":1
                    		}
						}
						console.log(res.email, " notified of deleted item")
						apnProvider.send(note, deviceToken).then( (result) => {
                            //console.log(result);
                        });
					});
				}
			});
		}
	});

	socket.on('User	Kicked From List', function(data) {
		//
	});

	socket.on('User Leaves List', function(data) {

	});

	//Disconnect
	socket.on('disconnect', function(data) {
		connections.splice(connections.indexOf(socket), 1);
		console.log('Disconnect: %s sockets are connected', connections.length);
	});

	socket.on('NODEJS Server Port', function(data) {
		//console.log(data);
		socket.emit('iOS Client Port', {msg: 'Hi iOS Client!'})
	});

	socket.on('New User', function(data) {
		//console.log(data);
		socket.emit('iOS Client Port', {msg: 'New User was inserted!'})

		CRUD.InsertUser('jesse.kilgore@gmail.com', 'jesse', 'kilgore', 'poopy', (err, res) => {
    		//console.log(res);
    		x = res;
    		if (x == false) {
				socket.emit('iOS Client Port', {msg: 'New User was NOT inserted!'});
    		} else {
        		socket.emit('iOS Client Port', {msg: 'New User was inserted!'});
    		}
		});
	});

	socket.on('Log Out', function(data) {
		if (IsJsonString(data)) {
            const obj = JSON.parse(data);
			if (Users.hasOwnProperty(obj.email) == true) {
				delete Users[obj.email];
			}
		}
	});

	/*socket.on('Delete Account', function(data) {
		if (IsJsonString(data)) {
            const obj = JSON.parse(data);
			GetListsForUser(connection, client, obj.email, (err, res) => {
				for (const list of res) {
					GetUsersForList: function(connection, client, ListUniqueName, (err, res2) => {
						//notify users that user left list this should also delete the user from the list.
						for (const user of res2) {
							if (user != obj.email) {
								//notify here
								CRUD.FindUser(connection, client, user, (err, res5) => {
									let deviceToken = res.deviceToken;	
				
									var note = new apn.Notification();
			
									note.expiry = Math.floor(Date.now() / 1000) + 3600;
									note.badge = 3;
                        			note.sound = "ping.aiff";
                        			note.topic = "Michael.ShoppingLists";

                        			note.alert = obj.email + " left " + list.split("-")[0]	
									note.payload = {
										'msg': 'userLeftList',
										'email': obj.email,
										'list': list
									}
									apnProvider.send(note, deviceToken).then( (result) => {
                            			//console.log(result);
                        			});									
								});
							}
						}
					}
					RemoveUserFromList(connection, client, list, obj.email, (err, res3) => {});
				}
			});
			DeleteUser(connection, client, email, (err, res4) => {});
        }
	});*/

});








