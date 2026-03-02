import 'package:flutter/material.dart';

import 'header.dart';
import 'about_section.dart';
import 'stats_row.dart';
import 'values_section.dart';
import 'footer_section.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF7F3),
      body: CustomScrollView(
        slivers: [
          const AboutHeader(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  AboutSection(
                    title: "Who We Are",
                    description:
                        "We are a technology-driven food platform focused on delivering fresh, homemade meals prepared with quality ingredients and care.",
                  ),
                  AboutSection(
                    title: "Our Vision",
                    description:
                        "To redefine food delivery by empowering local kitchens and ensuring sustainability.",
                  ),
                  AboutSection(
                    title: "Why Choose Us",
                    description:
                        "✔ Verified home chefs\n"
                        "✔ Hygienic food standards\n"
                        "✔ Fast & reliable delivery\n"
                        "✔ Customer-centric experience",
                  ),
                  SizedBox(height: 30),
                  StatsRow(),
                  SizedBox(height: 40),
                  ValuesSection(),
                  SizedBox(height: 40),
                  FooterSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
