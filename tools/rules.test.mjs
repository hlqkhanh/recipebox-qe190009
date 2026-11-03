import { readFile } from 'node:fs/promises';
import { before, after, beforeEach, test } from 'node:test';
import assert from 'node:assert/strict';
import { initializeTestEnvironment, assertSucceeds, assertFails } from '@firebase/rules-unit-testing';
import { doc, setDoc, getDoc, updateDoc, deleteDoc, collection, query, where, getDocs, Timestamp, runTransaction } from 'firebase/firestore';

let env;
const canonical = (uid, name) => `${uid}__${Buffer.from(name.trim().toLowerCase()).toString('hex').toUpperCase()}`;
const data = (uid, name = 'Pho Bo', changes = {}) => ({ id: canonical(uid, name), userId: uid, name,
  category: 'Dinner', difficulty: 'Easy', cookTime: 25, favorite: false, notes: '', createdAt: Timestamp.now(), ...changes });
const own = (uid = 'alice') => env.authenticatedContext(uid).firestore();
const ref = (db, value) => doc(db, 'recipes', value.id);

before(async () => { env = await initializeTestEnvironment({ projectId: 'demo-recipebox',
  firestore: { rules: await readFile(new URL('../firestore.rules', import.meta.url), 'utf8') } }); });
beforeEach(async () => { await env.clearFirestore(); });
after(async () => { await env?.cleanup(); });

test('valid recipe, omitted optional fields, ownership query and persistence', async () => {
  const db = own(); const value = data('alice'); delete value.notes;
  await assertSucceeds(setDoc(ref(db, value), value));
  assert.equal((await assertSucceeds(getDoc(ref(db, value)))).data().cookTime, 25);
  assert.equal((await assertSucceeds(getDocs(query(collection(db, 'recipes'), where('userId', '==', 'alice'))))).size, 1);
  await assertFails(getDocs(collection(db, 'recipes')));
});
test('Unicode and slash names produce safe canonical IDs', async () => {
  for (const name of ['Phở Bò', 'LUNCH / DINNER', 'Crème brûlée', '🍳 Breakfast']) {
    const value = data('alice', name); await assertSucceeds(setDoc(ref(own(), value), value));
  }
});
test('unauthenticated and another account cannot read, list, edit or delete', async () => {
  const value = data('alice'); await setDoc(ref(own(), value), value);
  for (const db of [own('bob'), env.unauthenticatedContext().firestore()]) {
    await assertFails(getDoc(ref(db, value)));
    await assertFails(getDocs(query(collection(db, 'recipes'), where('userId', '==', 'alice'))));
    await assertFails(updateDoc(ref(db, value), {favorite: true}));
    await assertFails(deleteDoc(ref(db, value)));
    await assertFails(setDoc(ref(db, data('alice', 'Other')), data('alice', 'Other')));
  }
});
test('cannot forge another owner, mismatch id, or transfer ownership', async () => {
  const db = own(); const value = data('alice'); await setDoc(ref(db, value), value);
  await assertFails(setDoc(ref(db, data('bob')), data('bob')));
  await assertFails(setDoc(doc(db, 'recipes', 'arbitrary-id'), {...data('alice', 'Random'), id: 'arbitrary-id'}));
  await assertFails(updateDoc(ref(db, value), {userId: 'bob'}));
  await assertFails(updateDoc(ref(db, value), {id: 'another-id'}));
});
for (const [label, changes] of [
  ['empty name', {name: ''}], ['spaces name', {name: '   '}], ['long name', {name: 'a'.repeat(81)}],
  ['category', {category: 'Snack'}], ['difficulty', {difficulty: 'Expert'}],
  ['zero cookTime', {cookTime: 0}], ['long cookTime', {cookTime: 601}], ['fraction cookTime', {cookTime: 1.5}],
  ['string cookTime', {cookTime: '25'}], ['negative servings', {servings: 0}], ['large servings', {servings: 21}],
  ['fraction servings', {servings: 2.5}], ['null servings', {servings: null}], ['long notes', {notes: 'x'.repeat(301)}],
  ['notes type', {notes: 3}], ['favorite type', {favorite: 'true'}], ['createdAt type', {createdAt: 'today'}],
]) test(`direct writes reject ${label}`, async () => {
  const value = data('alice', 'Pho Bo', changes); await assertFails(setDoc(ref(own(), value), value));
});
test('boundary values accepted', async () => {
  for (const [index, changes] of [{cookTime: 1, servings: 1}, {cookTime: 600, servings: 20, notes: 'x'.repeat(300)}].entries()) {
    const value = data('alice', `Boundary ${index}`, changes); await assertSucceeds(setDoc(ref(own(), value), value));
  }
  const value = data('alice', 'a'.repeat(80)); await assertSucceeds(setDoc(ref(own(), value), value));
});
test('same-user case-insensitive duplicate cannot create a second document; other users can', async () => {
  const value = data('alice'); await setDoc(ref(own(), value), value);
  const duplicate = data('alice', 'pho bo', {id: 'alice__fake'});
  await assertFails(setDoc(ref(own(), duplicate), duplicate));
  assert.equal(canonical('alice', 'Pho Bo'), canonical('alice', 'pho bo'));
  const bobValue = data('bob', 'pho bo'); await assertSucceeds(setDoc(ref(own('bob'), bobValue), bobValue));
  assert.equal((await getDocs(query(collection(own(), 'recipes'), where('userId', '==', 'alice')))).size, 1);
});
test('favorite, valid edits, immutable createdAt and atomic rename', async () => {
  const db = own(); const value = data('alice'); await setDoc(ref(db, value), value);
  await assertSucceeds(updateDoc(ref(db, value), {favorite: true, cookTime: 10, servings: 2}));
  await assertFails(updateDoc(ref(db, value), {createdAt: Timestamp.fromMillis(0)}));
  const renamed = data('alice', 'New Name', {createdAt: value.createdAt});
  await assertSucceeds(runTransaction(db, async tx => {
    const target = ref(db, renamed); const existing = await tx.get(target); assert.equal(existing.exists(), false);
    await tx.get(ref(db, value)); tx.set(target, renamed); tx.delete(ref(db, value));
  }));
  assert.equal((await getDoc(ref(db, renamed))).data().name, 'New Name');
  assert.equal((await getDoc(ref(db, value))).exists(), false);
  await assertSucceeds(deleteDoc(ref(db, renamed)));
});
