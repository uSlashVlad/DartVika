import 'package:DartVika/database.dart';

enum MarriageStatus { Invite, InviteRewritten, Accept, ExistsFrom, ExistsTo }

class MarriageLib {
  static Future<MarriageStatus> marry(String from, String to) async {
    // In case if one of parners is married
    // Exists "from" as A
    var eA = await MongoDB().loadOne('marriages', {'a': from});
    // Exists "from" as B
    var eB = await MongoDB().loadOne('marriages', {'b': from});
    if (eA != null || eB != null) {
      return MarriageStatus.ExistsFrom;
    }

    // Exists "to" as A
    eA = await MongoDB().loadOne('marriages', {'a': to});
    // Exists "to" as B
    eB = await MongoDB().loadOne('marriages', {'b': to});
    if (eA != null || eB != null) {
      return MarriageStatus.ExistsTo;
    }

    // If "from" already sent invite
    var eTemp = await MongoDB().loadOne('temp_marriages', {'a': from});
    if (eTemp != null) {
      await MongoDB().delete('temp_marriages', {'a': from});
      await MongoDB().insert('temp_marriages', {'a': from, 'b': to});
      return MarriageStatus.InviteRewritten;
    }

    // If "to" accepts invite of "from"
    eTemp = await MongoDB().loadOne('temp_marriages', {'a': to});
    if (eTemp != null && eTemp['b'] == from) {
      await MongoDB().insert('marriages', {'a': from, 'b': to});
      // Cleaning invites from DB
      await MongoDB().delete('temp_marriages', {'a': from});
      await MongoDB().delete('temp_marriages', {'a': to});
      return MarriageStatus.Accept;
    }

    print('$from $to');
    await MongoDB().insert('temp_marriages', {'a': from, 'b': to});
    return MarriageStatus.Invite;
  }

  static Future<String> divorse(String from) async {
    final eA = await MongoDB().loadOne('marriages', {'a': from});
    final eB = await MongoDB().loadOne('marriages', {'b': from});
    if (eA != null || eB != null) {
      await MongoDB().delete('marriages', {'a': from});
      await MongoDB().delete('marriages', {'b': from});
      return '${(eA != null) ? eA['b'] : ''}${(eB != null) ? eB['a'] : ''}';
    } else {
      return null;
    }
  }
}
