module.exports = {

	//    CRUD.InsertUser(connection, client, req.email, req.username, req.password, rand, (err, result) => {
	InsertUser: function (connection, client, email, username, password, rand, cb) {
		connection.then(() => {
			const data = {
                _id: email,
				username: username,
				deviceToken: "",
                password: password,
				invites: [],
				active: false,	
				verificationCode: rand
            }
			const db = client.db('ShoppingLists');
			const coll = db.collection('Users');	
			coll.insertOne(data, (err, res) => {
				cb(err, res);
			});
		});
	},

	ActivateUser: function(connection, client, email, cb) {
		connection.then(() => {
			const db = client.db('ShoppingLists');
			const coll = db.collection('Users');	
			coll.updateOne(
				{ _id: email },
				{ $set: { 
					active: true,
					verificationCode: ""
				} },
				function (err, res) {
					cb(err, res);
				}
			);
		});
	},

	DeleteUser: function(connection, client, email, cb) {
		connection.then(() => {
			const db = client.db('ShoppingLists');
			const coll = db.collection('Users');
			coll.deleteOne({ _id: email }, (err, res) => {
				cb(err, res);
			});

			//deleting all instances of the user being a part of a list.
			const coll2 = db.collection('Users_Lists');
			coll2.deleteMany({ _id: email }, (err, res) => {});
		});
	},

	UpdateTokenURL: function (connection, client, email, newTokenURL, cb) {
		connection.then(() => {
			const db = client.db('ShoppingLists');
			const coll = db.collection('Users');
			coll.updateOne(
                { _id: email },
                { $set: { deviceToken: newTokenURL } },
                function (err, res) {
                    cb(err, res);
                }
            );	
		});
	},

	FindUser: function(connection, client, email, cb) {
		connection.then(() => {
			const db = client.db('ShoppingLists');
			const coll = db.collection('Users');
			coll.findOne({ _id: email }, (err, res) => {
				cb(err, res);
			});
		});
	},

	//for testing purposes only -> prints all users in database
	ViewAllUsers: function(connection, client, cb) {
		connection.then(() => {
			const db = client.db('ShoppingLists');
			const coll = db.collection('Users');
			coll.find().toArray((err, result) => {
      			console.log(result);
   			});
		});
	},

	//Inserts a new list into 'Lists' database then also inserts the 'Host' into the 'Users_Lists' database.
	//will need to query the 'Users_Lists' collection looking for users in a paticular list and lists that a particular user uses.
	InsertNewList: function(connection, client, Host, ListName, cb) {
		connection.then(() => {
			ListUniqueName = Host.concat("-").concat(ListName);
        	const data = {
            	_id: ListUniqueName,
            	host: Host,
            	shoppingListName: ListName,
            	body: []
        	}
			const db = client.db('ShoppingLists');
			const coll = db.collection('Lists');
			coll.insertOne(data, (err, res) => {
				if (err) {

				} else {
					const data2 = {
						email: Host,
						listID: ListUniqueName
					}
					const coll2 = db.collection('Users_Lists');
					coll2.insertOne(data2, (err, res) => {
                		cb(err, res);
					});
				}
            });
		});
	},

	//Delete a list from database -> only the host can delete the list.
	DeleteList: function(connection, client, ListUniqueName, cb) {
		connection.then(() => {
			const db = client.db('ShoppingLists');
			const coll = db.collection('Lists'); 
			coll.deleteOne({ _id: ListUniqueName }, (err, res) => {
                cb(err, res);
            });
			
			const coll2 = db.collection('Users_Lists');
			coll2.deleteMany({ listID: ListUniqueName }, (err, res) => {});
		});
	},

	SendUserInviteRequest: function(connect, client, ListUniqueName, email, cb) {
		connection.then(() => {
			const db = client.db('ShoppingLists');
			const coll = db.collection('Users');
			coll.updateOne(
				{ _id: email },
				{ $push: { invites: ListUniqueName } },
				function (err, res) {
					cb(err, res);
				}
			);
		});	
	},

	RemoveUserInviteRequest: function(connect, client, email, ListUniqueName, cb) {
		connection.then(() => {
			const db = client.db('ShoppingLists');
			const coll = db.collection('Users');
			coll.updateOne(
				{ _id: email },
				{ $pull: { invites: ListUniqueName } },
				function (err, res) {
					cb(err, res);
				}
			);
		});
	},

	InsertUserToList: function(connection, client, ListUniqueName, email, cb) {
		connection.then(() => {
			data = {
				email: email,
				listID: ListUniqueName
			}
			const db = client.db('ShoppingLists');
			const coll = db.collection('Users_Lists');
			coll.insertOne(data, (err, res) => {
				cb(err, res);
			});
		});
	},

	//remove a user from a list -> either the host or the user can delete the user
	RemoveUserFromList: function(connection, client, ListUniqueName, email, cb) {
		connection.then(() => {
			const db = client.db('ShoppingLists');
			const coll = db.collection('Users_Lists');
			coll.deleteOne({ _id: email, listID: ListUniqueName }, (err, res) => {
			//coll.deleteOne({ _id: email }, (err, res) => {
                cb(err, res);
            });
		});	
	},

	//get all the lists that a user is a part of.
	GetListsForUser: function(connection, client, email, cb) {
		connection.then(() => {
			const db = client.db('ShoppingLists');
			const coll = db.collection('Users_Lists');
			var listOfLists = [];
			var num = 0;
			coll.find({ email: email }).toArray((err, result) => {
            	const obj = JSON.parse(JSON.stringify(result, null, 2));
				//console.log(obj);
				const coll2 = db.collection('Lists');
				for (const list of obj) {  
					//console.log(list);
					coll2.findOne({ _id: list.listID }, (err, res) => {
						curList = res;
						coll.find({ listID: list.listID }).toArray((err1, res1) => {
							const obj2 = JSON.parse(JSON.stringify(res1, null, 2));
							listOfUsers = [];
							for (const user of obj2) {
								listOfUsers.push(user.email);
							}
							res['Users'] = listOfUsers;
							//console.log(res);	

							listOfLists.push(res);
							num += 1;
							if (num == obj.length) {
                				cb(err, listOfLists);
							}
						});
					});
				}
				if (obj.length == 0) {
					cb(err, listOfLists);
				}
            });
		});
	},

	//get all the users that are a part of a list.
	GetUsersForList: function(connection, client, ListUniqueName, cb) {
		connection.then(() => {
            const db = client.db('ShoppingLists');
            const coll = db.collection('Users_Lists');
			coll.find({ listID: ListUniqueName }).toArray((err, result) => {
				const array = [];
				for (const user of result) {
					array.push(user.email);
				}
				cb(err, array);
			});
		});
	},

	//Inserts a new row into the body of a list.
	InsertRowIntoList: function(connection, client, uuid, ListUniqueName, NewBodyRow, email, cb) {
		const NewRow = {
        	id: uuid.v1(),
			email: email,
        	text: NewBodyRow
        }
		connection.then(() => {
			const db = client.db('ShoppingLists');
			const coll = db.collection('Lists');
			coll.updateOne(
				{ _id: ListUniqueName },
				{ $push: { Body: NewRow } },
				function (err, res) {
					cb(err, res);
   				}
			);
		});
	}, 
	
	InsertRowIntoListStringID: function(connection, client, uuid, ListUniqueName, NewBodyRow, email, cb) {
        const NewRow = {
            id: uuid,
            email: email,
            text: NewBodyRow
        }
        connection.then(() => {
            const db = client.db('ShoppingLists');
            const coll = db.collection('Lists');
            coll.updateOne(
                { _id: ListUniqueName },
                { $push: { Body: NewRow } },
                function (err, res) {
                    cb(err, res);
                }
            );
        });
    },

	DeleteRowFromList: function(connection, client, ListUniqueName, id, cb) {
		connection.then(() => {
            const db = client.db('ShoppingLists');
            const coll = db.collection('Lists');
            coll.updateOne(
                { _id: ListUniqueName },
				{ $pull: { Body: { id: id } } },
                function (err, res) {
                    cb(err, res);
                }
            );
        });
	},

	//for testing purposes only -> prints all lists in the database
    ViewAllLists: function(connection, client, cb) {
        connection.then(() => {
            const db = client.db('ShoppingLists');
            const coll = db.collection('Lists');
            coll.find().toArray((err, result) => {
				console.log(JSON.stringify(result, null, 2));
            });
        });
    },

	ViewUsersToLists: function(connection, client, cb) {
		connection.then(() => {
			const db = client.db('ShoppingLists');
			const coll = db.collection('Users_Lists');
			coll.find().toArray((err, result) => {
                console.log(result);
            });
		});
	},
	
	getList: function(connection, client, ListUniqueName, cb) {
		connection.then(() => {
			const db = client.db('ShoppingLists');
			const coll = db.collection('Lists');
			coll.findOne({ _id: ListUniqueName }, (err, res) => {
				const coll2 = db.collection('Users_Lists');
				coll2.find({ listID: ListUniqueName }).toArray((err1, res1) => {
					const obj = JSON.parse(JSON.stringify(res1, null, 2));
					listOfUsers = [];
					for (const user of obj) {
						listOfUsers.push(user.email);
					}
					var x = res;	
					console.log(ListUniqueName);
					console.log(x);
					x['Users'] = listOfUsers;
					console.log(x);
					cb(err, x);
				});
			});
		});
	},

	wipeAllThreeCollections: function(connection, client) {
		connection.then(() => {
			const db = client.db('ShoppingLists');
			const coll = db.collection('Lists');
			coll.remove( {}, true );
			const coll2 = db.collection('Users');
			coll2.remove( {}, true );
			const coll3 = db.collection('Users_Lists');
			coll3.remove( {}, true );
		});
	}

};



