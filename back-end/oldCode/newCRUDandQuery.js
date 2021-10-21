module.exports = {

	getListsForUser: function(connection, client, email, cb) {
        connection.then(() => {
            const db = client.db('ShoppingLists');
            const coll = db.collection('Users_Lists');
			const coll3 = db.collection('Users');
			var listOfLists = [];
            var num = 0;

			coll.find({ email: email }).toArray((err, result) => {
                const obj = JSON.parse(JSON.stringify(result, null, 2));
                const coll2 = db.collection('Lists');
                for (const list of obj) {
                    coll2.findOne({ _id: list.listID }, (err, res) => {
                        curList = res;
                        coll.find({ listID: list.listID }).toArray((err1, res1) => {
                            const obj2 = JSON.parse(JSON.stringify(res1, null, 2));
                            listOfUsers = [];
							var num2 = 0;
                            for (const user of obj2) {

								coll3.findOne({ _id: user.email }, (err, userRes) => {
									listOfUsers.push({'email': userRes._id, 'username': userRes.username });
									num2 += 1
									if (num2 == obj2.length) {
										curList['users'] = listOfUsers;
										
										listOfLists.push(curList);
										console.log(curList);
										num += 1;
										if (num == obj.length) {
											cb(err, listOfLists);
										}
									}									

								});

                            }
                        });
                    });
                }
                if (obj.length == 0) {
					console.log("no lists found");
                    cb(err, listOfLists);
                }
            });		
		});
	},

	insertUser: function (connection, client, email, username, password, rand, cb) {
        connection.then(() => {
            const data = {
                _id: email,
                username: username,
                password: password,
                deviceToken: "",
                invites: [],
                active: false,
                verificationCode: rand,
				changePasswordCode: ""
            }
            const db = client.db('ShoppingLists');
            const coll = db.collection('Users');
            coll.insertOne(data, (err, res) => {
                cb(err, res);
            });
        });
    },

	findUser: function(connection, client, email, cb) {
        connection.then(() => {
            const db = client.db('ShoppingLists');
            const coll = db.collection('Users');
            coll.findOne({ _id: email }, (err, res) => {
                cb(err, res);
            });
        });
    },
	
	activateUser: function(connection, client, email, cb) {
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

	updateTokenURL: function (connection, client, email, newTokenURL, cb) {
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
    },

	setPasswordChangeCode: function(connection, client, email, code, cb) {
		connection.then(() => {
			const db = client.db('ShoppingLists');
			const coll = db.collection('Users');
			coll.updateOne(
				{ _id: email },
				{ $set: { changePasswordCode: code } },
				function(err, res) {
					cb(err, res);
				}
			);
		});
	},

	changePassword: function(connection, client, email, newPassword, cb) {
		connection.then(() => {
			const db = client.db('ShoppingLists');
			const coll = db.collection('Users');
			coll.updateOne(
				{ _id: email },
				{ $set: { 
					password: newPassword,
					changePasswordCode: ""
				} },
				function(err, res) { 
					cb(err, res);
				} 
			);
		});
	},

	viewAllUsers: function(connection, client, cb) {
        connection.then(() => {
            const db = client.db('ShoppingLists');
            const coll = db.collection('Users');
            coll.find().toArray((err, result) => {
                console.log(result);
            });
        });
    },

	changeUsername: function(connection, client, email, newUsername, cb) {
		connection.then(() => {
			const db = client.db('ShoppingLists');
			const coll = db.collection('Users');
			coll.updateOne(
				{ _id: email },
				{ $set: {
					username: newUsername
				} },
				function(err, res) {
					cb(err, res);
				}
			);
			
			//TODO: PUSHKIT -> user x changed their username.
		});
	},

	insertNewList(connection, client, email, listName, uuid, cb) {
		connection.then(() => {
            listID = uuid.v1();
            const data = {
                _id: listID,
                host: email,
                shoppingListName: listName,
                body: []
            }
            const db = client.db('ShoppingLists');
            const coll = db.collection('Lists');
            coll.insertOne(data, (err, res) => {
                if (err) {

                } else {
                    const data2 = {
                        email: email,
                        listID: listID
                    }
                    const coll2 = db.collection('Users_Lists');
                    coll2.insertOne(data2, (err, res2) => {
                        cb(err, listID.toString());
                    });
                }
            });
        });
	},

	getUsersForList: function(connection, client, listID, cb) {
        connection.then(() => {
            const db = client.db('ShoppingLists');
            const coll = db.collection('Users_Lists');
            coll.find({ listID: listID }).toArray((err, result) => {
                const array = [];
                for (const user of result) {
                    array.push(user.email);
                }
                cb(err, array);
            });
        });
    },

	getListHost: function(connection, client, listID, cb) {
		connection.then(() => {
			const db = client.db('ShoppingLists');
			const coll = db.collection('Lists');
			coll.findOne({ _id: listID }, (err, res) => {
				cb(err, res.host);
			});
		});
	},
	
	getList: function(connection, client, listID, cb) {
		connection.then(() => {
			const db = client.db('ShoppingLists');
			const coll = db.collection('Lists');
			coll.findOne({ _id: listID }, (err, res) => {
				cb(err, res.body);
			});
		});
	},

	removeUserFromList: function(connection, client, listID, email, cb) {
        connection.then(() => {
            const db = client.db('ShoppingLists');
            const coll = db.collection('Users_Lists');
            coll.deleteOne({ email: email, listID: listID }, (err, res) => {
                cb(err, res);
            });
        });
    },

	deleteList: function(connection, client, listID, cb) {
        connection.then(() => {
            const db = client.db('ShoppingLists');
            const coll = db.collection('Lists');
            coll.deleteOne({ _id: listID }, (err, res) => {
                cb(err, res);
            });

            const coll2 = db.collection('Users_Lists');
            coll2.deleteMany({ listID: listID }, (err, res) => {});
        });
    },

	changeListHost: function(connection, client, newHost, listID, cb) {
		connection.then(() => {
			const db = client.db('ShoppingLists');
			const coll = db.collection('Lists');
			coll.updateOne(
                { _id: listID },
                { $set: {
                    host: newHost
                } },
                function(err, res) {
                    cb(err, res);
                }
            );
		});
	},
	
	removeUserFromList: function(connection, client, listID, email, cb) {
        connection.then(() => {
            const db = client.db('ShoppingLists');
            const coll = db.collection('Users_Lists');
            coll.deleteOne({ _id: email, listID: listID }, (err, res) => {
                cb(err, res);
            });
        });
    },

	viewAllLists: function(connection, client, cb) {
        connection.then(() => {
            const db = client.db('ShoppingLists');
            const coll = db.collection('Lists');
            coll.find().toArray((err, result) => {
                console.log(JSON.stringify(result, null, 2));
            });
        });
    },

    viewUsersToLists: function(connection, client, cb) {
        connection.then(() => {
            const db = client.db('ShoppingLists');
            const coll = db.collection('Users_Lists');
            coll.find().toArray((err, result) => {
                console.log(result);
            });
        });
    },

	//TODO: Will a user modifying their username be a pain in the ass? Cause they might have to let other users know of this.
	// probably not that big of a deal and will mostly go unnoticced. 
	insertListItem(connection, client, id, listID, text, email, username, hyperLink, containsImage, cb) {
        const newItem = {
            id: id,
            user: {
				email: email,
				username: username
			},
            text: text,
			hyperLink: hyperLink,
			containsImage: containsImage
        }
        connection.then(() => {
            const db = client.db('ShoppingLists');
            const coll = db.collection('Lists');
            coll.updateOne(
                { _id: listID },
                { $push: { body: newItem } },
                function (err, res) {
                    cb(err, res);
                }
            );
        });
    },

	clearDeviceToken(connection, client, email, cb) {
		connection.then(() => {
            const db = client.db('ShoppingLists');
            const coll = db.collection('Users');
            coll.updateOne(
                { _id: email },
                { $set: {
                    deviceToken: ""
                } },
                function(err, res) {
                    cb(err, res);
                }
            );
        });
	},
	
	deleteListItem(connection, client, email, listID, bodyID, cb) {
		connection.then(() => {
            const db = client.db('ShoppingLists');
            const coll = db.collection('Lists');
            coll.updateOne(
                { _id: listID },
                { $pull: { body: { id: bodyID } } },
                function (err, res) {
                    cb(err, res);
                }
            );
        });
	},

	inviteUser(connection, client, email, listID, listName, cb) {
		connection.then(() => {
            const db = client.db('ShoppingLists');
            const coll = db.collection('Users');
            coll.updateOne(
                { _id: email },
                { $push: { invites: {"listID": listID, "listName": listName } } },
                function (err, res) {
                    cb(err, res);
                }
            );
        });	
	},

	removeInviteRequest(connection, client, email, listID, cb) {
		connection.then(() => {
            const db = client.db('ShoppingLists');
            const coll = db.collection('Users');
            coll.updateOne(
                { _id: email },
                { $pull: { invites: {"listID": listID } } },
                function (err, res) {
                    cb(err, res);
                }
            );
        });
	},
		
	addUserToList(connection, client, email, listID, cb) {
		connection.then(() => {
            data = {
                email: email,
                listID: listID
            }
            const db = client.db('ShoppingLists');
            const coll = db.collection('Users_Lists');
            coll.insertOne(data, (err, res) => {
                cb(err, res);
            });
        });
	},

	updateItem(connection, client, listID, bodyID, text, hyperLink, cb) {
		connection.then(() => {
            const db = client.db('ShoppingLists');
            const coll = db.collection('Lists');
            coll.updateOne(
                { _id: listID, "body.id": bodyID },
                { $set: { body: { text: text, hyperLink: hyperLink } } },
                function (err, res) {
                    cb(err, res);
                }
            );
        });
	},

	viewUsersToLists: function(connection, client, cb) {
        connection.then(() => {
            const db = client.db('ShoppingLists');
            const coll = db.collection('Users_Lists');
            coll.find().toArray((err, result) => {
                console.log(result);
            });
        });
    }

};












