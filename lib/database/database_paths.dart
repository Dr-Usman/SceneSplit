import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

const databaseFileName = 'scene_split.sqlite';

Future<String> resolveDatabasePath() async {
  final dir = await getApplicationDocumentsDirectory();
  return p.join(dir.path, databaseFileName);
}
