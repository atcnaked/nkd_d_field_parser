import 'dart:developer';
import 'dart:io';

import 'examples_vrac_valid 23-02 et 16-02 2026.dart';

Future<void> retrieveDfromExamples() async {
  final notamExs = exValid2;
  final lines = notamExs.split('\n').map((e) => e.trim());
  // final regexp = RegExp('D\).*\n    E\)');

  var ds = <String>[];
  var dFielsAsLines = <String>[];
  int duCounter = 0;
  for (var line in lines) {
    if (line.startsWith('D)')) {
      dFielsAsLines.add(line);
    } else if (line.startsWith('E)') && dFielsAsLines.isNotEmpty) {
      final d = dFielsAsLines.join(' ').replaceAll(RegExp(r' +'), ' ');
      if (d.startsWith('D) MON-FRI 0700-SS')) {
        print('dFielsAsLines: $dFielsAsLines');
        print('d: $d');
      }
      ds.add(d);
      dFielsAsLines = [];
    } else if (dFielsAsLines.isNotEmpty) {
      dFielsAsLines.add(line);
    } else {
      if (line.startsWith('DU: ')) {
        duCounter++;
      }
    }
  }


final  dsUnique = ds.toSet().toList();
dsUnique.sort((a,b)=>a.length.compareTo(b.length));

  // print('dsUnique: ${dsUnique.join('\n')}');
  print('dsUnique ');
  print('');

  print('original ds length: ${ds.length}');
  print('dsUnique length: ${dsUnique.length}');
  print('duCounter: $duCounter');
  final path = getPathWithExtensionAndDateNumber('lib/d_field_lists/d_field_list','txt');
 await generateAndWriteFile(path, dsUnique.join('\n'));
 final regtext = r'\d\d?( \d\d?)+\n';
 print('in order to detect line finishing with date => regex $regtext');
}

Future<void> generateAndWriteFile(String path, String data) async {
      print('attempting to write $path');
  try {
    final File file = File(path);
    if (file.existsSync()) {
      print('can not write file, $path already exists');
      return;
    }
  await  file.writeAsString(data);
      print('file written succesfully');

  } catch (e) {
      print('can not write file, $e');
  } finally {
  }
}

String getPathWithExtensionAndDateNumber(String baseName, String ext) {
  print('getPathWithExtensionAndDate');

  // Generate a file-safe date stamp (e.g., "2026-04-24")
  final now = DateTime.now();
  final year = now.year.toString();
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');

  final seconds= now.difference(  DateTime(now.year,now.month, now.day)).inSeconds;
  final secondsText = seconds.toString().padLeft(5,'0');

  final String dateSecondsStamp = '$year-$month-$day-$secondsText';
  return '$baseName-$dateSecondsStamp.$ext';
 // return '$baseName.$extension\_$dateStamp';
}


void mfskjdf(){

  final v = 'fsdqdqfs'.split('rr');
}