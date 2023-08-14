import 'package:bungkus_bang/views/screens/widgets/banner_widget.dart';
import 'package:bungkus_bang/views/screens/widgets/category_text.dart';
import 'package:bungkus_bang/views/screens/widgets/men_shoes.dart';
import 'package:bungkus_bang/views/screens/widgets/reuseText_widget.dart';
import 'package:flutter/material.dart';

import 'widgets/beauty_widget.dart';
import 'widgets/customAppBar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        children: [
          CustomAppBar(),
          SizedBox(
            height: 10,
          ),
          BannerWidget(),
          SizedBox(
            height: 10,
          ),
          CategoryText(),
          ResuseTextWidget(
            title: "Roti's Products",
          ),
          MenShoes(),
          SizedBox(
            height: 10,
          ),
          ResuseTextWidget(
            title: "Nasi' Products",
          ),
          BeautyWidget(),
        ],
      ),
    ));
  }
}
