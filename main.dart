import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';
import 'package:dotenv/dotenv.dart' show load, env;

import 'package:DartVika/random.dart';
import 'package:DartVika/constants.dart';
import 'package:DartVika/logger.dart';
import 'package:DartVika/donationlib.dart';

void main() {
  load();

  Logger logger = Logger('./main.log');
  DonationLib donations = DonationLib('./data/donations.json');
  String _botUsername;

  try {
    TeleDart teledart = TeleDart(Telegram(env['TOKEN']), Event());
    teledart.start().then((me) {
      logger.log('[${DateTime.now()}]\n${me.username} is initialised');
      _botUsername = me.username;
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

    teledart.onCommand('luck').listen((message) {
      String text;
      if (RandomHelper.chance(0.5)) {
        text = 'Тебе не повезло, получай по жопе 👋👋👋';
      } else {
        text = 'Тебе повезло, твоя жопа в сохранности';
      }
      teledart.replyMessage(message, text);
    });

    // Hadling Callback query
    teledart.onCallbackQuery().listen((query) async {
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
          result = '[Unknown CQ]';
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
      String text = message.text;
      logger.logAction(
        ActionType.Message,
        user: message.from.username,
        channel:
            (message.chat.title != null) ? message.chat.title : _botUsername,
        text: (text != null) ? text : '[S]',
      );

      if (text != null) {
        if (text.toLowerCase().startsWith('вопрос:') && text.endsWith('?')) {
          teledart.replyMessage(message, RandomHelper.listElemt(kAnsVariants));
        }
      }
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
  } catch (e) {
    logger.log('[Fatal error]\n-- BOT WILL BE RESTARTED --\n$e');
  }
}

void editMessage(
    TeleDart teledart, Message message, String newText, String parseMode) {
  teledart.telegram.editMessageText(
    newText,
    chat_id: message.chat.id,
    message_id: message.message_id,
    parse_mode: parseMode,
  );
}
