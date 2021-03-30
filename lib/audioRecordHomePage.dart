import 'dart:io' as io;

import 'package:audio_recorder/audio_recorder.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class AudioRecordHomePage extends StatefulWidget {
  final LocalFileSystem localFileSystem;

  AudioRecordHomePage({localFileSystem})
      : this.localFileSystem = localFileSystem ?? LocalFileSystem();
  @override
  State<StatefulWidget> createState() => AudioRecordHomePageState();
}

class AudioRecordHomePageState extends State<AudioRecordHomePage> {
  AudioPlayer audioPlugin = AudioPlayer();
  bool _isPlayed = false;
  Recording _recording = new Recording();
  bool _isRecording = false;
  // List<FileSystemEntity> contents;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            new MaterialButton(
              onPressed: _isRecording ? null : _start,
              child: new Text("Start"),
              color: Colors.green,
            ),
            new MaterialButton(
              onPressed: _isRecording ? _stop : null,
              child: new Text("Stop"),
              color: Colors.red,
            ),
            IconButton(
                icon: Icon(_isPlayed ? Icons.stop : Icons.play_arrow),
                onPressed: () async {
                  if (_isPlayed) {
                    setState(() {
                      audioPlugin.stop();
                      _isPlayed = false;
                    });
                  } else {
                    await audioPlugin.play(_recording.path, isLocal: true);
                    setState(() {
                      _isPlayed = true;
                    });
                  }
                }),
            new Text("File path of the record: ${_recording.path}"),
          ],
        ),
      ),
    );
  }

  _start() async {
    try {
      if (await AudioRecorder.hasPermissions) {
        String fileName = 'audio_record_' + DateTime.now().toString();
        io.Directory appDocDirectory = await getApplicationDocumentsDirectory();
        fileName = appDocDirectory.path + '/' + fileName;
        print("Start recording: $fileName");
        await AudioRecorder.start(
            path: fileName, audioOutputFormat: AudioOutputFormat.AAC);

        bool isRecording = await AudioRecorder.isRecording;
        setState(() {
          _recording = new Recording(duration: new Duration(), path: "");
          _isRecording = isRecording;
        });
      } else {
        // _showMyDialog();

      }
    } catch (e) {
      print(e);
    }
  }

  _stop() async {
    var record = await AudioRecorder.stop();
    print("Stop recording: ${record.path}");
    bool isRecording = await AudioRecorder.isRecording;
    print("Path : ${record.path},\n"
        "Format : ${record.audioOutputFormat},\n"
        "Duration : ${record.duration},\n"
        "Extension : ${record.extension}");

    File file = widget.localFileSystem.file(record.path);
    print("File dirname: ${file.basename}");
    setState(() {
      _recording = record;
      _isRecording = isRecording;

      // readCounter();
    });
  }

  // Future readCounter() async {
  //   try {
  //     io.Directory appDocDirectory = await getApplicationDocumentsDirectory();
  //
  //     // Read the file
  //     setState(() {
  //       contents = appDocDirectory.listSync();
  //     });
  //
  //     print('contents: $contents');
  //
  //     return contents;
  //   } catch (e) {
  //     return 0;
  //   }
  // }

  Future<void> showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Warning'),
          content:
          Text('Please allow this app to use your mic and local storage.'),
          actions: <Widget>[
            TextButton(
              child: Text('Approve'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
