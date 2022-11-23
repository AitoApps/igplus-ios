import 'package:flutter/material.dart';
import 'package:igshark/presentation/resources/colors_manager.dart';
import 'package:igshark/presentation/resources/theme_manager.dart';

class TermsOfUse extends StatelessWidget {
  const TermsOfUse({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      theme: appMaterialTheme(),
      home: Scaffold(
        backgroundColor: ColorsManager.appBack,
        appBar: AppBar(
          backgroundColor: ColorsManager.appBack,
          title: const Text('Terms of Use'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                h1Title("Terms of Use"),
                subTitle("Last updated: 2022-11-22"),
                const SizedBox(height: 20.0),
                h2Title("TERMS OF USE"),
                const SizedBox(height: 4.0),
                paragraphe(
                    "By using the application IGShark, you agree to be bound by these terms of service. The Service is owned or controlled by AitoApps (\"IGShark\"). Please read all of the Terms of service, if you do not agree to be bound by all of these Terms of service, do not access or use the services. "),

                // --------
                const SizedBox(height: 14.0),
                h2Title("MAIN TERMS "),
                const SizedBox(height: 4.0),
                paragraphe(
                    "IGShark is a followers analytics application for Instagram account holders with the features of unfollow detection, blockers detection, detection of profile interactions and such. "),
                paragraphe(
                    "You are solely responsible for any activity that occurs through your account. You agree and undertake that you will use IGShark for Instagram accounts that are legally owned by you and you will not interfere with third party accounts. IGShark prohibits the creation of an account for anyone other than yourself. You also represent that all information you provide or provided to IGShark upon registration and at all other times will be true. "),
                paragraphe(
                    "You agree that you will not solicit, collect or use the login credentials of other IGShark & Instagram users. You are responsible for keeping your password secret and secure. You may not use the Service for any illegal or unauthorized purpose. You agree to comply with all laws, rules and regulations. You are solely responsible for your conduct and content."),
                paragraphe(
                    "You must not create accounts with the Service through unauthorized means, including but not limited to, by using an automated device, script, bot, spider, crawler or scraper. Violation of these Terms of service may, in IGShark's sole discretion, result in termination of your account. You understand and agree that IGShark cannot and will not be responsible for your actions you use the Service at your own risk. If you violate the letter or spirit of these Terms of service, or otherwise create risk or possible legal exposure for IGShark, we can stop providing all or part of the Service to you. "),
                // --------
                const SizedBox(height: 14.0),
                h2Title("CONDITIONS OF USE"),
                const SizedBox(height: 4.0),
                paragraphe(
                    "We reserve the right, in our sole discretion, to change these Terms of service from time to time. We reserve the right to refuse access to the Service to anyone for any reason at any time. We reserve the right to force forfeiture of any username for any reason. We may, but have no obligation to, remove, edit, block, and/or monitor Content or accounts containing Content that we determine in our sole discretion violates these Terms of Use. "),
                paragraphe(
                    "We reserve the right to modify or terminate the Service or your access to the Service for any reason, without notice, at any time, and without liability to you. You can deactivate your IGShark account by logging into the Service and completing the form. If we terminate your access to the Service or you use the form detailed above to deactivate your account, your statistics, information and other data will no longer be accessible through your account. "),
                paragraphe(
                    "There may be links from the Service, or from communications you receive from the Service, to third- party web sites or features. There may also be links to third- party web sites or features in images or comments within the Service. The Service may also includes third-party content that we do not control, maintain or endorse. Functionality on the Service may also permit interactions between the Service and a third-party web site or feature, including applications that connect the Service or your profile on the Service with a third-party web site or feature. IGShark does not control any of these third-party web services or any of their content. You expressly acknowledge and agree that IGShark is in no way responsible or liable for any such third-party services or features. "),
                paragraphe(
                    "Your correspondence and business dealings with third parties found through the service are solely between you and the third party. You may choose, at your sole and absolute discretion and risk, to use applications that connect the Service or your profile on the Service with a third-party service (each, an \"Application\") and such Application may interact with, connect to or gather and/or pull information from and to your Service profile. "),
                paragraphe(
                    "You agree that you are responsible for all data charges you incur through use of the Service. We prohibit crawling, scraping, caching or otherwise accessing any content on the Service via automated means, including but not limited to, user profiles and photos. "),

                // --------
                const SizedBox(height: 14.0),
                h2Title("RIGHTS "),
                const SizedBox(height: 4.0),
                paragraphe(
                    "The IGShark name and logo are trademarks of AitoApps, and may not be copied, imitated or used, in whole or in part, without the prior written permission of AitoApps. In addition, all page headers, custom graphics, button icons and scripts may not be copied, imitated or used, in whole or in part, without prior written permission from AitoApps. The Service contains content owned or licensed by IGShark. IGShark content is protected by copyright, trademark, patent, trade secret and other laws, and, as between you and IGShark, AitoApps owns and retains all rights in the IGShark Content and the Service. You will not remove, alter or conceal any copyright, trademark, service mark or other proprietary rights notices incorporated in or accompanying the IGShark Content and you will not reproduce, modify, adapt, prepare derivative works based on, perform, display, publish, distribute, transmit, broadcast, sell, license or otherwise exploit the content. "),
                paragraphe(
                    "Although it is IGShark intention for the Service to be available as much as possible, there will be occasions when the Service may be interrupted, including, without limitation, for scheduled maintenance or upgrades, for emergency repairs, or due to failure of telecommunications links and/or equipment. Also, IGShark reserves the right to remove any content from the Service for any reason, without prior notice. Content and istatistics removed from the Service may continue to be stored by IGShark. IGShark will not be liable to you for any modification, suspension, or discontinuation of the Services, or the loss of any Content. "),
                paragraphe(
                    "You hereby grant any and all kind of authorization to IGShark in order to keep the statistics through your Instagram account and devices. "),

                // --------
                const SizedBox(height: 14.0),
                h2Title("DISCLAIMER OF WARRANTIES"),
                const SizedBox(height: 4.0),
                paragraphe(
                    "IGShark do not represent or warrant that the service will be error-free or uninterrupted; that defects will be corrected; or that the service or the server that makes the service available is free from any harmful components, including, without limitation, viruses. IGShark parties do not make any representations or warranties that the information on the service is accurate, complete, or useful. You acknowledge that your use of the service is at your sole risk. "),
                paragraphe(
                    "By accessing or using the service you represent and warrant that your activities are lawful in every jurisdiction where you access or use the service. "),

                // --------
                const SizedBox(height: 14.0),
                h2Title("LIMITATION OF LIABILITY & WAIVER"),
                const SizedBox(height: 4.0),
                paragraphe(
                    "Under no circumstances will IGShark be liable to you for any loss or damages of any kind (including, without limitation, for any direct, indirect, economic, exemplary, special, punitive, incidental or consequential losses or damages) that are directly or indirectly related to use of IGShark. "),
                paragraphe(
                    "IGShark is not responsible for the actions, content, information, or data of third parties, and you release us, our directors, officers, employees, and agents from any claims and damages, known and unknown, arising out of or in any way connected with any claim you have against any such third parties. "),

                // --------
                const SizedBox(height: 14.0),
                h2Title("INDEMNIFICATION"),
                const SizedBox(height: 4.0),
                paragraphe(
                    "You agree to defend, indemnify and hold the IGShark harmless from and against any claims, liabilities, damages, losses, and expenses, including without limitation, reasonable attorneys fees and costs, arising out of or in any way connected with any of the following (including as a result of your direct activities on the Service or those conducted on your behalf): (i) your Content or your access to or use of the Service; (ii) your breach or alleged breach of these Terms of service; (iii) your violation of any third-party right, including without limitation, any intellectual property right, publicity, confidentiality, property or privacy right; (iv) your violation of any laws, rules, regulations, codes, statutes, ordinances or orders of any governmental and quasi-governmental authorities, including, without limitation, all regulatory, administrative and legislative authorities; or (v) any misrepresentation made by you. You will cooperate as fully required by IGShark in the defense of any claim. IGShark reserves the right to assume the exclusive defense and control of any matter subject to indemnification by you, and you will not in any event settle any claim without the prior written consent of IGShark. "),

                // --------

                h2Title("RESOLUTION OF DISPUTES, GOVERNING LAW & VENUE"),
                const SizedBox(height: 4.0),
                paragraphe(
                    "These Terms of service are governed by and construed in accordance with the Chinese Law, without giving effect to any principles of conflicts of law. Disputes with IGShark and arising from the use of IGShark shall resolute exclusively in the courts of Nanshan, Shenzhen, China. You agree that any claim you may have arising out of or related to your relationship with IGShark must be filed within 3 months after such claim arose; otherwise, your claim is permanently barred. "),

                const SizedBox(height: 14.0),
                h2Title("TERRITORIAL RESTRICTIONS"),
                const SizedBox(height: 4.0),
                paragraphe(
                    "We reserve the right to limit the availability of the Service or any portion of the Service, to any person, geographic area, or jurisdiction, at any time and in our sole discretion, and to limit the quantities of any content, program, product, service or other feature that IGShark provides. "),
                const SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget h1Title(text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: ColorsManager.primaryColor,
          fontSize: 24.0,
          fontFamily: 'Abel',
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget h2Title(text) {
    return Text(
      text,
      style: const TextStyle(
        color: ColorsManager.cardIconColor,
        fontSize: 20.0,
        fontFamily: 'Abel',
        fontStyle: FontStyle.normal,
      ),
      textAlign: TextAlign.left,
    );
  }

  subTitle(text) {
    return Text(
      text,
      style: const TextStyle(
        color: ColorsManager.secondarytextColor,
        fontSize: 12.0,
        fontFamily: 'OpenSans',
        fontStyle: FontStyle.normal,
        wordSpacing: 3.0,
        letterSpacing: 1.0,
        height: 1.5,
      ),
      textAlign: TextAlign.left,
    );
  }

  paragraphe(text) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Text(
        text,
        style: const TextStyle(
          color: ColorsManager.textColor,
          fontSize: 14.0,
          fontFamily: 'OpenSans',
        ),
        textAlign: TextAlign.left,
      ),
    );
  }
}
