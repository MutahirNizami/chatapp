import 'package:chatapp/utilites/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Appbutton extends StatelessWidget {
  final Function()? ontap;
  final String text;
  final Color? color;
  final double? btnwidth;
  final double? btnheight;
  final double? borderradius;
  final Border? borderSide;
  final Color? textcolor;
  final Color? btncolor;
  final double? fontSize;
  final FontWeight? fontWeight;

  const Appbutton(
      {super.key,
      required this.ontap,
      required this.text,
      this.color,
      this.btnwidth,
      this.btnheight,
      this.borderradius,
      this.textcolor,
      this.btncolor,
      this.fontSize,
      this.fontWeight,
      this.borderSide});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return InkWell(
      onTap: ontap,
      child: Container(
        height: btnheight ?? height * 0.05,
        width: btnwidth ?? width * 0.04,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            color: btncolor ?? Mycolor().subtitlecolor,
            borderRadius: BorderRadius.circular(borderradius ?? 8)),
        child: Center(
            child: Text(text,
                style: GoogleFonts.poppins(
                  color: textcolor ?? Colors.white,
                  fontSize: fontSize ?? height * 0.02,
                ))),
      ),
    );
  }
}
