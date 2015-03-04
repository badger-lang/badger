part of badger.io;

class IOLibrary {
  static void import(Context context) {
    context.define("getUrl", (args) async {
      var url = args[0];
      var client = new HttpClient();
      var request = await client.getUrl(Uri.parse(url));
      var response = await request.close();
      var text = await response.transform(UTF8.decoder).join();

      client.close();

      return text;
    });
  }
}
