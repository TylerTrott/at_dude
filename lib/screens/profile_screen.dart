import 'package:at_dude/models/profile_model.dart';
import 'package:at_dude/widgets/widgets.dart';
import 'package:flutter/material.dart';

import '../services/services.dart';

class ProfileScreen extends StatefulWidget {
  static const String routeName = 'profile';
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileModel profileModel = ProfileModel.newDude();
  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      profileModel = await DudeService.getInstance().getProfile();
      // profileName ??= DudeService.getInstance().atClient!.getCurrentAtSign();
      setState(() {});
    });
    super.initState();
  }

  // final ProfileModel profileModel;
  @override
  Widget build(BuildContext context) {
    final String profileName =
        ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: const Icon(Icons.campaign_outlined),
        title: Text(profileName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Hello Dude',
                    style: Theme.of(context).textTheme.headline1,
                  ),
                  const Text('Your Stats'),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ProfileStat(stat: '${profileModel.dudesSent} Dudes sent'),
                  ProfileStat(
                      stat:
                          '${profileModel.dudeHours.inMinutes} Minutes duding'),
                  ProfileStat(
                      stat:
                          '${profileModel.longestDude.inMinutes} Minute longest dude'),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
