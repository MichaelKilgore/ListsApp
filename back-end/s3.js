require('dotenv').config()
const fs = require('fs')
const S3 = require('aws-sdk/clients/s3')

const { POST, MSG } = require('./ENUM')

const bucketName = process.env.AWS_BUCKET_NAME
const region = process.env.AWS_BUCKET_REGION
const accessKeyId = process.env.AWS_ACCESS_KEY
const secretAccessKey = process.env.AWS_SECRET_KEY

const s3 = new S3({
	region,
	accessKeyId,
	secretAccessKey	
})


// uploads a file to s3
async function uploadFile(file, id) {
	const fileStream = fs.createReadStream(file.path)

	const uploadParams = {
		Bucket: bucketName,
		Body: fileStream,
		Key: id
	}

	const x = await s3.upload(uploadParams, function(err, data) {
		if (err) {
			console.log(err)
			return POST.SERVER_ERROR
		} else {
			return POST.SUCCESS
		}
	});
	return x
}
exports.uploadFile = uploadFile


// downloads a file from s3

function getFileStream(fileKey) {
	const downloadParams = {
		Key: fileKey,
		Bucket: bucketName
	}
	
	return s3.getObject(downloadParams).createReadStream().on('error', error => {
		console.log(error)
		console.log('error occurred')	
	});
	/*(s3.getObject(downloadParams, function(err, data) {
    	// Handle any error and exit
    	if (err) {
        	return err;
		}
		let objectData = data.Body.toString('utf-8'); // Use the encoding necessary
		return objectData;
	})*/

}
exports.getFileStream = getFileStream

async function deleteFile(id) {

	const params = {  
		Bucket: bucketName, 
		Key: id
	}

	const x = await s3.deleteObject(params, function(err, data) {
		if (err) {
			return POST.SERVER_ERROR 
		} else {
			return POST.SUCCESS
		}
	})
//.then(response => POST.SUCCESS).catch(err => POST.SERVER_ERROR)
	return x
}
exports.deleteFile = deleteFile





