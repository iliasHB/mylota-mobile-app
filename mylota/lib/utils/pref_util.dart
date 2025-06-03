//ignore: unused_import
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefUtils {
  static SharedPreferences? _sharedPreferences;

  PrefUtils() {
    SharedPreferences.getInstance().then((value) {
      _sharedPreferences = value;
    });
  }

  Future<void> init() async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
    print('SharedPreference Initialized');
  }

  Future<dynamic> setStringList(key, value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = prefs.setStringList('$key', value);
    return result;
  }

  Future<dynamic> getStringList(key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = prefs.getStringList('$key');
    return result;
  }

  Future<dynamic> setOtherStringList(key, value) async {
    final SharedPreferences otherPrefs = await SharedPreferences.getInstance();
    var result = otherPrefs.setStringList('$key', value);
    return result;
  }

  Future<dynamic> getOtherStringList(key) async {
    final SharedPreferences otherPrefs = await SharedPreferences.getInstance();
    var result = otherPrefs.getStringList('$key');
    return result;
  }

  Future<dynamic> deleteUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = prefs.clear();
    return result;
  }

  Future<dynamic> deletekey(key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = prefs.remove(key);
    return result;
  }

  Future<dynamic> setExerciseStr(key, value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = prefs.setString('$key', value);
    return result;
  }

  Future<dynamic> getExerciseStr(key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = prefs.getString('$key');
    return result;
  }

  Future<dynamic> setInt(key, value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = prefs.setInt('$key', value);
    return result;
  }

  Future<dynamic> getInt(key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = prefs.getInt('$key');
    return result;
  }


  ///will clear all the data stored in preference
  clearPreferencesData() async {
    _sharedPreferences!.clear();
  }
}
