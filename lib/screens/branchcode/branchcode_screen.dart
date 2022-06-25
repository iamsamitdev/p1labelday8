// ignore_for_file: avoid_unnecessary_containers, sized_box_for_whitespace, prefer_const_constructors, prefer_const_constructors_in_immutables, prefer_const_literals_to_create_immutables, avoid_print

import 'dart:developer';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:ota_update/ota_update.dart';
// import 'package:p1label/components/IAppBar.dart';
import 'package:p1label/components/widgets.dart';
import 'package:p1label/helper/shared_pref.dart';
import 'package:p1label/models/app_language.dart';
import 'package:p1label/provider/app_locale.dart';
import 'package:p1label/themes/colors.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
// import 'package:p1label/themes/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
// แสดงภาษาต่างๆ
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BranchCodeScreen extends StatefulWidget {
  BranchCodeScreen({Key? key}) : super(key: key);

  @override
  State<BranchCodeScreen> createState() => _BranchCodeScreenState();
}

class _BranchCodeScreenState extends State<BranchCodeScreen> {

  late SharedPreferences sharedPreferences;

  // สร้างตัวแปรสำหรับไว้ผูกกับฟอร์ม
  final formKey = GlobalKey<FormState>();

  // ตัวแปรเก็บรหัสสาขา
  late String _branchcode;

  // ตัวแปรเก็บชื่อสาขา
  final String _branch_name = "HHRSC1";

  // สร้าง Object Network Info
  final info = NetworkInfo();

  // สร้าง Object Device Info
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  // 

  //---------------------------------------------------
  // สำหรับการเปลี่ยนภาษา
  // สร้าง Object โหลด model สำหรับ drop downlist
  late AppLanguage dropdownValue;
  late String currentDefaultSystemLocale; // เก็บตัวภาษาจากระบบ // th_TH
  int selectedLangIndex = 0;
  late AppLocale _appLocale;

  @override
  void initState() {
    super.initState();
    dropdownValue = AppLanguage.languages().first;
    getAppVersion(); // เรียกใช้ฟังก์ชันอ่านข้อมูลแอพ
    
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appLocale = Provider.of<AppLocale>(context);
    getLocale().then((locale) {
      _appLocale.changeLocale(Locale(locale.languageCode));
      dropdownValue = AppLanguage.languages().firstWhere(
          (element) => element.languageCode == locale.languageCode);
      _setFlag();
    });
  }

  void _setFlag(){
    currentDefaultSystemLocale = _appLocale.locale.languageCode.split('_')[0];
    setState(() {
      selectedLangIndex = _getLangIndex(currentDefaultSystemLocale);
    });
  }

  int _getLangIndex(String currentDefaultSystemLocale){
    int _langIndex = 0;
    switch(currentDefaultSystemLocale){
      case 'en': _langIndex = 0; break;
      case 'th': _langIndex = 1; break;
      case 'lo': _langIndex = 2; break;
    }
    return _langIndex;
  }


  // --------------------------------------------------

  // สร้างฟังก์ชันการ submitBranch
  void submitBranch() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      // print(_branchcode);

      // สร้างตัวแปรเก็บ IP Address
      var _wifiIP = await info.getWifiIP();
      // print(_wifiIP);

      // สร้างตัวแปรเก็บชื่อ Device
      AndroidDeviceInfo _androidInfo = await deviceInfo.androidInfo;
      // print(_androidInfo.model);

      sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setInt('userStep', 1);
      sharedPreferences.setString('branchCode', _branchcode);
      sharedPreferences.setString('branchName', _branch_name);
      sharedPreferences.setString('ipAddress', _wifiIP.toString());
      sharedPreferences.setString('modelAndroid', _androidInfo.model.toString());

      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  // สร้าง Method อ่านเวอร์ชั่นและ build number ของแอพ
  String? app_version, app_build_number;

  void getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    // print(packageInfo.packageName);
    // print(packageInfo.version);
    // print(packageInfo.buildNumber);
    setState(() {
      app_version = packageInfo.version;
      app_build_number = packageInfo.buildNumber;
    });

    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('version', app_version!);
    sharedPreferences.setString('buildNumber', app_build_number!);

  }

  // สร้างฟังก์ชันเช็คอัพเดทแอพ
  late OtaEvent currentEvent; 
  
  Future<void> checkUpdateApp() async {
    if(int.parse(app_build_number!) > 1){
      try {
        OtaUpdate()
          .execute('https://itgenius.co.th/sandbox_api/apk/samit/p1labelv103.apk',
          destinationFilename: 'p1labelv103.apk',
        )
        .listen(
          (OtaEvent event) {
            setState(() => currentEvent = event);
          },
        );
      } catch (e) {
        print('Failed to make OTA update. Details: $e');
      }
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 2),
        backgroundColor: dartGreenColor,
        content: Text(
          'แอพของคุณเป็นเวอร์ชั่นล่าสุดแล้ว',
          textAlign: TextAlign.center,
        )));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
          child: Image.asset('assets/images/appicon/barcode100light.png'),
        ),
        titleSpacing: 0,
        title: Text(AppLocalizations.of(context)!.app_title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top:16.0),
            child: Text(AppLocalizations.of(context)!.changelang),
          ),
          SizedBox(width: 8,),
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: DropdownButton<AppLanguage>(
              dropdownColor: primaryColor,
              iconEnabledColor: white_color,
              underline: Container(
                height: 0,
                color: yellowColor,
              ),
              value: dropdownValue,
              items: AppLanguage.languages()
                    .map<DropdownMenuItem<AppLanguage>>(
                        (e) => DropdownMenuItem<AppLanguage>(
                            value: e,
                            child: Text(
                              e.name,
                              style: TextStyle(color: white_color),
                            )),
                      ).toList(),
              onChanged: (AppLanguage? language){
                dropdownValue = language!;
                _appLocale.changeLocale(Locale(language.languageCode));
                _setFlag();
                setLocale(language.languageCode);
              },
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
                child: Column(
              children: [
                headerWidget(context),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)!.textlabel_branchcode),
                            SizedBox(
                              height: 5,
                            ),
                            inputFieldWidget(
                                context,
                                const Icon(Icons.store_outlined),
                                "branchcode",
                                AppLocalizations.of(context)!.error_branchtext, (onValidateVal) {
                              if (onValidateVal.isEmpty) {
                                return AppLocalizations.of(context)!.error_emptybranch;
                              }else if(onValidateVal.length < 5){
                                return AppLocalizations.of(context)!.error_branchtextlength;
                              }
                              return null;
                            }, (onSavedVal) {
                              _branchcode = onSavedVal;
                            },
                            (onFieldSubmittedVal) {
                              submitBranch();
                            },
                            keyboardType: TextInputType.number,
                            autofocus: false,
                            maxlenght: 5,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            submitButton(AppLocalizations.of(context)!.button_branch_submit, () {
                              submitBranch();
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
                  child: Container(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                             'v.' + (app_version ?? "...") + '+' +(app_build_number ?? "..."),
                            style: TextStyle(fontSize: 14.0),
                          ),
                          SizedBox(
                            height: 30,
                            child: OutlinedButton.icon(
                              onPressed: checkUpdateApp,
                              icon: Icon(
                                Icons.history,
                                size: 18.0,
                              ),
                              label: Text(
                                AppLocalizations.of(context)!.checkupdate_button,
                                style: TextStyle(fontSize: 12.0),
                              ),
                            ),
                          ),
                        ],
                      )),
                )
              ],
            )),
          )
        ],
      ),
    );
  }
}
