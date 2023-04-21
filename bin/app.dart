// ignore_for_file: omit_local_variable_types, unawaited_futures, unnecessary_cast, library_prefixes, unused_local_variable
import 'dart:io' as DartIo;
import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';
import 'package:http/http.dart' as http;
import 'package:system_info/system_info.dart' as Sys;
import 'package:sqlite3/sqlite3.dart';

const int MEGABYTE = 1024 * 1024;

void main() async {
  String BOT_TOKEN = 'YOU TOKEN BOT';
  final username = (await Telegram(BOT_TOKEN).getMe()).username;
  TeleDart teledart = TeleDart(BOT_TOKEN, Event(username!));

// =-=-=-Welcomido-=-=-=
  teledart.onMessage().listen((message) {
    // Verifique se a mensagem é uma entrada de membro
    if (message.newChatMembers != null && message.newChatMembers!.isNotEmpty) {
      // Envie uma mensagem de boas vindas
      for (var user in message.newChatMembers!) {
        teledart.sendMessage(
            message.chat.id,
            '''
          Olá, ${user.firstName}! Seja bem-vindo(a) a Archon!
          Caso queria ver meus comandos basta dar um `/help`;
          Não se esqueça de ler a regras do grupo em nosso site [[-]](archon.net.br/grupo/)
          ''',
            parseMode: 'Markdown');
      }
    }
  });

// =-=-=-Document-=-=-=
  final fileDoc = DartIo.File('src/docs.json');
  final jsonStrDocs = fileDoc.readAsStringSync();
  Map<String, dynamic> docs = jsonDecode(jsonStrDocs);

  teledart.onCommand('doc').listen((message) {
    try {
      if (message.text!.split(' ').length < 2) {
        teledart.sendMessage(
            message.chat.id, 'Você não disse qual o comando que você queria');
      }
      String command = message.text!.split(' ')[1].toLowerCase();
      if (docs['docs'][command] != null) {
        teledart.sendMessage(message.chat.id, docs['docs'][command],
            parseMode: "Markdown");
      } else {
        teledart.sendMessage(
            message.chat.id, 'O comando que você quer não existe');
      }
    } catch (e) {
      teledart.sendMessage(
          message.chat.id, 'Não foi possivel conclur o comando, erro: $e');
    }
  });

// =-=-=-Help Admins-=-=-=
  teledart.onCommand('help').listen((message) {
    teledart.sendMessage(
        message.chat.id,
        '''Estes são os comandos exclusivos para os admins da Archon ☕

      =-=- Meus comandos -=-=
      `/archon`
      `/whois`
      `/consul`
      `/horas`
      `/cota`

      =-=- Comando Admin -=-=
      `/add`
      `/remove`

      Caso queira saber como usar um comando, dê `/doc <comando>`
      ''',
        parseMode: 'Markdown');
  });

// =-=-=-Ping-=-=-=
  // Disk Space Vef
  DartIo.ProcessResult resultDisk =
      await DartIo.Process.run('sh', ['src/storage_info.sh']);
  String outputDisk = resultDisk.stdout;

  // CPU Vef
  DartIo.ProcessResult resultCPU =
      await DartIo.Process.run('sh', ['src/cpu_info.sh']);
  String outputCPU = resultCPU.stdout;

  teledart
      .onCommand('ping')
      .listen((message) => message.reply('''Taca a mãe pra ver se pinga🏓

       =-=- S y s  I n f o -=-= 
          Kernel     : ${Sys.SysInfo.kernelName}🐧
          OS         : ${Sys.SysInfo.operatingSystemName}
          OS Version : ${Sys.SysInfo.operatingSystemVersion}
          Processo   : ${Sys.SysInfo.processors.first.name}🧮
          CPU USAGE  : $outputCPU
      Total physical memory   : ${Sys.SysInfo.getTotalPhysicalMemory() ~/ MEGABYTE} MB
      Free physical memory    : ${Sys.SysInfo.getFreePhysicalMemory() ~/ MEGABYTE} MB
      Total virtual memory    : ${Sys.SysInfo.getTotalVirtualMemory() ~/ MEGABYTE} MB
      Free virtual memory     : ${Sys.SysInfo.getFreeVirtualMemory() ~/ MEGABYTE} MB
      Virtual memory size     : ${Sys.SysInfo.getVirtualMemorySize() ~/ MEGABYTE} MB
      Disk Space     :  ${outputDisk.trim().split(' ')[0]}🛸
      Free Disk Space:  ${outputDisk.trim().split(' ')[2]}👀
      '''));

// =-=-=-Descrição-=-=-=
  teledart.onCommand('archon').listen((message) {
    teledart.sendMessage(message.chat.id,
        'A archon seguranças é um grupo de travadores de zap zap hahahaha cujo o site oficial é o archon-travas.net.br');
  });

// =-=-=-Whois-=-=-=
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
        teledart.sendMessage(message.chat.id, '''
        Domínio: ${json['ldhName']}
        Títular: ${json['entities'][0]['vcardArray'][1][2][3]}
        Email: ${json['entities'][1]['vcardArray'][1][3][3]}
        ${json['entities'][0]['publicIds'][0]['type'].toUpperCase()}: ${json['entities'][0]['publicIds'][0]['identifier']}
        Nameservers: $nameservers
        Criado: ${json['events'][0]['eventDate']}
        Ultima alteração:${json['events'][1]['eventDate']}
        Expira: ${json['events'][2]['eventDate']}
        Status: ${json['status'][0]}
        ''');
      } else {
        teledart.sendMessage(
            message.chat.id, 'Erro na requisição HTTP: ${response.statusCode}');
      }
    } catch (e) {
      teledart.sendMessage(message.chat.id, 'Erro ao obter eventos JSON: $e');
    }
  });

// =-=-=-Currency-=-=-=
  teledart.onCommand('cota').listen((message) async {
    if (message.text!.split(' ').length < 2) {
      teledart.sendMessage(
          message.chat.id, 'Error, seu animal, vê se você escreveu direito');
      return;
    }

    List<String> commandParts = message.text!.split(' ');
    String cent1 = commandParts[1].toUpperCase();
    String cent2 = commandParts[2].toUpperCase();
    String currencyConcat = '$cent1$cent2';

    // Implementação
    String apiUrl =
        'https://economia.awesomeapi.com.br/json/last/$cent1-$cent2';

    try {
      // Fazer a requisição HTTP
      http.Response response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        // Parsear o JSON de resposta
        Map<String, dynamic> json = jsonDecode(response.body);
        print(json);

        teledart.sendMessage(message.chat.id, '''
        Aqui a ultima cotação $cent1 e $cent2 hoje

        =-=-= ${json[currencyConcat]["name"]} =-=-=
        Maior Valor: ${json[currencyConcat]['high']}
        Menor Valor: ${json[currencyConcat]['low']}
        Data/Hora da verificação: ${json[currencyConcat]['create_date']}
        ''');
      } else {
        teledart.sendMessage(
            message.chat.id, 'Erro na requisição HTTP: ${response.statusCode}');
      }
    } catch (e) {
      teledart.sendMessage(message.chat.id, 'Erro ao obter eventos JSON: $e');
    }
  });
// =-=-=-Time-=-=-=
  teledart.onCommand('horas').listen((message) {
    teledart.sendMessage(message.chat.id, '''Horarios:
        Brasil-Brasilia: ${DateTime.now().hour + 4}:${DateTime.now().minute}:${DateTime.now().second}
        Russia-Moscou: ${DateTime.now().hour + 10}:${DateTime.now().minute}:${DateTime.now().second}
        EUA-Nova Iorque:${DateTime.now().hour + 3}:${DateTime.now().minute}:${DateTime.now().second}
        China-Xangai: ${DateTime.now().hour + 15}:${DateTime.now().minute}:${DateTime.now().second}
        Portugal-Lisboa: ${DateTime.now().hour + 8}:${DateTime.now().minute}:${DateTime.now().second}
        ''');
  });

// =-=-=-Hour-=-=-=
  final fileMessages = DartIo.File('src/mensagens.json');
  final jsonStrMessages = fileMessages.readAsStringSync();
  final messages = json.decode(jsonStrMessages);

  // Verifica a hora a cada 1 hora
  Timer.periodic(Duration(hours: 1), (timer) {
    DateTime now = DateTime.now();
    if (now.hour + 4 == 6) {
      teledart.sendMessage(
          -1001610232638, messages['bomDia'][Random().nextInt(11)]);
    } else if (now.hour + 4 == 12) {
      teledart.sendMessage(
          -1001610232638, messages['boaTarde'][Random().nextInt(11)]);
    } else if (now.hour + 4 == 18) {
      teledart.sendMessage(
          -1001610232638, messages['boaNoite'][Random().nextInt(11)]);
    }
  });

/*
  Comandos exclusivos para admins

  =-=-=-Json contendo o ID de todos aqueles que poderão usar esse comando
  final file = DartIo.File('db/admins.json');
  final jsonStr = file.readAsStringSync();
  Map<String, int> admins = jsonDecode(jsonStr);

  =-=-=-Verifica se dentro do Json tem o ID de quem enviou o comando
  if (admins['admins']!.any((element) => element == message.from!.id)) {

    Codigo caso ele retorne True, ou seja, caso o ID de quem enviou a mensagem esteja
    dentro do JSON de admins;

  }else{

    Codigo caso ele retorne False, ou seja, caso o ID de quem enviou a mensagem NÃO esteja
    dentro do JSON de admins;

  }
*/

  final fileAdmins = DartIo.File('db/admins.json');
  final jsonStrAdmins = fileAdmins.readAsStringSync();
  Map<String, dynamic> admins = jsonDecode(jsonStrAdmins);

// =-=-=-Add in Black List-=-=-=
  teledart.onCommand('add').listen((message) {
    if (message.text!.split(' ').length < 4) {
      teledart.sendMessage(message.chat.id,
          'Você fez algo de errado, dê um /help para ver como se usa esse comando!');
    }
    try {
      String Nick = message.text!.split(' ')[1];
      int idTele = int.parse(message.text!.split(' ')[2]);
      String Reason = message.text!.split(' ')[3];

      if (admins['admins']!.any((element) => element == message.from!.id)) {
        final blackListDB = sqlite3.open('db/blackListDB.sqlite');
        final stmt = blackListDB
            .prepare('INSERT INTO users(Nick,IdTele, Reason) VALUES(?, ?, ?)');
        stmt.execute([Nick, idTele, Reason]);
        stmt.dispose();

        teledart.sendMessage(message.chat.id,
            'O usuario $Nick de ID: $idTele foi adicionado a black list da archon pelo motivo $Reason');
      } else {
        teledart.sendMessage(message.chat.id,
            '@${message.from!.username} Você não tem permissão para usar esse comando');
      }
    } catch (e) {
      teledart.sendMessage(
          message.chat.id, 'Não foi possivel conclur o comando, erro: $e');
    }
  });

// =-=-=-Search in Black List-=-=-=

  //Esse comando não precisa de verificação admin, pois é bem simples e não altera nada no DB
  teledart.onCommand('consu').listen((message) {
    if (message.text!.split(' ').length < 2) {
      teledart.sendMessage(message.chat.id,
          'Você fez algo de errado, dê um /help para ver como se usa esse comando!');
    }
    try {
      int IdTele = int.parse(message.text!.split(' ')[1]);

      final blackListDB = sqlite3.open('db/blackListDB.sqlite');
      final searchDB =
          blackListDB.select('SELECT * FROM users WHERE IdTele = ?', [IdTele]);

      if (searchDB.isNotEmpty) {
        teledart.sendMessage(
            message.chat.id, 'O usuario está na BlackList da Archon');
      } else {
        teledart.sendMessage(
            message.chat.id, 'O usuario não está na BlackList da Archon');
      }
    } catch (e) {
      teledart.sendMessage(
          message.chat.id, 'Não foi possivel conclur o comando, erro: $e');
    }
  });

// =-=-=-Remove Black List-=-=-=
  teledart.onCommand('remove').listen((message) {
    if (message.text!.split(' ').length < 2) {
      teledart.sendMessage(message.chat.id,
          'Você fez algo de errado, dê um /help para ver como se usar esse comando!');
    }
    try {
      int IdTele = int.parse(message.text!.split(' ')[1]);
      
      if (admins['admins']!.any((element) => element == message.from!.id)) {
        final blackListDB = sqlite3.open('db/blackListDB.sqlite');
        final searchDB = blackListDB
            .select('SELECT * FROM users WHERE IdTele = ?', [IdTele]);

        if (searchDB.isNotEmpty) {
          final deletDB =
              blackListDB.prepare('DELETE FROM users WHERE IdTele = ?');
          deletDB.execute([IdTele]);
          teledart.sendMessage(message.chat.id,
              'O usuario com ID: $IdTele foi removido da Black List');
          deletDB.dispose();
        } else {
          teledart.sendMessage(
              message.chat.id, 'Esse usuario não se encontra na Black List');
        }
      } else {
        teledart.sendMessage(message.chat.id,
            '@${message.from!.username} Você não tem permissão para usar esse comando');
      }
    } catch (e) {
      teledart.sendMessage(
          message.chat.id, 'Não foi possivel conclur o comando, erro: $e');
    }
  });

  teledart.start();

  print('Bot On Meu Rei');
}
