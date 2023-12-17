import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class PreviewPage extends StatelessWidget {
  const PreviewPage({Key? key, required this.picture, required this.data})
      : super(key: key);

  final XFile picture;
  final dynamic data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview Page')),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: ListView(
            children: [
              Image.file(
                File(picture.path),
                fit: BoxFit.cover,
                width: 250,
              ),
              const SizedBox(height: 24),
              Text(picture.name),
              const Spacer(),
              Text("Name: ${data['Name']}"),
              Text("Email: ${data['Email']}"),
              Text("Phone: ${data['Phone']}"),
              Column(
                children: data['Sections'].entries.map<Widget>((section) {
                  return Text("${section.key}: ${section.value.toString()}");
                }).toList(),
              ),
              const Spacer(),
              Text("Text: ${data['Text']}"),
            ],
          ),
        ),
      ),
    );
  }
}
