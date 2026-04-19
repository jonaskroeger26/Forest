const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');

initializeApp();
const db = getFirestore();

exports.validateAndGrantReward = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError('unauthenticated', 'Authentication required.');
  }

  const { sessionId, durationSeconds, outcome } = request.data || {};
  if (!sessionId || typeof durationSeconds !== 'number' || !outcome) {
    throw new HttpsError('invalid-argument', 'Missing required fields.');
  }
  if (outcome !== 'success') {
    throw new HttpsError('failed-precondition', 'Rewards only apply to successful sessions.');
  }

  const sessionRef = db.collection('sessions').doc(sessionId);
  const userRef = db.collection('users').doc(uid);
  const cityRef = db.collection('cities').doc(uid);

  const reward = {
    coins: Math.min(120, Math.max(10, Math.floor(durationSeconds / 30))),
    materials: Math.max(1, Math.ceil(durationSeconds / 600)),
  };

  await db.runTransaction(async (tx) => {
    const sessionSnap = await tx.get(sessionRef);
    if (!sessionSnap.exists || sessionSnap.data().uid !== uid) {
      throw new HttpsError('not-found', 'Session not found for current user.');
    }
    if (sessionSnap.data().rewardGranted) {
      return;
    }

    const userSnap = await tx.get(userRef);
    const citySnap = await tx.get(cityRef);
    const user = userSnap.exists ? userSnap.data() : { coins: 0, streak: 0 };
    const city = citySnap.exists ? citySnap.data() : { materials: 0 };

    tx.update(sessionRef, { rewardGranted: true });
    tx.set(
      userRef,
      {
        coins: (user.coins || 0) + reward.coins,
        streak: (user.streak || 0) + 1,
      },
      { merge: true },
    );
    tx.set(
      cityRef,
      {
        materials: (city.materials || 0) + reward.materials,
        updatedAt: new Date().toISOString(),
      },
      { merge: true },
    );
  });

  return reward;
});
