import 'dart:async';

import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';
import 'package:dotenv/dotenv.dart' show load, env;

import 'package:DartVika/random.dart';
import 'package:DartVika/constants.dart';
import 'package:DartVika/logger.dart';
import 'package:DartVika/donations.dart';
import 'package:DartVika/dogcatapi.dart';
import 'package:DartVika/stringlib.dart';

void main() {
  load();

  Logger logger = Logger('./main.log');
  DonationLib donations = DonationLib('./data/donations.json');
  DogCatHelper advancedApi = DogCatHelper(env['DOGCAT_KEY'], logger);
  String _botUsername;

  try {
    TeleDart teledart = TeleDart(Telegram(env['TOKEN']), Event());
    teledart.start().then((me) {
      logger.log('[${DateTime.now()}]\n${me.username} is initialised');
      _botUsername = me.username;
    });

    // Hadling Callback query
    teledart.onCallbackQuery().listen((query) {
      // print(query.toJson());
      String data = query.data;
      String result = '[Error]';
      switch (data) {
        case 'help_about':
          editMessage(teledart, query.message, kCommandsList, 'html');
          result = '[Processed]';
          break;
        case 'help_commands':
          editMessage(teledart, query.message, kAboutBot, 'html');
          result = '[Processed]';
          break;
        default:
          final cqArgs = query.data.split(' ');
          switch (cqArgs[0]) {
            case 'cat':
              if (cqArgs[1] == 'upvote') {
                handleVoteWithApi(
                  teledart,
                  query,
                  advancedApi,
                  AnimalType.Cat,
                  cqArgs[2],
                  1,
                );
              } else {
                handleVoteWithApi(
                  teledart,
                  query,
                  advancedApi,
                  AnimalType.Cat,
                  cqArgs[2],
                  0,
                );
              }
              result = '[Processed]';
              break;
            case 'dog':
              if (cqArgs[1] == 'upvote') {
                handleVoteWithApi(
                  teledart,
                  query,
                  advancedApi,
                  AnimalType.Dog,
                  cqArgs[2],
                  1,
                );
              } else {
                handleVoteWithApi(
                  teledart,
                  query,
                  advancedApi,
                  AnimalType.Dog,
                  cqArgs[2],
                  0,
                );
              }
              result = '[Processed]';
              break;
            default:
              result = '[Unknown CQ]';
          }
      }
      logger.logAction(
        ActionType.CallbackQuery,
        user: query.from.username,
        channel: (query.message.chat.title != null)
            ? query.message.chat.title
            : _botUsername,
        text: '$data >> $result',
      );
    });

    // Handling messages
    teledart.onMessage().listen((message) {
      messageProcessing(teledart, message, logger, _botUsername);
    });
    teledart.onMention().listen((message) {
      messageProcessing(teledart, message, logger, _botUsername);
    });
    teledart.onHashtag().listen((message) {
      messageProcessing(teledart, message, logger, _botUsername);
    });

    // Handling general command situations
    teledart.onCommand().listen((command) {
      logger.logAction(
        ActionType.Message,
        user: command.from.username,
        channel:
            (command.chat.title != null) ? command.chat.title : _botUsername,
        text: (command.text != null) ? command.text : '[S]',
      );
    });

    // Handling messages editing
    teledart.onEditedMessage().listen((message) {
      logger.logAction(
        ActionType.Message,
        user: message.from.username,
        channel:
            (message.chat.title != null) ? message.chat.title : _botUsername,
        text: (message.text != null) ? message.text : '[special]',
        additional: '[E]',
      );
    });

    // Handling /start command
    teledart.onCommand('start').listen((message) {
      teledart.replyMessage(message, 'Hello World!');
    });

    // Handling /help command
    teledart.onCommand('help').listen((message) {
      teledart.replyMessage(
        message,
        'A?',
        reply_markup: InlineKeyboardMarkup(
          inline_keyboard: [
            [
              InlineKeyboardButton(
                text: 'Что можешь?',
                callback_data: 'help_about',
              ),
            ],
            [
              InlineKeyboardButton(
                text: 'О боте',
                callback_data: 'help_commands',
              ),
            ],
          ],
        ),
      );
    });

    // Handling /gay command
    teledart.onCommand('gay').listen((message) {
      teledart.replyMessage(message, kAboutCreator, parse_mode: 'html');
    });

    // Handling /donations command
    teledart.onCommand('donations').listen((message) {
      try {
        var list = donations.loadList();
        String text = '<b><u>[Почётные донатеры]</u></b>\n';
        for (int i = 0; i < list.length; i++) {
          if (i < 3) text += '<b>';
          text += '${i + 1}) ${list[i]['donator']}\n${list[i]['sum']}\n';
          if (i < 3) text += '</b>';
        }
        teledart.replyMessage(message, text, parse_mode: 'html');
      } catch (e) {
        logger.log('[Fatal command error] $e');
      }
    });

    // Handling /luck command
    teledart.onCommand('luck').listen((message) {
      String text;
      if (RandomHelper.chance(0.5)) {
        text = 'Тебе не повезло, получай по жопе 👋👋👋';
      } else {
        text = 'Тебе повезло, твоя жопа в сохранности';
      }
      teledart.replyMessage(message, text);
    });

    // Handling /f command
    teledart.onCommand('f').listen((message) {
      teledart.telegram.getStickerSet('FforRespect').then((responce) {
        final stickers = responce.stickers;
        Sticker randSticker = RandomHelper.listElement(stickers);
        teledart.replySticker(message, randSticker.file_id);
      });
    });

    // Handling /cat command
    teledart.onCommand('cat').listen((message) async {
      sendFileFromAPI(teledart, message, advancedApi, AnimalType.Cat);
    });

    // Handling /dog command
    teledart.onCommand('dog').listen((message) async {
      sendFileFromAPI(teledart, message, advancedApi, AnimalType.Dog);
    });
  } catch (e) {
    logger.log('[Fatal error]\n-- BOT WILL BE RESTARTED --\n$e');
  }
}

void sendFileFromAPI(
  TeleDart teledart,
  Message message,
  DogCatHelper advancedApi,
  AnimalType type,
) async {
  final apiParams = DogCatHelper.getApiParams(type);
  final args = StringLib.getArgs(message.text);
  String photoType = 'jpg,png';

  if (args.length != 0 && args[0] == 'gif') {
    photoType = 'gif';
    teledart.telegram.sendChatAction(message.chat.id, 'upload_video');
  } else {
    teledart.telegram.sendChatAction(message.chat.id, 'upload_photo');
  }

  final result = (await advancedApi.loadDataFromAPI(
    apiParams['url'],
    {
      'mime_types': photoType,
      'size': 'small',
      'sub_id': message.from.username,
      'limit': 1,
    },
  ))
      .data[0];

  final replyMarkup = InlineKeyboardMarkup(
    inline_keyboard: [
      [
        InlineKeyboardButton(
          text: '❤',
          callback_data: '${apiParams['typeEN']} upvote ${result['id']}',
        ),
        InlineKeyboardButton(
          text: '🤢',
          callback_data: '${apiParams['typeEN']} downvote ${result['id']}',
        ),
      ],
    ],
  );

  if (photoType == 'jpg,png') {
    teledart.replyPhoto(
      message,
      result['url'],
      reply_markup: replyMarkup,
    );
  } else {
    teledart.replyAnimation(
      message,
      result['url'],
      reply_markup: replyMarkup,
    );
  }
}

void handleVoteWithApi(
  TeleDart teledart,
  CallbackQuery query,
  DogCatHelper advancedApi,
  AnimalType type,
  String id,
  int value,
) async {
  final apiParams = DogCatHelper.getApiParams(type);

  final result = await advancedApi.voteWithAPI(apiParams['url'], {
    'image_id': id,
    'sub_id': query.from.username,
    'value': value,
  });

  if (result.statusCode == 200) {
    teledart.telegram.answerCallbackQuery(
      query.id,
      text:
          'Вы проголосовали ${(value == 1) ? 'за' : 'против'} этого ${apiParams['typeRU']}а!',
    );
  } else {
    teledart.telegram.answerCallbackQuery(
      query.id,
      text: 'Произошла ошибка ${result.statusCode} на стороне API',
    );
  }
}

void editMessage(
  TeleDart teledart,
  Message message,
  String newText,
  String parseMode,
) {
  teledart.telegram.editMessageText(
    newText,
    chat_id: message.chat.id,
    message_id: message.message_id,
    parse_mode: parseMode,
  );
}

void messageProcessing(
  TeleDart teledart,
  Message message,
  Logger logger,
  String botUsername,
) {
  String text = message.text;
  logger.logAction(
    ActionType.Message,
    user: message.from.username,
    channel: (message.chat.title != null) ? message.chat.title : botUsername,
    text: (text != null) ? text : '[S]',
  );

  if (text != null) {
    if (text.toLowerCase().startsWith('вопрос:') && text.endsWith('?')) {
      teledart.replyMessage(message, RandomHelper.listElement(kAnsVariants));
    } else if (text.startsWith('?')) {
      if (text.startsWith('? ')) {
        autoremoval(teledart, message, logger);
      } else {
        String strTimer = text.split(' ')[0].substring(1);
        int timer = int.tryParse(strTimer);
        if (timer != null) {
          autoremoval(teledart, message, logger, timer);
        }
      }
    }
  }
}

void autoremoval(TeleDart teledart, Message message, Logger logger,
    [int timer = 5]) {
  logger.log('Message will be deleted after $timer seconds');
  Timer(Duration(seconds: timer), () {
    teledart.telegram.deleteMessage(message.chat.id, message.message_id);
    logger.log('Message was deleted');
  });
}
