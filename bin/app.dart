// ignore_for_file: omit_local_variable_types, unawaited_futures

import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';
import 'package:system_info/system_info.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const int MEGABYTE = 1024 * 1024;

void main() async {
  String BOT_TOKEN = 'TOKEN do seu BOT';
  final username = (await Telegram(BOT_TOKEN).getMe()).username;
  TeleDart teledart = TeleDart(BOT_TOKEN, Event(username!));

  // Comando de Start
  teledart.onMessage(entityType: 'chat_member', keyword: 'newChatMembers').listen(
      (message) => teledart.sendMessage(message.chat.id, 'Hello TeleDart!'));

  // Ping
  teledart
      .onCommand('ping')
      .listen((message) => message.reply('''Taca a mãe pra ver se pinga🏓
    Sistema:
      Kernel: ${SysInfo.kernelName}
      S.O: ${SysInfo.operatingSystemName}
      Versão do S.O: ${SysInfo.operatingSystemVersion}
    Processador: ${SysInfo.processors.first.name}
    CPU: Meia noite eu te conto :) 
    Memória total: ${SysInfo.getTotalPhysicalMemory() ~/ MEGABYTE} MB 
    Memória disponível: ${SysInfo.getFreePhysicalMemory() ~/ MEGABYTE} MB 
    Espaço em disco total: Meia noite eu te conto :) 
    Espaço em disco disponível: Meia noite eu te conto :)'''));

  // Help
  teledart.onCommand('help').listen((message) =>
      message.reply('Help o que? Você quer um café? Então toma essa porra ☕'));

  // Descrição sobre a archon
  teledart.onCommand('archon').listen((message) => teledart.sendMessage(
      message.chat.id,
      'A archon seguranças é um grupo de travadores de zap zap hahahaha cujo o site oficial é o archon-travas.net.br'));

  //Whois
  teledart.onCommand('whois').listen((message) async {
    if (message.text!.split(' ').length < 2) {
      teledart.sendMessage(
          message.chat.id, 'Error, seu animal, vê se você escreveu direito');
      return;
    }

    List<String> commandParts = message.text!.split(' ');
    String domain = commandParts.sublist(1).join(' ');

    // Implementação
    String apiUrl = 'https://rdap.registro.br/domain/$domain';
    try {
      // Fazer a requisição HTTP
      http.Response response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        // Parsear o JSON de resposta
        Map<String, dynamic> json = jsonDecode(response.body);
        List<String> nameservers = [];
        for (var element in json['nameservers']) {
          nameservers.add(element['ldhName']);
        } //ignore
        teledart.sendMessage(message.chat.id, 
        '''
        Esse Whois funciona apenas com dominios .br :V

        Domínio: ${json['ldhName']}
        Títular: ${json['entities'][0]['vcardArray'][1][2][3]}
        Email: ${json['entities'][1]['vcardArray'][1][3][3]}
        ${json['entities'][0]['publicIds'][0]['type'].toUpperCase()}: ${json['entities'][0]['publicIds'][0]['identifier']}
        Nameservers: $nameservers
        Criado: ${json['events'][0]['eventDate']}
        Ultima alteração:${json['events'][1]['eventDate']}
        Expira: ${json['events'][2]['eventDate']}
        Status: ${json['status'][0]}
        '''
        );
      } else {
        teledart.sendMessage(
            message.chat.id, 'Erro na requisição HTTP: ${response.statusCode}');
      }
    } catch (e) {
      teledart.sendMessage(message.chat.id, 'Erro ao obter eventos JSON: $e');
    }
  });

  // Welcomido


  teledart.start();

  print('Bot On Meu Rei');
}
