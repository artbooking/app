import 'dart:async';

import 'package:artbooking/actions/books.dart';
import 'package:artbooking/components/animated_app_icon.dart';
import 'package:artbooking/components/book_card.dart';
import 'package:artbooking/components/create_or_edit_book_dialog.dart';
import 'package:artbooking/components/main_app_bar.dart';
import 'package:artbooking/components/popup_menu_item_icon.dart';
import 'package:artbooking/components/sliver_edge_padding.dart';
import 'package:artbooking/components/text_rectangle_button.dart';
import 'package:artbooking/components/themed_dialog.dart';
import 'package:artbooking/router/app_router_nav_args.dart';
import 'package:artbooking/screens/my_book_page.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/state/user.dart';
import 'package:artbooking/types/book.dart';
import 'package:artbooking/types/enums.dart';
import 'package:artbooking/types/one_book_op_resp.dart';
import 'package:artbooking/utils/app_logger.dart';
import 'package:artbooking/utils/fonts.dart';
import 'package:artbooking/utils/snack.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';
import 'package:unicons/unicons.dart';
import 'package:vrouter/vrouter.dart';

/// A stream subscription returning a map withing a query snapshot.
typedef SnapshotStreamSubscription
    = StreamSubscription<QuerySnapshot<Map<String, dynamic>>>;

/// A query containing a map.
typedef QueryMap = Query<Map<String, dynamic>>;

/// A document change containing a map.
typedef DocumentChangeMap = DocumentChange<Map<String, dynamic>>;

/// A query document snapshot containing a map.
typedef DocSnapMap = QueryDocumentSnapshot<Map<String, dynamic>>;

class MyBooksPage extends StatefulWidget {
  static String route = '/dashboard/books';

  @override
  _MyBooksPageState createState() => _MyBooksPageState();
}

class _MyBooksPageState extends State<MyBooksPage> {
  bool _isLoading = false;
  bool _descending = true;
  bool _hasNext = true;
  bool _isFabVisible = false;
  bool _isLoadingMore = false;
  bool _forceMultiSelect = false;
  bool _isCreating = false;

  DocumentSnapshot? _lastFirestoreDoc;

  final _books = <Book>[];
  final _focusNode = FocusNode();

  final _popupMenuEntries = <PopupMenuEntry<BookItemAction>>[
    PopupMenuItemIcon(
      icon: Icon(UniconsLine.trash),
      textLabel: "delete".tr(),
      value: BookItemAction.delete,
    ),
  ];

  int _limit = 20;

  Map<String?, Book> _multiSelectedItems = Map();

  ScrollController _scrollController = ScrollController();

  TextEditingController? _newBookNameController;
  String _newBookName = '';
  String _newBookDescription = '';

  SnapshotStreamSubscription? _streamSubscription;

  @override
  initState() {
    super.initState();
    _newBookNameController = TextEditingController();
    fetchManyBooks();
  }

  @override
  void dispose() {
    _newBookNameController?.dispose();
    _streamSubscription?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: fab(),
      body: NotificationListener<ScrollNotification>(
        onNotification: onNotification,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            SliverEdgePadding(),
            MainAppBar(),
            header(),
            body(),
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 100.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget body() {
    if (_isLoading) {
      return SliverList(
        delegate: SliverChildListDelegate.fixed([
          Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: AnimatedAppIcon(textTitle: "loading_books".tr()),
          ),
        ]),
      );
    }

    if (_books.isEmpty) {
      return emptyView();
    }

    return gridView();
  }

  Widget createButton() {
    return TextRectangleButton(
      onPressed: showBookCreationDialog,
      icon: Icon(UniconsLine.plus),
      label: Text('create'.tr()),
      primary: Colors.black38,
    );
  }

  Widget defaultActionsToolbar() {
    if (_multiSelectedItems.isNotEmpty) {
      return Container();
    }

    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: [
        createButton(),
        multiSelectButton(),
        sortButton(),
      ],
    );
  }

  Widget emptyView() {
    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 40.0,
        left: 50.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 12.0,
                ),
                child: Text(
                  "lonely_there".tr(),
                  style: TextStyle(
                    fontSize: 32.0,
                    color: stateColors.primary,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 12.0,
                ),
                child: Opacity(
                  opacity: 0.6,
                  child: Text(
                    "books_none_created".tr(),
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: showBookCreationDialog,
                icon: Icon(UniconsLine.book_medical),
                label: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "create".tr(),
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  Widget fab() {
    if (!_isFabVisible) {
      return FloatingActionButton(
        onPressed: fetchManyBooks,
        backgroundColor: stateColors.primary,
        foregroundColor: Colors.white,
        child: Icon(UniconsLine.refresh),
      );
    }

    return FloatingActionButton(
      onPressed: () {
        _scrollController.animateTo(
          0.0,
          duration: 1.seconds,
          curve: Curves.easeOut,
        );
      },
      backgroundColor: stateColors.primary,
      foregroundColor: Colors.white,
      child: Icon(UniconsLine.arrow_up),
    );
  }

  Widget header() {
    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 60.0,
        left: 50.0,
        bottom: 24.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              children: [
                Opacity(
                  opacity: 0.8,
                  child: Text(
                    "books".tr().toUpperCase(),
                    style: FontsUtils.mainStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (_isCreating)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 24.0,
                      top: 12.0,
                    ),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
          defaultActionsToolbar(),
          multiSelectToolbar(),
        ]),
      ),
    );
  }

  Widget gridView() {
    final selectionMode = _forceMultiSelect || _multiSelectedItems.isNotEmpty;

    return SliverPadding(
      padding: const EdgeInsets.all(40.0),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          mainAxisExtent: 410.0,
          maxCrossAxisExtent: 340.0,
          mainAxisSpacing: 20.0,
          crossAxisSpacing: 20.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final book = _books.elementAt(index);
            final selected = _multiSelectedItems.containsKey(book.id);

            return BookCard(
              book: book,
              selected: selected,
              selectionMode: selectionMode,
              onTap: () => onTap(book),
              onPopupMenuItemSelected: onPopupMenuItemSelected,
              popupMenuEntries: _popupMenuEntries,
              onLongPress: (selected) {
                if (selected) {
                  setState(() {
                    _multiSelectedItems.remove(book.id);
                  });

                  return;
                }

                setState(() {
                  _multiSelectedItems.putIfAbsent(book.id, () => book);
                });
              },
            );
          },
          childCount: _books.length,
        ),
      ),
    );
  }

  Widget multiSelectButton() {
    return TextRectangleButton(
      onPressed: () {
        setState(() {
          _forceMultiSelect = !_forceMultiSelect;
        });
      },
      icon: Icon(UniconsLine.layers_alt),
      label: Text('multi_select'.tr()),
      primary: _forceMultiSelect ? Colors.lightGreen : Colors.black38,
    );
  }

  Widget multiSelectToolbar() {
    if (_multiSelectedItems.isEmpty) {
      return Container();
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Opacity(
          opacity: 0.6,
          child: Text(
            "multi_items_selected"
                .tr(args: [_multiSelectedItems.length.toString()]),
            style: TextStyle(
              fontSize: 30.0,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            height: 25.0,
            width: 2.0,
            color: Colors.black12,
          ),
        ),
        TextButton.icon(
          onPressed: () {
            setState(() {
              _multiSelectedItems.clear();
            });
          },
          icon: Icon(Icons.border_clear),
          label: Text(
            "clear_selection".tr(),
          ),
        ),
        TextButton.icon(
          onPressed: () {
            _books.forEach((illustration) {
              _multiSelectedItems.putIfAbsent(
                  illustration.id, () => illustration);
            });

            setState(() {});
          },
          icon: Icon(Icons.select_all),
          label: Text("select_all".tr()),
        ),
        TextButton.icon(
          onPressed: confirmDeleteManyBooks,
          style: TextButton.styleFrom(
            primary: Colors.red,
          ),
          icon: Icon(Icons.delete_outline),
          label: Text("delete".tr()),
        ),
      ],
    );
  }

  Widget sortButton() {
    return TextRectangleButton(
      onPressed: () {},
      icon: Icon(UniconsLine.sort),
      label: Text('sort'.tr()),
      primary: Colors.black38,
    );
  }

  /// Fire when a new document has been created in Firestore.
  /// Add the corresponding document in the UI.
  void addStreamingDoc(DocumentChangeMap documentChange) {
    final data = documentChange.doc.data();

    if (data == null) {
      return;
    }

    setState(() {
      data['id'] = documentChange.doc.id;
      final book = Book.fromJSON(data);
      _books.insert(0, book);
    });
  }

  /// Show a dialog to confirm multiple books deletion.
  void confirmDeleteManyBooks() async {
    showDialog(
      context: context,
      builder: (context) {
        return ThemedDialog(
          focusNode: _focusNode,
          title: Column(
            children: [
              Opacity(
                opacity: 0.8,
                child: Text(
                  "books_delete".tr().toUpperCase(),
                  style: FontsUtils.mainStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                width: 300.0,
                padding: const EdgeInsets.only(top: 8.0),
                child: Opacity(
                  opacity: 0.4,
                  child: Text(
                    "books_delete_description".tr(),
                    textAlign: TextAlign.center,
                    style: FontsUtils.mainStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(),
          textButtonValidation: "delete".tr(),
          onCancel: context.router.pop,
          onValidate: () {
            deleteSelection();
            context.router.pop();
          },
        );
      },
    );
  }

  /// Show a dialog to confirm a single book deletion.
  void confirmDeleteOneBook(Book book, int index) async {
    showDialog(
      context: context,
      builder: (context) {
        return ThemedDialog(
          focusNode: _focusNode,
          title: Column(
            children: [
              Opacity(
                opacity: 0.8,
                child: Text(
                  "book_delete".tr().toUpperCase(),
                  style: FontsUtils.mainStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                width: 300.0,
                padding: const EdgeInsets.only(top: 8.0),
                child: Opacity(
                  opacity: 0.4,
                  child: Text(
                    "book_delete_description".tr(),
                    textAlign: TextAlign.center,
                    style: FontsUtils.mainStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(),
          textButtonValidation: "delete".tr(),
          onCancel: context.router.pop,
          onValidate: () {
            deleteBook(book, index);
            context.router.pop();
          },
        );
      },
    );
  }

  void createBook() async {
    setState(() => _isCreating = true);

    final OneBookOpResp response = await BooksActions.createOne(
      name: _newBookName,
      description: _newBookDescription,
    );

    setState(() => _isCreating = false);

    if (!response.success) {
      Snack.e(
        context: context,
        message: "book_creation_error".tr(),
      );

      return;
    }

    Snack.s(
      context: context,
      message: "book_creation_success".tr(),
    );
  }

  void deleteSelection() async {
    _multiSelectedItems.entries.forEach((multiSelectItem) {
      _books.removeWhere((item) => item.id == multiSelectItem.key);
    });

    final copyItems = _multiSelectedItems.values.toList();
    final booksIds = _multiSelectedItems.keys.toList();

    setState(() {
      _multiSelectedItems.clear();
      _forceMultiSelect = false;
    });

    final response = await BooksActions.deleteMany(
      bookIds: booksIds,
    );

    if (response.hasErrors) {
      Snack.e(
        context: context,
        message: "illustrations_delete_error".tr(),
      );

      _books.addAll(copyItems);
    }
  }

  void fetchManyBooks() async {
    setState(() {
      _isLoading = true;
      _hasNext = true;
      _books.clear();
    });

    try {
      final query = FirebaseFirestore.instance
          .collection('books')
          .where('user.id', isEqualTo: stateUser.userAuth!.uid)
          .orderBy('createdAt', descending: _descending)
          .limit(_limit);

      startListenningToData(query);
      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _isLoading = false;
          _hasNext = false;
        });

        return;
      }

      for (DocSnapMap document in snapshot.docs) {
        final data = document.data();
        data['id'] = document.id;

        _books.add(Book.fromJSON(data));
      }

      setState(() {
        _lastFirestoreDoc = snapshot.docs.last;
        _hasNext = snapshot.docs.length == _limit;
      });
    } catch (error) {
      appLogger.e(error);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void fetchManyBooksMore() async {
    if (!_hasNext || _lastFirestoreDoc == null) {
      return;
    }

    _isLoadingMore = true;

    try {
      final userAuth = FirebaseAuth.instance.currentUser;

      if (userAuth == null) {
        throw Exception("User is not authenticated.");
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('books')
          .where('user.id', isEqualTo: userAuth.uid)
          .orderBy('createdAt', descending: _descending)
          .limit(_limit)
          .startAfterDocument(_lastFirestoreDoc!)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _hasNext = false;
          _isLoadingMore = false;
        });

        return;
      }

      for (DocSnapMap document in snapshot.docs) {
        final data = document.data();
        data['id'] = document.id;

        _books.add(Book.fromJSON(data));
      }

      setState(() {
        _isLoadingMore = false;
        _lastFirestoreDoc = snapshot.docs.last;
        _hasNext = snapshot.docs.length == _limit;
      });
    } catch (error) {
      appLogger.e(error);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// On scroll notifications.
  bool onNotification(ScrollNotification notification) {
    // FAB visibility
    if (notification.metrics.pixels < 50 && _isFabVisible) {
      setState(() {
        _isFabVisible = false;
      });
    } else if (notification.metrics.pixels > 50 && !_isFabVisible) {
      setState(() {
        _isFabVisible = true;
      });
    }

    if (notification.metrics.pixels < notification.metrics.maxScrollExtent) {
      return false;
    }

    if (_hasNext && !_isLoadingMore) {
      fetchManyBooksMore();
    }

    return false;
  }

  /// Fire when a new document has been delete from Firestore.
  /// Delete the corresponding document from the UI.
  void removeStreamingDoc(DocumentChangeMap documentChange) {
    setState(() {
      _books.removeWhere((book) => book.id == documentChange.doc.id);
    });
  }

  void showBookCreationDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateOrEditBookDialog(
        textTitle: "book_create".tr().toUpperCase(),
        textSubtitle: "book_create_description".tr(),
        nameController: _newBookNameController,
        onNameChanged: (newValue) {
          _newBookName = newValue;
        },
        onDescriptionChanged: (newValue) {
          _newBookDescription = newValue;
        },
        onCancel: context.router.pop,
        onSubmitted: (value) {
          createBook();
          context.router.pop();
        },
      ),
    );
  }

  /// Listen to the last Firestore query of this page.
  void startListenningToData(QueryMap query) {
    _streamSubscription = query.snapshots().skip(1).listen(
      (snapshot) {
        for (DocumentChangeMap documentChange in snapshot.docChanges) {
          switch (documentChange.type) {
            case DocumentChangeType.added:
              addStreamingDoc(documentChange);
              break;
            case DocumentChangeType.modified:
              updateStreamingDoc(documentChange);
              break;
            case DocumentChangeType.removed:
              removeStreamingDoc(documentChange);
              break;
          }
        }
      },
      onError: (error) {
        appLogger.e(error);
      },
    );
  }

  /// Fire when a new document has been updated in Firestore.
  /// Update the corresponding document in the UI.
  void updateStreamingDoc(DocumentChangeMap documentChange) {
    try {
      final data = documentChange.doc.data();
      if (data == null) {
        return;
      }

      final int index = _books.indexWhere(
        (book) => book.id == documentChange.doc.id,
      );

      data['id'] = documentChange.doc.id;
      final updatedBook = Book.fromJSON(data);

      setState(() {
        _books.removeAt(index);
        _books.insert(index, updatedBook);
      });
    } on Exception catch (error) {
      appLogger.e(
        "The document with the id ${documentChange.doc.id} "
        "doesn't exist in the books list.",
      );

      appLogger.e(error);
    }
  }

  void deleteBook(Book book, int index) async {
    setState(() => _books.removeAt(index));

    final response = await BooksActions.deleteOne(
      bookId: book.id,
    );

    if (response.success) {
      return;
    }

    setState(() => _books.insert(index, book));

    Snack.e(
      context: context,
      message: response.error.details,
    );
  }

  void multiSelectBook(book) {
    final selected = _multiSelectedItems.containsKey(book.id);

    if (selected) {
      setState(() {
        _multiSelectedItems.remove(book.id);
        _forceMultiSelect = _multiSelectedItems.length > 0;
      });

      return;
    }

    setState(() {
      _multiSelectedItems.putIfAbsent(book.id, () => book);
    });
  }

  void navigateToBook(Book book) {
    AppRouterNavArgs.lastBookSelected = book;

    // Navigator.of(context).push(
    //   PageRouteBuilder(
    //     pageBuilder: (context, animation, secondaryAnimation) {
    //       return MyBookPage(
    //         // bookId: book.id,
    //         book: book,
    //       );
    //     },
    //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
    //       return child;
    //     },
    //   ),
    // );

    context.vRouter.pushNamed(
      // MyBookPage.path,
      'my_book',
      pathParameters: {'bookId': book.id},
    );
  }

  /// When [onTap] event fires on a book.
  void onTap(Book book) {
    if (_multiSelectedItems.isEmpty && !_forceMultiSelect) {
      navigateToBook(book);
      return;
    }

    multiSelectBook(book);
  }

  void onPopupMenuItemSelected(
    BookItemAction action,
    int index,
    Book book,
  ) {
    switch (action) {
      case BookItemAction.delete:
        confirmDeleteOneBook(book, index);
        break;
      default:
    }
  }
}
