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
import 'package:DartVika/changelog.dart';
import 'package:DartVika/database.dart';

// Classes initializations
Logger logger = Logger('./main.log');
DogCatHelper advancedApi = DogCatHelper(env['DOGCAT_KEY'], logger);
TeleDart teledart = TeleDart(Telegram(env['TOKEN']), Event());
String changelog = loadChanges('./data/changelog');
String _botUsername;

void main() {
  load(); // Enviroment variables loading

  MongoDB().start('backdb');

  try {
    teledart.start().then((me) {
      logger.log('[${DateTime.now()}]\n${me.username} is initialised');
      _botUsername = me.username;
    });

    // Hadling Callback query
    teledart
      ..onCallbackQuery().listen(callbackqueryProcessing)

      // Handling messages
      ..onMessage().listen(messageProcessing)
      ..onMention().listen(messageProcessing)
      ..onHashtag().listen(messageProcessing)

      // Handling general command situations
      ..onCommand().listen((command) {
        logger.logAction(
          ActionType.Message,
          user: command.from.username,
          channel:
              (command.chat.title != null) ? command.chat.title : _botUsername,
          text: (command.text != null) ? command.text : '[S]',
        );
      })

      // Handling messages editing
      ..onEditedMessage().listen((message) {
        logger.logAction(
          ActionType.Message,
          user: message.from.username,
          channel:
              (message.chat.title != null) ? message.chat.title : _botUsername,
          text: (message.text != null) ? message.text : '[special]',
          additional: '[E]',
        );
        messagePostProcessing(message);
      })

      // Handling /start command
      ..onCommand('start')
          .listen((message) => teledart.replyMessage(message, 'Hello World!'))

      // Handling /help command
      ..onCommand('help').listen((message) {
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
      })

      // Handling /gay command
      ..onCommand('gay').listen((message) =>
          teledart.replyMessage(message, kAboutCreator, parse_mode: 'html'))

      // Handling /donations command
      ..onCommand('donations').listen((message) async {
        try {
          final inlineKeyboard = InlineKeyboardMarkup(inline_keyboard: [
            [
              InlineKeyboardButton(
                  text: 'Мой Qiwi', url: 'https://qiwi.com/n/VLADN')
            ],
            [
              InlineKeyboardButton(
                  text: 'Donation alerts',
                  url: 'https://www.donationalerts.com/r/uslashvlad')
            ],
          ]);

          final donations = await DonationLib.loadList();
          String text = '<b><u>[Почётные донатеры]</u></b>\n';
          int i = 0;
          donations.forEach((key, value) {
            if (i < 3) text += '<b>'; // (for 1st-3rd places)
            text += '${i + 1}) $key\n$value руб.\n';
            if (i < 3) text += '</b>'; // (for 1st-3rd places)});
            i++;
          });
          teledart.replyMessage(
            message,
            text,
            parse_mode: 'html',
            reply_markup: inlineKeyboard,
          );
        } catch (e) {
          logger.log('[Fatal command error] $e');
        }
      })

      // Handling /luck command
      ..onCommand('luck').listen((message) {
        String text;
        if (RandomHelper.chance(0.5)) {
          text = 'Тебе не повезло, получай по жопе 👋👋👋';
        } else {
          text = 'Тебе повезло, твоя жопа в сохранности';
        }
        teledart.replyMessage(message, text);
      })

      // Handling /f command
      ..onCommand('f').listen((message) {
        teledart.telegram.getStickerSet('FforRespect').then((responce) {
          final stickers = responce.stickers;
          Sticker randSticker = RandomHelper.listElement(stickers);
          teledart.replySticker(message, randSticker.file_id);
        });
      })

      // Handling /cat command
      ..onCommand('cat')
          .listen((message) => sendFileFromAPI(message, AnimalType.Cat))

      // Handling /dog command
      ..onCommand('dog')
          .listen((message) => sendFileFromAPI(message, AnimalType.Dog))

      // Handling /changelog command
      ..onCommand('changelog').listen((message) => teledart
          .replyMessage(message, '`$changelog`', parse_mode: 'markdown'));
  } catch (e) {
    // If main part causes problems
    logger.log('[Fatal error]\n\n$e\n\n-- BOT WILL BE RESTARTED --');
    main();
  }
}

/// Function for sending file from API to chat
void sendFileFromAPI(
  Message message,
  AnimalType type,
) async {
  final apiParams = DogCatHelper.getApiParams(type);
  final args = StringLib.getArgs(message.text);
  String photoType = 'jpg,png';

  // Chat action to chat like "sending photo..."
  if (args.length > 1 && args[1] == 'gif') {
    photoType = 'gif';
    teledart.telegram.sendChatAction(message.chat.id, 'upload_video');
  } else {
    teledart.telegram.sendChatAction(message.chat.id, 'upload_photo');
  }

  // Request
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

  // Inline keyboard
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

/// Function for handling votes
void handleVoteWithApi(
  CallbackQuery query,
  AnimalType type,
  String id,
  int value,
) async {
  final apiParams = DogCatHelper.getApiParams(type);

  // Request
  final result = await advancedApi.voteWithAPI(apiParams['url'], {
    'image_id': id,
    'sub_id': query.from.username,
    'value': value,
  });

  if (result.statusCode == 200) {
    // If everything is OK
    teledart.telegram.answerCallbackQuery(
      query.id,
      text:
          'Вы проголосовали ${(value == 1) ? 'за' : 'против'} этого ${apiParams['typeRU']}а!',
    );
  } else {
    // If there is an error
    teledart.telegram.answerCallbackQuery(
      query.id,
      text: 'Произошла ошибка ${result.statusCode} на стороне API',
    );
  }
}

/// Function for simple message editing
void editMessage(Message message, String newText, String parseMode) {
  teledart.telegram.editMessageText(
    newText,
    chat_id: message.chat.id,
    message_id: message.message_id,
    parse_mode: parseMode,
  );
}

/// Function for processing usual messages
void messageProcessing(Message message) {
  String text = message.text;
  logger.logAction(
    ActionType.Message,
    user: message.from.username,
    channel: (message.chat.title != null) ? message.chat.title : _botUsername,
    text: (text != null) ? text : '[S]',
  );
  messagePostProcessing(message);
}

void messagePostProcessing(Message message) {
  String text = message.text;

  if (text != null) {
    if (text.toLowerCase().startsWith('вопрос:') && text.endsWith('?')) {
      // For "Вопрос: <question>" syntax
      teledart.replyMessage(message, RandomHelper.listElement(kAnsVariants));
    } else if (text.startsWith('?')) {
      // Handling messages for autoremoval
      if (text.startsWith('? ') || text.startsWith('?\n')) {
        // Without specific timer
        autoremoval(message);
      } else {
        // With specific timer
        // Cuts string with lines, spaces, gets the very first part (with "?<time>" syntax)
        String strTimer = text.split('\n')[0].split(' ')[0].substring(1);
        int timer = int.tryParse(strTimer);
        if (timer != null) {
          autoremoval(message, timer);
        }
      }
    }
  }
}

/// Function fot processing CQs
void callbackqueryProcessing(CallbackQuery query) {
  // print(query.toJson());
  String data = query.data;
  String result = '[Error]';
  switch (data) {
    // /help command CQs processing
    case 'help_about':
      editMessage(query.message, kCommandsList, 'html');
      result = '[Processed]';
      break;
    case 'help_commands':
      editMessage(query.message, kAboutBot, 'html');
      result = '[Processed]';
      break;
    default:
      // /cat and /dog commands CQs processing
      final cqArgs = StringLib.getArgs(query.data);
      switch (cqArgs[0]) {
        case 'cat':
          if (cqArgs[1] == 'upvote') {
            handleVoteWithApi(
              query,
              AnimalType.Cat,
              cqArgs[2],
              1,
            );
          } else {
            handleVoteWithApi(
              query,
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
              query,
              AnimalType.Dog,
              cqArgs[2],
              1,
            );
          } else {
            handleVoteWithApi(
              query,
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
}

/// Function for processing autoremoval
void autoremoval(Message message, [int timer = 5]) {
  logger.log('Message will be deleted after $timer seconds');
  Timer(Duration(seconds: timer), () {
    teledart.telegram.deleteMessage(message.chat.id, message.message_id);
    logger.log('Message was deleted');
  });
}
