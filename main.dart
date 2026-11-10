// ============================================================
// Lab 3: Final Midterm Project - "The Dart App Simulator"
// System: Community Learning Center - Enrollment Simulator
// Covers (Weeks 7-11): OOP, inheritance, abstract class,
//                      interface, mixin, Future, async/await,
//                      try-catch error handling.
// Run with:  dart run main.dart
// ============================================================

// ------------------------------------------------------------
// 1. CUSTOM EXCEPTION (used for error handling with try-catch)
// ------------------------------------------------------------
class EnrollmentException implements Exception {
  final String message;

  EnrollmentException(this.message);

  @override
  String toString() => 'EnrollmentException: $message';
}

// ------------------------------------------------------------
// 2. MIXIN (code reuse) - any class that "with Loggable"
//    gets log() and a log history without inheritance.
// ------------------------------------------------------------
mixin Loggable {
  final List<String> _logHistory = [];

  List<String> get logHistory => List.unmodifiable(_logHistory);

  void log(String message) {
    final entry = '[LOG] $message';
    _logHistory.add(entry);
    print(entry);
  }
}

// ------------------------------------------------------------
// 3. INTERFACE - a contract that classes must implement.
//    (In Dart, any class can be used as an interface via
//    "implements".)
// ------------------------------------------------------------
abstract class Reportable {
  String toReport();
}

// ------------------------------------------------------------
// 4. ABSTRACT CLASS - cannot be instantiated directly.
// ------------------------------------------------------------
abstract class Person implements Reportable {
  final String id;
  final String name;

  // Constructor
  Person(this.id, this.name);

  // Abstract members: subclasses MUST provide these.
  String get role;
  String getDetails();

  // Concrete method shared by all subclasses.
  void introduce() {
    print('Hello, I am $name ($role).');
  }

  @override
  String toReport() => '$role | $id | $name | ${getDetails()}';
}

// ------------------------------------------------------------
// 5. INHERITANCE - Student and Instructor extend Person.
//    Student also uses the Loggable mixin.
// ------------------------------------------------------------
class Student extends Person with Loggable {
  final String program;
  final List<Course> enrolledCourses = [];

  // Constructor (calls the parent constructor with super)
  Student(String id, String name, this.program) : super(id, name);

  @override
  String get role => 'Student';

  @override
  String getDetails() =>
      'Program: $program, Courses enrolled: ${enrolledCourses.length}';

  bool isEnrolledIn(String courseCode) =>
      enrolledCourses.any((course) => course.code == courseCode);

  void addCourse(Course course) {
    enrolledCourses.add(course);
    log('$name was added to ${course.code}.');
  }

  void removeCourse(Course course) {
    enrolledCourses.remove(course);
    log('$name was removed from ${course.code}.');
  }
}

class Instructor extends Person {
  final String department;

  Instructor(String id, String name, this.department) : super(id, name);

  @override
  String get role => 'Instructor';

  @override
  String getDetails() => 'Department: $department';
}

// ------------------------------------------------------------
// 6. COURSE CLASS - implements the Reportable interface.
// ------------------------------------------------------------
class Course implements Reportable {
  final String code;
  final String title;
  final int capacity;
  final Instructor instructor;
  final List<Student> students = [];

  Course(this.code, this.title, this.capacity, this.instructor);

  bool get isFull => students.length >= capacity;

  int get slotsLeft => capacity - students.length;

  @override
  String toReport() =>
      '$code - $title | Instructor: ${instructor.name} | '
      'Enrolled: ${students.length}/$capacity';
}

// ------------------------------------------------------------
// 7. SERVICE CLASS - the "system". Uses the mixin and contains
//    the asynchronous operations (Future + simulated delay).
// ------------------------------------------------------------
class LearningCenterService with Loggable {
  final Map<String, Student> _students = {};
  final Map<String, Course> _courses = {};

  // Simulates loading data from a remote server.
  Future<void> loadData() async {
    log('Loading data...');
    await Future.delayed(Duration(seconds: 2)); // simulated delay

    final inst1 = Instructor('I-001', 'Prof. Maria Santos', 'Information Technology');
    final inst2 = Instructor('I-002', 'Prof. Jose Reyes', 'Mathematics');

    final dart = Course('IT101', 'Intro to Dart Programming', 2, inst1);
    final web = Course('IT102', 'Web Development Basics', 3, inst1);
    final math = Course('MA101', 'Discrete Mathematics', 2, inst2);
    _courses[dart.code] = dart;
    _courses[web.code] = web;
    _courses[math.code] = math;

    final s1 = Student('S-001', 'Ana Dela Cruz', 'BSIT');
    final s2 = Student('S-002', 'Ben Garcia', 'BSIT');
    final s3 = Student('S-003', 'Carla Mendoza', 'BSCS');
    _students[s1.id] = s1;
    _students[s2.id] = s2;
    _students[s3.id] = s3;

    log('Data loaded: ${_courses.length} courses, ${_students.length} students.');
  }

  // Simulates a server-side enrollment request.
  // Throws EnrollmentException when a rule is broken.
  Future<void> enrollStudent(String studentId, String courseCode) async {
    log('Processing enrollment: $studentId -> $courseCode ...');
    await Future.delayed(Duration(seconds: 1)); // simulated delay

    final student = _students[studentId];
    if (student == null) {
      throw EnrollmentException('Student "$studentId" does not exist.');
    }

    final course = _courses[courseCode];
    if (course == null) {
      throw EnrollmentException('Course "$courseCode" does not exist.');
    }

    if (student.isEnrolledIn(courseCode)) {
      throw EnrollmentException(
          '${student.name} is already enrolled in $courseCode.');
    }

    if (course.isFull) {
      throw EnrollmentException('$courseCode is already full.');
    }

    course.students.add(student);
    student.addCourse(course);
    log('SUCCESS: ${student.name} enrolled in ${course.title}.');
  }

  // Simulates a drop request.
  Future<void> dropStudent(String studentId, String courseCode) async {
    log('Processing drop request: $studentId -> $courseCode ...');
    await Future.delayed(Duration(seconds: 1));

    final student = _students[studentId];
    final course = _courses[courseCode];

    if (student == null || course == null) {
      throw EnrollmentException('Invalid student or course.');
    }
    if (!student.isEnrolledIn(courseCode)) {
      throw EnrollmentException(
          '${student.name} is not enrolled in $courseCode.');
    }

    course.students.remove(student);
    student.removeCourse(course);
    log('SUCCESS: ${student.name} dropped ${course.title}.');
  }

  // Simulates generating a report (returns a value in the future).
  Future<String> generateReport() async {
    log('Generating report...');
    await Future.delayed(Duration(seconds: 1));

    final buffer = StringBuffer();
    buffer.writeln('========== LEARNING CENTER REPORT ==========');
    buffer.writeln('--- Courses ---');
    for (final course in _courses.values) {
      buffer.writeln(course.toReport());
    }
    buffer.writeln('--- Students ---');
    for (final student in _students.values) {
      buffer.writeln(student.toReport());
    }
    buffer.write('============================================');
    return buffer.toString();
  }

  // Helper that runs an action and handles errors so one failure
  // does not crash the whole program.
  Future<void> safely(String label, Future<void> Function() action) async {
    try {
      await action();
    } on EnrollmentException catch (e) {
      print('[ERROR] $label failed -> ${e.message}');
    } catch (e) {
      print('[UNEXPECTED ERROR] $label failed -> $e');
    }
  }
}

// ------------------------------------------------------------
// 8. MAIN - uses async/await correctly and try-catch.
// ------------------------------------------------------------
Future<void> main() async {
  print('=== Community Learning Center Enrollment Simulator ===\n');

  final service = LearningCenterService();

  try {
    // Step 1: Load data (await the Future).
    await service.loadData();

    // Step 2: Demonstrate polymorphism via the abstract class.
    print('\n--- Meet the people ---');
    final List<Person> people = [
      Instructor('I-100', 'Prof. Demo', 'IT'),
      Student('S-100', 'Demo Student', 'BSIT'),
    ];
    for (final person in people) {
      person.introduce();
    }

    // Step 3: Valid enrollments.
    print('\n--- Enrollment requests ---');
    await service.enrollStudent('S-001', 'IT101');
    await service.enrollStudent('S-002', 'IT101');

    // Step 4: Error cases - each is caught and reported.
    await service.safely(
        'Enroll S-003 in IT101 (full)', () => service.enrollStudent('S-003', 'IT101'));
    await service.safely(
        'Enroll S-001 in IT101 (duplicate)', () => service.enrollStudent('S-001', 'IT101'));
    await service.safely(
        'Enroll S-999 in IT102 (unknown student)', () => service.enrollStudent('S-999', 'IT102'));
    await service.safely(
        'Enroll S-003 in XX999 (unknown course)', () => service.enrollStudent('S-003', 'XX999'));

    // Step 5: Drop a course, then enroll the waiting student.
    print('\n--- Drop and re-enroll ---');
    await service.dropStudent('S-002', 'IT101');
    await service.enrollStudent('S-003', 'IT101');

    // Step 6: Print the final report.
    print('');
    final report = await service.generateReport();
    print(report);
  } on EnrollmentException catch (e) {
    print('[ERROR] $e');
  } catch (e) {
    print('[UNEXPECTED ERROR] $e');
  } finally {
    print('\nProgram finished. Total log entries: ${service.logHistory.length}');
  }
}
