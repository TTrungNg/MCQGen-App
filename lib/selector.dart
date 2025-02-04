import 'package:flutter/material.dart';
import 'package:mcqgen_app/drop_down_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mcqgen_app/model_api.dart';
import 'package:http/http.dart' as http;

class Selector extends StatefulWidget {
  final Function(Map<String, String>) addMessage;
  const Selector({required this.addMessage, super.key});

  @override
  State<Selector> createState() => _SelectorState();
}

class _SelectorState extends State<Selector> {
  String bookButtonTriggered = "";
  String testTypeButtonTriggered = "";
  String dropDownValue = "";
  bool isLoading = false;

  void setQueryData(String queryData) {
    dropDownValue = queryData;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            bookButtonTriggered = 'Canh Dieu';
                          });
                        },
                        style: bookButtonTriggered == 'Canh Dieu'
                            ? ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 0, 11, 135),
                              )
                            : ElevatedButton.styleFrom(),
                        child: Text(
                          'Cánh Diều',
                          style: bookButtonTriggered == 'Canh Dieu'
                              ? const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)
                              : const TextStyle(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            bookButtonTriggered = 'Ket noi tri thuc';
                          });
                        },
                        style: bookButtonTriggered == 'Ket noi tri thuc'
                            ? ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 0, 11, 135),
                              )
                            : ElevatedButton.styleFrom(),
                        child: Text(
                          'Kết nối tri thức (Incoming)',
                          style: bookButtonTriggered == 'Ket noi tri thuc'
                              ? const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)
                              : const TextStyle(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            bookButtonTriggered = 'Chan troi sang tao';
                          });
                        },
                        style: bookButtonTriggered == 'Chan troi sang tao'
                            ? ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 0, 11, 135),
                              )
                            : ElevatedButton.styleFrom(),
                        child: Text(
                          'Chân trời sáng tạo (Incoming)',
                          style: bookButtonTriggered == 'Chan troi sang tao'
                              ? const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)
                              : const TextStyle(),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                        child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          testTypeButtonTriggered = 'Lesson Test';
                        });
                      },
                      style: testTypeButtonTriggered == 'Lesson Test'
                          ? ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 0, 11, 135),
                            )
                          : ElevatedButton.styleFrom(),
                      child: Text(
                        'Lesson Test',
                        style: testTypeButtonTriggered == 'Lesson Test'
                            ? const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)
                            : const TextStyle(),
                      ),
                    )),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            testTypeButtonTriggered = 'Midterm Test';
                          });
                        },
                        style: testTypeButtonTriggered == 'Midterm Test'
                            ? ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 0, 11, 135),
                              )
                            : ElevatedButton.styleFrom(),
                        child: Text(
                          'Midterm Test (Incoming)',
                          style: testTypeButtonTriggered == 'Midterm Test'
                              ? const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)
                              : const TextStyle(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            testTypeButtonTriggered = 'Final Test';
                          });
                        },
                        style: testTypeButtonTriggered == 'Final Test'
                            ? ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 0, 11, 135),
                              )
                            : ElevatedButton.styleFrom(),
                        child: Text(
                          'Final Test (Incoming)',
                          style: testTypeButtonTriggered == 'Final Test'
                              ? const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)
                              : const TextStyle(),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Expanded(
                child: DropDownWidget(
                  setQueryData: setQueryData,
                  bookButtonTriggered: bookButtonTriggered,
                  testTypeButtonTriggered: testTypeButtonTriggered,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          width: 42,
        ),
        SizedBox(
          height: double.infinity,
          width: 120,
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () async {
                    isLoading = true;
                    widget
                        .addMessage({"role": "user", "context": dropDownValue});

                    final db = FirebaseFirestore.instance;

                    db
                        .collection(bookButtonTriggered)
                        .where("lesson", isEqualTo: dropDownValue)
                        .get()
                        .then(
                      (querySnapshot) async {
                        print("Successfully completed query");
                        List<String> contextInputs = [];
                        for (var docSnapshot in querySnapshot.docs) {
                          contextInputs.add(docSnapshot.data()['context']);
                        }
                        final client = http.Client();
                        final api = ModelApi(client);

                        final results =
                            await api.processMultipleContexts(contextInputs);

                        for (String result in results) {
                          widget.addMessage(
                              {"role": 'system', "context": result});
                        }

                        isLoading = false;
                      },
                      onError: (e) {
                        widget.addMessage({
                          "role": "system",
                          "context": "Error completing: $e"
                        });
                        isLoading = false;
                      },
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
            child: const Text(
              "Generate",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
