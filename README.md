# Community Learning Center - Enrollment Simulator

**Lab 3: Final Midterm Project - "The Dart App Simulator"**
Course: Mobile Development | Individual Project

A console-based Dart application that simulates enrolling students in
courses at a community learning center, using OOP and asynchronous
programming.

## How to run
1. Install the [Dart SDK](https://dart.dev/get-dart) (3.0 or newer).
2. Clone this repo and open the folder in a terminal.
3. Run: `dart run main.dart`

## Requirements checklist
| Requirement | Where in `main.dart` |
|---|---|
| 2+ classes with inheritance | `Student` and `Instructor` extend `Person` |
| Constructors and methods | Every class (e.g. `Student(...)`, `enrollStudent()`) |
| Abstract class | `Person` (abstract members `role`, `getDetails()`) |
| Interface | `Reportable`, implemented by `Person` and `Course` |
| Mixin | `Loggable`, applied to `Student` and `LearningCenterService` |
| Future + simulated delay | `loadData()`, `enrollStudent()`, `dropStudent()`, `generateReport()` use `Future.delayed` |
| async/await in `main()` | `Future<void> main() async` awaits every operation |
| try-catch error handling | `main()`, `safely()`, custom `EnrollmentException` |

## Sample output
```
=== Community Learning Center Enrollment Simulator ===

[LOG] Loading data...
[LOG] Data loaded: 3 courses, 3 students.
...
[ERROR] Enroll S-003 in IT101 (full) failed -> IT101 is already full.
```

## Author
Harvey yuan A. Flores - BSIT 
