require('dotenv').config();

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const sharp = require("sharp");
const fs = require("fs");
const path = require("path");


admin.initializeApp({
    storageBucket: process.env.STORAGE_BUCKET || ''
});

const bucket = admin.storage().bucket();

const downloadImageFromStorage = async (pictureId) => {
    try {
        const remoteFilePath = pictureId;
        const tempDir = path.join(process.env.TEMP || '/tmp');
        const tempFilePath = path.join(tempDir,  pictureId.split("/", 2)[1]);

        if (!fs.existsSync(tempDir)) {
            fs.mkdirSync(tempDir);
        }

        await bucket.file(remoteFilePath).download({ destination: tempFilePath });

        const imageBuffer = fs.readFileSync(tempFilePath);
        return imageBuffer;
    } catch (error) {
        throw new Error(`Error downloading image: ${error.message}`);
    }
};

const scaleImage = async (imageBuffer, width) => {
    try {
        const widthInt = parseInt(width, 10);

        if (isNaN(widthInt) || widthInt <= 0) {
            throw new Error("Invalid width parameter. It must be a positive integer.");
        }

        return await sharp(imageBuffer)
            .resize({ width: widthInt })
            .toBuffer();
    } catch (error) {
        throw new Error(`Error scaling image: ${error.message}`);
    }
};


exports.getResizedImage = functions.https.onRequest( async (req, res) => {
    try {
        const { pictureId, width } = req.query;

        if (!pictureId || !width) {
            return res.status(400).send("Missing pictureId or width parameters.");
        }

        const imageBuffer = await downloadImageFromStorage(pictureId);

        const scaledImage = width == 0 ? imageBuffer : await scaleImage(imageBuffer, width);

        res.set('Content-Type', 'image/png');
        res.send(scaledImage);
    } catch (error) {
        console.error("Error processing image:", error);
        res.status(500).send("Internal server error.");
    }
});
