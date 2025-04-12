import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as sgMail from '@sendgrid/mail';
import axios from 'axios';

admin.initializeApp();
sgMail.setApiKey(functions.config().sendgrid.key);

export const sendPaymentEmail = functions.https.onRequest(async (req, res) => {
  try {
    const { email, eventName, imageBase64, amount, paymentId } = req.body;

    const msg = {
      to: email,
      from: 'your-verified-sender@yourdomain.com',
      subject: `Payment Proof - ${eventName}`,
      text: `New payment proof received for ${eventName}. Amount: $${amount}`,
      attachments: [{
        content: imageBase64,
        filename: 'payment_proof.jpg',
        type: 'image/jpeg',
        disposition: 'attachment'
      }]
    };

    await sgMail.send(msg);
    res.status(200).send('Email sent successfully');
  } catch (error) {
    res.status(500).send(error.message);
  }
});

export const sendWhatsAppMessage = functions.https.onRequest(async (req, res) => {
  try {
    const { phone, eventName, imageBase64, amount, paymentId } = req.body;
    const whatsappApiUrl = 'https://graph.facebook.com/v17.0/YOUR_PHONE_NUMBER_ID/messages';

    const response = await axios.post(whatsappApiUrl, {
      messaging_product: "whatsapp",
      recipient_type: "individual",
      to: phone,
      type: "template",
      template: {
        name: "payment_proof",
        language: { code: "en" },
        components: [
          {
            type: "header",
            parameters: [
              {
                type: "image",
                image: {
                  link: `data:image/jpeg;base64,${imageBase64}`
                }
              }
            ]
          },
          {
            type: "body",
            parameters: [
              { type: "text", text: eventName },
              { type: "text", text: amount.toString() }
            ]
          }
        ]
      }
    }, {
      headers: {
        'Authorization': `Bearer ${functions.config().whatsapp.token}`,
        'Content-Type': 'application/json'
      }
    });

    res.status(200).json(response.data);
  } catch (error) {
    res.status(500).send(error.message);
  }
});
