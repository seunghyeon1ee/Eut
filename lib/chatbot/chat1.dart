import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:taba_app_proj/chatbot/greeting.dart';


// RippleAnimation(
// child: CircleAvatar(
// minRadius: 75,
// maxRadius: 75,
// backgroundImage: NetworkImage(Constants.avtarUrl),
// ),
// color: Colors.deepOrange,
// delay: const Duration(milliseconds: 300),
// repeat: true,
// minRadius: 75,
// ripplesCount: 6,
// duration: const Duration(milliseconds: 6 * 300),
// )

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GreetingProvider(),
      child: Chat1(),
    ),
  );
}

// class Chat1 extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: HomeScreen(),
//     );
//   }
// }

class Chat1 extends StatelessWidget {
  const Chat1({super.key});
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
        body: Padding(
        padding: EdgeInsets.all(20),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 150),
        Consumer<GreetingProvider> (
          builder: (context, provider, child) {
            return Text(provider.greeting,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontSize: 24,
                  fontFamily: 'Noto Sans', fontWeight: FontWeight.w600, height: 0.06),);
          },
        ),
            ],
          ),
        ),
      ),
    );
  }
}

class RippleEffectPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RippleAnimation(
          repeat: true,
          color: Color(0xFFFF7672),
          minRadius: 90,
          ripplesCount: 6,
          child: ClipOval(
            child: SvgPicture.asset('assets/chatbot_test.svg',
            width: 120, height: 120, fit: BoxFit.cover),
          ),
              ),
            ),
    );
  }
}