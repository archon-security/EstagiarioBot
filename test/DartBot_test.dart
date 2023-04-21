// ignore_for_file: omit_local_variable_types, unawaited_futures, unnecessary_cast, library_prefixes, unused_import, unused_local_variable

import 'dart:convert';
import 'dart:io' as DartIo; // O teledar e o Dart:io temo mesmo comando File
import 'package:html/parser.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';

void main() async {
  String BOT_TOKEN = '6047574218:AAGPUi-k-yT1Knwxt4un7NGES5Q__GUajTA';
  final username = (await Telegram(BOT_TOKEN).getMe()).username;
  TeleDart teledart = TeleDart(BOT_TOKEN, Event(username!));

  
  print('Bot On Meu Rei');
  teledart.start();
}
