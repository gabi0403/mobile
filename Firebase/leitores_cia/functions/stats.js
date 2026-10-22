function calculateReadingStats(books) {
  let totalBooksRead = 0;
  let totalPagesRead = 0;

  for (const book of books) {
    if (book?.status !== 'LIDOS') continue;

    totalBooksRead += 1;
    const pageCount = book.pageCount;
    if (typeof pageCount === 'number' && Number.isFinite(pageCount) && pageCount > 0) {
      totalPagesRead += Math.floor(pageCount);
    }
  }

  return { totalBooksRead, totalPagesRead };
}

module.exports = { calculateReadingStats };
