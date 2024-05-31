import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TextInputButton extends StatefulWidget {
  const TextInputButton({super.key, this.buttonText});
  final buttonText;
  @override
  _TextInputButtonState createState() => _TextInputButtonState();
}

class _TextInputButtonState extends State<TextInputButton> {
  final TextEditingController _controller = TextEditingController();
  Color _buttonColor = Color(0xFFE2E2E2);
  Color _textColor = Color(0xFFAEAEAE);

  @override
  void initState() {
    super.initState();
    // _controller.addListener(() {
    //   setState(() {
    //     if (_controller.text.length == 6 && _controller|.text.runes.every((r) => r >= '0'.runes.first && r <= '9'.runes.first)) {
    //       _buttonColor = Color(0xFFEC295D);
    //       _textColor = Colors.white;
    //     } else {
    //       _buttonColor = Color(0xFFE2E2E2);
    //       _textColor = Colors.white;
    //     }
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}