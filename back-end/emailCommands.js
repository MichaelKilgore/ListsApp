require('dotenv').config()

const emailUsername = process.env.EMAIL
const emailPassword = process.env.EMAIL_PASSWORD

////////////ENUM///////////////
const { POST } = require('./ENUM')

//////////EMAIL SETUP///////////
var nodemailer = require("nodemailer");
var smtpTransport = nodemailer.createTransport({
    service: "hotmail",
    auth: {
        user: emailUsername,
        pass: emailPassword
    }
});
var mailOptions,host,link;

////////////FUNCTIONS//////////
async function newAccountMail(hostIP, email, verificationCode) {
	link="https://"+hostIP+"/verify?id="+verificationCode+"&email="+email;
   	mailOptions={
    	from: emailUsername,
       	to : email,
       	subject : "Please confirm your Email account",
     	html : "Hello,<br> Please Click on the link to verify your email.<br><a href="+link+">Click here to verify</a>"
 	}
   	const x = await smtpTransport.sendMail(mailOptions).then(result => POST.SUCCESS).catch(err => { POST.SERVER_ERROR })
	return x
}
exports.newAccountMail = newAccountMail

async function changePasswordMail(hostIP, randomCode, email) {
	const link = "https://"+hostIP+"/changePassword?id="+randomCode+"&email="+email;
	mailOptions={
      	from: emailUsername,
      	to: email,
       	subject: "Password Change Requested",
       	html: "Hello,<br> Please Click on the link to change your password.<br><a href="+link+">Click here to change</a>"
 	}
 	const resp = await smtpTransport.sendMail(mailOptions).then(result => POST.SUCCESS).catch(err => POST.SERVER_ERROR)
	return resp
}
exports.changePasswordMail = changePasswordMail






