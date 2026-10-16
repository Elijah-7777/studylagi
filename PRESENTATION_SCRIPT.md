# StudyLagi — Recorded Presentation Script / Outline

Use this as a talking-point script for your screen recording. Suggested
total length: 6–9 minutes. Record your phone/emulator screen with
Android's built-in screen recorder, OBS Studio, or the Android Studio
emulator's record button, and narrate over it (or add narration/subtitles
after in any video editor).

---

## 1. What the app is (≈60–90 sec)

Talking points:
- StudyLagi is a mobile and web application proposed for Senior High
  School students of St. Matthew Academy of Cavite.
- Problem it solves: students juggle multiple subjects, deadlines, and
  performance tasks using scattered tools (notebooks, basic phone
  calendars) with no integration, personalization, or motivation built in.
- StudyLagi combines **personalized study scheduling**, **progress
  tracking**, and **gamification** (streaks, badges, leaderboards, a
  Knowledge Points economy) in one platform — inspired by Duolingo and
  Habitica.
- This build is the **mobile front-end simulation** built in Flutter, with
  no live database — it demonstrates the full proposed UI/UX flow and
  basic CRUD functionality on study tasks.

---

## 2. Rundown of planned features (≈2–3 min) — include screenshots here

Walk through each screen live in the emulator/device while narrating.
Suggested order, matching the app's navigation:

1. **Welcome / Log In / Sign Up** — entry point; in the real system this
   is backed by Firebase Authentication (email/password + Google login).
2. **Dashboard** — personalized greeting, Knowledge Points + streak
   summary cards, "Log Today" streak action, upcoming tasks preview.
3. **Study Tasks (CRUD)** — the core planning feature:
   - **Create** a task (title, subject, due date, priority) via the "New
     Task" button.
   - **Read** — tasks list split into Pending / Completed.
   - **Update** — tap a task to edit it, or check it off (awards KP).
   - **Delete** — swipe a task away.
   - Mention: in the full proposal this maps to the "Study Planning and
     Learning Modules" and "Assignment and Task Management Module" from
     Chapter 3 of the capstone document.
4. **Achievements** — streak milestones and KP-collector badges with
   claimable rewards, matching the gamification goals in the proposal
   (achievement badges, streak counters, experience points).
5. **Leaderboard** — ranks the student against schoolmates by Knowledge
   Points, encouraging "friendly competition" as described in the
   objectives.
6. **Progress Report** — KP totals, weekly KP gained, subject-by-subject
   completion breakdown (computed live from your tasks), and a
   personalized tip pointing at the weakest subject.
7. **Study Store** — spend earned Knowledge Points on cosmetic
   rewards (outfits, themes, sounds) — the motivational "reward for
   completing goals" loop described in the Purpose and Description
   section.
8. **Profile / Log Out** — basic account info, returns to Welcome.

Take a screenshot of each screen here for your slides (Android
emulator: Ctrl+S / camera icon in the emulator toolbar; physical device:
Power + Volume Down).

---

## 3. Tools and how you plan to develop the features (≈1–1.5 min)

Talking points, drawn from your Chapter 3 technical background:
- **Frontend/mobile prototype**: Flutter/Dart for this mobile simulation
  — chosen for one codebase that can target Android and iOS, matching
  the "mobile-first" strategy in your proposal.
- **State management**: the `provider` package with a single
  `ChangeNotifier` (`AppState`) standing in for a real backend during
  this phase — every CRUD method (`addTask`, `updateTask`, `deleteTask`,
  `toggleTaskComplete`) is already written so swapping in Firestore calls
  later is a drop-in change, not a rewrite.
- **Planned production stack** (per your capstone document): HTML,
  Tailwind CSS, JavaScript/TypeScript for the web app; Firebase
  Authentication + Cloud Firestore for auth and real-time data sync;
  Firebase Hosting for deployment; Figma/Framer for UI/UX design; GitHub
  for version control.
- **Design process**: high-fidelity wireframes were built first in Figma
  (shown in Appendix H of the document) and this Flutter build translates
  those wireframes directly into working screens, matching colors,
  layout, and copy.
- **Methodology**: Agile development, in iterative cycles, as described
  in Chapter 4 — this mobile simulation represents an early sprint
  deliverable (System Design → early System Development).

---

## 4. Anticipated difficulties and challenges (≈1 min)

Pick 3–5 of these (or your own) and speak to them honestly:
- **Real-time sync across devices** — once Firestore is introduced,
  keeping web and mobile in sync (e.g., a task completed on mobile
  should instantly reflect on the web dashboard) will require careful
  listener/stream design, not just one-time reads.
- **Adaptive scheduling logic** — the proposal calls for the app to
  "recommend optimized study paths" based on performance; designing a
  fair, explainable algorithm (not a black box) that actually helps
  rather than frustrates students is a non-trivial design problem.
- **Gamification balance** — tuning KP rewards, streak forgiveness (e.g.,
  what happens if a student misses one day), and store prices so the
  system motivates without feeling manipulative or "pay-to-win."
- **Offline access** — the proposal lists offline learning access as a
  functional requirement; caching Firestore data for offline use and
  reconciling conflicts on reconnect adds real complexity.
- **Role-based access control** — three roles (student, teacher, admin)
  each need different Firestore security rules; getting this wrong risks
  a student seeing another student's data.
- **Adoption/engagement risk** — like any habit-forming app, the biggest
  risk isn't technical: it's whether SHS students actually open the app
  daily once the novelty wears off.
- **Scope for a 5-person student team** — balancing the full feature
  list (quizzes, auto-grading, teacher dashboards, admin panel,
  leaderboards, store) against a single academic term's timeline.

---

## 5. Short demo of the system flow (≈1.5–2 min)

Live, unscripted walkthrough — narrate as you tap:
1. Launch app → Welcome screen → tap **Log In** → fill the form → land on
   Dashboard.
2. Tap **Log Today** to bump the streak.
3. Go to **Tasks** → tap **New Task** → create one (e.g., "Review Trigonometry
   notes", Mathematics, tomorrow, High priority) → show it appear in
   Pending.
4. Tap the task → edit its priority → save → show the change reflected.
5. Check the task complete → point out the KP counter increasing on the
   Dashboard/Progress Report.
6. Swipe a task away to show **Delete**.
7. Jump to **Achievements** → show a completed badge → tap **Claim**.
8. Jump to **Leaderboard** → point out your entry moved up after
   earning KP.
9. Jump to **Study Store** → buy an item → show the balance deduct and
   the button change to "Owned."
10. Open **Progress Report** → show the subject breakdown update based on
    the task you just completed.
11. Close on **Profile** → mention this is where account management and
    log out would live, then log out to end the demo.

---

### Closing line (optional)
"This Flutter build shows the complete proposed user experience for
StudyLagi end-to-end — from onboarding through daily task management,
gamified motivation, and progress reporting — all without a backend, as
required for this milestone. Firebase integration is the next planned
step, using the same CRUD interface already built into this app's state
layer."

---

## Added: Teacher accounts (include this in sections 2 and 5)

Talking points:
- The login now supports two roles. After logging in, the app opens the
  student dashboard or the teacher dashboard depending on the account.
- Teachers sign up with their subject specialization and school, then wait
  for administrator verification (shown with a Simulate admin approval
  button because the admin portal is web-only).
- Teacher tools: create classes, add students of the same strand, create
  assignments with due dates, grade submissions with feedback, post
  announcements, and monitor each student's progress.
- Student side: assignments show under Tasks > From Your Teachers, with
  status chips (To submit, Submitted, Graded). Grades and feedback also
  appear in the Progress Report.

Demo flow to add (about 1.5 minutes):
1. Log in as the teacher (teacher@smac.edu.ph / teach123).
2. Open Classes, open Gen Math 11-STEM A, add a student, post an announcement.
3. Open Tasks, create a new assignment for that class.
4. Open a submission that needs grading, give a score and feedback.
5. Open Reports to show submission rate, average score and the Needs support flag.
6. Log out, log in as the student (kylie@smac.edu.ph / study123), show the
   new assignment and announcement, submit it, then show the grade and
   feedback.
