import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class BoldMsgGenerator {
  static AutoSizeText toRichText({
    required String text,
    required TextStyle style,
    required TextStyle boldStyle,
    TextAlign? textAlign,
    int? maxLine,
  }) {
    List<InlineSpan> texts = [];
    var text0 = _GuideMessageGenerator.from(text);

    for (var i = 0; i < text0.length; i++) {
      texts.add(
        TextSpan(
          text: text0[i].message,
          // recognizer: TapGestureRecognizer()
          //   ..onTap = () {
          //     if (_text[i].isBold && onTap != null) {
          //       onTap();
          //     }
          //   },
          style: text0[i].isBold ? boldStyle : style,
        ),
      );
    }

    return AutoSizeText.rich(
      TextSpan(
        children: texts,
      ),
      minFontSize: 1,
      textAlign: textAlign,
      maxLines: maxLine ?? _getTextLine(text),
      overflow: TextOverflow.ellipsis,
    );
  }

  static int _getTextLine(String text) {
    if (text.contains("\n")) {
      return text.split("\n").length;
    } else {
      return 1;
    }
  }
}

class _BoldMessage {
  final String message;
  final bool isBold;

  _BoldMessage({required this.message, this.isBold = false});
}

class _GuideMessageGenerator {
  static const BOLD_SIGN = "*";

  static List<_BoldMessage> from(String msg) {
    if (msg.split('').where((e) => e == BOLD_SIGN).toList().length % 2 != 0) {
      msg = msg + BOLD_SIGN;
    }

    int startIdx = 0;
    List<int> signIdxs = [];
    while (startIdx != -1) {
      startIdx = msg.indexOf(BOLD_SIGN, startIdx) + 1;
      if (startIdx != 0) {
        signIdxs.add(startIdx);
      } else {
        break;
      }
    }

    if (signIdxs.isEmpty) {
      return [_BoldMessage(message: msg)];
    }

    List<_BoldMessage> result = [];
    for (var i = 0; i < signIdxs.length / 2; i++) {
      var idx = 0;
      try {
        idx = signIdxs[2 * i - 1];
        // ignore: empty_catches
      } catch (err) {}
      result
          .add(_BoldMessage(message: msg.substring(idx, signIdxs[2 * i] - 1)));
      result.add(_BoldMessage(
          message: msg.substring(signIdxs[2 * i], signIdxs[2 * i + 1] - 1),
          isBold: true));

      if (i == signIdxs.length / 2 - 1 && signIdxs[i] != msg.length) {
        result.add(
            _BoldMessage(message: msg.substring(signIdxs.last, msg.length)));
      }
    }

    result = result.where((e) => e.message != "").toList();
    return result;
  }
}
