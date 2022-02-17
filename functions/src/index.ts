import * as functions from "firebase-functions";
import admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

exports.myFunction = functions.firestore
    .document("users/{userId}")
    .onWrite(async (change, context) => {
        if (change.before.exists) {
            const before = change.before.data();
            if (before) {
                const country: string = before["country"];
                const state: string = before["state"];
                await updateCensus(country, state, -1);
            }
        }
        if (change.after.exists) {
            const after = change.after.data();
            if (after) {
                const country: string = after["country"];
                const state: string = after["state"];
                await updateCensus(country, state, 1);
            }
        }
    });

async function updateCensus(country: string, state: string, delta: number) {
    if (!country) {
        return;
    }
    if (!state) {
        return;
    }

    let oldEntries = 0;
    let oldCensusExists = false;
    let oldCensus = 0;

    const documentReference = db.collection("census").doc(country);
    const documentSnapshot = await documentReference.get();

    if (documentSnapshot.exists) {
        const documentData = documentSnapshot.data();
        if (documentData) {
            oldEntries = Object.keys(documentData).length;
            oldCensusExists =
                Object.prototype.hasOwnProperty.call(documentData, state);
            if (oldCensusExists) {
                oldCensus = documentData[state];
            }
        }
    }

    const newCensus: number = oldCensus + delta;

    if (oldCensusExists && newCensus <= 0) {
        if (oldEntries == 1) {
            await documentReference.delete();
        } else {
            await documentReference.set(
                { [state]: admin.firestore.FieldValue.delete() },
                { merge: true });
        }
    } else if (newCensus > 0) {
        await documentReference.set(
            { [state]: newCensus },
            { merge: true });
    }
}
