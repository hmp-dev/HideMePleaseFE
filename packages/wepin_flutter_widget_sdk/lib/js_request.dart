class JSRequest {
  RequestHeader header;
  RequestBody body;

  JSRequest({required this.header, required this.body});

  factory JSRequest.fromJson(Map<String, dynamic> json) {
    return JSRequest(
        header: RequestHeader.fromJson(json['header']),
        body: RequestBody.fromJson(json['body']));
  }
}

class RequestHeader {
  int id;
  String request_to;
  String request_from;


  // RequestHeader()
  // : id = DateTime.now().millisecondsSinceEpoch,
  //   request_to = 'wepin_widget',
  //   request_from = 'flutter';

  RequestHeader({required this.id, required this.request_to, required this.request_from});

  factory RequestHeader.fromJson(Map<dynamic, dynamic> json) {
    return RequestHeader(
        id: json['id'],
        request_to: json['request_to'],
        request_from: json['request_from']);
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request_to': request_to,
      'request_from': request_from,
    };
  }

}

class RequestBody {
  String command;
  dynamic parameter;

  RequestBody({required this.command, this.parameter});

  factory RequestBody.fromJson(Map<dynamic, dynamic> json) {
    return RequestBody(command: json['command'], parameter: json['parameter']);
  }
}
