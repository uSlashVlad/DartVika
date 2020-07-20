/// Variants for "Вопрос: <question>" syntax
const kAnsVariants = [
  'Да, конечно',
  'Определённо',
  'Ну конечно же!',
  'В принципе да...',
  'А какой у тебя ответ?',
  'Думаю да',
  'Пока что да',
  'Скорее да, чем нет',
  'Может быть',
  'Затрудняюсь ответить',
  'Не понятно...',
  'Спроси лучше настоящую Вику',
  'Я здесь ничем не помогу',
  'Не думаю',
  'Вряд ли',
  'Точно нет',
  'Ну не знаю...',
  'Да конечно же нет!',
];

/// String for /help command > help_commands CQ
const kCommandsList = '''<b>[ Команды ]</b>
    
-основные-
/start - <i>"Hello World!"</i>
/help - <i>помощь</i>
/gay - <i>о создателе</i>
/donations - <i>список лучших людей на свете</i>
/luck - <i>рандомно даст/не даст по жопе</i>
/f - <i>Press F to pay respect</i>
/changelog - <i>список изменений</i>
/try <code>[текст]</code> - <i>попробовать что-нибудь</i>

-API-
/cat - <i>отправит фото котика</i>
/dog - <i>отправит фото пёсика</i>

-свадьбы-
/marry <code>[юзернейм]</code> - <i>жениться/выйти замуж</i>
/divorse - <i>развестись</i>
/pairs - <i>список пар</i>

-другое-
Вопрос: <code>[текст]</code>? - <i>бот как-нибудь отвечает в варианте да/нет</i>
?<code>[время в сек]</code> <code>[текст]</code> - <i>бот удалит через количество секунд, указанное после "?"</i>''';

/// String for /help command > help_about CQ
const kAboutBot = '''Всё сделано ради <a href="https://umschool.net/core/profile/">Умскула</a>

<b>[ О боте ]</b>
Бот создан специально для беседы <b>Дети Вики</b>
Узнать функционал можно через меню команды /help
<a href="https://github.com/uSlashVlad/DartVika">Исходный код</a>

О создателе: /gay''';

/// String for /gay command
const kAboutCreator = '''<b>[ Создатель ]</b>
<a href="https://github.com/uslashvlad">GitHub</a> <a href="https://vk.com/uslashvlad">ВК</a>
<a href="https://t.me/uslashvlad">Telegram</a>
Список донатеров и способ задонатить в /donations

<i>Не ЧСВ :)</i>''';

/// Cat API url
const kCatApiUrl = 'https://api.thecatapi.com';
/// Dog API url
const kDogApiUrl = 'https://api.thedogapi.com';
