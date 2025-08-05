// index.js

// Import necessary modules for Firebase Functions V1
const functions = require('firebase-functions');
const nodemailer = require('nodemailer');

// IMPORTANT: The environment variables are set using the old V1 method.
// Use the Firebase CLI to set them:
// firebase functions:config:set email.user="your_email_address" email.pass="your_email_password"
const transporter = nodemailer.createTransport({
    service: 'gmail', // or 'outlook', etc.
    auth: {
        user: functions.config().email.user, // Accessing V1 config
        pass: functions.config().email.pass,
    }
});

// A Firebase Function V1 triggered by an HTTPS callable request from the client app.
exports.sendReportEmail = functions.https.onCall((data, context) => {
    // Check for authentication. This is a good security practice.
    if (!context.auth) {
        throw new functions.https.HttpsError(
            'unauthenticated',
            'The function must be called while authenticated.'
        );
    }

    // Get data from the Flutter app
    const { name, email, mobileNumber, comment } = data;

    if (!name || !email || !mobileNumber || !comment) {
        throw new functions.https.HttpsError(
            'invalid-argument',
            'Missing required fields: name, email, mobileNumber, or comment.'
        );
    }

    // Build the email message
    const mailOptions = {
        from: functions.config().email.user,
        to: 'b09220002@student.unimy.edu.my',
        subject: 'Help and Support Report from Get Set Go App',
        html: `
            <h1>New Support Report</h1>
            <p><strong>Name:</strong> ${name}</p>
            <p><strong>Email:</strong> ${email}</p>
            <p><strong>Mobile Number:</strong> ${mobileNumber}</p>
            <p><strong>Comment:</strong></p>
            <p>${comment}</p>
        `,
    };

    // Send the email using Nodemailer
    return transporter.sendMail(mailOptions)
        .then(() => {
            console.log("Email sent successfully.");
            return { success: true, message: 'Report submitted successfully!' };
        })
        .catch(error => {
            console.error("Error sending email:", error);
            throw new functions.https.HttpsError(
                'internal',
                'Failed to send report.'
            );
        });
});
