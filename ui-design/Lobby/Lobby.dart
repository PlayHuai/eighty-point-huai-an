class Lobby extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 1440,
          height: 900,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFF0A0E13) /* darkTokens-color-bgBase */,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 88,
                padding: const EdgeInsets.symmetric(horizontal: 32),
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: const Color(0xFF131A23) /* darkTokens-color-bgPanel */,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 0.50,
                      color: const Color(0x40C9A24B),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 12,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                              color: const Color(0x10C9A24B),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '80',
                                  style: TextStyle(
                                    color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                    fontSize: 26,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 3,
                              children: [
                                Text(
                                  '淮安80分',
                                  style: TextStyle(
                                    color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                    fontSize: 20,
                                    fontFamily: 'Noto Serif SC',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'HUAIAN · 80 POINTS',
                                  style: TextStyle(
                                    color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                    fontSize: 9,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 24,
                        children: [
                          Text(
                            '晚上好，淮安玩家',
                            style: TextStyle(
                              color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 1.43,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                          ),
                          Container(
                            width: 20,
                            height: 20,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(),
                                  child: Stack(),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: 10,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: const Color(0x10C9A24B),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        '淮',
                                        style: TextStyle(
                                          color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                          fontSize: 16,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '淮安玩家',
                                  style: TextStyle(
                                    color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                    height: 1.43,
                                  ),
                                ),
                                Container(
                                  width: 14,
                                  height: 14,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(),
                                  child: Stack(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 208,
                        height: double.infinity,
                        padding: const EdgeInsets.only(
                          top: 32,
                          left: 20,
                          right: 20,
                          bottom: 24,
                        ),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: const Color(0xFF131A23) /* darkTokens-color-bgPanel */,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 12,
                          children: [
                            Text(
                              '我的大厅',
                              style: TextStyle(
                                color: const Color(0xFF84909E),
                                fontSize: 10,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: const Color(0x10C9A24B),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    color: const Color(0x40C9A24B),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 12,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(),
                                    child: Stack(),
                                  ),
                                  Text(
                                    '游戏大厅',
                                    style: TextStyle(
                                      color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      height: 1.43,
                                    ),
                                  ),
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                      shape: OvalBorder(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: const Color(0xFF131A23) /* darkTokens-color-bgPanel */,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    color: const Color(0xFF131A23) /* darkTokens-color-bgPanel */,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 12,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(),
                                    child: Stack(),
                                  ),
                                  Text(
                                    '我的房间',
                                    style: TextStyle(
                                      color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      height: 1.43,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: const Color(0xFF131A23) /* darkTokens-color-bgPanel */,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    color: const Color(0xFF131A23) /* darkTokens-color-bgPanel */,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 12,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(),
                                    child: Stack(),
                                  ),
                                  Text(
                                    '好友',
                                    style: TextStyle(
                                      color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      height: 1.43,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: const Color(0xFF131A23) /* darkTokens-color-bgPanel */,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    color: const Color(0xFF131A23) /* darkTokens-color-bgPanel */,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 12,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(),
                                    child: Stack(),
                                  ),
                                  Text(
                                    '战绩',
                                    style: TextStyle(
                                      color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      height: 1.43,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 12,
                                children: [
                                  Opacity(
                                    opacity: 0.50,
                                    child: Text(
                                      '♠ ♥ ♣ ♦',
                                      style: TextStyle(
                                        color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                        fontSize: 23,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '一局好牌，一席老友。',
                                    style: TextStyle(
                                      color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                      fontSize: 15,
                                      fontFamily: 'Noto Serif SC',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    '淮安80分  /  v1.0.0',
                                    style: TextStyle(
                                      color: const Color(0xFF84909E),
                                      fontSize: 10,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 12,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(),
                                    child: Stack(),
                                  ),
                                  Text(
                                    '设置与帮助',
                                    style: TextStyle(
                                      color: const Color(0xFF84909E),
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      height: 1.43,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(
                            top: 32,
                            left: 36,
                            right: 36,
                            bottom: 28,
                          ),
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 24,
                            children: [
                              Container(
                                width: double.infinity,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        spacing: 8,
                                        children: [
                                          Text(
                                            '游戏大厅',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 40,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w700,
                                              height: 1.20,
                                              letterSpacing: -0.40,
                                            ),
                                          ),
                                          Text(
                                            '选择牌局，呼朋唤友，开局出发。',
                                            style: TextStyle(
                                              color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                              height: 1.43,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        spacing: 12,
                                        children: [
                                          Container(
                                            height: 44,
                                            padding: const EdgeInsets.symmetric(horizontal: 18),
                                            clipBehavior: Clip.antiAlias,
                                            decoration: ShapeDecoration(
                                              color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 1,
                                                  color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                                ),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              spacing: 7,
                                              children: [
                                                Container(
                                                  width: 18,
                                                  height: 18,
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: BoxDecoration(),
                                                  child: Stack(),
                                                ),
                                                Text(
                                                  '创建房间',
                                                  style: TextStyle(
                                                    color: const Color(0xFF14181E),
                                                    fontSize: 14,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w500,
                                                    height: 1.43,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 32,
                                  children: [
                                    Container(
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        spacing: 11,
                                        children: [
                                          Text(
                                            '经典大厅',
                                            style: TextStyle(
                                              color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w500,
                                              height: 1.43,
                                            ),
                                          ),
                                          Container(
                                            width: 32,
                                            height: 2,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '好友房',
                                      style: TextStyle(
                                        color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                        fontSize: 14,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        height: 1.43,
                                      ),
                                    ),
                                    Text(
                                      '休闲大厅',
                                      style: TextStyle(
                                        color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                        fontSize: 14,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        height: 1.43,
                                      ),
                                    ),
                                    Text(
                                      '至尊大厅',
                                      style: TextStyle(
                                        color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                        fontSize: 14,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        height: 1.43,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 822,
                                      child: Text(
                                        '按人气排序 ↓',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          color: const Color(0xFF84909E),
                                          fontSize: 12,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                          height: 1.33,
                                          letterSpacing: 0.20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(),
                                child: Wrap(
                                  alignment: WrapAlignment.start,
                                  runAlignment: WrapAlignment.start,
                                  spacing: 16,
                                  runSpacing: 16,
                                  children: [
                                    Container(
                                      width: 356,
                                      padding: const EdgeInsets.all(20),
                                      clipBehavior: Clip.antiAlias,
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            width: 0.50,
                                            color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        spacing: 16,
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: ShapeDecoration(
                                                    color: const Color(0x10C9A24B),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    spacing: 5,
                                                    children: [
                                                      Container(
                                                        width: 13,
                                                        height: 13,
                                                        clipBehavior: Clip.antiAlias,
                                                        decoration: BoxDecoration(),
                                                        child: Stack(),
                                                      ),
                                                      Text(
                                                        '经典大厅',
                                                        style: TextStyle(
                                                          color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                                          fontSize: 11,
                                                          fontFamily: 'Inter',
                                                          fontWeight: FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: BoxDecoration(),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    spacing: 5,
                                                    children: [
                                                      Container(
                                                        width: 6,
                                                        height: 6,
                                                        decoration: ShapeDecoration(
                                                          color: const Color(0xFF65B88A),
                                                          shape: OvalBorder(),
                                                        ),
                                                      ),
                                                      Text(
                                                        '4/4',
                                                        style: TextStyle(
                                                          color: const Color(0xFF65B88A),
                                                          fontSize: 11,
                                                          fontFamily: 'Inter',
                                                          fontWeight: FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              spacing: 6,
                                              children: [
                                                Text(
                                                  '8001',
                                                  style: TextStyle(
                                                    color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                                    fontSize: 28,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Text(
                                                  '经典80分 · 主花色♠ · 2级',
                                                  style: TextStyle(
                                                    color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                                    fontSize: 14,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.43,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              spacing: 8,
                                              children: [
                                                Container(
                                                  width: 44,
                                                  height: 44,
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: ShapeDecoration(
                                                    color: const Color(0x10C9A24B),
                                                    shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                                                        width: 1,
                                                        color: const Color(0x40C9A24B),
                                                      ),
                                                      borderRadius: BorderRadius.circular(22),
                                                    ),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        '清',
                                                        style: TextStyle(
                                                          color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                                          fontSize: 13,
                                                          fontFamily: 'Inter',
                                                          fontWeight: FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  width: 44,
                                                  height: 44,
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: ShapeDecoration(
                                                    color: const Color(0x10C9A24B),
                                                    shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                                                        width: 1,
                                                        color: const Color(0x40C9A24B),
                                                      ),
                                                      borderRadius: BorderRadius.circular(22),
                                                    ),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        '淮',
                                                        style: TextStyle(
                                                          color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                                          fontSize: 13,
                                                          fontFamily: 'Inter',
                                                          fontWeight: FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  width: 44,
                                                  height: 44,
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: ShapeDecoration(
                                                    color: const Color(0x10C9A24B),
                                                    shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                                                        width: 1,
                                                        color: const Color(0x40C9A24B),
                                                      ),
                                                      borderRadius: BorderRadius.circular(22),
                                                    ),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        '运',
                                                        style: TextStyle(
                                                          color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                                          fontSize: 13,
                                                          fontFamily: 'Inter',
                                                          fontWeight: FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  width: 44,
                                                  height: 44,
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: ShapeDecoration(
                                                    color: const Color(0x10C9A24B),
                                                    shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                                                        width: 1,
                                                        color: const Color(0x40C9A24B),
                                                      ),
                                                      borderRadius: BorderRadius.circular(22),
                                                    ),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        '牌',
                                                        style: TextStyle(
                                                          color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                                          fontSize: 13,
                                                          fontFamily: 'Inter',
                                                          fontWeight: FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '已进行 12 分钟',
                                                  style: TextStyle(
                                                    color: const Color(0xFF84909E),
                                                    fontSize: 12,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.33,
                                                    letterSpacing: 0.20,
                                                  ),
                                                ),
                                                Container(
                                                  height: 30,
                                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: ShapeDecoration(
                                                    color: const Color(0x10C9A24B),
                                                    shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                                                        width: 1,
                                                        color: const Color(0x40C9A24B),
                                                      ),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    spacing: 6,
                                                    children: [
                                                      Text(
                                                        '旁观',
                                                        style: TextStyle(
                                                          color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                                          fontSize: 12,
                                                          fontFamily: 'Inter',
                                                          fontWeight: FontWeight.w500,
                                                          height: 1.33,
                                                          letterSpacing: 0.20,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 356,
                                      padding: const EdgeInsets.all(20),
                                      clipBehavior: Clip.antiAlias,
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            width: 0.50,
                                            color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        spacing: 16,
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: ShapeDecoration(
                                                    color: const Color(0x10C9A24B),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    spacing: 5,
                                                    children: [
                                                      Container(
                                                        width: 13,
                                                        height: 13,
                                                        clipBehavior: Clip.antiAlias,
                                                        decoration: BoxDecoration(),
                                                        child: Stack(),
                                                      ),
                                                      Text(
                                                        '经典大厅',
                                                        style: TextStyle(
                                                          color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                                          fontSize: 11,
                                                          fontFamily: 'Inter',
                                                          fontWeight: FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: BoxDecoration(),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    spacing: 5,
                                                    children: [
                                                      Container(
                                                        width: 6,
                                                        height: 6,
                                                        decoration: ShapeDecoration(
                                                          color: const Color(0xFF65B88A),
                                                          shape: OvalBorder(),
                                                        ),
                                                      ),
                                                      Text(
                                                        '3/4',
                                                        style: TextStyle(
                                                          color: const Color(0xFF65B88A),
                                                          fontSize: 11,
                                                          fontFamily: 'Inter',
                                                          fontWeight: FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              spacing: 6,
                                              children: [
                                                Text(
                                                  '8006',
                                                  style: TextStyle(
                                                    color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                                    fontSize: 28,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Text(
                                                  '经典80分 · 主花色♥ · 3级',
                                                  style: TextStyle(
                                                    color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                                    fontSize: 14,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.43,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              spacing: 8,
                                              children: [
                                                Container(
                                                  width: 44,
                                                  height: 44,
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: ShapeDecoration(
                                                    color: const Color(0x10C9A24B),
                                                    shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                                                        width: 1,
                                                        color: const Color(0x40C9A24B),
                                                      ),
                                                      borderRadius: BorderRadius.circular(22),
                                                    ),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        '月',
                                                        style: TextStyle(
                                                          color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                                          fontSize: 13,
                                                          fontFamily: 'Inter',
                                                          fontWeight: FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  width: 44,
                                                  height: 44,
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: ShapeDecoration(
                                                    color: const Color(0x10C9A24B),
                                                    shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                                                        width: 1,
                                                        color: const Color(0x40C9A24B),
                                                      ),
                                                      borderRadius: BorderRadius.circular(22),
                                                    ),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        '一',
                                                        style: TextStyle(
                                                          color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                                          fontSize: 13,
                                                          fontFamily: 'Inter',
                                                          fontWeight: FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  width: 44,
                                                  height: 44,
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: ShapeDecoration(
                                                    color: const Color(0x10C9A24B),
                                                    shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                                                        width: 1,
                                                        color: const Color(0x40C9A24B),
                                                      ),
                                                      borderRadius: BorderRadius.circular(22),
                                                    ),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        '牌',
                                                        style: TextStyle(
                                                          color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                                          fontSize: 13,
                                                          fontFamily: 'Inter',
                                                          fontWeight: FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  width: 44,
                                                  height: 44,
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: ShapeDecoration(
                                                    color: const Color(0xFF131A23) /* darkTokens-color-bgPanel */,
                                                    shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                                                        width: 1,
                                                        color: Colors.white.withValues(alpha: 0.05),
                                                      ),
                                                      borderRadius: BorderRadius.circular(22),
                                                    ),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        '空',
                                                        style: TextStyle(
                                                          color: const Color(0xFF84909E),
                                                          fontSize: 13,
                                                          fontFamily: 'Inter',
                                                          fontWeight: FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '等待第 4 位玩家',
                                                  style: TextStyle(
                                                    color: const Color(0xFF84909E),
                                                    fontSize: 12,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.33,
                                                    letterSpacing: 0.20,
                                                  ),
                                                ),
                                                Container(
                                                  height: 30,
                                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: ShapeDecoration(
                                                    color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    spacing: 6,
                                                    children: [
                                                      Text(
                                                        '加入',
                                                        style: TextStyle(
                                                          color: const Color(0xFF14181E),
                                                          fontSize: 12,
                                                          fontFamily: 'Inter',
                                                          fontWeight: FontWeight.w500,
                                                          height: 1.33,
                                                          letterSpacing: 0.20,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 356,
                                      padding: const EdgeInsets.all(20),
                                      clipBehavior: Clip.antiAlias,
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            width: 0.50,
                                            color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        spacing: 16,
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: ShapeDecoration(
                                                    color: const Color(0x10C9A24B),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    spacing: 5,
                                                    children: [
                                                      Container(
                                                        width: 13,
                                                        height: 13,
                                                        clipBehavior: Clip.antiAlias,
                                                        decoration: BoxDecoration(),
                                                        child: Stack(),
                                                      ),
                                                      Text(
                                                        '经典大厅',
                                                        style: TextStyle(
                                                          color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                                          fontSize: 11,
                                                          fontFamily: 'Inter',
                                                          fontWeight: FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: BoxDecoration(),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    spacing: 5,
                                                    children: [
                                                      Container(
                                                        width: 6,
                                                        height: 6,
                                                        decoration: ShapeDecoration(
                                                          color: const Color(0xFF74808E),
                                                          shape: OvalBorder(),
                                                        ),
                                                      ),
                                                      Text(
                                                        '2/4',
                                                        style: TextStyle(
                                                          color: const Color(0xFF74808E),
                                                          fontSize: 11,
                                                          fontFamily: 'Inter',
                                                          fontWeight: FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              spacing: 6,
                                              children: [
                                                Text(
                                                  '8012',
                                                  style: TextStyle(
                                                    color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                                    fontSize: 28,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Text(
                                                  '经典80分 · 好友房 · 2级',
                                                  style: TextStyle(
                                                    color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                                    fontSize: 14,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.43,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              spacing: 8,
                                              children: [
                                                Container(
                                                  width: 44,
                                                  height: 44,
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: ShapeDecoration(
                                                    color: const Color(0x10C9A24B),
                                                    shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                                                        width: 1,
                                                        color: const Color(0x40C9A24B),
                                                      ),
                                                      borderRadius: BorderRadius.circular(22),
                                                    ),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        '淮',
                                                        style: TextStyle(
                                                          color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                                          fontSize: 13,
                                                          fontFamily: 'Inter',
                                                          fontWeight: FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  width: 44,
                                                  height: 44,
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: ShapeDecoration(
                                                    color: const Color(0x10C9A24B),
                                                    shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                                                        width: 1,
                                                        color: const Color(0x40C9A24B),
                                                      ),
                                                      borderRadius: BorderRadius.circular(22),
                                                    ),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        '清',
                                                        style: TextStyle(
                                                          color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                                          fontSize: 13,
                                                          fontFamily: 'Inter',
                                                          fontWeight: FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  width: 44,
                                                  height: 44,
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: ShapeDecoration(
                                                    color: const Color(0xFF131A23) /* darkTokens-color-bgPanel */,
                                                    shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                                                        width: 1,
                                                        color: Colors.white.withValues(alpha: 0.05),
                                                      ),
                                                      borderRadius: BorderRadius.circular(22),
                                                    ),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        '空',
                                                        style: TextStyle(
                                                          color: const Color(0xFF84909E),
                                                          fontSize: 13,
                                                          fontFamily: 'Inter',
                                                          fontWeight: FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  width: 44,
                                                  height: 44,
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: ShapeDecoration(
                                                    color: const Color(0xFF131A23) /* darkTokens-color-bgPanel */,
                                                    shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                                                        width: 1,
                                                        color: Colors.white.withValues(alpha: 0.05),
                                                      ),
                                                      borderRadius: BorderRadius.circular(22),
                                                    ),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        '空',
                                                        style: TextStyle(
                                                          color: const Color(0xFF84909E),
                                                          fontSize: 13,
                                                          fontFamily: 'Inter',
                                                          fontWeight: FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '还差 2 位即可开局',
                                                  style: TextStyle(
                                                    color: const Color(0xFF84909E),
                                                    fontSize: 12,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.33,
                                                    letterSpacing: 0.20,
                                                  ),
                                                ),
                                                Container(
                                                  height: 30,
                                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: ShapeDecoration(
                                                    color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    spacing: 6,
                                                    children: [
                                                      Text(
                                                        '加入',
                                                        style: TextStyle(
                                                          color: const Color(0xFF14181E),
                                                          fontSize: 12,
                                                          fontFamily: 'Inter',
                                                          fontWeight: FontWeight.w500,
                                                          height: 1.33,
                                                          letterSpacing: 0.20,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 356,
                                      padding: const EdgeInsets.all(20),
                                      clipBehavior: Clip.antiAlias,
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            width: 0.50,
                                            color: const Color(0x20C9A24B),
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        spacing: 16,
                                        children: [
                                          Container(
                                            width: 56,
                                            height: 56,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: ShapeDecoration(
                                              color: const Color(0x10C9A24B),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(14),
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: 24,
                                                  height: 24,
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: BoxDecoration(),
                                                  child: Stack(),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              spacing: 8,
                                              children: [
                                                Text(
                                                  '快速开一局',
                                                  style: TextStyle(
                                                    color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                                    fontSize: 16,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w500,
                                                    height: 1.50,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 316,
                                                  child: Text(
                                                    '创建属于你的好友房，邀请牌友入局，定制玩法。',
                                                    style: TextStyle(
                                                      color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                                      fontSize: 12,
                                                      fontFamily: 'Inter',
                                                      fontWeight: FontWeight.w400,
                                                      height: 1.33,
                                                      letterSpacing: 0.20,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            height: 40,
                                            padding: const EdgeInsets.symmetric(horizontal: 18),
                                            clipBehavior: Clip.antiAlias,
                                            decoration: ShapeDecoration(
                                              color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              spacing: 7,
                                              children: [
                                                Text(
                                                  '创建房间',
                                                  style: TextStyle(
                                                    color: const Color(0xFF14181E),
                                                    fontSize: 14,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w500,
                                                    height: 1.43,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.only(top: 8),
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '共 3 间房间 · 实时更新',
                                      style: TextStyle(
                                        color: const Color(0xFF84909E),
                                        fontSize: 12,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        height: 1.33,
                                        letterSpacing: 0.20,
                                      ),
                                    ),
                                    Container(
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 5,
                                        children: [
                                          Container(
                                            width: 13,
                                            height: 13,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(),
                                            child: Stack(),
                                          ),
                                          Text(
                                            '刷新',
                                            style: TextStyle(
                                              color: const Color(0xFF84909E),
                                              fontSize: 12,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                              height: 1.33,
                                              letterSpacing: 0.20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}