import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kava_beats_app/Constants/book2.dart';
import 'package:kava_beats_app/Screens/Book1/book1.dart';
import 'package:kava_beats_app/Screens/Book2/book_detail_screen.dart';

class Book2Screen extends StatefulWidget {
  const Book2Screen({super.key});

  @override
  State<Book2Screen> createState() => _Book2ScreenState();
}

class _Book2ScreenState extends State<Book2Screen> {
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
  List<Book> searchList = [];
  @override
  void initState() {
    super.initState();
    fetchBooks();
    // uploadBook();
  }

  uploadBook() async {
    for (var e in book2) {
      FirebaseFirestore.instance.collection('book2').doc().set({
        "title": "${e['title']}",
        "content": "${e['description']}",
      });
      await Future.delayed(Duration(milliseconds: 100));
      print("IUploading done");
    }
    print("IUploading Close");
  }

  List<Book> fetchedBooks = [];
  Future<void> fetchBooks() async {
    try {
      setState(() {
        loading = true;
      });
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('book2').get();

      List<Book> data = snapshot.docs.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, dynamic> docData =
            entry.value.data() as Map<String, dynamic>;

        return Book(
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
                      //search logic
                      // _searchList.clear();

                      // for (var i in _list) {
                      //   if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                      //       i.email.toLowerCase().contains(val.toLowerCase())) {
                      //     _searchList.add(i);
                      //     setState(() {
                      //       _searchList;
                      //     });
                      //   }
                      // }
                    },
                  )
                : const Text(
                    "HIVA FAKALOTU",
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
              // searchField(
              //     context: context,
              //     hint: "Search",
              //     onChanged: (value) {
              //       // searchTitle(value);
              //     }),
              SizedBox(
                  height: height * 0.85,
                  child: loading
                      ? Center(
                          child: CircularProgressIndicator(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
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
                                                          BookDetailScreen(
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

class Book {
  final String number;
  final String title;
  final String? content;

  Book({
    required this.number,
    required this.title,
    this.content,
  });
}
