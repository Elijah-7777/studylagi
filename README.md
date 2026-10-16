# StudyLagi: Mobile Front-End Simulation (Flutter)

A Flutter mobile simulation of the StudyLagi proposal: a personalized study
scheduling and progress tracker for Senior High School students of St.
Matthew Academy of Cavite. **No database or backend is used.** All data lives
in memory for the session only, inside one `ChangeNotifier`
(`lib/state/app_state.dart`).

## Two account types

The login redirects to a different dashboard depending on the account's role
(Functional Requirement #1 in the capstone document).

| Role | Demo account | What they can do |
|---|---|---|
| Student | `kylie@smac.edu.ph` / `study123` | Personal study tasks (CRUD), assignments from teachers, submit work, see grades and feedback, Knowledge Points, streak, achievements, leaderboard, store, progress report |
| Teacher | `teacher@smac.edu.ph` / `teach123` | Classes (CRUD), enroll students, assignments (CRUD), grade with feedback, post announcements, monitor student progress |

You can also create new accounts from **Sign Up**:
- **Student**: choose grade level and strand. You start with 0 points and no tasks.
- **Teacher**: enter subject specialization and school. The account then waits
  for the school administrator's verification, as described in the document.
  There is no admin in the mobile build, so the **Simulate admin approval**
  button stands in for that step.

## Teacher features

- **Home**: class, student and assignment counts, submissions waiting to be
  graded, upcoming deadlines.
- **Classes**: create, edit and delete classes. Open a class to add or remove
  students (only students of the same strand are offered), manage its
  assignments and post announcements.
- **Tasks (assignments)**: create, edit and delete assignments with a due date
  and maximum score. Open one to see every student's status (not submitted,
  missing, needs grading, graded) and grade each submission with feedback.
- **Reports**: filter by class and see each student's submission rate, average
  score, Knowledge Points and streak. Students with a low submission rate or an
  average under 75% are flagged "Needs support".

## How teacher and student sides connect

1. The teacher adds a student to a class and assigns work to it.
2. The student sees the assignment under **Tasks > From Your Teachers** and on
   the Home screen, plus the teacher's announcements.
3. The student submits it and earns Knowledge Points (half if late).
4. The teacher grades it. The student then sees the score and feedback, and
   graded work appears in the **Progress Report**.

Students only see work from the classes they were added to.

## Basic CRUD (as required)

- Student tasks: `lib/screens/tasks_screen.dart`, `task_form_sheet.dart`
- Teacher classes: `lib/screens/teacher/classes_screen.dart`, `class_form_sheet.dart`
- Teacher assignments: `lib/screens/teacher/teacher_assignments_screen.dart`, `assignment_form_sheet.dart`
- All the logic is in `lib/state/app_state.dart`

## Running it

1. Install [Flutter](https://docs.flutter.dev/get-started/install) (stable channel).
2. From this folder:
   ```bash
   flutter pub get
   flutter run
   ```
   Use `flutter run -d chrome` for a quick preview without an emulator.
3. Optional checks: `flutter test`

## Project structure

```
lib/
  main.dart                        entry point (Provider + theme)
  constants.dart                   strands, grade levels, subjects
  theme/app_theme.dart             colors from the wireframes
  models/                          StudyTask, Achievement, StoreItem, LeaderboardEntry,
                                   RegisteredUser + UserRole, StudentProfile,
                                   SchoolClass, Assignment + Submission, Announcement
  state/
    app_state.dart                 single in-memory data store and all logic
    student_data.dart              each student's private tasks/achievements/store
  screens/                         student screens + shared auth/profile
    teacher/                       teacher shell, dashboard, classes, assignments,
                                   grading, reports, pending-approval screen
  widgets/                         shared cards, chips, sheets, formatting
test/
  widget_test.dart                 welcome screen smoke test
  app_state_test.dart              login roles + teacher-to-student workflow
```

## Not included in this mobile build

- The Admin role and the web admin portal (teacher verification is simulated).
- The teacher quiz builder and auto-grading. Assignments here are graded by hand.
- Real persistence: closing the app resets everything to the seed data.

The production system uses Firebase Authentication and Cloud Firestore.
Replacing the lists in `AppState` with Firestore calls behind the same method
names is the natural next step.
