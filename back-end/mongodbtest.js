var CRUD = require('./oldCode/newCRUDandQuery');

const MongoClient = require('mongodb').MongoClient;
const uri = 'mongodb://127.0.0.1:27017';
const client = new MongoClient(uri);
connection = client.connect();
var uuid = require('uuid');

//CRUD.InsertUserToList(connection, client, 'michael.kilgore@gmail.com-my birthday', 'jason.momo@gmail.com', (err, res) => {
//CRUD.RemoveUserFromList(connection, client, 'michael.kilgore@gmail.com-my birthday', 'jason.momo@gmail.com', (err, res) => {
//CRUD2.DeleteUser(connection, client, 'kilgomic@uw.edu', (err, res) => {
//CRUD.DeleteList(connection, client, 'michael.kilgore@gmail.com-shopping list', (err, res) => {
//CRUD.RemoveUserFromList(connection, client, 'jesse.kilgore@gmail.com-Shopping List', 'jesse.kilgore@gmail.com', (err, res) => {
//CRUD.InsertUser(connection, client, 'michael.kilgore@gmail.com', 'michael', 'kilgore', 'yeet', 'idek.com', (err, res) => {
//CRUD.findUser(connection, client, 'mkilgore2000@gmail.com', (err, res) => {
	//console.log(res);
//CRUD.UpdateTokenURL(connection, client, 'michael.kilgore@gmail.com', 'itworked.com', (err, res) => {
//CRUD.InsertNewList(connection, client, 'mkilgore2000@gmail.com', 'shopping list', (err, res) => {

//});
//CRUD.RemoveUserInviteRequest(connection, client, 'jason.momo@gmail.com', 'michael.kilgore@gmail.com-my birthday', (err, res) => {
//CRUD.SendUserInviteRequest(connection, client, 'michael.kilgore@gmail.com-my birthday', 'jason.momo@gmail.com', (err, res) => {
//CRUD.InsertRowIntoList(connection, client, uuid, 'mkilgore2000@gmail.com-shopping list', 'Need sushi', 'michael.kilgore@gmail.com', (err, res) => {
//CRUD.DeleteRowFromList(connection, client, 'michael.kilgore@gmail.com-my birthday', 'd10fbf60-e432-11eb-862e-0be2288c6a4d', (err, res) => {
//CRUD.getListsForUser(connection, client, 'mkilgore2000@gmail.com', (err, res) => {
//	console.log(res);
//CRUD.GetUsersForList(connection, client, 'mkilgore2000@gmail.com-shopping list', (err, res) => {
//CRUD.getList(connection, client, 'mkilgore2000@gmail.com-shopping list', (err, res) => {
	//console.log('working');
	//console.log(res);
	//var x = res;
	//x['Users'] = [];
	//console.log(x);
	//console.log(data);
	//console.log(res);
	CRUD.viewAllUsers(connection, client, (err, res) => {});
	//CRUD.wipeAllThreeCollections(connection, client);
	CRUD.viewAllLists(connection, client, (err, res) => { });
    CRUD.viewUsersToLists(connection, client, (err, res) => {});
//});

/*CRUD.DeleteRowFromList(connection, client, 'jesse.kilgore@gmail.com-Shopping List', 'f72b7830-dbca-11eb-b6d8-1b48d6c89c6f', (err, res) => {
	CRUD.ViewAllLists(connection, client, (err, res) => {});	
});*/


/*connection.then(() => {
	const db = client.db('ShoppingLists');
    const coll = db.collection('Lists');
    coll.updateOne(
    	{ _id: 'jesse.kilgore@gmail.com-Shopping List' },
        { $pop: { Body: -1} },
        function (err, res) {
			CRUD.ViewAllLists(connection, client, (err, res) => {});
		}
    );
});*/
/*connection.then(() => {
	const db = client.db('ShoppingLists');
	const coll = db.collection('Users');
	coll.deleteOne({ password: 'jesse' }, (err, res) => {});
});*/

//CRUD.ViewAllUsers(connection, client, (err, res) => {});
//CRUD.ViewAllLists(connection, client, (err, res) => {});




