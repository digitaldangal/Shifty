import 'package:flutter/material.dart';
import 'package:shifty/app_text_styles.dart';
import 'package:shifty/font_awesome_icon_data.dart';

final botNavItems = [
  new BottomNavigationBarItem(
    icon: new Icon(FontAwesomeIcons.user_circle),
    title: new Text(
      'Profile',
      style: AppTextStyles.tabBarLabel,
    ),
  ),
  new BottomNavigationBarItem(
    icon: new Icon(FontAwesomeIcons.briefcase),
    title: new Text(
      'Jobs',
      style: AppTextStyles.tabBarLabel,
    ),
  ),
  new BottomNavigationBarItem(
    icon: new Icon(FontAwesomeIcons.calendar_alt),
    title: new Text(
      'Schedule',
      style: AppTextStyles.tabBarLabel,
    ),
  ),
  new BottomNavigationBarItem(
    icon: new Icon(FontAwesomeIcons.cog),
    title: new Text(
      'Settings',
      style: AppTextStyles.tabBarLabel,
    ),
  ),
];

final botNavItemTabs = {0: false, 1: true, 2: false, 3: false};
