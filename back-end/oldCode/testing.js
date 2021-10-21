const MongoClient = require('mongodb').MongoClient;
const uri = 'mongodb://127.0.0.1:27017';
const client = new MongoClient(uri);
//connection = client.connect();



		async function run() {
			await client.connect();
            const db = client.db('ShoppingLists');
            const coll = db.collection('Users_Lists');
            const coll3 = db.collection('Users');
            var listOfLists = [];
            var num = 0;

			const result = await coll.find({ email: 'mkilgore2000@gmail.com' }).toArray();
			
			console.log(result);
			console.log('hello');

		}
	
		run();

	

            /*coll.find({ email: email }).toArray((err, result) => {
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
            });*/


