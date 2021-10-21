////////SERVER SET UP//////////////////
var bodyParser = require('body-parser');

const express = require('express');

const app = express();

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

const bcrypt = require ('bcrypt');
crypto = require('crypto');

var uuid = require('uuid');

var multer  = require('multer')

var storage = multer.diskStorage({
    destination: function (req, file, cb) {
      cb(null, './uploads')
    },
    filename: function (req, file, cb) {
      cb(null, file.originalname)
    }
})
var upload = multer({ storage: storage })

var type = upload.single('image');

/////////ENUM///////////////////
const MSG = Object.freeze({
	INVITE_REQUEST: 0,
    USER_JOINS_LIST: 1,
    USER_LEAVES_LIST: 2,
    NEW_BODY_ITEM: 3,
    REMOVE_BODY_ITEM: 4,
    EDIT_BODY_ITEM: 5,
    LOGOUT: 6
});

const POST = Object.freeze({
	SUCCESS: 0,
    INVALID_LOGIN: 1,
    INVALID_REQUEST: 2,
    SERVER_ERROR: 3
});

////////S3//////////////////
const { uploadFile, getFileStream, deleteFile } = require('./s3')

const util = require('util')
const unlinkFile = util.promisify(fs.unlink)


/////////MONGODB//////////////////
var CRUD = require('./newCRUDandQuery');

const MongoClient = require('mongodb').MongoClient;
const uri = 'mongodb://127.0.0.1:27017';
const client = new MongoClient(uri);
connection = client.connect();
var uuid = require('uuid');

////////PUSHKIT/////////////////////
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

//////EMAIL///////////////////
var nodemailer = require("nodemailer");

var smtpTransport = nodemailer.createTransport({
    service: "hotmail",
    auth: {
        user: "lists.app1234@outlook.com",
        pass: "Montero17$"
    }
});

var rand,mailOptions,host,link;

//////ALL SERVER REQUEST HANDLING////

app.post('/createNewUser', (req, res) => {
	console.log("Creating new user.")
	rand = crypto.randomBytes(64).toString('hex');
	saltRounds = 10;
	bcrypt.hash(req.body.password, saltRounds, function(err, hash) {
		CRUD.insertUser(connection, client, req.body.email, req.body.username, hash, rand, (err, result) => {
			if (err) {
				res.send({'response': POST.INVALID_REQUEST});
			} else {
				//send email to req.email to verify user.
            	host=req.get('host');
            	link="https://"+req.get('host')+"/verify?id="+rand+"&email="+req.body.email;
            	mailOptions={
                	from: "lists.app1234@outlook.com",
                	to : req.body.email, // change to req.email
                	subject : "Please confirm your Email account",
                	html : "Hello,<br> Please Click on the link to verify your email.<br><a href="+link+">Click here to verify</a>"
            	}
            	smtpTransport.sendMail(mailOptions, function(error, resp) {
                	if (error) {
                    	console.log(error);
                	} else {
                    	//console.log("Message sent: " + resp.response);
                	}
            	});
				res.send({'response': POST.SUCCESS});
			}
		}); //: CRUD INSERT
	}); //: BCRYPT
})

app.get('/verify', function(req,res) {
	CRUD.findUser(connection, client, req.query.email, (err, result) => {
		if (!err) {
    		if(req.query.id==result.verificationCode) {
        		res.end("<h1>Email "+req.query.email+" has been Successfully verified");
				CRUD.activateUser(connection, client, req.query.email, (err, res) => {});
			} else {
				res.end("<h1>Code given was incorrect</h1");
			}
    	} else {
        	res.end("<h1>Bad Request</h1>");
    	}
	});
})

app.post('/login', async function(req,res) {
	await client
	CRUD.findUser(connection, client, req.body.email, (err, userInfo) => {
		if (userInfo != null) {
				bcrypt.compare(req.body.password, userInfo.password, function(err, credentialsMatch) {
					if (credentialsMatch && userInfo.active) {
						CRUD.getListsForUser(connection, client, req.body.email, (err , listsForUser) => {
							const data = {
								userInfo: {
									email: req.body.email,
									username: userInfo.username,
									password: userInfo.password,
									deviceToken: req.body.deviceToken,
									invites: userInfo.invites
										},
								lists: listsForUser
							}
							res.send(data);
						});

						CRUD.updateTokenURL(connection, client, req.body.email, req.body.deviceToken, (err, res) => { });
					} else {
						console.log(req.body.email + " failed to login");
						res.send('failure');
					}	
				});
		} else {
			console.log('wtf');
			res.send('failure');
		}

	});
})

app.get('/forgotPassword', function(req, res) {
	CRUD.findUser(connection, client, req.query.email, (err, userInfo) => {
        if (!err && userInfo.active) {
            rand = crypto.randomBytes(64).toString('hex');
            host = req.get('host');
            console.log(req.query.email);
            link = "https://"+host+"/changePassword?id="+rand+"&email="+req.query.email;
            CRUD.setPasswordChangeCode(connection, client, req.query.email, rand, (err2, didWork) => {
                if (!err2) {
                    mailOptions={
                        from: "lists.app1234@outlook.com",
                        to: req.query.email,
                        subject: "Password Change Requested",
						html: "Hello,<br> Please Click on the link to change your password.<br><a href="+link+">Click here to change</a>"
                    }
                    smtpTransport.sendMail(mailOptions, function(error, resp) {
                        if (error) {
                            console.log(error);
                        } else {

                        }
                    });
					res.send({'response': POST.SUCCESS});
                }
            });
        } else {
			if (userInfo.active) {
				res.send({'response': POST.SERVER_ERROR});	
			} else {
				res.send({'response': POST.INVALID_LOGIN});
			}
		}
    });	
})

app.get('/changePassword', function(req, res) {
	res.send('<form method="POST"><label for="newPassword">New Password:</label><br><input type="text" id="newPassword" name="newPassword"><br><input type="submit" value="Submit"></form>')
})

app.post('/changePassword', function(req, res) {
	CRUD.findUser(connection, client, req.query.email, (err, userInfo) => {
		if (!err && userInfo.active) {
			if (userInfo.changePasswordCode == req.query.id) {
				//Salt and crypt	
				saltRounds = 10;
    			bcrypt.hash(req.body.newPassword, saltRounds, function(err, hash) {
					CRUD.changePassword(connection, client, req.query.email, hash, (err3, res3) => {
						if (!err3) {
							res.end("<h1>Password has been successfully reset.</h1>");
						} else {
							res.end("<h1>Bad Request</h1>");	
						}
					});
				});
			} else {
				res.end("<h1>invalid code given.</h1>");
			} 
		} else {
			res.end("<h1>Bad Request</h1>");
		}
	});
})

app.post('/changeUsername', function(req, res) {
	CRUD.findUser(connection, client, req.body.email, (err, userInfo) => {
		if (!err) {
			bcrypt.compare(req.body.password, userInfo.password, function(err, credentialsMatch) {
				if (!err && userInfo.active && credentialsMatch) {
				
					//find all lists and update username in list of users.

					//TODO: send silent pushkit to users that user changed their username
					
	
					CRUD.changeUsername(connection, client, req.body.email, req.body.username, (err2, res2) => {
						if (!err2) {
							res.send({'response': POST.SUCCESS});
						} else {
							res.send({'response': POST.SERVER_ERROR});
						}
					});
				} else {
					if (userInfo.active) {
                		res.send({'response': POST.SERVER_ERROR});
            		} else {
                		res.send({'response': POST.INVALID_LOGIN});
            		}	
				}
			});
		} else {
			res.send({'response': POST.SERVER_ERROR});
		}
	});
})
	
app.post('/createNewList', function(req, res) {
	console.log('Creating New List');
	console.log(req.body.email);
	console.log(req.body.password);
	console.log(req.body.listName);
	CRUD.findUser(connection, client, req.body.email, (err, userInfo) => {
		if (!err) {
			bcrypt.compare(req.body.password, userInfo.password, function(err, credentialsMatch) {
				if (!err && userInfo.active && credentialsMatch) {
					CRUD.insertNewList(connection, client, req.body.email, req.body.listName, uuid, (err2, res2) => {
						if (!err2) {
							console.log(res2);
							res.send({'listID': res2, resp: POST.SUCCESS});
						} else {
							res.send('failure');
						}
					});
				} else {
					res.end("Bad Request");
				}
			});
		} else {
			res.end("Bad Request");
		}
	});
})

app.post('/deleteList', function(req, res) {
	CRUD.findUser(connection, client, req.body.email, (err, userInfo) => {
		if (!err) {
			bcrypt.compare(req.body.password, userInfo.password, function(err, credentialsMatch) {
				if (!err && userInfo.active && credentialsMatch) {
					CRUD.getUsersForList(connection, client, req.body.listID, (err, users) => {
        				if (users.length != 1) {
            				firstUser = true
            				nextHost = ""
            				CRUD.getListHost(connection, client, req.body.listID, (err, host) => {
                				for (const user of users) {
                    				if (host == req.body.email && firstUser == true) {
                        				if (host != user) {
                            				firstUser = false
                            				nextHost = user
											changeListHost(connection, client, newHost, req.body.listID, (err, res) => {});
                        				}
                    				}
                				} //: FOR
								

                				for (const user of users) {
                    				let deviceToken = res.deviceToken;

                    				var note = new apn.Notification();

                    				note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
                    				note.badge = 3;
                    				note.sound = "ping.aiff";
                    				note.topic = "Michael.ShoppingLists";

                    				//hopefully i don't need an alert? idk.
                    				//note.alert = obj.email + " joined " + obj.ListUniqueName.split("-")[0]

                    				note.payload = {
                        				'userRemoved': user,
                        				'newHost': nextHost,
                    				}
                    				apnProvider.send(note, deviceToken).then( (result) => {
                        				console.log("list deletion called.");
                    				});
                				} //: FOR
            				});
							res.end({'response': POST.SUCCESS});

							CRUD.removeUserFromList(connection, client, req.body.listID, email, (err, res) => {});
						} else { //delete list.
							//we also need to delete all items in list from node
							//deleteFile(id, cb) {
							CRUD.getList(connection, client, req.body.listID, (err, res) => {
								for (const item in res) {
									if (item.containsImage == true) {
										deleteFile(item.id, (err, res) => {

										});
									}
								}
							});

                            CRUD.deleteList(connection, client, req.body.listID, (err, res) => {
								console.log("inside list deletion.");
								console.log(res);
							});
							
                        }
                    });
                } else {
					if (userInfo.active) {
                        res.end({'response': POST.SERVER_ERROR});
                    } else {
                        res.end({'response': POST.INVALID_LOGIN});
                    }	
				}
            });
		} else {
			res.end({'response': POST.SERVER_ERROR});
		}
	});
})

app.get('/getImage', function(req, res) {
	const key = req.query.id
	console.log("image requested with id: ", key);
	const readStream = getFileStream(key);
	
	//TypeError: Cannot read property 'pipe' of undefined

	readStream.pipe(res);
})

//body.user = { username: mkilgore2000, email: mkilgore2000@gmail.com }
app.post('/addListItemWithImage', type, async function(req, res) {

	CRUD.findUser(connection, client, req.body.email, (err, userInfo) => {
        if (!err) {
            bcrypt.compare(req.body.password, userInfo.password, function(err, credentialsMatch) {
                if (!err && userInfo.active && credentialsMatch) {
					itemID = uuid.v1();
    				//{ path: email/uuid, id: uuid }
    				const file = req.file
    				console.log(file);
    				//const result = await uploadFile(file, req.body.email, itemID);
    				//await unlinkFile(file.path);
					//await uploadFile(file, req.body.email, itemID);
					uploadFile(file, itemID, (err, data) => {
						unlinkFile(file.path);
    					const path = itemID;
    					res.send({'path': path, 'id': itemID});
					});
					console.log('inserting item into list with id: ', req.body.listID);
    				CRUD.insertListItem(connection, client, itemID, req.body.listID, req.body.text, req.body.email, req.body.username, req.body.hyperLink, true, (err, res) => { });	
				} else {
					res.send('failure');
				}
			})
		} else {
			res.send('failure');
		}
	});
})

app.post('/addListItem', function(req, res) {
	CRUD.findUser(connection, client, req.body.email, (err, userInfo) => {
        if (!err && userInfo != null) {
            bcrypt.compare(req.body.password, userInfo.password, function(err, credentialsMatch) {
                if (!err && userInfo.active && credentialsMatch) {
					itemID = uuid.v1();
					res.send({'path': '', 'id': itemID});
					CRUD.insertListItem(connection, client, itemID, req.body.listID, req.body.text, req.body.email, req.body.username, req.body.hyperLink, false, (err, res) => {

                    });
				}
			});
		}
	});
	
})

app.post('/clearDeviceToken', function(req, res) {
	CRUD.findUser(connection, client, req.body.email, (err, userInfo) => {
        if (!err && userInfo != null) {
            bcrypt.compare(req.body.password, userInfo.password, function(err, credentialsMatch) {
                if (!err && userInfo.active && credentialsMatch) {	
					CRUD.clearDeviceToken(connection, client, req.body.email, (err, res2) => {
						res.send({'response':POST.SUCCESS});
					});
				} else {
					if (userInfo.active) {
                        res.send({'response':POST.SERVER_ERROR});
                    } else {
                        res.send({'response':POST.INVALID_LOGIN});
                    }
				}
			});
		} else {
			res.send({'response':POST.SERVER_ERROR});
		}
	});
});

app.post('/deleteListItem', function(req, res) {
	console.log('in the delete list item');
	CRUD.findUser(connection, client, req.body.email, (err, userInfo) => {
        if (!err && userInfo != null) {
            bcrypt.compare(req.body.password, userInfo.password, function(err, credentialsMatch) {
                if (!err && userInfo.active && credentialsMatch) {
                    CRUD.deleteListItem(connection, client, req.body.email, req.body.listID, req.body.bodyID, (err, res2) => {
						if (!err) {
							res.send({'response':POST.SUCCESS});
						} else {
							res.send({'response':POST.SERVER_ERROR});
						}
                    });
                } else {
					res.send({'response':POST.SERVER_ERROR});
                }
            });
        } else {
			if (userInfo.active) {
            	res.send({'response':POST.SERVER_ERROR});
         	} else {
           		res.send({'response':POST.INVALID_LOGIN});
          	}
        }

		if (userInfo.containsImage) {
			//delete from s3
			deleteFile(req.body.bodyID, (err, res) => {
        	});
		}

    });
});

app.post('/inviteUser', function(req, res) {
	CRUD.findUser(connection, client, req.body.email, (err, userInfo) => {
        if (!err && userInfo != null) {
            bcrypt.compare(req.body.password, userInfo.password, function(err, credentialsMatch) {
                if (!err && userInfo.active && credentialsMatch) {
                    CRUD.inviteUser(connection, client, req.body.invitedUser, req.body.listID, req.body.listName, (err, res2) => {
                        if (!err) {
							res.send({'response':POST.SUCCESS});

							//send pushkit notification to user
							CRUD.findUser(connection, client, req.body.invitedUser, (err, invitedUserInfo) => {
								let deviceToken = invitedUserInfo.deviceToken;

                            	var note = new apn.Notification();

                            	note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
                       			note.badge = 3;
                         		note.sound = "ping.aiff";
                           		note.topic = "Michael.ShoppingLists";

                       			//hopefully i don't need an alert? idk.
                          		note.alert = "You were invited to join the " + req.body.listName + " by " +  userInfo.username + "."

                          		note.payload = {
                             		'msg': MSG.INVITE_REQUEST,
                               		'listID': req.body.listID,
									'listName': req.body.listName
                           		}
                          		apnProvider.send(note, deviceToken).then( (result) => {
                              		console.log("list deletion called.");
                           		});
							});

                        } else {
							res.send({'response':POST.SERVER_ERROR});
                        }
                    });
                } else {
					if (userInfo.active) {
                        res.send({'response':POST.SERVER_ERROR});
                    } else {
                        res.send({'response':POST.INVALID_LOGIN});
                    }
                }
            });
        } else {
			res.send({'response':POST.SERVER_ERROR});
        }
    });
});

app.post('/acceptInvite', function(req, res) {
	CRUD.findUser(connection, client, req.body.email, (err, userInfo) => {
        if (!err && userInfo != null) {
            bcrypt.compare(req.body.password, userInfo.password, function(err, credentialsMatch) {
                if (!err && userInfo.active && credentialsMatch) {
				
					CRUD.removeInviteRequest(connection, client, req.body.email, req.body.listID, (err2, res2) => { });
					CRUD.addUserToList(connection, client, req.body.email, req.body.listID, (err3, res3) => {
						if (!err3) {
							res.send({'response':POST.SUCCESS});
						} else {
							res.send({'response':POST.SERVER_ERROR});
						}
					});

                } else {
					res.send({'response':POST.SERVER_ERROR});
                }
            });
        } else {
			if (userInfo.active) {
            	res.send({'response':POST.SERVER_ERROR});
           	} else {
               	res.send({'response':POST.INVALID_LOGIN});
          	}	
        }
    });
});

app.post('/declineInvite', function(req, res) {
	CRUD.findUser(connection, client, req.body.email, (err, userInfo) => {
        if (!err && userInfo != null) {
            bcrypt.compare(req.body.password, userInfo.password, function(err, credentialsMatch) {
                if (!err && userInfo.active && credentialsMatch) {

                    CRUD.removeInviteRequest(connection, client, req.body.email, req.body.listID, (err, res) => {
                        if (!err) {
							res.send({'response':POST.SUCCESS});
                        } else {
							res.send({'response':POST.SERVER_ERROR});
                        }
                    });

                } else {
					if (userInfo.active) {
                        res.send({'response':POST.SERVER_ERROR});
                    } else {
                        res.send({'response':POST.INVALID_LOGIN});
                    }
                }
            });
        } else {
			res.send({'response':POST.SERVER_ERROR});
        }
    });
});
	
app.post('/updateItem', function(req, res) {
	CRUD.findUser(connection, client, req.body.email, (err, userInfo) => {
        if (!err && userInfo != null) {
            bcrypt.compare(req.body.password, userInfo.password, function(err, credentialsMatch) {
                if (!err && userInfo.active && credentialsMatch) {

	    			CRUD.updateItem(connection, client, req.body.listID, req.body.bodyID, req.body.text, req.body.hyperLink, (err, res) => {});

                } else {
					if (userInfo.active) {
                        res.send({'response':POST.SERVER_ERROR});
                    } else {
                        res.send({'response':POST.INVALID_LOGIN});
                    }
                }
            });
        } else {
			res.send({'response':POST.SERVER_ERROR});
        }
    });
});

app.post('/updateItemWithImage', type, async function(req, res) {
	CRUD.findUser(connection, client, req.body.email, (err, userInfo) => {
        if (!err && userInfo != null) {
            bcrypt.compare(req.body.password, userInfo.password, function(err, credentialsMatch) {
                if (!err && userInfo.active && credentialsMatch) {

                    CRUD.updateItem(connection, client, req.body.listID, req.body.bodyID, req.body.text, req.body.hyperLink, (err, res) => {});
					const file = req.file;
					deleteFile(req.body.bodyID, (err, res) => {
						uploadFile(file, req.body.bodyID, (err, data) => {
							unlinkFile(file.path);
							res.send({'response':POST.SUCCESS});
						});
					});
					

                } else {
					if (userInfo.active) {
                        res.send({'response':POST.SERVER_ERROR});
                    } else {
                        res.send({'response':POST.INVALID_LOGIN});
                    }
                }
            });
        } else {
			res.send({'response':POST.SERVER_ERROR});
        }
    });
});

sslServer.listen(6311, () => {
	console.log('Secure server listening on port 6311.')
})



