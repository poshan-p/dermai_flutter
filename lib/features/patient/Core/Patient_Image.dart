import 'dart:io';
import 'dart:ui';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class PatientImage {
  late File imgPath;
  final picker = ImagePicker();

  PatientImage();

  void getImageFromGallery(ImageSource source) async {
    final image = await picker.pickImage(source: ImageSource.gallery);
    imgPath = File(image!.path);
  }

  void getImageFromCamera() async {
    final image = await picker.pickImage(source: ImageSource.camera);
    imgPath = File(image!.path);
  }

  Future<String?> sendImg(String Filename) async {
    // send request to python flask server
    var postURi = Uri.parse("URi here");

    var request = http.MultipartRequest("POST", postURi);

    http.Response res = await http.Response.fromStream(request.files.add(http.MultipartFile.fromBytes(
        Filename, File.fromRawPath(imgPath.readAsBytesSync()).readAsBytesSync(),
        contentType: MediaType('image', 'jpeg')));

    request.send().then((response) {
      if (response.statusCode == 200) print("uploaded!!");
    }););

    return res.headers['response'];
  }
}
