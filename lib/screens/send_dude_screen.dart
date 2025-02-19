import 'package:at_app_flutter/at_app_flutter.dart';

import 'package:at_contacts_flutter/at_contacts_flutter.dart';
import 'package:at_dude/controller/dude_controller.dart';

import 'package:at_dude/models/dude_model.dart';
import 'package:at_dude/screens/screens.dart';
import 'package:at_dude/services/services.dart';
import 'package:at_dude/widgets/atsign_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

import '../widgets/widgets.dart';

class SendDudeScreen extends StatefulWidget {
  const SendDudeScreen({Key? key}) : super(key: key);
  static String routeName = 'sendDudeScreen';

  @override
  State<SendDudeScreen> createState() => _SendDudeScreenState();
}

class _SendDudeScreenState extends State<SendDudeScreen> {
  bool _buttonPressed = false;
  DudeModel dude = DudeModel.newDude();
  late DateTime startTime;
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    Provider.of<DudeController>(context).getDudes();
  }

  @override
  void dispose() async {
    super.dispose();
    await _stopWatchTimer.dispose();
  }

  void updateIsLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  Future<void> _handleSendDudeToContact({
    required DudeModel dude,
    required String contactAtsign,
    required BuildContext context,
  }) async {
    if (dude.dude.isEmpty) {
      SnackBars.notificationSnackBar(
          content: 'No duuude to send', context: context);
    } else {
      await DudeService.getInstance().putDude(dude, contactAtsign).then(
        (value) {
          if (value) {
            SnackBars.notificationSnackBar(
                content: 'Dude Successfully Sent', context: context);
          } else {
            SnackBars.errorSnackBar(
                content: 'Something went wrong, please try again',
                context: context);
          }
        },
      );
    }
  }

  int rawTime = 0;
  @override
  Widget build(BuildContext context) {
    initializeContactsService(rootDomain: AtEnv.rootDomain);
    SizeConfig().init(context);

    List<String> strArr = ['D', 'u', 'd', 'e'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Dude'),
        actions: const [AtsignAvatar()],
      ),
      bottomNavigationBar: const DudeBottomNavigationBar(
        selectedIndex: 0,
      ),
      body: Stack(children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DudeTimer(rawTime: rawTime),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        dude.dude,
                        style: Theme.of(context).textTheme.headline1,
                        textAlign: TextAlign.center,
                        maxLines: 4,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    child: ElevatedButton(
                      // style: ButtonStyle().copyWith(
                      //     minimumSize:
                      //         MaterialStateProperty.all<Size>(Size(width:, height:))),
                      // style:
                      //     ElevatedButton.styleFrom(padding: EdgeInsets.all(8.0)),
                      onPressed: () {
                        startTime = DateTime.now();
                        _stopWatchTimer.onExecute.add(StopWatchExecute.start);
                        dude.saveId;
                        setState(() {
                          rawTime = _stopWatchTimer.rawTime.value;
                          dude.saveDude(strArr.join("").toString());
                        });
                        _stopWatchTimer.onExecute.add(StopWatchExecute.stop);

                        dude.saveDuration(startTime);
                      },
                      child: const Text(
                        'Duuude',
                        style: TextStyle(color: Colors.white, fontSize: 25),
                      ),
                    ),
                    onLongPressStart: (_) async {
                      startTime = DateTime.now();
                      if (_stopWatchTimer.rawTime.value > 1) {
                        _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
                      }
                      _stopWatchTimer.onExecute.add(StopWatchExecute.start);

                      _buttonPressed = true;
                      do {
                        strArr.insert(1, "u");
                        setState(() {
                          rawTime = _stopWatchTimer.rawTime.value;
                          dude.saveDude(strArr.join("").toString());
                        });
                        await Future.delayed(const Duration(seconds: 1));
                      } while (_buttonPressed);
                    },
                    onLongPressEnd: (_) {
                      setState(() {
                        _buttonPressed = false;
                      });

                      _stopWatchTimer.onExecute.add(StopWatchExecute.stop);

                      dude.saveDuration(startTime);
                      dude.saveId();
                    },
                  ),
                  const SizedBox(
                    width: 25,
                  ),
                  RotatedBox(
                    quarterTurns: 1,
                    child: IconButton(
                      icon: const Icon(
                        Icons.navigation_outlined,
                        size: 40,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) => ContactsScreen(
                              onSendIconPressed: (String atsign) =>
                                  _handleSendDudeToContact(
                                      dude: dude,
                                      contactAtsign: atsign,
                                      context: context),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 180,
              child: FavoriteContacts(
                dude: dude,
                updateIsLoading: updateIsLoading,
              ),
            ),
          ],
        ),
        isLoading
            ? Container(
                color: Colors.transparent.withOpacity(0.2),
                width: double.infinity,
                height: double.infinity,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : const SizedBox()
      ]),
    );
  }
}
