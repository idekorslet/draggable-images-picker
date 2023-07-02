# draggable-images-picker

Class ini adalah hasil gabungan dari dua package, yaitu:
  1. <a href="https://pub.dev/packages/reorderables">reorderables</a>
  2. <a href="https://pub.dev/packages/image_picker">image_picker</a>

berguna untuk memilih beberapa gambar sekaligus dan gambar yang ditampilkan bisa dipindah-pindah posisinya

=========================================================================<br>
This class is the combined result of two packages, namely:<br>
    1. <a href="https://pub.dev/packages/reorderables">reorderable</a><br>
    2. <a href="https://pub.dev/packages/image_picker">image_picker</a>

useful for selecting several images at once and the displayed image can be moved position

video:<br>

https://github.com/idekorslet/draggable-images-picker/assets/80518183/9ec1287a-0d2f-4d9f-95f1-289e0e4c19ea 

<br>
<h3>How to use</h3>
  
1. buat objek baru / create new object <br>

```dart
  DraggableImagesPicker draggableImagesPicker = DraggableImagesPicker(maxImageCount: 8);
```  

2. panggil method init di initState() / call init method in initState()

```dart
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    draggableImagesPicker.init(setState);
  }
```

3. panggil method dispose di dispose() method / call dispose method in dispose()
```dart
  @override
  void dispose() {
    draggableImagesPicker.dispose();
    super.dispose();
  }
```

4. panggil method/fungsi onWidgetRebuild di Widget build(BuildContext context) / call method/function onWidgetRebuild in Widget build(BuildContext context)
```dart
   draggableImagesPicker.onWidgetRebuild();
```

5. panggil method draggableImagesPicker.wrappedImages sebagai anakan widget / call method draggableImagesPicker.wrappedImages as child of widget
```dart
   Container(
      height: 200,
      width: 300,
      child: draggableImagesPicker.wrappedImages,  
   )
```

video lengkap cara menggunakannya / full video how to use it: <br>
[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/G9-jTEeHRo0/0.jpg)](https://youtu.be/G9-jTEeHRo0)
