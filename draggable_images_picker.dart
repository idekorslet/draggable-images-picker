import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:reorderables/reorderables.dart';

///  install 2 package:
///  1. image_picker --> https://pub.dev/packages/image_picker
///  2. reorderables --> https://pub.dev/packages/reorderables

const double _containerImageHeight = 80;
const double _containerImageWidth = 80;
const double _mainContainerHeight = 16;
const double _mainContainerWidth = 36;
const _showMainText = true;
const double _iconSize = 40;

class DraggableImagesPicker {
  final int maxImageCount;
  final BuildContext localContext;
  List<String>? imageStringList;

  DraggableImagesPicker({this.maxImageCount=5, required this.localContext, this.imageStringList});

  List<XFile> images = [];
  List<Widget> imageContainerList = [];
  final ImagePicker _imgPicker = ImagePicker();
  final ScrollController _scrollController = ScrollController();

  bool _allowReorderable = false;
  bool _isDragging = false;
  bool isPositionChanged = false;
  late Function _setState;
  late ReorderableWrap wrappedImages;

  void init(Function setState) {
    // print('[draggable_images_picker] init');

    final isEditData = imageStringList != null;

    if (isEditData) {
      images = [];
      int counter = 0;
      /// convert image path into XFile type and add it into images variable
      /// berguna ketika misalnya ingin update data dan ingin mengganti image
      for (final img in imageStringList!) {
        images.add(XFile(img));
        imageContainerList.add(_imageCaptureContainer(containerIndex: counter, imagePath: img));
        counter++;
      }
    }

    final imageContainerIndex = isEditData ? images.length : 0;

    imageContainerList.add(_imageCaptureContainer(asImageCapture: true, containerIndex: imageContainerIndex));
    _setState = setState;
  }

  void dispose() {
    _scrollController.dispose();
  }

  void _onReorder(int oldIndex, int newIndex) {
    /// ketika image container dilepas dan berada diposisi paling akhir (ke posisi paling kanan)
    /// maka tidak diperbolehkan, karena posisi paling kanan untuk mengambil image (image capture)
    /// to keep the camera container in the rightmost position
    if (newIndex == imageContainerList.length - 1 || oldIndex == imageContainerList.length - 1) {
      _isDragging = false;
    }
    else {
      _setState(() {
        Widget row = imageContainerList.removeAt(oldIndex);
        imageContainerList.insert(newIndex, row);

        XFile tmpImg = images.removeAt(oldIndex);
        images.insert(newIndex, tmpImg);
      });

      debugPrint('[draggable_images_picker] position changed');
      isPositionChanged = true;
    }
  }

  void onWidgetRebuild() {
    print('[draggable_images_picker @onWidgetRebuild]image container list length: ${imageContainerList.length}');
    _reOrderImageList();
    _allowReorderable = imageContainerList.length > 2 ? true : false;
    _isDragging = false;
    isPositionChanged = false;

    wrappedImages = ReorderableWrap(
        controller: _scrollController,
        spacing: 8.0,
        runSpacing: 4.0,
        padding: const EdgeInsets.all(8),
        onReorder: _onReorder,
        enableReorder: _allowReorderable,
        onNoReorder: (int index) {
          //this callback is optional
          debugPrint('[draggable_images_picker] ${DateTime.now().toString().substring(5, 22)} reorder cancelled. index:$index');
        },
        onReorderStarted: (int index) {
          //this callback is optional
          debugPrint('[draggable_images_picker] ${DateTime.now().toString().substring(5, 22)} reorder started: index:$index');
        },
      
        children: imageContainerList
    );
  }

  void _reOrderImageList() {
    if (!_isDragging) {
      imageContainerList = [];

      images.map((img) {
        final imgIndex = images.indexOf(img);
        imageContainerList.add(_imageCaptureContainer(containerIndex: imgIndex, imagePath: img.path));
      }).toList();

      imageContainerList.add(_imageCaptureContainer(
        asImageCapture: true,
        containerIndex: images.length,
      ));
    }

    debugPrint('[draggable_images_picker] image container list length: ${imageContainerList.length}');
    debugPrint('[draggable_images_picker] images length: ${images.length}');
  }

  Widget _showPickedImages({required String imgPath, required int imgIndex}) {
    return Stack(
      children: <Widget>[
        /// image from image picker
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey)
          ),
          height: double.infinity, width: double.infinity,
          child: Image.file(
            // File(img!.path),
            File(imgPath),
            fit: BoxFit.cover,
          ),
        ),

        /// main text for first image
        imgIndex == 0 && _showMainText
            ? Positioned(
          top: _containerImageHeight - _mainContainerHeight - 6,
          left: _containerImageWidth - _mainContainerWidth - (_mainContainerWidth / 2),
          child: Container(
            height: 16,
            width: 36,
            decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.7),
                borderRadius: BorderRadius.circular(6)
            ),
            child: const Center(child: Text('Main', style: TextStyle(fontSize: 12),)),
          ),
        )
            : const SizedBox(),

        /// close button to delete image from product image list
        Positioned(
            right: 0,
            top: 0,
            child: InkWell(
              onTap: () {
                /// hapus image dari daftar image produk (images variable)
                /// delete image from product image list
                debugPrint('[draggable_images_picker] image index $imgIndex removed');

                _setState(() {
                  images.removeAt(imgIndex);
                  imageContainerList.removeAt(imgIndex);
                });
              },
              child: Icon(
                Icons.cancel,
                color: Colors.grey.withOpacity(0.8),
                size: 20,
              ),
            )
        )
      ],
    );
  }

  Widget _imageCaptureContainer({bool asImageCapture=false, String? imagePath, required int containerIndex}) {
    return Container(
      height: _containerImageHeight,
      width: _containerImageWidth,
      decoration: const BoxDecoration(
        color: Colors.grey,
      ),
      child: InkWell(
          onTap: () async {
            if (asImageCapture) {
              try {
                _isDragging = false;
                var pickedFiles = await _imgPicker.pickMultiImage();

                //you can use ImageCourse.camera for Camera capture
                if (pickedFiles.isNotEmpty){

                  if (pickedFiles.length + images.length > maxImageCount) {
                    pickedFiles = [];
                    debugPrint("[draggable_images_picker] Only $maxImageCount image allowed");
                    showAlert();
                  }
                  else {
                    images.addAll(pickedFiles);
                    _setState(() {

                    });
                  }

                } else {
                  debugPrint("[draggable_images_picker] No image is selected.");
                }
              } catch (e) {
                debugPrint("[draggable_images_picker] error while picking file. \n$e");
              }
            }

            debugPrint('[draggable_images_picker] on tap, index: $containerIndex');
          },

          child: asImageCapture
            ? const Icon(
                Icons.camera_alt,
                size: _iconSize,
              )
            : _showPickedImages(imgPath: imagePath!, imgIndex: containerIndex)
      ),
    );
  }

  Future<void> showAlert() async {
    if (localContext.mounted) {
      await showDialog(context: localContext, builder: (ctx) {
        return AlertDialog(
          title: const Text("Warning"),
          content: Text("Only $maxImageCount image allowed",
            style: const TextStyle(fontSize: 16),
          ),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(localContext);
              },
              child: const Text('Ok',
                style: TextStyle(fontSize: 16),
              ),
            )
          ],
        );
      });
    }
  }
}
