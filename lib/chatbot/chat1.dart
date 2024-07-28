import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:taba_app_proj/provider/greeting.dart';
import 'package:taba_app_proj/chatbot/select_image_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GreetingProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Chat1(),
    );
  }
}

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
              Consumer<GreetingProvider>(
                builder: (context, provider, child) {
                  return Text(
                    provider.greeting,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontFamily: 'Noto Sans',
                      fontWeight: FontWeight.w600,
                      height: 0.06,
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              RippleEffectPage(imagePath: 'assets/botboy.svg'),
            ],
          ),
        ),
      ),
    );
  }
}

class RippleEffectPage extends StatelessWidget {
  final String imagePath;

  RippleEffectPage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SelectImagePage(),
            ),
          );
        },
        child: RippleAnimation(
          repeat: true,
          color: Color(0xFFFF7672),
          minRadius: 90,
          ripplesCount: 6,
          child: ClipOval(
            child: SvgPicture.asset(
              imagePath,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
