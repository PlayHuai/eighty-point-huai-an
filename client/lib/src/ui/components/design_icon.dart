import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum DesignIconName {
  addFriend('ic_add_friend', true),
  autoplay('ic_autoplay'),
  autoplayActive('ic_autoplay_active'),
  back('ic_back'),
  cardBack('ic_card_back'),
  chat('ic_chat', true),
  close('ic_close', true),
  closeHand('ic_close_hand'),
  combo510k('ic_combo_510k'),
  comeback('ic_comeback'),
  countdown('ic_countdown'),
  createRoom('ic_create_room'),
  defeat('ic_defeat'),
  drawLighting('ic_draw_lighting'),
  host('ic_host'),
  invite('ic_invite', true),
  level('ic_level'),
  levelCard('ic_level_card'),
  locked('ic_locked'),
  login('ic_login', true),
  more('ic_more'),
  naturalLevel('ic_natural_level'),
  offline('ic_offline'),
  online('ic_online'),
  openHand('ic_open_hand'),
  passwordRoom('ic_paddword_room'),
  readFive('ic_read_five'),
  refresh('ic_refresh'),
  roomExpert('ic_room_expert'),
  roomNormal('ic_room_normal'),
  roomSupreme('ic_room_supreme'),
  search('ic_search', true),
  seat('ic_seat'),
  settings('ic_settings', true),
  skyEarth('ic_sky_earth'),
  spectator('ic_spectator'),
  spring('ic_spring'),
  suitClub('ic_suit_club'),
  suitDiamond('ic_suit_diamond'),
  suitHeart('ic_surt_heart'),
  suitSpade('ic_suit_spade'),
  swapHost('ic_swap_host'),
  trump('ic_trump'),
  trumpBadge('ic_trump_dadge'),
  victory('ic_victory'),
  waiting('ic_waiting'),
  watching('ic_watching');

  const DesignIconName(this.directory, [this.uses32xNaming = false]);

  final String directory;
  final bool uses32xNaming;
}

class DesignIcon extends StatelessWidget {
  const DesignIcon({
    required this.name,
    required this.enabled,
    this.size = 32,
    this.semanticLabel,
    super.key,
  });

  final DesignIconName name;
  final bool enabled;
  final double size;
  final String? semanticLabel;

  String get assetPath {
    final state = enabled ? 'enabled' : 'disabled';
    final filename = name.uses32xNaming ? '32x$state.svg' : 'state=$state.svg';
    return 'assets/icons/${name.directory}/$filename';
  }

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    assetPath,
    width: size,
    height: size,
    semanticsLabel: semanticLabel,
  );
}

class AppIcon extends StatelessWidget {
  const AppIcon({this.size = 64, super.key});

  static const assetPath = 'assets/app_icon.png';

  final double size;

  @override
  Widget build(BuildContext context) => Image.asset(
    assetPath,
    width: size,
    height: size,
    fit: BoxFit.contain,
  );
}
