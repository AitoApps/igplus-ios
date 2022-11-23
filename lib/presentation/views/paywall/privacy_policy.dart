import 'package:flutter/material.dart';
import 'package:igshark/presentation/resources/colors_manager.dart';
import 'package:igshark/presentation/resources/theme_manager.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({Key? key}) : super(key: key);

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
          title: const Text('Privacy Policy'),
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
                h1Title("Privacy Policy"),
                subTitle("Last updated: 2022-11-22"),
                const SizedBox(height: 20.0),
                h2Title("PRIVACY POLICY"),
                const SizedBox(height: 4.0),
                paragraphe(
                    "IGShark is a followers analytics application for Instagram account holders with the features of unfollow detection, blockers detection, detection of profile interactions and such. This privacy policy describes how IGShark collects and uses the information you provide. By using our Service you understand and agree that we are providing a analytics for Instagram. This means we use your content, preferences and personal information you make available through the Service, consistent with the terms and conditions of this privacy policy and our terms of use applies to all users, and others who access to our services. "),

                // --------
                const SizedBox(height: 14.0),
                h2Title("INFORMATION "),
                const SizedBox(height: 4.0),
                paragraphe(
                    "We may collect your location based data, personal information and share your information of the account, profile information, user content, preferences, product and content interests, communication and marketing preferences, usage activity, purchase history, content you viewed, the apps you visited, device information and operating system. We may ask advertisers or other partners to serve ads or services to your devices, which may use cookies or similar technologies placed by us or the third party."),
                paragraphe(
                    "We use third-party analytics tools to help us measure traffic and usage trends for the Service. These tools collect information sent by your device or our Service, including the web pages you visit, add-ons, and other information that assists us in improving the Service. "),
                paragraphe(
                    "Log file information is automatically reported by your browser each time you make a request to access a web page or app. It can also be provided when the content of the webpage or app is downloaded to your browser or device. We may also collect similar information from emails sent to our Users which then help us track which emails are opened and which links are clicked by recipients. The information allows for more accurate reporting and improvement of the Service. "),
                paragraphe(
                    "When you use a mobile device like a tablet or phone to access our Service, we may access, collect monitor, store on your device, and/or remotely store one or more device identifiers. "),

                // --------
                const SizedBox(height: 14.0),
                h2Title("USE OF YOUR INFORMATION"),
                const SizedBox(height: 4.0),
                paragraphe(
                    "In addition to some of the specific uses of information we describe in this Privacy Policy, we may use information that we receive to help you efficiently access your information after you sign in, remember information so you will not have to re-enter it during your visit or the next time you visit the Service; provide personalized content and information to you and others, which could include online ads or other forms of marketing; develop and test new products and features; monitor metrics such as total number of visitors, traffic, and demographic patterns; diagnose or fix technology problems; automatically update the application on your device. IGShark or other Users may run contests, special offers or other events or activities on the Service."),

                // --------
                const SizedBox(height: 14.0),
                h2Title("SHARING OF YOUR INFORMATION"),
                const SizedBox(height: 4.0),
                paragraphe(
                    "We may share your information as well as information from tools like cookies, log files, and device identifiers and location data, with third-party organizations that help us provide the Service to you. Our Service Providers will be given access to your information as is reasonably necessary to provide the Service under reasonable confidentiality terms. We may share user content and your information with businesses that are legally part of the same group of companies that IGShark is part of, or that become part of that group. Affiliates may use this information to help provide, understand, and improve the Service and Affiliates' own services. "),
                paragraphe(
                    "We may share certain information such as cookie data with third-party advertising partners. This information would allow third-party ad networks to, among other things. "),
                paragraphe(
                    "We may remove parts of data that can identify you and share anonymised data with other parties. We may also combine your information with other information in a way that it is no longer associated with you and share that aggregated information. "),
                paragraphe(
                    "We may disclose your personal information required by law, such as to comply legal process. When we believe in good faith that disclosure is necessary to protect our rights, protect your safety or the safety of others, investigate fraud, or respond to a government request. If IGShark is involved in a merger, acquisition, or sale of all or a portion of its assets, you will be notified via email and/or a prominent notice on our Web site of any change in ownership or uses of your personal information, as well as any choices you may have regarding your personal information, to any other third party with your prior consent to do so; tracking and ads. "),
                paragraphe(
                    "We reserve the right to partner with a third party ad network to either display advertising on our App or to manage our advertising on other sites. Our ad network partner would use technologies to collect non-personally identifiable information about your activities on this and other Apps to provide you targeted advertising based upon your interests If we sell or otherwise transfer part or the whole of IGShark, or our assets to another organization, your information such as name and email address, User Content and any other information collected through the Service may be among the items sold or transferred. You will continue to own your User Content The buyer or transferee will have to honor the commitments we have made in this Privacy Policy. "),
                paragraphe(
                    "We may access, preserve and share your information in response to a legal request if we have a good faith belief that the law requires us to do so. This may include responding to legal requests from jurisdictions outside of the China where we have a good faith belief that the response is required by law in that jurisdiction, affects users in that jurisdiction, and is consistent with internationally recognized standards. We may also access, preserve and share information when we have a good faith belief it is necessary to detect, prevent and address fraud and other illegal activity; to protect ourselves, you and others, including as part of investigations; and to prevent death or imminent bodily harm. Information we receive about you may be accessed, processed and retained for an extended period of time when it is the subject of a legal request or obligation, governmental investigation, or investigations concerning possible violations of our terms or policies, or otherwise to prevent harm. "),
                // --------
                const SizedBox(height: 14.0),
                h2Title("HOW WE STORE YOUR INFORMATION"),
                const SizedBox(height: 4.0),
                paragraphe(
                    "Your information collected through the Service may be stored and processed in the China or any other country in which IGShark, its Affiliates or Service Providers maintain facilities. IGShark, its Affiliates, or Service Providers may transfer information that we collect about you, including personal information across borders and from your country or jurisdiction to other countries or jurisdictions around the world. "),
                paragraphe(
                    "By registering for and using the Service you consent to the transfer of information to any other country in which IGShark, its Affiliates or Service Providers maintain facilities and the use and disclosure of information about you as described in this Privacy Policy. "),
                paragraphe(
                    "We use commercially reasonable safeguards to help keep the information collected through the Service secure and take reasonable steps to verify your identity before granting you access to your account .However, IGShark cannot ensure the security of any information you transmit to IGShark or guarantee that information on the Service may not be accessed, disclosed, altered, or destroyed."),
                paragraphe(
                    "Please do your part to help us. You are responsible for maintaining the secrecy of your unique password and account information, and for controlling access to emails between you and IGShark at all times. Your privacy settings may also be affected by changes the social media services you connect to IGShark make to their services. We are not responsible for the functionality, privacy, or security measures of any other organization. "),
                // --------
                const SizedBox(height: 14.0),
                h2Title("YOUR CHOICES ABOUT YOUR INFORMATION"),
                const SizedBox(height: 4.0),
                paragraphe(
                    "Update your account at any time by logging in and changing your profile settings. Unsubscribe from email communications from us by clicking on the unsubscribe line provided in such communications. As noted above, you may not opt out of Service-related communications (e.g., account verification, purchase and billing confirmations and reminders, changes/updates to features of the Service, technical and security notices). "),
                paragraphe(
                    "Following termination or deactivation of your account IGShark, its Affiliates, or its Service Providers may retain information (including your profile information) and User Content for a commercially reasonable time for backup, archival, and/or audit purposes. "),
                // --------
                const SizedBox(height: 14.0),
                h2Title("OTHER WEB SITES AND SERVICES"),
                const SizedBox(height: 4.0),
                paragraphe(
                    "We are not responsible for the practices employed by any websites or services linked to or from our Service, including the information or content contained within them. We are not responsible and do not have control over any third-parties that you authorize to access your User Content. "),
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
        color: ColorsManager.textColor,
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
