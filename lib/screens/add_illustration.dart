import 'package:artbooking/components/default_app_bar.dart';
import 'package:artbooking/components/illustration_card.dart';
import 'package:artbooking/state/upload_manager.dart';
import 'package:artbooking/state/colors.dart';
import 'package:artbooking/types/enums.dart';
import 'package:artbooking/types/upload_task.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:unicons/unicons.dart';

class AddIllustration extends StatefulWidget {
  @override
  _AddIllustrationState createState() => _AddIllustrationState();
}

class _AddIllustrationState extends State<AddIllustration> {
  bool isLoading = false;

  ScrollController _scrollController = ScrollController();
  final uploadTasks = <UploadTask>[];
  final doneTasks = <UploadTask>[];

  final files = <String>[];

  ContentVisibility imageVisibility = ContentVisibility.public;

  ReactionDisposer _filesReactionDisposer;

  @override
  initState() {
    super.initState();
    checkUploadQueue();
  }

  @override
  void dispose() {
    _filesReactionDisposer?.reaction?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          DefaultAppBar(),
          headerAndBody(),
          successImagesText(),
          successImagesGrid(),
          emptyView(),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 200.0),
          ),
        ],
      ),
    );
  }

  Widget headerAndBody() {
    return SliverList(
      delegate: SliverChildListDelegate([
        header(),
        uploadsListProgress(),
      ]),
    );
  }

  Widget emptyView() {
    if (uploadTasks.isNotEmpty || doneTasks.isNotEmpty) {
      return SliverPadding(
        padding: EdgeInsets.zero,
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(left: 80.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Nothing to show",
                style: TextStyle(
                  fontSize: 26.0,
                ),
              ),
              Opacity(
                opacity: 0.6,
                child: Text(
                  "Try uploading an image file to fill up this space",
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  Widget header() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 60.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 20.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Upload',
                style: TextStyle(
                  fontSize: 80.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (isLoading)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
          ),
          Wrap(
            spacing: 20.0,
            runSpacing: 20.0,
            children: [
              OutlinedButton.icon(
                onPressed: pickImage,
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Icon(UniconsLine.upload),
                ),
                label: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text('Upload more'),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Icon(UniconsLine.times),
                ),
                label: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text('Clear all'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget uploadsListProgress() {
    return Padding(
      padding: const EdgeInsets.only(left: 80.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: uploadTasks.map((uploadTask) {
          return Container(
            padding: const EdgeInsets.all(10.0),
            height: 100.0,
            width: 200.0,
            child: Column(
              children: [
                Text(
                  uploadTask.filename,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                uploadProgress(uploadTask),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget uploadProgress(uploadTask) {
    return Container();
    // return StreamBuilder<fb.UploadTaskSnapshot>(
    //   stream: uploadTask.task.future.asStream(),
    //   builder: (context, snapshot) {
    //     Widget progressBar = Padding(padding: EdgeInsets.zero);
    //     final event = snapshot?.data;

    //     double progressPercent =
    //         event != null ? event.bytesTransferred / event.totalBytes * 100 : 0;

    //     if (snapshot.connectionState == ConnectionState.none) {
    //       progressPercent = 0;
    //     }

    //     if (progressPercent == 100) {
    //     } else if (progressPercent > 0) {
    //       progressBar = LinearProgressIndicator(
    //         value: progressPercent,
    //       );
    //     }

    //     return Stack(
    //       children: <Widget>[
    //         // uploadText(progressPercent),
    //         progressBar,
    //       ],
    //     );
    //   },
    // );
  }

  Widget successImagesGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: 60.0,
        vertical: 60.0,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300.0,
          mainAxisSpacing: 20.0,
          crossAxisSpacing: 20.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final doneTask = doneTasks.elementAt(index);
            final illustration = doneTask.illustration;

            return IllustrationCard(
              illustration: illustration,
              onBeforeDelete: () {
                setState(() {
                  doneTasks.removeAt(index);
                });
              },
              onAfterDelete: (response) {
                if (response.success) {
                  return;
                }

                setState(() {
                  doneTasks.insert(index, doneTask);
                });
              },
            );
          },
          childCount: doneTasks.length,
        ),
      ),
    );
  }

  Widget successImagesText() {
    if (doneTasks.isEmpty) {
      return SliverList(
        delegate: SliverChildListDelegate.fixed([
          Container(),
        ]),
      );
    }

    final illustrationsText =
        doneTasks.length > 1 ? 'illustrations' : 'illustration';

    return SliverList(
      delegate: SliverChildListDelegate.fixed([
        Padding(
          padding: const EdgeInsets.only(
            left: 60.0,
            right: 60.0,
            top: 40.0,
          ),
          child: Wrap(
            spacing: 10.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.check, size: 28.0),
              Opacity(
                opacity: 0.6,
                child: Text(
                  "You've successfully uploaded ${doneTasks.length} $illustrationsText",
                  style: TextStyle(
                    fontSize: 24.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget metaData() {
    return SizedBox(
      width: 300.0,
      child: Column(
        children: <Widget>[
          Center(
            child: SizedBox(
              width: 300.0,
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(7.0)),
                    borderSide: BorderSide(),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 20.0,
              bottom: 40.0,
            ),
            child: TextField(
              maxLines: null,
              autofocus: true,
              // focusNode: nameFocusNode,
              // controller: nameController,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (newValue) {},
              decoration: InputDecoration(
                hintText: 'Description',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                  color: stateColors.primary,
                  width: 2.0,
                )),
              ),
            ),
          ),
          CheckboxListTile(
            title: Text('is Private?'),
            subtitle: Text(
                'If true, only you will be able to view this illustration'),
            value: false,
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }

  /// A "select file/folder" window will appear. User will have to choose a file.
  /// This file will be then read, and uploaded to firebase storage;
  void pickImage() async {
    final pickerResult = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (pickerResult == null) {
      return;
    }

    uploadImage(pickerResult.files.first);
  }

  /// Upload file to firebase storage
  /// and updates [_uploadTask] to the latest file upload
  void uploadImage(PlatformFile imageFile) async {
    // try {
    //   final userAuth = FirebaseAuth.instance.currentUser;

    //   if (userAuth == null) {
    //     throw Exception("User is not authenticated.");
    //   }

    //   setState(() {
    //     isLoading = true;
    //   });

    //   final result = await IllustrationsActions.createOne(
    //     name: imageFile.name,
    //     visibility: imageVisibility,
    //   );

    //   if (!result.success) {
    //     Snack.e(
    //       context: context,
    //       message: "There was an issue while uploading your image.",
    //     );

    //     setState(() {
    //       isLoading = false;
    //     });

    //     return;
    //   }

    //   final filePath = "users/${userAuth.uid}/images/${result.illustrationId}" +
    //       "/original.${imageFile.extension}";

    //   // final storage = fb.storage();
    //   // final fileRef = storage.ref(filePath);

    //   // final task = fileRef.put(
    //   //   imageFile.bytes,
    //   //   fb.UploadMetadata(
    //   //     contentType: mimeFromExtension(imageFile.extension),
    //   //     customMetadata: {
    //   //       'extension': imageFile.extension,
    //   //       'firestoreId': result.illustrationId,
    //   //       'userId': userAuth.uid,
    //   //       'visibility': Illustration.visibilityPropToString(imageVisibility),
    //   //     },
    //   //   ),
    //   // );

    //   // final uploadTask = UploadTask(
    //   //   filename: imageFile.name,
    //   //   task: task,
    //   // );

    //   // setState(() {
    //   //   uploadTasks.add(uploadTask);
    //   // });

    //   task.future.asStream().listen((uploadTaskSnapshot) {}, onDone: () async {
    //     final doc = await FirebaseFirestore.instance
    //         .collection('illustrations')
    //         .doc(result.illustrationId)
    //         .get();

    //     final data = doc.data();
    //     if (data == null) {
    //       return;
    //     }

    //     data['id'] = doc.id;
    //     uploadTask.illustration = Illustration.fromJSON(data);

    //     final uri = await task.snapshot.ref.getDownloadURL();
    //     uploadTask.illustration.urls.original = uri.toString();

    //     setState(() {
    //       uploadTasks.remove(uploadTask);
    //       doneTasks.add(uploadTask);
    //       isLoading = uploadTasks.isNotEmpty;
    //     });
    //   }, onError: (error) {
    //     appLogger.e(error);
    //   });
    // } catch (error) {
    //   appLogger.e(error);
    //   setState(() => isLoading = false);
    // }
  }

  void checkUploadQueue() {
    _filesReactionDisposer = autorun((reaction) {
      if (appUploadManager.selectedFiles.isEmpty) {
        return;
      }

      for (var file in appUploadManager.selectedFiles) {
        uploadImage(file);
      }
    });
  }
}
