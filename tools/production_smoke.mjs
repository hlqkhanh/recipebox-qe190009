import {readFile} from 'node:fs/promises';
import assert from 'node:assert/strict';
import {initializeApp, deleteApp} from 'firebase/app';
import {getAuth, signInWithEmailAndPassword, signOut} from 'firebase/auth';
import {getFirestore, doc, setDoc, getDoc, updateDoc, deleteDoc, serverTimestamp, terminate} from 'firebase/firestore';
const config = JSON.parse(await readFile(new URL('../android/app/google-services.json', import.meta.url), 'utf8'));
const app = initializeApp({apiKey: config.client[0].api_key[0].current_key, projectId: config.project_info.project_id, appId: config.client[0].client_info.mobilesdk_app_id});
const auth = getAuth(app), db = getFirestore(app);
const {TEST_EMAIL, TEST_PASSWORD} = JSON.parse(await readFile(new URL('../artifacts/device-test-defines.json', import.meta.url), 'utf8'));
try {
  const credential = await signInWithEmailAndPassword(auth, TEST_EMAIL, TEST_PASSWORD);
  console.log('Production Firebase sign-in succeeded');
  const uid = credential.user.uid, name = `Smoke test ${Date.now()}`;
  const id = `${uid}__${Buffer.from(name.toLowerCase()).toString('hex').toUpperCase()}`;
  const target = doc(db, 'recipes', id);
  await setDoc(target, {id, userId: uid, name, category: 'Dinner', difficulty: 'Easy', cookTime: 25, favorite: false, notes: '', createdAt: serverTimestamp()});
  await updateDoc(target, {cookTime: 7, favorite: true, servings: 2});
  const saved = (await getDoc(target)).data();
  assert.equal(saved.favorite, true); assert.equal(saved.cookTime, 7);
  await assert.rejects(updateDoc(target, {cookTime: 601}));
  await assert.rejects(updateDoc(target, {userId: 'another-user'}));
  await deleteDoc(target);
  assert.equal((await getDoc(target)).exists(), false);
  console.log('Production Firestore create/read/edit/favorite/delete and invalid-write rejection succeeded');
  await signOut(auth);
} finally { await terminate(db); await deleteApp(app); }
