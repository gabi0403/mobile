const { initializeApp } = require('firebase-admin/app');
const { FieldValue, getFirestore } = require('firebase-admin/firestore');
const { onDocumentWritten } = require('firebase-functions/v2/firestore');
const { calculateReadingStats } = require('./stats');

initializeApp();

const firestore = getFirestore();

exports.recalculateReadingStats = onDocumentWritten(
  {
    document: 'users/{userId}/books/{bookId}',
    retry: true,
  },
  async (event) => {
    const { userId } = event.params;
    const booksQuery = firestore
      .collection('users')
      .doc(userId)
      .collection('books')
      .where('status', '==', 'LIDOS');
    const statsRef = firestore
      .collection('users')
      .doc(userId)
      .collection('stats')
      .doc('summary');

    await firestore.runTransaction(async (transaction) => {
      const booksSnapshot = await transaction.get(booksQuery);
      await transaction.get(statsRef);

      const stats = calculateReadingStats(
        booksSnapshot.docs.map((bookDocument) => bookDocument.data()),
      );

      transaction.set(statsRef, {
        ...stats,
        lastUpdated: FieldValue.serverTimestamp(),
      });
    });
  },
);
