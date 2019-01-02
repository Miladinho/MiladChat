const functions = require('firebase-functions')
const admin = require('firebase-admin')

admin.initializeApp()


exports.sendChatNotification = functions.firestore.document('channels/main/thread/{thread}').onCreate((snap, context) => {
	var messageObject = snap.data()
	console.log(messageObject.content)
	const payload = {
		notification: {
			title: `${messageObject.senderName} @ Shadow LA`,
			body: messageObject.content,
			sound: "default"
		}
	}
	const options = {
		priority: "high",
		timeToLive: 60 * 60 * 24
	}
	return admin.messaging().sendToTopic("pushNotifications", payload, options)
})