import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, it } from 'node:test';

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import { Timestamp, doc, setDoc } from 'firebase/firestore';
import {
  deleteObject,
  getBytes,
  listAll,
  ref,
  updateMetadata,
  uploadBytes,
} from 'firebase/storage';

const STAFF_UID = 'staff-uid';
const NOT_STAFF_UID = 'not-staff-uid';
const TEN_MB = 10 * 1024 * 1024;
const DOCUMENT_ID = 'AbCdEfGhIjKlMnOpQrSt';
const EXISTING_ID = 'ExistingDocument0001';

const fixedTime = Timestamp.fromDate(new Date('2024-05-15T12:00:00Z'));

let testEnv;

function transaction(status) {
  return {
    type: 'lienRelease',
    clientName: 'Test User 1',
    clientNameLower: 'test user 1',
    clientPhone: null,
    customerId: null,
    status,
    dateReceived: fixedTime,
    dateCompleted: status === 'completed' ? fixedTime : null,
    createdBy: STAFF_UID,
    createdAt: fixedTime,
    updatedAt: fixedTime,
  };
}

function bytesOfSize(size) {
  return new Uint8Array(size).fill(7);
}

function path(transactionId, fileName) {
  return `transactions/${transactionId}/documents/${fileName}`;
}

function staffStorage() {
  return testEnv.authenticatedContext(STAFF_UID).storage();
}

function notStaffStorage() {
  return testEnv.authenticatedContext(NOT_STAFF_UID).storage();
}

function signedOutStorage() {
  return testEnv.unauthenticatedContext().storage();
}

async function deleteEverythingIn(folder) {
  const { items, prefixes } = await listAll(folder);
  await Promise.all(items.map((item) => deleteObject(item)));
  await Promise.all(prefixes.map((subfolder) => deleteEverythingIn(subfolder)));
}

async function clearAllFiles() {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await deleteEverythingIn(ref(context.storage()));
  });
}

function upload(storage, filePath, { size = 1000, contentType = 'image/jpeg' } = {}) {
  return uploadBytes(ref(storage, filePath), bytesOfSize(size), { contentType });
}

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'demo-my-office',
    firestore: {
      rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8'),
    },
    storage: {
      rules: readFileSync(new URL('../storage.rules', import.meta.url), 'utf8'),
    },
  });
});

after(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
  await clearAllFiles();
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'staff', STAFF_UID), { email: 'staff@example.com' });
    await setDoc(doc(db, 'transactions', 'pending-tx'), transaction('pending'));
    await setDoc(doc(db, 'transactions', 'completed-tx'), transaction('completed'));
    await setDoc(doc(db, 'transactions', 'cancelled-tx'), transaction('cancelled'));
    await upload(context.storage(), path('pending-tx', `${EXISTING_ID}.jpg`));
  });
});

describe('test setup', () => {
  it('starts every test without files from earlier tests', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const { items, prefixes } = await listAll(
        ref(context.storage(), 'transactions/pending-tx/documents'),
      );
      if (items.length !== 1 || prefixes.length !== 0) {
        throw new Error(`Expected only the seeded file, found ${items.length} files`);
      }
    });
  });
});

describe('signed out', () => {
  it('cannot read a document file', async () => {
    await assertFails(getBytes(ref(signedOutStorage(), path('pending-tx', `${EXISTING_ID}.jpg`))));
  });

  it('cannot upload a document file', async () => {
    await assertFails(upload(signedOutStorage(), path('pending-tx', `${DOCUMENT_ID}.jpg`)));
  });
});

describe('signed in but not on the staff list', () => {
  it('cannot read a document file', async () => {
    await assertFails(getBytes(ref(notStaffStorage(), path('pending-tx', `${EXISTING_ID}.jpg`))));
  });

  it('cannot upload a document file', async () => {
    await assertFails(upload(notStaffStorage(), path('pending-tx', `${DOCUMENT_ID}.jpg`)));
  });
});

describe('staff', () => {
  it('can read a document file', async () => {
    await assertSucceeds(getBytes(ref(staffStorage(), path('pending-tx', `${EXISTING_ID}.jpg`))));
  });

  it('can upload a JPEG, PNG or PDF to a pending transaction', async () => {
    await assertSucceeds(upload(staffStorage(), path('pending-tx', `${DOCUMENT_ID}.jpg`)));
    await assertSucceeds(
      upload(staffStorage(), path('pending-tx', 'PngDocument000000001.png'), {
        contentType: 'image/png',
      }),
    );
    await assertSucceeds(
      upload(staffStorage(), path('pending-tx', 'PdfDocument000000001.pdf'), {
        contentType: 'application/pdf',
      }),
    );
  });

  it('can upload to a completed transaction', async () => {
    await assertSucceeds(upload(staffStorage(), path('completed-tx', `${DOCUMENT_ID}.jpg`)));
  });

  it('cannot upload to a cancelled transaction', async () => {
    await assertFails(upload(staffStorage(), path('cancelled-tx', `${DOCUMENT_ID}.jpg`)));
  });

  it('cannot upload to a transaction that does not exist', async () => {
    await assertFails(upload(staffStorage(), path('missing-tx', `${DOCUMENT_ID}.jpg`)));
  });
});

describe('file size', () => {
  it('accepts a file of exactly 10 MB', async () => {
    await assertSucceeds(
      upload(staffStorage(), path('pending-tx', `${DOCUMENT_ID}.jpg`), { size: TEN_MB }),
    );
  });

  it('refuses a file over 10 MB', async () => {
    await assertFails(
      upload(staffStorage(), path('pending-tx', `${DOCUMENT_ID}.jpg`), { size: TEN_MB + 1 }),
    );
  });

  it('refuses an empty file', async () => {
    await assertFails(
      upload(staffStorage(), path('pending-tx', `${DOCUMENT_ID}.jpg`), { size: 0 }),
    );
  });
});

describe('file type', () => {
  it('refuses other image and file types', async () => {
    await assertFails(
      upload(staffStorage(), path('pending-tx', 'GifDocument000000001.gif'), {
        contentType: 'image/gif',
      }),
    );
    await assertFails(
      upload(staffStorage(), path('pending-tx', 'ZipDocument000000001.zip'), {
        contentType: 'application/zip',
      }),
    );
  });

  it('refuses a content type that does not match the file name', async () => {
    await assertFails(
      upload(staffStorage(), path('pending-tx', `${DOCUMENT_ID}.jpg`), {
        contentType: 'application/pdf',
      }),
    );
    await assertFails(
      upload(staffStorage(), path('pending-tx', `${DOCUMENT_ID}.pdf`), {
        contentType: 'text/plain',
      }),
    );
  });
});

describe('file path', () => {
  it('refuses files outside a transaction documents folder', async () => {
    await assertFails(upload(staffStorage(), `other/${DOCUMENT_ID}.jpg`));
    await assertFails(upload(staffStorage(), `transactions/pending-tx/${DOCUMENT_ID}.jpg`));
    await assertFails(
      upload(staffStorage(), `transactions/pending-tx/documents/extra/${DOCUMENT_ID}.jpg`),
    );
  });

  it('refuses a file name that is not a document id', async () => {
    await assertFails(upload(staffStorage(), path('pending-tx', 'photo.jpg')));
    await assertFails(upload(staffStorage(), path('pending-tx', `${DOCUMENT_ID}x.jpg`)));
  });
});

describe('existing files are permanent', () => {
  const existing = () => ref(staffStorage(), path('pending-tx', `${EXISTING_ID}.jpg`));

  it('staff cannot overwrite an existing file', async () => {
    await assertFails(uploadBytes(existing(), bytesOfSize(500), { contentType: 'image/jpeg' }));
  });

  it('staff cannot change a file\'s details', async () => {
    await assertFails(updateMetadata(existing(), { contentType: 'image/png' }));
  });

  it('staff cannot delete a file', async () => {
    await assertFails(deleteObject(existing()));
  });
});
