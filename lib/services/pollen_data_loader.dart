import '../models/pollen_entry.dart';

typedef PollenDataLoader =
    Future<List<PollenEntry>> Function({
      required double latitude,
      required double longitude,
    });
