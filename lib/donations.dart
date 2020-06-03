import 'dart:convert';
import 'dart:io';

class DonationLib {
  DonationLib(this.jsonPath) {
    jsonFile = File(jsonPath);
  }
  
  File jsonFile;
  final String jsonPath;

  /// Method fot loading list of donators
  List<dynamic> loadList() {
    return jsonDecode(jsonFile.readAsStringSync());
  }
}
