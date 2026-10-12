
 
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RegistrationPage(),
    );
  }
}

// PAGE 1: USER REGISTRATION
class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final nameController = TextEditingController();
  final sectionController = TextEditingController();
  final courseController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    sectionController.dispose();
    courseController.dispose();
    super.dispose();
  }

  void nextPage() {
    if (nameController.text.trim().isEmpty ||
        sectionController.text.trim().isEmpty ||
        courseController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubjectEnrollmentPage(
          name: nameController.text.trim(),
          section: sectionController.text.trim(),
          course: courseController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Registration')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Name'),
          TextField(
            controller: nameController,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 15),
          const Text('Section'),
          TextField(controller: sectionController),
          const SizedBox(height: 15),
          const Text('Course'),
          TextField(
            controller: courseController,
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: nextPage,
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}

// PAGE 2: SUBJECT ENROLLMENT
class SubjectEnrollmentPage extends StatefulWidget {
  final String name;
  final String section;
  final String course;

  const SubjectEnrollmentPage({
    super.key,
    required this.name,
    required this.section,
    required this.course,
  });

  @override
  State<SubjectEnrollmentPage> createState() =>
      _SubjectEnrollmentPageState();
}

class _SubjectEnrollmentPageState extends State<SubjectEnrollmentPage> {
  final subject1Controller = TextEditingController();
  final time1Controller = TextEditingController();
  final subject2Controller = TextEditingController();
  final time2Controller = TextEditingController();

  @override
  void dispose() {
    subject1Controller.dispose();
    time1Controller.dispose();
    subject2Controller.dispose();
    time2Controller.dispose();
    super.dispose();
  }

  void nextPage() {
    if (subject1Controller.text.trim().isEmpty ||
        time1Controller.text.trim().isEmpty ||
        subject2Controller.text.trim().isEmpty ||
        time2Controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all subject fields.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubjectVerificationPage(
          name: widget.name,
          section: widget.section,
          course: widget.course,
          subject1: subject1Controller.text.trim(),
          time1: time1Controller.text.trim(),
          subject2: subject2Controller.text.trim(),
          time2: time2Controller.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subject Enrollment')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Subject'),
          TextField(
            controller: subject1Controller,
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 15),
          const Text('Time'),
          TextField(controller: time1Controller),
          const SizedBox(height: 20),
          const Text('Another Subject'),
          TextField(
            controller: subject2Controller,
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 15),
          const Text('Time'),
          TextField(controller: time2Controller),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: nextPage,
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}

// PAGE 3: SUBJECT VERIFICATION
class SubjectVerificationPage extends StatefulWidget {
  final String name;
  final String section;
  final String course;
  final String subject1;
  final String time1;
  final String subject2;
  final String time2;

  const SubjectVerificationPage({
    super.key,
    required this.name,
    required this.section,
    required this.course,
    required this.subject1,
    required this.time1,
    required this.subject2,
    required this.time2,
  });

  @override
  State<SubjectVerificationPage> createState() =>
      _SubjectVerificationPageState();
}

class _SubjectVerificationPageState
    extends State<SubjectVerificationPage> {
  bool isSaving = false;

  Future<void> saveEnrollment() async {
    setState(() => isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('enrollments').add({
        'name': widget.name,
        'section': widget.section,
        'course': widget.course,
        'subjects': [
          {'subject': widget.subject1, 'time': widget.time1},
          {'subject': widget.subject2, 'time': widget.time2},
        ],
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enrollment saved successfully!')),
      );

      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save enrollment: $error')),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subject Verification')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Name: ${widget.name}'),
          const SizedBox(height: 12),
          Text('Section: ${widget.section}'),
          const SizedBox(height: 12),
          Text('Course: ${widget.course}'),
          const SizedBox(height: 12),
          Text('Subject: ${widget.subject1}'),
          const SizedBox(height: 12),
          Text('Time: ${widget.time1}'),
          const SizedBox(height: 12),
          Text('Subject: ${widget.subject2}'),
          const SizedBox(height: 12),
          Text('Time: ${widget.time2}'),
          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: isSaving ? null : saveEnrollment,
            child: Text(isSaving ? 'Saving...' : 'Save'),
          ),
        ],
      ),
    );
  }
}