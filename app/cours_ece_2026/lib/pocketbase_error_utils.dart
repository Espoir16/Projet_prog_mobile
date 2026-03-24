import 'package:pocketbase/pocketbase.dart';

bool isMissingCollectionError(Object error) {
  return error is ClientException &&
      error.statusCode == 404 &&
      error.response['message'] == 'Missing collection context.';
}
