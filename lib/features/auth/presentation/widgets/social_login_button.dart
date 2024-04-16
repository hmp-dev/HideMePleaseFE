import 'package:flutter/material.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/default_image.dart';

/// All Supported Button Types
enum SocialLoginButtonType {
  /// Facebook
  facebook,

  /// Google
  google,

  /// Twitter
  twitter,

  /// Apple
  apple,

  /// Apple (with black background)
  appleBlack,

  /// Microsoft
  microsoft,

  /// Microsoft (with black background)
  microsoftBlack,

  /// Github
  github,

  /// General Logo, without any image, default text is 'Sign In'
  generalLogin,

  //

  worldId
}

/// All SSupported Button Modes
enum SocialLoginButtonMode { single, multi }

// ignore: must_be_immutable
class SocialLoginButton extends StatelessWidget {
  SocialLoginButton({
    super.key,
    required this.buttonType,
    required this.onPressed,
    this.imageURL,
    this.imagePath,
    this.text,
    this.backgroundColor = white,
    this.disabledBackgroundColor,
    this.height = 52.0,
    this.borderRadius = 100.0,
    this.width,
    this.imageWidth = 32,
    this.mode = SocialLoginButtonMode.multi,
    this.textStyle,
  });

  /// Button Type
  final SocialLoginButtonType buttonType;

  /// Action onPressed
  final VoidCallback? onPressed;

  /// Image URL (increase you want to use network image), an optional param can be
  /// used to override default image.
  String? imageURL;

  /// Image Path (increase you want to use local image), an optional param can be
  /// used to override default image.
  String? imagePath;

  /// Button text, an optional param can be used to override default text
  String? text;

  /// Background Color, an optional param can be used to override default
  /// background color.
  Color? backgroundColor;

  /// Height, an optional param can be used to override default height of button,
  /// which is 55.0
  double? height;

  /// Border Radius text, an optional param can be used to override default
  /// border radius, which is 4.0.
  double? borderRadius;

  /// Width, an optional param can be used to override default button Width.
  double? width;

  /// Image Width, an optional param can be used to override default button
  /// image width which is 45.0.
  double? imageWidth;

  /// Grey out color, an optional param can be used to override default
  /// background Color when button is in disabled state.
  Color? disabledBackgroundColor;

  /// Button Mode, an optional param, can be used to create single style button.
  SocialLoginButtonMode? mode;

  /// Text Style, an optional param can be used to override default text style.
  TextStyle? textStyle;

  final _defaultImagePath = "assets/social-auth-logos/";
  bool _isLocal = true;

  @override
  Widget build(BuildContext context) {
    String? imageName;
    String? text;
    Color? backgroundColor;
    TextStyle? buttonTextStyle;

    switch (buttonType) {
      case SocialLoginButtonType.facebook:
        buttonTextStyle = textStyle ?? const TextStyle(color: Colors.white);
        text = "Sign In with Facebook";
        imageName = "${_defaultImagePath}facebook-logo.png";
        backgroundColor = const Color(0xFF334D92);
        _isLocal = false;
        break;
      case SocialLoginButtonType.google:
        buttonTextStyle = textStyle ?? const TextStyle(color: Colors.black87);
        text = "Sign In with Google";
        imageName = "${_defaultImagePath}google-logo.png";
        backgroundColor = Colors.white;
        _isLocal = false;
        break;
      case SocialLoginButtonType.twitter:
        buttonTextStyle = textStyle ?? const TextStyle(color: Colors.white);
        text = "Sign In with Twitter";
        imageName = "${_defaultImagePath}twitter-logo.png";
        backgroundColor = const Color(0xFF1DA1F2);
        _isLocal = false;
        break;
      case SocialLoginButtonType.apple:
        buttonTextStyle = textStyle ?? const TextStyle(color: Colors.black);
        text = "Sign In with Apple";
        imageName = "${_defaultImagePath}apple-logo.png";
        _isLocal = false;
        backgroundColor = Colors.white;
        break;
      case SocialLoginButtonType.appleBlack:
        buttonTextStyle = textStyle ?? const TextStyle(color: Colors.white);
        text = "Sign In with Apple";
        imageName = "${_defaultImagePath}apple-black-logo.png";
        backgroundColor = Colors.black;
        _isLocal = false;
        break;
      case SocialLoginButtonType.microsoft:
        buttonTextStyle =
            textStyle ?? const TextStyle(color: Color(0xFF5E5E5E));
        text = "Sign In with Microsoft";
        imageName = "${_defaultImagePath}microsoft-logo.png";
        backgroundColor = Colors.white;
        _isLocal = false;
        break;
      case SocialLoginButtonType.microsoftBlack:
        buttonTextStyle = textStyle ?? const TextStyle(color: Colors.white);
        text = "Sign In with Microsoft";
        imageName = "${_defaultImagePath}microsoft-logo.png";
        backgroundColor = const Color(0xFF2F2F2F);
        _isLocal = false;
        break;
      case SocialLoginButtonType.github:
        buttonTextStyle =
            textStyle ?? const TextStyle(color: Color(0xFFFEFEFE));
        text = "Sign In with Github";
        imageName = "${_defaultImagePath}github-logo.png";
        backgroundColor = const Color(0xFF444444);
        _isLocal = false;
        break;

      case SocialLoginButtonType.worldId:
        buttonTextStyle =
            textStyle ?? const TextStyle(color: Color(0xFFFEFEFE));
        text = "Sign In with WorldId";
        imageName = "${_defaultImagePath}ic_worldcoin.svg";
        backgroundColor = const Color(0xFF444444);
        _isLocal = false;
        break;

      case SocialLoginButtonType.generalLogin:
        buttonTextStyle = textStyle ?? const TextStyle(color: Colors.white);
        text = "Sign In";
        backgroundColor = Colors.teal[700];
        _isLocal = true;
        break;
    }
    text =
        mode == null || mode == SocialLoginButtonMode.multi ? text : ' Sign In';
    return _LoginButton(
      imagePath: imagePath ?? imageURL ?? imageName,
      text: this.text ?? text,
      backgroundColor: this.backgroundColor ?? backgroundColor,
      disabledBackgroundColor: disabledBackgroundColor,
      onPressed: onPressed,
      height: height!,
      borderRadius: borderRadius!,
      mode: mode!,
      width: width,
      imageWidth: imageWidth,
      isNetworkImage: imagePath == null && imageURL != null,
      isLocal: _isLocal,
      textStyle: buttonTextStyle,
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({
    super.key,
    required this.imagePath,
    required this.isNetworkImage,
    required this.text,
    this.backgroundColor = Colors.blueAccent,
    this.disabledBackgroundColor,
    required this.height,
    required this.borderRadius,
    required this.onPressed,
    required this.mode,
    this.width,
    this.imageWidth,
    this.textStyle,
    required this.isLocal,
  });

  final String? imagePath;
  final bool isNetworkImage;
  final String text;
  final Color? backgroundColor;
  final Color? disabledBackgroundColor;
  final double height;
  final double? width;
  final double? imageWidth;
  final double borderRadius;
  final VoidCallback? onPressed;
  final SocialLoginButtonMode mode;
  final bool isLocal;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: height,
        width: width,
        child: ElevatedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(borderRadius),
                ),
              ),
            ),
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.disabled)) {
                  return disabledBackgroundColor ?? backgroundColor!;
                }
                return backgroundColor!;
              },
            ),
          ),
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              createImageChildren(),
              Text(
                text,
                style: fontSB(16, color: black800),
              ),
              Opacity(
                opacity: 0.0,
                child: createImageChildren(mode: mode),
              ),
            ],
          ),
        ),
      ),
    );
  }

  createImageChildren({SocialLoginButtonMode? mode}) {
    if (mode == null || mode == SocialLoginButtonMode.multi) {
      return imagePath == null
          ? const Column()
          : isNetworkImage
              ? Image.network(
                  imagePath!,
                  width: imageWidth,
                  errorBuilder: (context, exception, stackTrace) =>
                      const Icon(Icons.error),
                )
              : DefaultImage(
                  path: imagePath ?? "",
                  //width: imageWidth,
                  height: imageWidth,
                );
    }
    return const Column();
  }
}
