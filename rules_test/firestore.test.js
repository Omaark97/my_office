import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, it } from 'node:test';

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  Timestamp,
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  serverTimestamp,
  setDoc,
  updateDoc,
} from 'firebase/firestore';

const STAFF_UID = 'staff-uid';
const OTHER_STAFF_UID = 'other-staff-uid';
const NOT_STAFF_UID = 'not-staff-uid';
const TEN_MB = 10 * 1024 * 1024;

const fixedTime = Timestamp.fromDate(new Date('2024-05-15T12:00:00Z'));

let testEnv;

function savedTransaction(fields = {}) {
  return {
    type: 'lienRelease',
    clientName: 'Test User 1',
    clientNameLower: 'test user 1',
    clientPhone: null,
    customerId: null,
    status: 'pending',
    dateReceived: fixedTime,
    dateCompleted: null,
    createdBy: STAFF_UID,
    createdAt: fixedTime,
    updatedAt: fixedTime,
    ...fields,
  };
}

function newTransaction(fields = {}) {
  return savedTransaction({
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
    ...fields,
  });
}

function newDocument(transactionId, documentId, fields = {}) {
  return {
    name: 'ID_Front.jpg',
    mimeType: 'image/jpeg',
    sizeBytes: 1200000,
    category: 'identification',
    uploadedAt: serverTimestamp(),
    uploadedBy: STAFF_UID,
    storagePath: `transactions/${transactionId}/documents/${documentId}.jpg`,
    ...fields,
  };
}

function staffDb() {
  return testEnv.authenticatedContext(STAFF_UID).firestore();
}

function notStaffDb() {
  return testEnv.authenticatedContext(NOT_STAFF_UID).firestore();
}

function signedOutDb() {
  return testEnv.unauthenticatedContext().firestore();
}

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'demo-my-office',
    firestore: {
      rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8'),
    },
  });
});

after(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'staff', STAFF_UID), { email: 'staff@example.com' });
    await setDoc(doc(db, 'staff', OTHER_STAFF_UID), { email: 'other@example.com' });
    await setDoc(doc(db, 'transactions', 'pending-tx'), savedTransaction());
    await setDoc(
      doc(db, 'transactions', 'completed-tx'),
      savedTransaction({ status: 'completed', dateCompleted: fixedTime }),
    );
    await setDoc(
      doc(db, 'transactions', 'cancelled-tx'),
      savedTransaction({ status: 'cancelled' }),
    );
    await setDoc(
      doc(db, 'transactions', 'pending-tx', 'documents', 'doc-1'),
      newDocument('pending-tx', 'doc-1', { uploadedAt: fixedTime }),
    );
  });
});

describe('signed out', () => {
  it('cannot read a transaction', async () => {
    await assertFails(getDoc(doc(signedOutDb(), 'transactions', 'pending-tx')));
  });

  it('cannot list transactions', async () => {
    await assertFails(getDocs(collection(signedOutDb(), 'transactions')));
  });

  it('cannot create a transaction', async () => {
    await assertFails(setDoc(doc(signedOutDb(), 'transactions', 'new-tx'), newTransaction()));
  });

  it('cannot read documents', async () => {
    await assertFails(
      getDocs(collection(signedOutDb(), 'transactions', 'pending-tx', 'documents')),
    );
  });
});

describe('signed in but not on the staff list', () => {
  it('cannot read a transaction', async () => {
    await assertFails(getDoc(doc(notStaffDb(), 'transactions', 'pending-tx')));
  });

  it('cannot list transactions', async () => {
    await assertFails(getDocs(collection(notStaffDb(), 'transactions')));
  });

  it('cannot create a transaction, even as its own creator', async () => {
    await assertFails(
      setDoc(
        doc(notStaffDb(), 'transactions', 'new-tx'),
        newTransaction({ createdBy: NOT_STAFF_UID }),
      ),
    );
  });

  it('cannot change a transaction', async () => {
    await assertFails(
      updateDoc(doc(notStaffDb(), 'transactions', 'pending-tx'), {
        status: 'cancelled',
        updatedAt: serverTimestamp(),
      }),
    );
  });

  it('cannot read documents', async () => {
    await assertFails(
      getDocs(collection(notStaffDb(), 'transactions', 'pending-tx', 'documents')),
    );
  });

  it('cannot add itself to the staff list', async () => {
    await assertFails(
      setDoc(doc(notStaffDb(), 'staff', NOT_STAFF_UID), { email: 'me@example.com' }),
    );
  });
});

describe('staff list', () => {
  it('staff can read their own staff document', async () => {
    await assertSucceeds(getDoc(doc(staffDb(), 'staff', STAFF_UID)));
  });

  it('staff cannot read another staff document', async () => {
    await assertFails(getDoc(doc(staffDb(), 'staff', OTHER_STAFF_UID)));
  });

  it('staff cannot change the staff list', async () => {
    await assertFails(setDoc(doc(staffDb(), 'staff', STAFF_UID), { email: 'changed@example.com' }));
    await assertFails(setDoc(doc(staffDb(), 'staff', NOT_STAFF_UID), { email: 'new@example.com' }));
    await assertFails(deleteDoc(doc(staffDb(), 'staff', OTHER_STAFF_UID)));
  });
});

describe('staff reading', () => {
  it('can read a transaction', async () => {
    await assertSucceeds(getDoc(doc(staffDb(), 'transactions', 'pending-tx')));
  });

  it('can list transactions', async () => {
    await assertSucceeds(getDocs(collection(staffDb(), 'transactions')));
  });

  it('can read documents', async () => {
    await assertSucceeds(
      getDocs(collection(staffDb(), 'transactions', 'pending-tx', 'documents')),
    );
  });
});

describe('staff creating a transaction', () => {
  const create = (fields) =>
    setDoc(doc(staffDb(), 'transactions', 'new-tx'), newTransaction(fields));

  it('can create a valid pending transaction', async () => {
    await assertSucceeds(create());
  });

  it('can create one with a client phone', async () => {
    await assertSucceeds(create({ clientPhone: '00 000 000' }));
  });

  it('cannot create it in someone else\'s name', async () => {
    await assertFails(create({ createdBy: OTHER_STAFF_UID }));
  });

  it('cannot create it already completed or cancelled', async () => {
    await assertFails(create({ status: 'completed', dateCompleted: serverTimestamp() }));
    await assertFails(create({ status: 'cancelled' }));
  });

  it('cannot use an unknown type', async () => {
    await assertFails(create({ type: 'spaceship' }));
  });

  it('cannot leave the client name or search key empty', async () => {
    await assertFails(create({ clientName: '' }));
    await assertFails(create({ clientNameLower: '' }));
  });

  it('cannot link a customer yet', async () => {
    await assertFails(create({ customerId: 'customer-uid' }));
  });

  it('cannot set createdAt or updatedAt from the phone clock', async () => {
    await assertFails(create({ createdAt: Timestamp.now() }));
    await assertFails(create({ updatedAt: Timestamp.now() }));
  });

  it('cannot store dateReceived as a string', async () => {
    await assertFails(create({ dateReceived: '2024-05-15' }));
  });

  it('cannot add unknown fields or leave fields out', async () => {
    await assertFails(create({ notes: 'extra' }));
    const missingPhone = newTransaction();
    delete missingPhone.clientPhone;
    await assertFails(setDoc(doc(staffDb(), 'transactions', 'new-tx'), missingPhone));
  });
});

describe('staff correcting a pending transaction', () => {
  const correct = (fields) =>
    updateDoc(doc(staffDb(), 'transactions', 'pending-tx'), {
      updatedAt: serverTimestamp(),
      ...fields,
    });

  it('can correct the client name and search key', async () => {
    await assertSucceeds(
      correct({ clientName: 'Test User One', clientNameLower: 'test user one' }),
    );
  });

  it('can correct the phone and the type', async () => {
    await assertSucceeds(correct({ clientPhone: '11 111 111' }));
    await assertSucceeds(correct({ type: 'other' }));
  });

  it('cannot correct without server time in updatedAt', async () => {
    await assertFails(
      updateDoc(doc(staffDb(), 'transactions', 'pending-tx'), {
        clientPhone: '11 111 111',
        updatedAt: Timestamp.now(),
      }),
    );
  });

  it('cannot empty the search key or use an unknown type', async () => {
    await assertFails(correct({ clientNameLower: '' }));
    await assertFails(correct({ type: 'spaceship' }));
  });

  it('cannot change who created it, when, or when it was received', async () => {
    await assertFails(correct({ createdBy: OTHER_STAFF_UID }));
    await assertFails(correct({ createdAt: serverTimestamp() }));
    await assertFails(correct({ dateReceived: Timestamp.now() }));
  });

  it('cannot link a customer', async () => {
    await assertFails(correct({ customerId: 'customer-uid' }));
  });

  it('cannot mix a correction with a status change', async () => {
    await assertFails(
      correct({ clientPhone: '11 111 111', status: 'cancelled' }),
    );
  });
});

describe('status changes', () => {
  const change = (id, fields) =>
    updateDoc(doc(staffDb(), 'transactions', id), {
      updatedAt: serverTimestamp(),
      ...fields,
    });

  it('can complete a pending transaction with server times', async () => {
    await assertSucceeds(
      change('pending-tx', { status: 'completed', dateCompleted: serverTimestamp() }),
    );
  });

  it('cannot complete without dateCompleted', async () => {
    await assertFails(change('pending-tx', { status: 'completed' }));
  });

  it('cannot complete with a phone-clock dateCompleted', async () => {
    await assertFails(
      change('pending-tx', { status: 'completed', dateCompleted: Timestamp.now() }),
    );
  });

  it('can cancel a pending transaction', async () => {
    await assertSucceeds(change('pending-tx', { status: 'cancelled' }));
  });

  it('cannot cancel and set dateCompleted', async () => {
    await assertFails(
      change('pending-tx', { status: 'cancelled', dateCompleted: serverTimestamp() }),
    );
  });

  it('cannot use an unknown status', async () => {
    await assertFails(change('pending-tx', { status: 'archived' }));
  });
});

describe('completed and cancelled transactions are locked', () => {
  const change = (id, fields) =>
    updateDoc(doc(staffDb(), 'transactions', id), {
      updatedAt: serverTimestamp(),
      ...fields,
    });

  it('cannot reopen a completed transaction', async () => {
    await assertFails(change('completed-tx', { status: 'pending', dateCompleted: null }));
  });

  it('cannot correct a completed transaction', async () => {
    await assertFails(
      change('completed-tx', { clientName: 'Changed', clientNameLower: 'changed' }),
    );
  });

  it('cannot reopen or complete a cancelled transaction', async () => {
    await assertFails(change('cancelled-tx', { status: 'pending' }));
    await assertFails(
      change('cancelled-tx', { status: 'completed', dateCompleted: serverTimestamp() }),
    );
  });

  it('cannot correct a cancelled transaction', async () => {
    await assertFails(change('cancelled-tx', { clientPhone: '11 111 111' }));
  });
});

describe('deleting', () => {
  it('staff cannot delete a transaction', async () => {
    await assertFails(deleteDoc(doc(staffDb(), 'transactions', 'pending-tx')));
    await assertFails(deleteDoc(doc(staffDb(), 'transactions', 'completed-tx')));
  });

  it('staff cannot delete a document', async () => {
    await assertFails(deleteDoc(doc(staffDb(), 'transactions', 'pending-tx', 'documents', 'doc-1')));
  });
});

describe('staff adding documents', () => {
  const add = (transactionId, fields = {}, documentId = 'doc-2') =>
    setDoc(
      doc(staffDb(), 'transactions', transactionId, 'documents', documentId),
      newDocument(transactionId, documentId, fields),
    );

  it('can add a valid image or PDF to a pending transaction', async () => {
    await assertSucceeds(add('pending-tx'));
    await assertSucceeds(
      add(
        'pending-tx',
        {
          name: 'Sale_Deed.pdf',
          mimeType: 'application/pdf',
          category: 'saleDeed',
          storagePath: 'transactions/pending-tx/documents/doc-3.pdf',
        },
        'doc-3',
      ),
    );
  });

  it('can add a document to a completed transaction', async () => {
    await assertSucceeds(add('completed-tx'));
  });

  it('cannot add a document to a cancelled transaction', async () => {
    await assertFails(add('cancelled-tx'));
  });

  it('cannot add a document to a transaction that does not exist', async () => {
    await assertFails(add('missing-tx'));
  });

  it('cannot change or delete a document of a completed transaction', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(
        doc(context.firestore(), 'transactions', 'completed-tx', 'documents', 'doc-9'),
        newDocument('completed-tx', 'doc-9', { uploadedAt: fixedTime }),
      );
    });
    const existing = doc(staffDb(), 'transactions', 'completed-tx', 'documents', 'doc-9');

    await assertFails(updateDoc(existing, { name: 'Renamed.jpg' }));
    await assertFails(deleteDoc(existing));
  });

  it('cannot use an unknown category', async () => {
    await assertFails(add('pending-tx', { category: 'photo' }));
  });

  it('cannot add a file type other than JPEG, PNG or PDF', async () => {
    await assertFails(add('pending-tx', { mimeType: 'image/gif' }));
    await assertFails(add('pending-tx', { mimeType: 'application/zip' }));
  });

  it('cannot add a file over 10 MB or with no size', async () => {
    await assertSucceeds(add('pending-tx', { sizeBytes: TEN_MB }));
    await assertFails(add('pending-tx', { sizeBytes: TEN_MB + 1 }, 'doc-4'));
    await assertFails(add('pending-tx', { sizeBytes: 0 }, 'doc-5'));
  });

  it('cannot point to a file outside the transaction folder', async () => {
    await assertFails(
      add('pending-tx', { storagePath: 'transactions/completed-tx/documents/doc-2.jpg' }),
    );
    await assertFails(add('pending-tx', { storagePath: 'somewhere/else.jpg' }));
  });

  it('cannot upload in someone else\'s name or with phone-clock time', async () => {
    await assertFails(add('pending-tx', { uploadedBy: OTHER_STAFF_UID }));
    await assertFails(add('pending-tx', { uploadedAt: Timestamp.now() }));
  });

  it('cannot change an existing document', async () => {
    await assertFails(
      updateDoc(doc(staffDb(), 'transactions', 'pending-tx', 'documents', 'doc-1'), {
        name: 'Renamed.jpg',
      }),
    );
  });
});

describe('everything else is denied', () => {
  it('staff cannot read or write other collections', async () => {
    await assertFails(getDoc(doc(staffDb(), 'notes', 'note-1')));
    await assertFails(setDoc(doc(staffDb(), 'notes', 'note-1'), { text: 'hello' }));
  });
});
