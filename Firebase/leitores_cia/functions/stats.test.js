const assert = require('node:assert/strict');
const test = require('node:test');
const { calculateReadingStats } = require('./stats');

test('soma livros e páginas somente para livros com status LIDOS', () => {
  assert.deepEqual(
    calculateReadingStats([
      { status: 'LIDOS', pageCount: 250 },
      { status: 'LIDOS', pageCount: 120 },
      { status: 'LENDO', pageCount: 400 },
      { status: 'QUERO_LER', pageCount: 300 },
    ]),
    { totalBooksRead: 2, totalPagesRead: 370 },
  );
});

test('conta livros sem somar páginas ausentes, nulas, inválidas ou zero', () => {
  assert.deepEqual(
    calculateReadingStats([
      { status: 'LIDOS' },
      { status: 'LIDOS', pageCount: null },
      { status: 'LIDOS', pageCount: -10 },
      { status: 'LIDOS', pageCount: 0 },
      { status: 'LIDOS', pageCount: '120' },
    ]),
    { totalBooksRead: 5, totalPagesRead: 0 },
  );
});

test('recalcula os totais sem incluir livros movidos para outra estante ou excluídos', () => {
  assert.deepEqual(
    calculateReadingStats([
      { status: 'LIDOS', pageCount: 250 },
      { status: 'LENDO', pageCount: 100 },
    ]),
    { totalBooksRead: 1, totalPagesRead: 250 },
  );
  assert.deepEqual(calculateReadingStats([]), {
    totalBooksRead: 0,
    totalPagesRead: 0,
  });
});
