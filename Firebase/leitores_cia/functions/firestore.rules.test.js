const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const path = require('node:path');
const test = require('node:test');
const {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} = require('@firebase/rules-unit-testing');
const {
  deleteDoc,
  doc,
  getDoc,
  setDoc,
  updateDoc,
} = require('firebase/firestore');

const projectId = 'demo-leitores-cia';
const firestoreRules = readFileSync(
  path.join(__dirname, '..', 'firestore.rules'),
  'utf8',
);

let testEnvironment;

test.before(async () => {
  testEnvironment = await initializeTestEnvironment({
    projectId,
    firestore: { rules: firestoreRules },
  });
});

test.beforeEach(async () => {
  await testEnvironment.clearFirestore();
});

test.after(async () => {
  await testEnvironment.cleanup();
});

test('usuário autenticado pode criar, ler, atualizar e excluir os próprios livros', async () => {
  const db = testEnvironment.authenticatedContext('reader-a').firestore();
  const bookRef = doc(db, 'users/reader-a/books/book-1');

  await assertSucceeds(setDoc(bookRef, { title: 'Duna', status: 'LIDOS' }));
  assert.equal((await assertSucceeds(getDoc(bookRef))).data().title, 'Duna');
  await assertSucceeds(updateDoc(bookRef, { status: 'LENDO' }));
  assert.equal((await assertSucceeds(getDoc(bookRef))).data().status, 'LENDO');
  await assertSucceeds(deleteDoc(bookRef));
});

test('usuário autenticado não pode acessar livros de outro usuário', async () => {
  const db = testEnvironment.authenticatedContext('reader-a').firestore();
  const otherBookRef = doc(db, 'users/reader-b/books/book-1');

  await assertFails(getDoc(otherBookRef));
  await assertFails(setDoc(otherBookRef, { title: 'Privado' }));
  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'users/reader-b/books/book-1'), {
      title: 'Privado',
    });
  });
  await assertFails(updateDoc(otherBookRef, { title: 'Alterado' }));
  await assertFails(deleteDoc(otherBookRef));
});

test('usuário não autenticado não pode acessar livros ou estatísticas', async () => {
  const db = testEnvironment.unauthenticatedContext().firestore();

  await assertFails(getDoc(doc(db, 'users/reader-a/books/book-1')));
  await assertFails(
    setDoc(doc(db, 'users/reader-a/books/book-1'), { title: 'Sem sessão' }),
  );
  await assertFails(getDoc(doc(db, 'users/reader-a/stats/summary')));
});

test('usuário pode ler apenas o resumo de estatísticas do próprio UID', async () => {
  const db = testEnvironment.authenticatedContext('reader-a').firestore();
  const ownStatsRef = doc(db, 'users/reader-a/stats/summary');
  const otherStatsRef = doc(db, 'users/reader-b/stats/summary');

  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'users/reader-a/stats/summary'), {
      totalBooksRead: 2,
      totalPagesRead: 300,
    });
    await setDoc(doc(context.firestore(), 'users/reader-b/stats/summary'), {
      totalBooksRead: 8,
      totalPagesRead: 900,
    });
  });

  assert.equal((await assertSucceeds(getDoc(ownStatsRef))).data().totalBooksRead, 2);
  await assertFails(getDoc(otherStatsRef));
});

test('cliente não pode criar, alterar ou excluir resumo de estatísticas', async () => {
  const db = testEnvironment.authenticatedContext('reader-a').firestore();
  const statsRef = doc(db, 'users/reader-a/stats/summary');

  await assertFails(
    setDoc(statsRef, { totalBooksRead: 1, totalPagesRead: 100 }),
  );
  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'users/reader-a/stats/summary'), {
      totalBooksRead: 1,
      totalPagesRead: 100,
    });
  });
  await assertFails(updateDoc(statsRef, { totalBooksRead: 5 }));
  await assertFails(deleteDoc(statsRef));
});

test('acesso a outros caminhos permanece negado pelo bloqueio geral', async () => {
  const db = testEnvironment.authenticatedContext('reader-a').firestore();

  await assertFails(getDoc(doc(db, 'private-data/record-1')));
  await assertFails(
    setDoc(doc(db, 'private-data/record-1'), { secret: true }),
  );
});
