import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 90,
              child: Image.asset('assets/images/search.png', fit: BoxFit.cover),
            ),
            SizedBox(height: 17),
            Text(
              'Looking for a resource, project, task, or update? Search here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                fontFamily: GoogleFonts.inter().fontFamily,
                color: Color.fromRGBO(51, 51, 51, 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
