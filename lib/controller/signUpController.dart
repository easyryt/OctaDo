import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpController{
  Future<String> signInWithImage(File imageFile, String name, String email, String password) async {
    try {
      var stream = new http.ByteStream(imageFile.openRead());
      stream.cast();
      var length = await imageFile.length();

      var uri =
      Uri.parse('https://notesapp-i6yf.onrender.com/user/auth/signUp');
      var request = new http.MultipartRequest('POST', uri);
      request.headers['Content-Type'] = 'application/x-www-form-urlencoded';
      request.fields['name'] = name;
      request.fields['password'] = password;
      request.fields['email'] = email;

      var multiport = new http.MultipartFile('profilePic', stream, length);

      request.files.add(multiport);

      var reponse = await request.send();

      if (reponse.statusCode == 201) {
        return "${reponse.statusCode}${reponse.stream.bytesToString()}";
      } else {
        return "${reponse.statusCode}${reponse.stream.bytesToString()}";
      }
      //
    } catch (e) {
      return "failed$e";
    }
  }

  Future<String> signIn(String name, String email, String password) async {

    if(name.isNotEmpty && email.isNotEmpty && password.isNotEmpty){
      try {
        final apiUrl = Uri.parse('https://notesapp-i6yf.onrender.com/user/auth/signUp');

        final headers = {
          'Content-Type': 'application/json',
        };

        final data = {
          'name': name,
          'password': password,
          'email': email,
        };
        final response = await http.post(
          apiUrl,
          headers: headers,
          body: jsonEncode(data),
        );

        if (response.statusCode == 201) {
          return "${response.body}"; // Data posted successfully
        } else {
          return "HTTP Error:${response.statusCode} ${response.body}"; // Data posting failed
        }
      } catch (error) {
        return "Error Occurred-$error"; // Data posting failed
      }
    }else{
      return 'Enter All fields';
    }

  }
}