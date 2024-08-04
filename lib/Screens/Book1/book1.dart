import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kava_beats_app/Screens/Book1/book1_detail_screen.dart';

import '../../Constants/book1.dart';

class Book1Screen extends StatefulWidget {
  const Book1Screen({super.key});

  @override
  State<Book1Screen> createState() => _Book1ScreenState();
}

class _Book1ScreenState extends State<Book1Screen> {
  void searchBooks(String query) {
    setState(() {
      searchList = fetchedBooks.where((book) {
        return book.title.toLowerCase().contains(query.toLowerCase()) ||
            book.number.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  bool _isSearching = false;
  bool loading = false;
  List<Book1> searchList = [];
  @override
  void initState() {
    super.initState();
    // searchList = List.from(books);
    // searchList.addAll(books);
    // uploadBook();
    fetchBooks();
  }

  uploadBook() async {
    for (var e in book1) {
      FirebaseFirestore.instance.collection('book1').doc().set({
        "title": "${e['title']}",
        "content": "${e['description']}",
      });
      await Future.delayed(Duration(milliseconds: 100));
      print("IUploading Book1 done");
    }
  }

  List<Book1> fetchedBooks = [];
  Future<void> fetchBooks() async {
    try {
      setState(() {
        loading = true;
      });
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('book1').get();

      List<Book1> data = snapshot.docs.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, dynamic> docData =
            entry.value.data() as Map<String, dynamic>;

        return Book1(
          number:
              "${index + 1}", // Adding 1 to the index to start from 1 instead of 0
          title: docData['title'],
          content: docData['content'],
        );
      }).toList();
      // data.sort((a, b) => int.parse(a.number).compareTo(int.parse(b.number)));

      setState(() {
        fetchedBooks = data;
        searchList.addAll(fetchedBooks);
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          // backgroundColor: redClr,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            elevation: Theme.of(context).appBarTheme.elevation,
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            title: _isSearching
                ? TextFormField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search',
                      hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    cursorColor: Colors.white,
                    autofocus: true,
                    style: const TextStyle(
                      fontSize: 16,
                      letterSpacing: 0.5,
                      color: Colors.white,
                    ),
                    //when search text changes then updated search list
                    onChanged: (val) {
                      searchBooks(val);
                    },
                  )
                : const Text(
                    "HIVA KAKALA",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
            actions: [
              IconButton(
                  tooltip: "search",
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                  icon: Icon(
                    _isSearching
                        ? CupertinoIcons.clear_circled_solid
                        : CupertinoIcons.search,
                    color: Colors.white,
                  )),
            ],
          ),
          body: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                  height: height * 0.85,
                  child: loading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).brightness ==
                                    Brightness.dark
                                ? Colors.white
                                : Theme.of(context).appBarTheme.backgroundColor,
                          ),
                        )
                      : fetchedBooks.isEmpty
                          ? Center(
                              child:
                                  Text("Oops! No Data please try again later"),
                            )
                          : searchList.isNotEmpty
                              ? ListView.builder(
                                  itemCount: searchList.length,
                                  physics: const BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 10, right: 0, left: 0),
                                      child: Card(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 20),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: ListTile(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          Book1DetailScreen(
                                                            book: searchList[
                                                                index],
                                                          )));
                                            },
                                            horizontalTitleGap: 10,
                                            leading: Padding(
                                              padding: const EdgeInsets.only(
                                                left: 5,
                                              ),
                                              child: Text(
                                                searchList[index]
                                                    .number
                                                    .toString(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2,
                                              ),
                                            ),
                                            title: Text(
                                                searchList[index]
                                                    .title
                                                    .toString(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2),
                                            // trailing: const Icon(
                                            //   Icons.arrow_forward,
                                            //   color: Colors.black,
                                            // ),
                                          ),
                                        ),
                                      ),
                                    );
                                  })
                              : const Center(
                                  child: Text(
                                  "No data found",
                                )))
            ],
          ),
        ),
      ),
    );
  }
}

class Book1 {
  final String number;
  final String title;
  final String? content;

  Book1({
    required this.number,
    required this.title,
    this.content,
  });
}
