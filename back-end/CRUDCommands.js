///////////CRYPTOCRAPHY///////////////
const bcrypt = require ('bcrypt');
crypto = require('crypto');
const saltRounds = 10;
const uuid = require('uuid');
////////////ENUM///////////////
const { POST, MSG } = require('./ENUM')

/////////////////login/////////////////
//This function returns two different types of things.
//1. It returns [true, userInfo] if the user login succeeds. True meaning it succeeded, and userInfo is the info you send to the user.
//2. It returns [false, num] where the num represents what went wrong. False means some type of failure occurred.
	// num == 1 means the login credentials for incorrect
	// num == 3 means their was a server error.
async function login(db, email, password) {
	const Users_Lists = db.collection('Users_Lists');
    const Users = db.collection('Users');
    const Lists = db.collection('Lists');

    var userInfo = Users.findOne({ _id: email});
    var listsUsersIn = Users_Lists.find({ email: email }).toArray();

    [userInfo, listsUsersIn] = await Promise.all([userInfo, listsUsersIn]).then(result => result).catch(err => { return [false, POST.SERVER_ERROR] })

	// checks if either the user does not exist, or the user is not a part of any lists.
	if (userInfo == null) {
		return [false, POST.INVALID_LOGIN]
	} else if (listsUsersIn == []) {
		return [true, { 'response': POST.SUCCESS, 'userInfo': userInfo, 'lists': [] }]
	}

    var comparePassword = bcrypt.compare(password, userInfo.password)

    comparePassword = await comparePassword.then(result => result).catch(err => { return [false, POST.SERVER_ERROR] })

    //checks if the password is the right password
	if (comparePassword == false) {
		return [false, POST.INVALID_LOGIN]	
	}

    var usersInEachList = [];
    var listsInfo = [];

    for (var i = 0; i < listsUsersIn.length; i++) {
        usersInEachList.push(Users_Lists.find({ listID: listsUsersIn[i].listID }).toArray());
        listsInfo.push(Lists.findOne({ _id: listsUsersIn[i].listID }));
    }

    usersInEachList = await Promise.all(usersInEachList).then(result => result).catch(err => { return [false, POST.SERVER_ERROR] })
    listsInfo = await Promise.all(listsInfo).then(result => result).catch(err => { return [false, POST.SERVER_ERROR] })

    var everyUsersInfo = [];

    for (var i = 0; i < usersInEachList.length; i++) {
        var tempList = [];
        for (var j = 0; j < usersInEachList[i].length; j++) {
            tempList.push(Users.findOne({ _id: usersInEachList[i][j].email }));
        }
        everyUsersInfo.push(tempList);
    }

	try { 
		everyUsersInfo = await Promise.all( everyUsersInfo.map(function(innerPromiseArray) { return Promise.all(innerPromiseArray); }) )
	} catch {
		return [false, POST.SERVER_ERROR]
	}

    const refinedUserList = [];

    for (var i = 0; i < everyUsersInfo.length; i++) {
        var curList = [];
        for (var j = 0; j < everyUsersInfo[i].length; j++) {
            curList.push({'username': everyUsersInfo[i][j].username, 'email': everyUsersInfo[i][j]._id});
        }
        refinedUserList.push(curList);
    }

    for (var i = 0; i < listsInfo.length; i++) {
        listsInfo[i]['users'] = refinedUserList[i];
    }

	
	userInfo['email'] = userInfo['_id']
	delete userInfo['_id']
	delete userInfo['active']
	delete userInfo['verificationCode']
	delete userInfo['changePasswordCode']

	return [true, { 'response': POST.SUCCESS, 'userInfo': userInfo, 'lists': listsInfo }]
}
exports.login = login

/////////////createNewUser////////////////
//This function creates a new user account, and returns whether it was a success or a failure.
async function createNewUser(db, email, username, password, verificationCode) {
	var hashedPassword = bcrypt.hash(password, saltRounds)
	
	hashedPassword = await hashedPassword.then(result => result).catch(err => POST.SERVER_ERROR)


	const data = {
		_id: email,
		username: username,
		password: hashedPassword,
		deviceToken: "",
		invites: [],
		active: true, //FIX: temporarily set to true
		verificationCode: verificationCode,
		changePasswordCode: ""
	}

	const Users = db.collection('Users');
	const resp = await Users.insertOne(data).then(result => POST.SUCCESS ).catch(err => POST.SERVER_ERROR )
	return resp
}
exports.createNewUser = createNewUser

async function findUser(db, email) {
	const Users = db.collection('Users')
	const userInfo = await Users.findOne({ _id: email}).then(result => result).catch(err => POST.SERVER_ERROR)
	if (userInfo == null) {
		return [POST.INVALID_LOGIN, null]
	}
	if (userInfo == POST.SERVER_ERROR) {
		return [POST.SERVER_ERROR, null]
	}
	return [POST.SUCCESS, userInfo]
}
exports.findUser = findUser

async function activateUser(db, email) {
	const Users = db.collection('Users');
	const res = Users.updateOne(
		{ _id: email },
		{ $set: {
			active: true,
			verificationCode: ""
		} }
	)
	.then(result => POST.SUCCESS)
	.catch(err => POST.SERVER_ERROR)	

	return await res
}
exports.activateUser = activateUser

async function setPasswordChangeCode(db, email, code) {
	const Users = db.collection('Users');
	const res = Users.updateOne(
		{ _id: email },
		{ $set: { changePasswordCode: code } },
	)
	.then(result => POST.SUCCESS)	
	.catch(err => POST.SERVER_ERROR)
}
exports.setPasswordChangeCode = setPasswordChangeCode

async function changePassword(db, email, newPassword) {
	const Users = db.collection('Users');
	const x = Users.updateOne(
		{ _id: email },
		{ $set: {
			password: newPassword,
			changePasswordCode: ""
		} }
	)
	.then(result => POST.SUCCESS)
	.catch(err => POST.SERVER_ERROR)
	
	return x
}
exports.changePassword = changePassword

async function changeUsername(db, email, newUsername) {
	const Users = db.collection('Users');
	const x = Users.updateOne(
		{ _id: email },
		{ $set: {
			username: newUsername	
		} }
	)
	.then(result => POST.SUCCESS)
	.catch(err => POST.SERVER_ERROR)

	return x
}
exports.changeUsername = changeUsername


async function credentialCheck(db, email, password) {
	const Users = db.collection('Users')
    const userInfo = await Users.findOne({ _id: email}).then(result => result).catch(err => POST.SERVER_ERROR)
    if (userInfo == null) {
        return POST.INVALID_LOGIN
    } else if (userInfo == POST.SERVER_ERROR) {
        return POST.SERVER_ERROR
    } else {
		const credentialsMatch = await bcrypt.compare(password, userInfo.password).then(result => result).catch(err => false)
        if (credentialsMatch) {	
			return POST.SUCCESS	
		} else {
			return POST.INVALID_LOGIN
		}
	}
}
exports.credentialCheck = credentialCheck

async function createNewList(db, email, listName, listID) {
	
	const data = {
		_id: listID,
		host: email,
		shoppingListName: listName,
		body: []
	}	
	const Lists = db.collection('Lists');
	//wait for list to insert first, and then if it fails then don't enter into the next thing.
	const resp = await Lists.insertOne(data)
					.then(response => POST.SUCCESS)
					.catch(err => {
						return POST.SERVER_ERROR
					})
	if (resp == POST.SUCCESS) {
		const data2 = {
			email: email,
			listID: listID
		}
		const usersLists = db.collection('Users_Lists');
		const resp2 = await usersLists.insertOne(data2)
						.then(response => POST.SUCCESS)	
						.catch(err => {
							return POST.SERVER_ERROR
						})
		return {'listID': listID, 'resp': resp2}
	} else {
		return {'listID': listID, 'resp': resp}
	}
}
exports.createNewList = createNewList

async function getUsersInList(db, listID) {
	const usersLists = db.collection('Users_Lists');	
	const res = await usersLists.find({ listID: listID }).toArray()
	const ans = [];
	for (const user of res) {
		ans.push(user.email);
	}
	return ans
}
exports.getUsersInList = getUsersInList

async function getListHost(db, listID) {
	const Lists = db.collection('Lists');
	const res = await Lists.findOne({ _id: listID })
	return res.host
}
exports.getListHost = getListHost

async function changeListHost(db, newHost, listID) {
	const Lists = db.collection('Lists');	
	const x = Lists.updateOne(
		{ _id: listID },
		{ $set: {
			host: newHost
		} }
	)
	.then(result => POST.SUCCESS)
	.catch(err => POST.SERVER_ERROR)
	return x
}
exports.changeListHost = changeListHost

async function removeUserFromList(db, listID, email) {
	const usersLists = db.collection('Users_Lists');
	const x = usersLists.deleteOne({ _id: email, listID: listID })
				.then(result => POST.SUCCESS)
				.catch(err => POST.SERVER_ERROR)
	return x
}
exports.removeUserFromList = removeUserFromList

async function getList(db, listID) {
	const Lists = db.collection('Lists');	
	const x = Lists.findOne({ _id: listID })
				.then(result => result)
				.catch(err => POST.SERVER_ERROR)
	return x
}
exports.getList = getList

async function getListBody(db, listID) {
    const Lists = db.collection('Lists');
    const x = Lists.findOne({ _id: listID })
                .then(result => result.body)
                .catch(err => POST.SERVER_ERROR)
    return x
}
exports.getListBody = getListBody

async function deleteList(db, listID) {
	const Lists = db.collection('Lists');
	Lists.deleteOne({ _id: listID });
		
	const usersLists = db.collection('Users_Lists');	
	usersLists.deleteMany({ listID: listID });
}
exports.deleteList = deleteList

async function insertListItem(db, itemID, listID, text, email, username, hyperLink, containsImage) {
	const newItem = {
		id: itemID,
		user: {
			email: email,
			username: username
		},
		text: text,	
		hyperLink: hyperLink,
		containsImage: containsImage
	}
	const Lists = db.collection('Lists');
	const x = Lists.updateOne(
		{ _id: listID },
		{ $push: { body: newItem } }
	)
	.then(response => POST.SUCCESS)
	.catch(err => POST.SERVER_ERROR)

	return x
}
exports.insertListItem = insertListItem

async function clearDeviceToken(db, email) {
	const Users = db.collection('Users');
	const x = Users.updateOne(
		{ _id: email },
		{ $set: {
			deviceToken: ""
		} }
	)
	.then(response => POST.SUCCESS)
	.catch(err => POST.SERVER_ERROR)
	
	return x
}
exports.clearDeviceToken = clearDeviceToken

async function deleteListItem(db, email, listID, bodyID) {
	const Users = db.collection('Lists');
	const x = Users.updateOne(
		{ _id: listID },
		{ $pull: { body: { id: bodyID } } }
	)
	.then(response => POST.SUCCESS )
    .catch(err => POST.SERVER_ERROR)
	
	return x	
}
exports.deleteListItem = deleteListItem

async function inviteUser(db, email, listID, listName) {
	const Users = db.collection('Users');
	const x = Users.updateOne(
		{ _id: email },
		{ $push: { invites: {"listID": listID, "listName": listName } } }
	)
	.then(response => POST.SUCCESS)
    .catch(err => POST.SERVER_ERROR)

	return x
}
exports.inviteUser = inviteUser

async function removeInviteRequest(db, email, listID) {
	const Users = db.collection('Users')
	const x = Users.updateOne(
		{ _id: email },
		{ $pull: { invites: {"listID": listID } } }
	)
	.then(response => POST.SUCCESS)
	.catch(err => POST.SERVER_ERROR)
	
	return x
}
exports.removeInviteRequest = removeInviteRequest

async function addUserToList(db, email, listID) {
	data = {
		email: email,
		listID: listID
	}
	const usersLists = db.collection('Users_Lists');
	var x = usersLists.insertOne(data)
			.then(response => POST.SUCCESS)
			.catch(err => POST.SERVER_ERROR)
	return x
}
exports.addUserToList = addUserToList

async function updateItem(db, listID, bodyID, text, hyperLink) {
	const Lists = db.collection('Lists');
	const x = Lists.updateOne(
		{ _id: listID, "body.id": bodyID },
      	{ $set: { body: { text: text, hyperLink: hyperLink } } }
	)
	.then(response => POST.SUCCESS)
	.catch(err => POST.SERVER_ERROR)

	return x
}
exports.updateItem = updateItem

async function getBodyItem(db, listID, bodyID) {
	const Lists = db.collection('Lists');	
	const x = await Lists.findOne({ _id: listID })
						.then(result => result.body)
						.catch(err => POST.SERVER_ERROR)

	for (const bodyItem of x) {
		if (bodyItem.id == bodyID) {
			console.log(bodyItem);
			return bodyItem
			break
		}
	}
}
exports.getBodyItem = getBodyItem

async function setDeviceToken(db, email, deviceToken) {
	const Users = db.collection('Users');
	const x = Users.updateOne(
        { _id: email },
        { $set: { deviceToken: deviceToken } }
    )
    .then(response => POST.SUCCESS)
    .catch(err => POST.SERVER_ERROR)
}
exports.setDeviceToken = setDeviceToken

async function getListInfo(db, listID) {
	const Lists = db.collection('Lists');
	const usersLists = db.collection('Users_Lists');
	const Users = db.collection('Users');
	const x = await Lists.findOne({ _id: listID })
                        .then(result => result)
                        .catch(err => POST.SERVER_ERROR)
	
	const users = await usersLists.find({ listID: listID }).toArray();
	var userPromises = [];

	for (const user of users) {
		userPromises.push(Users.findOne({ _id: user.email }))
	}

	const finalListOfUsers = [];

	userPromises = await Promise.all(userPromises).then(result => result).catch(err => err)

	for (const user of userPromises) {
		finalListOfUsers.push({'email': user._id, 'username': user.username})
	}		

	x['users'] = finalListOfUsers

	return x
}
exports.getListInfo = getListInfo

















