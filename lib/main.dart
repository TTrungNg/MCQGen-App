import 'package:flutter/material.dart';
import 'package:mcqgen_app/selector.dart';
import 'package:firebase_core/firebase_core.dart';
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter MCQ Gen App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 54, 88, 237)),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void addMessage(Map<String, String> data) {
    setState(() {
      conversation.add(data);
    });
  }

  List<Map<String, String>> conversation = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Flutter MCQ Gen App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png',
                width: 100,
              ),
              const SizedBox(
                height: 8,
              ),
              Expanded(
                  child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer, // Border color
                    width: 2.0, // Border width
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ListView.builder(
                    itemBuilder: (context, index) => Align(
                          alignment: conversation[index]['role'] == "user"
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: conversation[index]['role'] == "user"
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSecondary,
                                borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: Text(
                              conversation[index]['context']!,
                              style: TextStyle(
                                  color: conversation[index]['role'] == "user"
                                      ? Colors.white
                                      : Colors.black),
                            ),
                          ),
                        ),
                    itemCount: conversation.length),
              )),
              const SizedBox(
                height: 8,
              ),
              SizedBox(
                  height: 160,
                  child: Selector(
                    addMessage: addMessage,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
