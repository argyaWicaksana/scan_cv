import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scan_cv/preview_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CameraPage extends StatefulWidget {
  final List<CameraDescription>? cameras;

  const CameraPage({Key? key, required this.cameras}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;
  bool _isRearCameraSelected = true;

  Future initCamera(CameraDescription cameraDescription) async {
    _cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
    );

    try {
      await _cameraController.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint('camera error $e');
    }
  }

  Future<dynamic> scanCv(XFile picture) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://192.168.1.2:5000/extract_info'));

    request.files.add(http.MultipartFile.fromBytes(
        'file', File(picture.path).readAsBytesSync(),
        filename: picture.path));

    var res = await request.send();
    var response = await http.Response.fromStream(res);

    var tes = json.decode(response.body);
    // print(tes['Email']);
    return tes;
  }

  Future takePicture() async {
    if (!_cameraController.value.isInitialized) {
      return null;
    }
    if (_cameraController.value.isTakingPicture) {
      return null;
    }
    try {
      await _cameraController.setFlashMode(FlashMode.off);
      XFile picture = await _cameraController.takePicture();
      var extractedData = await scanCv(picture);
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewPage(
            picture: picture,
            data: extractedData,
          ),
        ),
      );
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    initCamera(widget.cameras![0]);
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          (_cameraController.value.isInitialized)
              ? CameraPreview(_cameraController)
              : const Center(
                  child: CircularProgressIndicator(),
                ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.2,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                color: Colors.black,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 30,
                      icon: Icon(
                        _isRearCameraSelected
                            ? CupertinoIcons.switch_camera
                            : CupertinoIcons.switch_camera_solid,
                      ),
                      color: Colors.white,
                      onPressed: () {
                        setState(() =>
                            _isRearCameraSelected = !_isRearCameraSelected);
                        initCamera(
                            widget.cameras![_isRearCameraSelected ? 0 : 1]);
                      },
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      onPressed: takePicture,
                      iconSize: 50,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.circle, color: Colors.white),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          )
        ]),
      ),
    );
  }
}
