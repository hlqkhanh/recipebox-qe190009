# RecipeBox verification

Student: QE190009 — Hồ Lê Quốc Khánh

Firebase project: `recipebox-qe190009`

## Completed checks

- Flutter analyzer: no issues.
- Flutter unit/widget tests: 8 passed, covering exact validation, combined filters, sorting, summary, Unicode IDs, responsive forms and large text.
- Firestore Emulator security tests: 24 passed, including direct invalid writes, ownership, anonymous access, optional fields, canonical name uniqueness and atomic renames.
- Rules compiled and published to the real Firebase project with Firebase CLI.
- Production Firebase Authentication: test-account sign-in verified.
- Production Firestore client smoke test: create/read/update/favorite/delete verified; invalid cooking time and ownership transfer rejected.
- Release APK built successfully from a clean extraction of the source ZIP: 50.4 MB.
- Actual Android emulator screenshots captured at 360 × 800 logical pixels. See `artifacts/screenshots/` in the working directory.
- Production-backed Android end-to-end test: passed. Verified Register, wrong-password rejection and successful Login, Add/Edit validation, five real recipes, case-insensitive duplicate rejection, every filter, notes search, summary, favorite persistence, rename, Delete confirmation/cancellation, deletion, and isolation between two accounts.
- 24 real Android screenshots saved. The grader account retains four sample recipes after the deletion test.

## Submission work

- Prepare `QE190009.docx` using the exact exam identity template, real app screenshots and captions.
- Capture Firebase Console Authentication Users, Firestore data and published Rules screenshots.
- Upload the source to the public GitHub repository and publish the release APK at a durable public download URL.
- Add the verified public APK URL to the Word report; submit only the Word report and source ZIP in the final submission folder.

No admin/service-account key is used or included.
