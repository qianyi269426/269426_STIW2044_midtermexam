import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:midtermstiw2044myshop/main.dart';
import 'package:progress_dialog/progress_dialog.dart';

class NewProduct extends StatefulWidget {
  @override
  _NewProductState createState() => _NewProductState();
}

class _NewProductState extends State<NewProduct> {
  ProgressDialog pr;
  double screenHeight;
  double screenWidth;
  File _image;
  String pathAsset = 'assets/images/camera.png';
  TextEditingController _prname = new TextEditingController();
  TextEditingController _prtype = new TextEditingController();
  TextEditingController _prprice = new TextEditingController();
  TextEditingController _prqty = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Product'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text('Add'),
        onPressed: () {
          _postDialog();
        },
        icon: Icon(Icons.add),
      ),
      body: Center(
        child: Container(
          child: Padding(
              padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
              child: SingleChildScrollView(
                  child: Column(
                children: [
                  GestureDetector(
                    onTap: () => {_onPictureSelectionDialog()},
                    child: Container(
                        height: screenHeight / 3,
                        width: screenWidth / 1,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: _image == null
                                ? AssetImage(pathAsset)
                                : FileImage(_image),
                            fit: BoxFit.scaleDown,
                          ),
                        )),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Click the camera to add photo',
                    style: TextStyle(fontSize: 10),
                  ),
                  SizedBox(height: 5),
                  TextField(
                    controller: _prname,
                    decoration: InputDecoration(labelText: 'Product name: '),
                  ),
                  SizedBox(height: 5),
                  TextField(
                    controller: _prtype,
                    decoration: InputDecoration(labelText: 'Product type: '),
                  ),
                  SizedBox(height: 5),
                  TextField(
                    controller: _prprice,
                    decoration: InputDecoration(labelText: 'Product price: '),
                  ),
                  SizedBox(height: 5),
                  TextField(
                    controller: _prqty,
                    decoration:
                        InputDecoration(labelText: 'Product quantity: '),
                  ),
                  SizedBox(height: 5),
                ],
              ))),
        ),
      ),
    );
  }

  _onPictureSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          content: new Container(
            height: screenHeight / 4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    child: Text(
                      "Add photo from ",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    )),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                        child: MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      minWidth: 100,
                      height: 100,
                      child: Text(
                        'Camera',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      color: Theme.of(context).accentColor,
                      elevation: 10,
                      onPressed: () =>
                          {Navigator.pop(context), _camera(), _cropImage()},
                    )),
                    SizedBox(width: 10),
                    Flexible(
                        child: MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      minWidth: 100,
                      height: 100,
                      child: Text(
                        'Album',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      color: Theme.of(context).accentColor,
                      elevation: 10,
                      onPressed: () => {Navigator.pop(context), _album()},
                    )),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future _camera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(
        source: ImageSource.camera, maxHeight: 800, maxWidth: 800);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
    } else {
      print('No image selected.');
    }

    _cropImage();
  }

  _album() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(
      source: ImageSource.gallery,
      maxHeight: 800,
      maxWidth: 800,
    );

    if (pickedFile != null) {
      _image = File(pickedFile.path);
    } else {
      print('No image selected.');
    }

    _cropImage();
  }

  _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: _image.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop your image',
            toolbarColor: Colors.red,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));

    if (croppedFile != null) {
      _image = croppedFile;
      setState(() {});
    }
  }

  void _postDialog() {
    if (_image == null ||
        _prname.text.toString() == "" ||
        _prtype.text.toString() == "" ||
        _prprice.text.toString() == "" ||
        _prqty.text.toString() == "") {
      Fluttertoast.showToast(
          msg: "Image/Information is empty!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
            title: Text("Do you want to post?"),
            content: Text("Are you confirm?"),
            actions: [
              TextButton(
                child: Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                  _post();
                },
              ),
              TextButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
            ],
          );
        });
  }

  Future<void> _post() async {
    pr = ProgressDialog(context);
    pr.style(
      message: 'Posting...',
      borderRadius: 5.0,
      backgroundColor: Colors.white,
      progressWidget: CircularProgressIndicator(),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
    );
    pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: true, showLogs: true);
    await pr.show();
    String base64Image = base64Encode(_image.readAsBytesSync());
    String name = _prname.text.toString();
    String type = _prtype.text.toString();
    String price = _prprice.text.toString();
    String qty = _prqty.text.toString();

    http.post(
        Uri.parse("http://javathree99.com/s269426/myshop/php/newproduct.php"),
        body: {
          "prname": name,
          "prtype": type,
          "prprice": price,
          "prqty": qty,
          "encoded_string": base64Image
        }).then((response) {
      pr.hide().then((isHidden) {
        print(isHidden);
      });
      print(response.body);
      if (response.body == "success") {
        Fluttertoast.showToast(
            msg: "Success",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        setState(() {
          _image = null;
          _prname.text = "";
          _prtype.text = "";
          _prprice.text = "";
          _prqty.text = "";
        });
        Navigator.push(
            context, MaterialPageRoute(builder: (content) => MyApp()));
      } else {
        Fluttertoast.showToast(
            msg: "Failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    });
  }
}
