async function main() {

////////////////////MONGODB///////////////////
const MongoClient = require('mongodb').MongoClient;
const uri = 'mongodb://127.0.0.1:27017';
const client = new MongoClient(uri);
await client.connect();
const db = client.db('ShoppingLists');
const { login, createNewUser, findUser, activateUser, setPasswordChangeCode, changePassword, changeUsername, credentialCheck, createNewList, getUsersInList, getListHost, changeListHost, removeUserFromList, getList, deleteList, insertListItem, clearDeviceToken, deleteListItem, inviteUser, removeInviteRequest, addUserToList, updateItem, getBodyItem, setDeviceToken } = require('./CRUDCommands')

///////////////SERVER////////////////////
crypto = require('crypto');
const express = require('express');
const app = express();
const bodyParser = require('body-parser');
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
const https = require('https');
const fs = require('fs');
const path = require('path');
const sslServer = https.createServer(
    {
        key: fs.readFileSync(path.join(__dirname, 'cert', 'key.pem')),
        cert: fs.readFileSync(path.join(__dirname, 'cert', 'cert.pem')),
    },
    app
)
const uuid = require('uuid');
const multer  = require('multer')
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
      cb(null, './uploads')
    },
    filename: function (req, file, cb) {
      cb(null, file.originalname)
    }
})
const upload = multer({ storage: storage })
const type = upload.single('image');
/////////ENUM///////////////////
const { POST, MSG } = require('./ENUM')
////////////S3//////////////////
const { uploadFile, getFileStream, deleteFile } = require('./s3')
const util = require('util')
const unlinkFile = util.promisify(fs.unlink)
//////EMAIL///////////////////
const { newAccountMail, changePasswordMail } = require('./emailCommands')
/////////PUSHKIT//////////////
const { userDeletesListPushkit, userAcceptsInvitePushkit, inviteUserToListPushkit, logoutPushkit, addListItemPushkit, deleteListItemPushkit, updateListItemPushkit } = require('./pushNotifications')
//////ALL SERVER REQUEST HANDLING////

//////////////LOGIN///////////////////////
//retrieves the users login information and sends it back to him.
app.post('/login', async function(req,res) {
	setDeviceToken(db, req.body.email, req.body.deviceToken)
	if (req.body.email && req.body.password) {
		var x = await login(db, req.body.email, req.body.password)
		if (x[0]) {
			res.send(x[1]);	
		} else {
			res.send({ 'response': x[1], 'userInfo': {}, 'lists': [] })
		}
	} else {
		res.send({'response': 2, 'userInfo': {}, 'lists': []});	
	}
})
/*login test
var x = await login(db, 'mkilgore2000@gmail.com', 'monkeyboi12');
console.log(x);*/

////////////CREATE NEW USER///////////////////
//This function creates a user
app.post('/createNewUser', async function(req,res) {
	if (req.body.email && req.body.password && req.body.username) {
		rand = crypto.randomBytes(64).toString('hex')
		var x = await createNewUser(db, req.body.email, req.body.username, req.body.password, rand);
		if (x == POST.SUCCESS) {
			var y = await newAccountMail(req.get('host'), req.body.email, rand);
			if (y == POST.SUCCESS) {
				res.send({ 'response': POST.SUCCESS })
			} else {
				res.send({ 'response': y })
			}
		} else {
			res.send({ 'response': x })
		}
	} else {
		res.send({'response': POST.SERVER_ERROR})
	}
})
/*//create new user test
var x = await createNewUser(db, 'mkilgore2013@gmail.com', 'mkilgore2000', 'monkeyboi12');
console.log(x);*/

////////////VERIFY///////////////
//Activates the users account.
app.get('/verify', async function(req,res) {
	const resp = await findUser(db, req.query.email)

	if (resp[0] == POST.SUCCESS) {
		if (req.query.id == resp[1].verificationCode) {
			res.send("<h1>Email "+req.query.email+" has been Successfully verified")
			const resp = activateUser(db, req.query.email)
			/*if (resp != POST.SUCCESS) {
				console.log("Server error occurred when verifying user.")
			}*/
		} else {
			res.send("<h3>Code given was incorrect</h3>")
		}
	} else {
		res.send("<h3>Server error occurred, try clicking the link in your email again.</h3>")
	}
})

/////////////FORGOTPASSWORD/////////////////
//user requests to change password. This will store a code and email that code to the user.
//The email sent to the user will allow the user to change their password.
app.get('/forgotPassword', async function(req, res) {
	const resp = await findUser(db, req.query.email)			
	if (resp[0] == POST.SUCCESS && resp[1].active) {
		rand = crypto.randomBytes(64).toString('hex')				
		host = req.get('host')
		const change = await setPasswordChangeCode(db, req.query.email, rand)
		if (change == POST.SUCCESS) {
			const succ = await changePasswordMail(host, rand, req.query.email)	
			res.send({'response': succ})
		} else {
			res.send({'response': change})
		}
	} else {
		res.send({'response': resp[0]})
	}
})

//////////////CHANGEPASSWORDGET///////////////
//this is what is sent to the user so they can change their password.
app.get('/changePassword', async function(req, res) {
    res.send('<form method="POST"><label for="newPassword">New Password:</label><br><input type="text" id="newPassword" name="newPassword"><br><input type="submit" value="Submit"></form>')
})

////////////////CHANGEPASSWORDPOST//////////////
//This is what is called when the user wants to change their password.
//If the code that was emailed to the user is identical to the code stored, then the password will be changed.
app.post('/changePassword', async function(req, res) {
	const user = await findUser(db, req.query.email)
	if (user[0] == POST.SUCCESS && user[1].active) {
		if (user[1].changePasswordCode == req.query.id) {
			newPassword = await bycrypt.hash(req.body.newPassword, saltRounds)
			const resp = await changePassword(db, req.query.email, newPassword)
			if (resp == POST.SUCCESS) {
				res.end("<h1>Password has been successfully reset.</h1>")
			} else {
				res.end("<h1>Bad Request</h1>")
			}
		} else {
			res.end("<h1>Bad Request</h1>")
		}
	} else {
		res.end("<h1>Bad Request</h1>");	
	}
})

//////////CHANGE USERNAME////////////////
//Changes the users username
app.post('/changeUsername', async function(req, res) {
	const isValid = await credentialCheck(db, req.body.email, req.body.password);
	if (isValid == POST.SUCCESS) {
		const succ = await changeUsername(db, req.body.email, req.body.username)				
		res.end({ 'response': succ })
	} else {
		res.end({ 'response': isValid })
	}
})

//////////CREATE NEW LIST//////////
//User creates a new list
app.post('/createNewList', async function(req, res) {
	const isValid = await credentialCheck(db, req.body.email, req.body.password)
	if (isValid == POST.SUCCESS) {
		const succ = await createNewList(db, req.body.email, req.body.listName)
		res.send(succ);
	} else {
		res.end({ 'listID': '', 'resp': isValid })
	}
})

/////////DELETE LIST//////////
//User deletes a list. If that user is the last person in the list then the list gets deleted,
//otherwise the host is changed, and the user is removed from the list
app.post('/deleteList', async function(req, res) {
	const isValid = await credentialCheck(db, req.body.email, req.body.password)		
	if (isValid == POST.SUCCESS) {
		const users = await getUsersInList(db, req.body.listID);				
		if (users.length != 1) {
			const host = await getListHost(db, listID);
			firstUser = true
			nextHost = ""
			for (const user of users) {
				if (host == req.body.email && firstUser == true) {
					if (host != user) {
						firstUser = false
						nextHost = user
						const res = changeListHost(db, newHost, listID) //TODO: no fallback for if this fails.
					}
				}
			}
		
			for (const user of users) {
				if (user /*!=*/== req.body.email) {
					const userInfo = await findUser(db, user)	
					userDeletesListPushkit(userInfo[1].deviceToken, userInfo[1].username, req.body.listID, "", nextHost, req.body.email)
				}
			}
			res.send({ 'response': POST.SUCCESS })
			const succ = await removeUserFromList(db, req.body.listID, req.body.email)
				
		} else {
			const list = await getList(db, req.body.listID) //TODO: does this succeed
			if (list != POST.SERVER_ERROR) {
				for (const item of list) {
					if (item.containsImage == true) {
						deleteFile(item.id); //TODO: does this succeed?
					}	
				}
			
				deleteList(db, req.body.listID) //TODO: does this need to succeed?
				res.send({'response': POST.SUCCESS });
			} else {
				res.send({ 'response': POST.SERVER_ERROR });
			}
		}
	} else {
     	res.send({ 'response': POST.SERVER_ERROR });
	}
})

//////////GET IMAGE///////////////////
//This returns an image from s3 that the user requests.
app.get('/getImage', function(req, res) {
	const key = req.query.id
    console.log("image requested with id: ", key);
    const readStream = getFileStream(key);

    //TypeError: Cannot read property 'pipe' of undefined

	//res.send(readStream)
    readStream.pipe(res);
})

//////////ADD LIST ITEM WITH IMAGE/////////////
//When the user wants to add an item to a list with an image, this function is called.
app.post('/addListItemWithImage', type, async function(req, res) {
	const isValid = await credentialCheck(db, req.body.email, req.body.password)
    if (isValid == POST.SUCCESS) {
		itemID = uuid.v1();
		const file = req.file
		const fileDidUpload = await uploadFile(file, itemID)
		//unlinkFile(file.path);
		const path = itemID;
	
		const x = await insertListItem(db, itemID, req.body.listID, req.body.text, req.body.email, req.body.username, req.body.hyperLink, true)

		const body = {
			'id': itemID,
			'user': {
				'email': req.body.email,
				'username': req.body.username
			},
			'text': req.body.text,
			'hyperLink': req.body.hyperLink,
			'containsImage': true
		}

		const users = await getUsersInList(db, req.body.listID)
		for (const user of users) {
			if (user /*!=*/== req.body.email) {
				var userInfo = findUser(db, user)
				var listInfo = getList(db, req.body.listID)
				[userInfo, listInfo] = await Promise.all([userInfo, listInfo]).then(result => result).catch(err => { return POST.SERVER_ERROR })
				console.log(body);
				const y = addListItemPushkit(userInfo[1].deviceToken, req.body.listID, listInfo.listName, body);
			}
		}

		if (x == POST.SUCCESS) {
			res.send({ 'path': path, 'id': itemID })
		} else {
			res.send('fail');
		}
	} else {
		res.send('fail');
	}
})

//////////ADD LIST ITEM////////////////
//This function adds a list item to mongodb without an image.
app.post('/addListItem', async function(req, res) {
	const isValid = await credentialCheck(db, req.body.email, req.body.password)
    if (isValid == POST.SUCCESS) {
		itemID = uuid.v1();
		const x = await insertListItem(db, itemID, req.body.listID, req.body.text, req.body.email, req.body.username, req.body.hyperLink, false)

		const body = {
            'id': itemID,
            'user': {
                'email': req.body.email,
                'username': req.body.username
            },
            'text': req.body.text,
            'hyperLink': req.body.hyperLink,
            'containsImage': false
        }

		const users = await getUsersInList(db, req.body.listID)
        for (const user of users) {
			if (user /*!=*/== req.body.email) {
            	var userInfo = findUser(db, user)
				var listInfo = getList(db, req.body.listID)
				[userInfo, listInfo] = await Promise.all([userInfo, listInfo]).then(result => result).catch(err => { return POST.SERVER_ERROR })
            	const y = addListItemPushkit(userInfo[1].deviceToken, req.body.username, req.body.listID, listInfo.listName, body);
			}
        }

        if (x == POST.SUCCESS) {
            res.send({ 'path': '', 'id': itemID })
        } else {
            res.send('fail');
        }	
	} else {
		res.send('fail');
	}
})

//////////CLEAR DEVICE TOKEN//////////
//Sets the users device token to ""
app.post('/clearDeviceToken', async function(req, res) {
	const isValid = await credentialCheck(db, req.body.email, req.body.password)
    if (isValid == POST.SUCCESS) {
		const ans = clearDeviceToken(db, req.body.email)
		res.send({ 'response': ans })
	} else {
		res.send({ 'response': isValid })
	}
})

///////////DELETE LIST ITEM/////////////
//Delets a list item from a list, attempts to delete the image as well.
app.post('/deleteListItem', async function(req, res) {
	const isValid = await credentialCheck(db, req.body.email, req.body.password)
    if (isValid == POST.SUCCESS) {
		const succ = await deleteListItem(db, req.body.email, req.body.listID, req.body.bodyID)
        const succ2 = deleteFile(req.body.bodyID); //TODO: this might cause a crash, cause im not checking to see if the file contains an image before deleting file. maybe send whether it contains image or not from the user.
		if (succ == POST.SUCCESS) {
			res.send({ 'response':succ })
		}
		
		/*if (succ2 == POST.SUCCESS) {
			console.log("Image deleted from s3 successfully.")
		} else {
			console.log("Failed to delete image from s3.")
		}*/


		const users = await getUsersInList(db, req.body.listID)
        for (const user of users) {
			if (user /*!=*/== req.body.email) {
            	var userInfo = findUser(db, user)
				var listInfo = getList(db, req.body.listID)
				var bodyItem = getBodyItem(db, req.body.listID, req.body.bodyID) //TODO: There is no getbodyItem function
				[userInfo, listInfo, bodyItem] = await Promise.all([userInfo, listInfo, bodyItem]).then(result => result).catch(err => { return POST.SERVER_ERROR })
            	const y = deleteListItemPushkit(userInfo[1].deviceToken, req.body.listID, req.body.bodyID, bodyItem.text, listInfo.listName)
			}
        }

	} else {
		res.send({ 'response': isValid })	
	}
})

///////////INVITE USER/////////////
//Adds an invite to the users invite list
//also sends a push notification to the user that they've been added to a list
app.post('/inviteUser', async function(req, res) {
	const isValid = await credentialCheck(db, req.body.email, req.body.password)
    if (isValid == POST.SUCCESS) {
		didWork = await inviteUser(db, req.body.email, req.body.listID, req.body.listName)
		if (didWork == POST.SUCCESS) {
			var userInfo = await findUser(db, req.body.invitedUser)
			var x = inviteUserToListPushkit(userInfo[1].deviceToken, req.body.email, req.body.listID, req.body.listName)

			res.send({ 'response':POST.SUCCESS })
		} else {
			res.send({'response':POST.SERVER_ERROR })
		}
	} else {
		res.send( {'response': isValid })
	}
})

/////////////ACCEPT INVITE//////////////
//Removes the invite from the user and adds that user to the list
//This also sends a push notification to all users in the list that that user was added to the list.
app.post('/acceptInvite', async function(req, res) {
	const isValid = await credentialCheck(db, req.body.email, req.body.password)
    if (isValid == POST.SUCCESS) {
		//removeInviteRequest
		removeInviteRequest(db, req.body.email, req.body.listID)
		//add user to list
		const didWork = await addUserToList(db, req.body.email, req.body.listID)

		const users = await getUsersInList(db, req.body.listID)
        for (const user of users) {
            if (user /*!=*/== req.body.email) {
                var userInfo = findUser(db, user)
				var listInfo = getList(db, req.body.listID)
				[userInfo, listInfo] = await Promise.all([userInfo, listInfo]).then(result => result).catch(err => { return POST.SERVER_ERROR })	
				const y = userAcceptsInvitePushkit(userInfo[1].deviceToken, req.body.email, listInfo.listName, req.body.listID)
            }
        }			
	
		res.send({ 'response': didWork })
	} else {
		res.send({ 'response': isValid })
	}
})

///////////////DECLINE INVITE////////////////
//Removes the invite from the users list of invites.
app.post('/declineInvite', async function(req, res) {
	console.log('declineInvite')
	const isValid = await credentialCheck(db, req.body.email, req.body.password)
    if (isValid == POST.SUCCESS) {
		const didWork = removeInviteRequest(db, req.body.email, req.body.listID)
		res.send({ 'response': didWork })
	} else {
		res.send({ 'response': isValid })
	}
})

//////////////UPDATE ITEM//////////////////
//Updates an items body with the new parameters sent
//pushkit notifies all users of the change
app.post('/updateItem', async function(req, res) {
	const isValid = await credentialCheck(db, req.body.email, req.body.password)
    if (isValid == POST.SUCCESS) {	
		//updateItem		
		const didWork = await updateItem(db, req.body.listID, req.body.bodyID, req.body.text, req.body.hyperLink)

		const userOfItem = await findUser(db, req.body.email)
		const body = {
            'id': req.body.bodyID,
            'user': {
                'email': req.body.email,
                'username': userOfItem.username
            },
            'text': req.body.text,
            'hyperLink': req.body.hyperLink,
            'containsImage': false
        }

		const users = await getUsersInList(db, req.body.listID)
        for (const user of users) {
            if (user /*!=*/== req.body.email) {
                const userInfo = findUser(db, user)
                const listInfo = getList(db, req.body.listID)
                [userInfo, listInfo] = await Promise.all([userInfo[1], listInfo]).then(result => result).catch(err => { return POST.SERVER_ERROR })
                const y = updateListItemPushkit(deviceToken, userInfo[1].username, req.body.listID, body)
            }
        }

		res.send({ 'response': didWork })
	} else {
		res.send({ 'response': isValid })
	}
})

///////////UPDATE ITEM WITH IMAGE/////////////
//Updates an items body with the new parameters sent
//also updates the image in s3
//pushkit notifies all users of the change
app.post('/updateItemWithImage', type, async function(req, res) {
	const isValid = await credentialCheck(db, req.body.email, req.body.password)
    if (isValid == POST.SUCCESS) {
		const didWork = await updateItem(db, listID, bodyID, text, hyperLink)
		const file = req.file;
		const x = await deleteFile(req.body.bodyID)
			.then(response => POST.SUCCESS)
			.catch(err => POST.SERVER_ERROR)
		if (x == POST.SUCCESS) {
			uploadFile(file, req.body.bodyID)
			unlinkFile(file.path)

			const userOfItem = await findUser(db, req.body.email)
        	const body = {
            	'id': req.body.bodyID,
            	'user': {
                	'email': req.body.email,
                	'username': userOfItem.username
            	},
            	'text': req.body.text,
            	'hyperLink': req.body.hyperLink,
            	'containsImage': false
        	}

        	const users = await getUsersInList(db, req.body.listID)
        	for (const user of users) {
            	if (user /*!=*/== req.body.email) {
                	var userInfo = findUser(db, user)
                	var listInfo = getList(db, req.body.listID)
                	[userInfo, listInfo] = await Promise.all([userInfo, listInfo]).then(result => result).catch(err => { return POST.SERVER_ERROR })
                	const y = updateListItemPushkit(deviceToken, userInfo[1].username, req.body.listID, body)
            	}
        	}
		}
		res.send({ 'response': x})
	} else {
		res.send({ 'response': isValid })
	}
})

sslServer.listen(6311, () => {
	console.log('Secure server listening on port 6311.')
})

} //: MAIN

main();


			
	
