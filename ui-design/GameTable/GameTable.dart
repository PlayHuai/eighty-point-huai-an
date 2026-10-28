class Gametable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 1404,
          height: 784,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFF0A0E13) /* darkTokens-color-bgBase */,
          ),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: 1620,
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 0.50,
                        color: const Color(0x45C9A24B),
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
                          spacing: 10,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(),
                              child: Stack(),
                            ),
                            Container(
                              width: 32,
                              height: 32,
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: const Color(0x12C9A24B),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                  ),
                                  borderRadius: BorderRadius.circular(9),
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
                                      fontSize: 21,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '淮安80分',
                              style: TextStyle(
                                color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                fontSize: 17,
                                fontFamily: 'Noto Serif SC',
                                fontWeight: FontWeight.w700,
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
                          spacing: 10,
                          children: [
                            Text(
                              '8012 · 好友房',
                              style: TextStyle(
                                color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                fontSize: 12,
                                fontFamily: 'Noto Sans SC',
                                fontWeight: FontWeight.w400,
                                height: 1.40,
                              ),
                            ),
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
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 40,
                top: 72,
                child: Container(
                  width: 280,
                  height: 84,
                  padding: const EdgeInsets.only(top: 8, left: 12, right: 12, bottom: 4),
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF131A23) /* darkTokens-color-bgPanel */,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: const Color(0x45C9A24B),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
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
                            Text(
                              '第 1 局 · 第 1 墩',
                              style: TextStyle(
                                color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                fontSize: 11,
                                fontFamily: 'Noto Sans SC',
                                fontWeight: FontWeight.w400,
                                height: 1.40,
                              ),
                            ),
                            Container(
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 6,
                                children: [
                                  Text(
                                    '主牌',
                                    style: TextStyle(
                                      color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                      fontSize: 11,
                                      fontFamily: 'Noto Sans SC',
                                      fontWeight: FontWeight.w400,
                                      height: 1.40,
                                    ),
                                  ),
                                  Text(
                                    '♠',
                                    style: TextStyle(
                                      color: const Color(0xFFE6C56A) /* darkTokens-color-goldBright */,
                                      fontSize: 18,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    '黑桃 · 级牌 2',
                                    style: TextStyle(
                                      color: const Color(0xFFE6C56A) /* darkTokens-color-goldBright */,
                                      fontSize: 12,
                                      fontFamily: 'Noto Sans SC',
                                      fontWeight: FontWeight.w400,
                                      height: 1.40,
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
                            Container(
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                spacing: 9,
                                children: [
                                  Text(
                                    '我方 · 庄',
                                    style: TextStyle(
                                      color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                      fontSize: 12,
                                      fontFamily: 'Noto Sans SC',
                                      fontWeight: FontWeight.w400,
                                      height: 1.40,
                                    ),
                                  ),
                                  Text(
                                    '0',
                                    style: TextStyle(
                                      color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                      fontSize: 24,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                      height: 1.33,
                                      letterSpacing: -0.20,
                                    ),
                                  ),
                                  Text(
                                    '分',
                                    style: TextStyle(
                                      color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                      fontSize: 11,
                                      fontFamily: 'Noto Sans SC',
                                      fontWeight: FontWeight.w400,
                                      height: 1.40,
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
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                spacing: 9,
                                children: [
                                  Text(
                                    '对方 · 闲',
                                    style: TextStyle(
                                      color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                      fontSize: 12,
                                      fontFamily: 'Noto Sans SC',
                                      fontWeight: FontWeight.w400,
                                      height: 1.40,
                                    ),
                                  ),
                                  Text(
                                    '0',
                                    style: TextStyle(
                                      color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                      fontSize: 24,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                      height: 1.33,
                                      letterSpacing: -0.20,
                                    ),
                                  ),
                                  Text(
                                    '/ 80',
                                    style: TextStyle(
                                      color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                      fontSize: 11,
                                      fontFamily: 'Noto Sans SC',
                                      fontWeight: FontWeight.w400,
                                      height: 1.40,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '庄家 淮安阿淮',
                        style: TextStyle(
                          color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                          fontSize: 10,
                          fontFamily: 'Noto Sans SC',
                          fontWeight: FontWeight.w400,
                          height: 1.40,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 40,
                top: 196,
                child: Container(
                  width: 280,
                  height: 55,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
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
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 7,
                                children: [
                                  Container(
                                    width: 27,
                                    height: 27,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          width: 2,
                                          color: const Color(0xFF497BA5) /* darkTokens-color-infoBlue */,
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          '60s',
                                          style: TextStyle(
                                            color: const Color(0xFF497BA5) /* darkTokens-color-infoBlue */,
                                            fontSize: 9,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '托管中',
                                    style: TextStyle(
                                      color: const Color(0xFF497BA5) /* darkTokens-color-infoBlue */,
                                      fontSize: 12,
                                      fontFamily: 'Noto Sans SC',
                                      fontWeight: FontWeight.w400,
                                      height: 1.40,
                                    ),
                                  ),
                                  Text(
                                    '· 可手动出牌',
                                    style: TextStyle(
                                      color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                      fontSize: 10,
                                      fontFamily: 'Noto Sans SC',
                                      fontWeight: FontWeight.w400,
                                      height: 1.40,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '取消托管',
                              style: TextStyle(
                                color: const Color(0xFF497BA5) /* darkTokens-color-infoBlue */,
                                fontSize: 11,
                                fontFamily: 'Noto Sans SC',
                                fontWeight: FontWeight.w400,
                                height: 1.40,
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
                                    width: 18,
                                    height: 18,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(),
                                    child: Stack(),
                                  ),
                                  Text(
                                    '聊天',
                                    style: TextStyle(
                                      color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                      fontSize: 11,
                                      fontFamily: 'Noto Sans SC',
                                      fontWeight: FontWeight.w400,
                                      height: 1.40,
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
                                spacing: 6,
                                children: [
                                  Text(
                                    '观战主视角',
                                    style: TextStyle(
                                      color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                      fontSize: 10,
                                      fontFamily: 'Noto Sans SC',
                                      fontWeight: FontWeight.w400,
                                      height: 1.40,
                                    ),
                                  ),
                                  Container(
                                    width: 26,
                                    height: 24,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: ShapeDecoration(
                                      color: const Color(0x12C9A24B),
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          width: 1,
                                          color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          '1',
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
                                    width: 26,
                                    height: 24,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFF131A23) /* darkTokens-color-bgPanel */,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          width: 1,
                                          color: const Color(0x45C9A24B),
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          '2',
                                          style: TextStyle(
                                            color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                            fontSize: 11,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 26,
                                    height: 24,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFF131A23) /* darkTokens-color-bgPanel */,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          width: 1,
                                          color: const Color(0x45C9A24B),
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          '3',
                                          style: TextStyle(
                                            color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                            fontSize: 11,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 26,
                                    height: 24,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFF131A23) /* darkTokens-color-bgPanel */,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          width: 1,
                                          color: const Color(0x45C9A24B),
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          '4',
                                          style: TextStyle(
                                            color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 40,
                top: 408,
                child: Container(
                  width: 1100,
                  height: 150,
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF131A23) /* darkTokens-color-bgPanel */,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: const Color(0x45C9A24B),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 8,
                        top: 0,
                        child: Container(
                          width: 1084,
                          height: 20,
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
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 8,
                                  children: [
                                    Text(
                                      '我的手牌',
                                      style: TextStyle(
                                        color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                        fontSize: 14,
                                        fontFamily: 'Noto Sans SC',
                                        fontWeight: FontWeight.w700,
                                        height: 1.40,
                                      ),
                                    ),
                                    Text(
                                      '25 张',
                                      style: TextStyle(
                                        color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                        fontSize: 12,
                                        fontFamily: 'Noto Sans SC',
                                        fontWeight: FontWeight.w400,
                                        height: 1.40,
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
                                      width: 16,
                                      height: 16,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(),
                                      child: Stack(),
                                    ),
                                    Text(
                                      '开牌 · 点击关牌',
                                      style: TextStyle(
                                        color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                        fontSize: 10,
                                        fontFamily: 'Noto Sans SC',
                                        fontWeight: FontWeight.w400,
                                        height: 1.40,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 8,
                        top: 22,
                        child: Container(
                          width: 1084,
                          height: 108,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(),
                          child: Stack(
                            children: [
                              Positioned(
                                left: 38,
                                top: 11.40,
                                child: Container(
                                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(-0.05),
                                  width: 62,
                                  height: 88,
                                  padding: const EdgeInsets.only(top: 4.23, left: 7.05),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFF4EFDF) /* darkTokens-color-cardFace */,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1.41,
                                        color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                      ),
                                      borderRadius: BorderRadius.circular(11.27),
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Text(
                                        '2',
                                        style: TextStyle(
                                          color: const Color(0xFF19212A),
                                          fontSize: 28.18,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          height: 1.10,
                                        ),
                                      ),
                                      Text(
                                        '♠',
                                        style: TextStyle(
                                          color: const Color(0xFF19212A),
                                          fontSize: 22.55,
                                          fontFamily: 'Noto Sans Symbols2',
                                          fontWeight: FontWeight.w400,
                                          height: 1.10,
                                        ),
                                      ),
                                      Positioned(
                                        left: 10.09,
                                        top: 68.09,
                                        child: Text(
                                          '级',
                                          style: TextStyle(
                                            color: const Color(0xFF8A6A2F) /* darkTokens-color-goldDark */,
                                            fontSize: 12.68,
                                            fontFamily: 'Noto Sans SC',
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 77.60,
                                top: 10.95,
                                child: Container(
                                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(-0.04),
                                  width: 62,
                                  height: 88,
                                  padding: const EdgeInsets.only(top: 4.23, left: 7.05),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFF4EFDF) /* darkTokens-color-cardFace */,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1.41,
                                        color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                      ),
                                      borderRadius: BorderRadius.circular(11.27),
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Text(
                                        '2',
                                        style: TextStyle(
                                          color: const Color(0xFFBF382A) /* darkTokens-color-suitRed */,
                                          fontSize: 28.18,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          height: 1.10,
                                        ),
                                      ),
                                      Text(
                                        '♥',
                                        style: TextStyle(
                                          color: const Color(0xFFBF382A) /* darkTokens-color-suitRed */,
                                          fontSize: 22.55,
                                          fontFamily: 'Noto Sans Symbols2',
                                          fontWeight: FontWeight.w400,
                                          height: 1.10,
                                        ),
                                      ),
                                      Positioned(
                                        left: 9.84,
                                        top: 67.94,
                                        child: Text(
                                          '级',
                                          style: TextStyle(
                                            color: const Color(0xFF8A6A2F) /* darkTokens-color-goldDark */,
                                            fontSize: 12.68,
                                            fontFamily: 'Noto Sans SC',
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 117.20,
                                top: 10.50,
                                child: Container(
                                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(-0.04),
                                  width: 62,
                                  height: 88,
                                  padding: const EdgeInsets.only(top: 4.23, left: 7.05),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFF4EFDF) /* darkTokens-color-cardFace */,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1.41,
                                        color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                      ),
                                      borderRadius: BorderRadius.circular(11.27),
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Text(
                                        '2',
                                        style: TextStyle(
                                          color: const Color(0xFF19212A),
                                          fontSize: 28.18,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          height: 1.10,
                                        ),
                                      ),
                                      Text(
                                        '♣',
                                        style: TextStyle(
                                          color: const Color(0xFF19212A),
                                          fontSize: 22.55,
                                          fontFamily: 'Noto Sans Symbols2',
                                          fontWeight: FontWeight.w400,
                                          height: 1.10,
                                        ),
                                      ),
                                      Positioned(
                                        left: 9.58,
                                        top: 67.79,
                                        child: Text(
                                          '级',
                                          style: TextStyle(
                                            color: const Color(0xFF8A6A2F) /* darkTokens-color-goldDark */,
                                            fontSize: 12.68,
                                            fontFamily: 'Noto Sans SC',
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 156.80,
                                top: 5.05,
                                child: Container(
                                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(-0.03),
                                  width: 62,
                                  height: 88,
                                  padding: const EdgeInsets.only(top: 4.23, left: 7.05),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFF4EFDF) /* darkTokens-color-cardFace */,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 2.82,
                                        color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                      ),
                                      borderRadius: BorderRadius.circular(11.27),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'A',
                                        style: TextStyle(
                                          color: const Color(0xFF19212A),
                                          fontSize: 28.18,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          height: 1.10,
                                        ),
                                      ),
                                      Text(
                                        '♠',
                                        style: TextStyle(
                                          color: const Color(0xFF19212A),
                                          fontSize: 22.55,
                                          fontFamily: 'Noto Sans Symbols2',
                                          fontWeight: FontWeight.w400,
                                          height: 1.10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 196.40,
                                top: 4.60,
                                child: Container(
                                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(-0.03),
                                  width: 62,
                                  height: 88,
                                  padding: const EdgeInsets.only(top: 4.23, left: 7.05),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFF4EFDF) /* darkTokens-color-cardFace */,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 2.82,
                                        color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                      ),
                                      borderRadius: BorderRadius.circular(11.27),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'A',
                                        style: TextStyle(
                                          color: const Color(0xFF19212A),
                                          fontSize: 28.18,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          height: 1.10,
                                        ),
                                      ),
                                      Text(
                                        '♠',
                                        style: TextStyle(
                                          color: const Color(0xFF19212A),
                                          fontSize: 22.55,
                                          fontFamily: 'Noto Sans Symbols2',
                                          fontWeight: FontWeight.w400,
                                          height: 1.10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 236,
                                top: 9.15,
                                child: Container(
                                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(-0.03),
                                  width: 62,
                                  height: 88,
                                  padding: const EdgeInsets.only(top: 4.23, left: 7.05),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFF4EFDF) /* darkTokens-color-cardFace */,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1.41,
                                        color: const Color(0xFFD5CEBD),
                                      ),
                                      borderRadius: BorderRadius.circular(11.27),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'K',
                                        style: TextStyle(
                                          color: const Color(0xFF19212A),
                                          fontSize: 28.18,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          height: 1.10,
                                        ),
                                      ),
                                      Text(
                                        '♠',
                                        style: TextStyle(
                                          color: const Color(0xFF19212A),
                                          fontSize: 22.55,
                                          fontFamily: 'Noto Sans Symbols2',
                                          fontWeight: FontWeight.w400,
                                          height: 1.10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 275.60,
                                top: 8.70,
                                child: Container(
                                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(-0.02),
                                  width: 62,
                                  height: 88,
                                  padding: const EdgeInsets.only(top: 4.23, left: 7.05),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFF4EFDF) /* darkTokens-color-cardFace */,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1.41,
                                        color: const Color(0xFFD5CEBD),
                                      ),
                                      borderRadius: BorderRadius.circular(11.27),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Q',
                                        style: TextStyle(
                                          color: const Color(0xFF19212A),
                                          fontSize: 28.18,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          height: 1.10,
                                        ),
                                      ),
                                      Text(
                                        '♠',
                                        style: TextStyle(
                                          color: const Color(0xFF19212A),
                                          fontSize: 22.55,
                                          fontFamily: 'Noto Sans Symbols2',
                                          fontWeight: FontWeight.w400,
                                          height: 1.10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 315.20,
                                top: 8.25,
                                child: Container(
                                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(-0.02),
                                  width: 62,
                                  height: 88,
                                  padding: const EdgeInsets.only(top: 4.23, left: 7.05),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFF4EFDF) /* darkTokens-color-cardFace */,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1.41,
                                        color: const Color(0xFFD5CEBD),
                                      ),
                                      borderRadius: BorderRadius.circular(11.27),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'J',
                                        style: TextStyle(
                                          color: const Color(0xFF19212A),
                                          fontSize: 28.18,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          height: 1.10,
                                        ),
                                      ),
                                      Text(
                                        '♠',
                                        style: TextStyle(
                                          color: const Color(0xFF19212A),
                                          fontSize: 22.55,
                                          fontFamily: 'Noto Sans Symbols2',
                                          fontWeight: FontWeight.w400,
                                          height: 1.10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 354.80,
                                top: 7.80,
                                child: Container(
                                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(-0.02),
                                  width: 62,
                                  height: 88,
                                  padding: const EdgeInsets.only(top: 4.23, left: 7.05),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFF4EFDF) /* darkTokens-color-cardFace */,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1.41,
                                        color: const Color(0xFFD5CEBD),
                                      ),
                                      borderRadius: BorderRadius.circular(11.27),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '10',
                                        style: TextStyle(
                                          color: const Color(0xFF19212A),
                                          fontSize: 28.18,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          height: 1.10,
                                        ),
                                      ),
                                      Text(
                                        '♠',
                                        style: TextStyle(
                                          color: const Color(0xFF19212A),
                                          fontSize: 22.55,
                                          fontFamily: 'Noto Sans Symbols2',
                                          fontWeight: FontWeight.w400,
                                          height: 1.10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 394.40,
                                top: 7.35,
                                child: Container(
                                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(-0.01),
                                  width: 62,
                                  height: 88,
                                  padding: const EdgeInsets.only(top: 4.23, left: 7.05),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFF4EFDF) /* darkTokens-color-cardFace */,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1.41,
                                        color: const Color(0xFFD5CEBD),
                                      ),
                                      borderRadius: BorderRadius.circular(11.27),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '9',
                                        style: TextStyle(
                                          color: const Color(0xFF19212A),
                                          fontSize: 28.18,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          height: 1.10,
                                        ),
                                      ),
                                      Text(
                                        '♠',
                                        style: TextStyle(
                                          color: const Color(0xFF19212A),
                                          fontSize: 22.55,
                                          fontFamily: 'Noto Sans Symbols2',
                                          fontWeight: FontWeight.w400,
                                          height: 1.10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 434,
                                top: 6.90,
                                child: Container(
                                  width: 62,
                                  height: 88,
                                  padding: const EdgeInsets.only(top: 4.23, left: 7.05),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFF4EFDF) /* darkTokens-color-cardFace */,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1.41,
                                        color: const Color(0xFFD5CEBD),
                                      ),
                                      borderRadius: BorderRadius.circular(11.27),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '8',
                                        style: TextStyle(
                                          color: const Color(0xFF19212A),
                                          fontSize: 28.18,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          height: 1.10,
                                        ),
                                      ),
                                      Text(
                                        '♠',
                                        style: TextStyle(
                                          color: const Color(0xFF19212A),
                                          fontSize: 22.55,
                                          fontFamily: 'Noto Sans Symbols2',
                                          fontWeight: FontWeight.w400,
                                          height: 1.10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 473.60,
                                top: 6.45,
                                child: Container(
                                  width: 62,
                                  height: 88,
                                  padding: const EdgeInsets.only(top: 4.23, left: 7.05),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFF4EFDF) /* darkTokens-color-cardFace */,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1.41,
                                        color: const Color(0xFFD5CEBD),
                                      ),
                                      borderRadius: BorderRadius.circular(11.27),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '7',
                                        style: TextStyle(
                                          color: const Color(0xFF19212A),
                                          fontSize: 28.18,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          height: 1.10,
                                        ),
                                      ),
                                      Text(
                                        '♠',
                                        style: TextStyle(
                                          color: const Color(0xFF19212A),
                                          fontSize: 22.55,
                                          fontFamily: 'Noto Sans Symbols2',
                                          fontWeight: FontWeight.w400,
                                          height: 1.10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 513.20,
                                top: 6,
                                child: Container(
                                  width: 62,
                                  height: 88,
                                  padding: const EdgeInsets.only(top: 4.23, left: 7.05),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFF4EFDF) /* darkTokens-color-cardFace */,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 2.82,
                                        color: const Color(0xFFE6C56A) /* darkTokens-color-goldBright */,
                                      ),
                                      borderRadius: BorderRadius.circular(11.27),
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Text(
                                        '5',
                                        style: TextStyle(
                                          color: const Color(0xFFBF382A) /* darkTokens-color-suitRed */,
                                          fontSize: 28.18,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          height: 1.10,
                                        ),
                                      ),
                                      Text(
                                        '♥',
                                        style: TextStyle(
                                          color: const Color(0xFFBF382A) /* darkTokens-color-suitRed */,
                                          fontSize: 22.55,
                                          fontFamily: 'Noto Sans Symbols2',
                                          fontWeight: FontWeight.w400,
                                          height: 1.10,
                                        ),
                                      ),
                                      Positioned(
                                        left: 7.05,
                                        top: 76.09,
                                        child: Container(
                                          width: 22.55,
                                          height: 7.05,
                                          decoration: ShapeDecoration(
                                            color: const Color(0xFFE6C56A) /* darkTokens-color-goldBright */,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(2.82),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 552.80,
                                top: 6.45,
                                child: Container(
                                  width: 62,
                                  height: 88,
                                  padding: const EdgeInsets.only(top: 4.23, left: 7.05),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFF4EFDF) /* darkTokens-color-cardFace */,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1.41,
                                        color: const Color(0xFFD5CEBD),
                                      ),
                                      borderRadius: BorderRadius.circular(11.27),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'A',
                                        style: TextStyle(
                                          color: const Color(0xFFBF382A) /* darkTokens-color-suitRed */,
                                          fontSize: 28.18,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          height: 1.10,
                                        ),
                                      ),
                                      Text(
                                        '♥',
                                        style: TextStyle(
                                          color: const Color(0xFFBF382A) /* darkTokens-color-suitRed */,
                                          fontSize: 22.55,
                                          fontFamily: 'Noto Sans Symbols2',
                                          fontWeight: FontWeight.w400,
                                          height: 1.10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 592.40,
                                top: 6.90,
                                child: Container(
                                  width: 62,
                                  height: 88,
                                  padding: const EdgeInsets.only(top: 4.23, left: 7.05),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFF4EFDF) /* darkTokens-color-cardFace */,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1.41,
                                        color: const Color(0xFFD5CEBD),
                                      ),
                                      borderRadius: BorderRadius.circular(11.27),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'K',
                                        style: TextStyle(
                                          color: const Color(0xFFBF382A) /* darkTokens-color-suitRed */,
                                          fontSize: 28.18,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          height: 1.10,
                                        ),
                                      ),
                                      Text(
                                        '♥',
                                        style: TextStyle(
                                          color: const Color(0xFFBF382A) /* darkTokens-color-suitRed */,
                                          fontSize: 22.55,
                                          fontFamily: 'Noto Sans Symbols2',
                                          fontWeight: FontWeight.w400,
                                          height: 1.10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 632,
                                top: 7.35,
                                child: Container(
                                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(0.01),
                                  width: 62,
                                  height: 88,
                                  padding: const EdgeInsets.only(top: 4.23, left: 7.05),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFF4EFDF) /* darkTokens-color-cardFace */,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1.41,
                                        color: const Color(0xFFD5CEBD),
                                      ),
                                      borderRadius: BorderRadius.circular(11.27),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Q',
                                        style: TextStyle(
                                          color: const Color(0xFFBF382A) /* darkTokens-color-suitRed */,
                                          fontSize: 28.18,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          height: 1.10,
                                        ),
                                      ),
                                      Text(
                                        '♥',
                                        style: TextStyle(
                                          color: const Color(0xFFBF382A) /* darkTokens-color-suitRed */,
                                          fontSize: 22.55,
                                          fontFamily: 'Noto Sans Symbols2',
                                          fontWeight: FontWeight.w400,
                                          height: 1.10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 671.60,
                                top: 7.80,
                                child: Container(
                                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(0.02),
                                  width: 62,
                                  height: 88,
                                  padding: const EdgeInsets.only(top: 4.23, left: 7.05),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFF4EFDF) /* darkTokens-color-cardFace */,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1.41,
                                        color: const Color(0xFFD5CEBD),
                                      ),
                                      borderRadius: BorderRadius.circular(11.27),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '10',
                                        style: TextStyle(
                                          color: const Color(0xFFBF382A) /* darkTokens-color-suitRed */,
                                          fontSize: 28.18,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          height: 1.10,
                                        ),
                                      ),
                                      Text(
                                        '♥',
                                        style: TextStyle(
                                          color: const Color(0xFFBF382A) /* darkTokens-color-suitRed */,
                                          fontSize: 22.55,
                                          fontFamily: 'Noto Sans Symbols2',
                                          fontWeight: FontWeight.w400,
                                          height: 1.10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 711.20,
                                top: 8.25,
                                child: Container(
                                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(0.02),
                                  width: 62,
                                  height: 88,
                                  padding: const EdgeInsets.only(top: 4.23, left: 7.05),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFF4EFDF) /* darkTokens-color-cardFace */,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1.41,
                                        color: const Color(0xFFD5CEBD),
                                      ),
                                      borderRadius: BorderRadius.circular(11.27),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'A',
                                        style: TextStyle(
                                          color: const Color(0xFF19212A),
                                          fontSize: 28.18,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          height: 1.10,
                                        ),
                                      ),
                                      Text(
                                        '♣',
                                        style: TextStyle(
                                          color: const Color(0xFF19212A),
                                          fontSize: 22.55,
                                          fontFamily: 'Noto Sans Symbols2',
                                          fontWeight: FontWeight.w400,
                                          height: 1.10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 750.80,
                                top: 8.70,
                                child: Container(
                                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(0.02),
                                  width: 62,
                                  height: 88,
                                  padding: const EdgeInsets.only(top: 4.23, left: 7.05),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFF4EFDF) /* darkTokens-color-cardFace */,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1.41,
                                        color: const Color(0xFFD5CEBD),
                                      ),
                                      borderRadius: BorderRadius.circular(11.27),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'K',
                                        style: TextStyle(
                                          color: const Color(0xFF19212A),
                                          fontSize: 28.18,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          height: 1.10,
                                        ),
                                      ),
                                      Text(
                                        '♣',
                                        style: TextStyle(
                                          color: const Color(0xFF19212A),
                                          fontSize: 22.55,
                                          fontFamily: 'Noto Sans Symbols2',
                                          fontWeight: FontWeight.w400,
                                          height: 1.10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 790.40,
                                top: 9.15,
                                child: Container(
                                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(0.03),
                                  width: 62,
                                  height: 88,
                                  padding: const EdgeInsets.only(top: 4.23, left: 7.05),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFF4EFDF) /* darkTokens-color-cardFace */,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1.41,
                                        color: const Color(0xFFD5CEBD),
                                      ),
                                      borderRadius: BorderRadius.circular(11.27),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Q',
                                        style: TextStyle(
                                          color: const Color(0xFF19212A),
                                          fontSize: 28.18,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          height: 1.10,
                                        ),
                                      ),
                                      Text(
                                        '♣',
                                        style: TextStyle(
                                          color: const Color(0xFF19212A),
                                          fontSize: 22.55,
                                          fontFamily: 'Noto Sans Symbols2',
                                          fontWeight: FontWeight.w400,
                                          height: 1.10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 830,
                                top: 9.60,
                                child: Container(
                                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(0.03),
                                  width: 62,
                                  height: 88,
                                  padding: const EdgeInsets.only(top: 4.23, left: 7.05),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFF4EFDF) /* darkTokens-color-cardFace */,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1.41,
                                        color: const Color(0xFFD5CEBD),
                                      ),
                                      borderRadius: BorderRadius.circular(11.27),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '9',
                                        style: TextStyle(
                                          color: const Color(0xFF19212A),
                                          fontSize: 28.18,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          height: 1.10,
                                        ),
                                      ),
                                      Text(
                                        '♣',
                                        style: TextStyle(
                                          color: const Color(0xFF19212A),
                                          fontSize: 22.55,
                                          fontFamily: 'Noto Sans Symbols2',
                                          fontWeight: FontWeight.w400,
                                          height: 1.10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 869.60,
                                top: 10.05,
                                child: Container(
                                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(0.03),
                                  width: 62,
                                  height: 88,
                                  padding: const EdgeInsets.only(top: 4.23, left: 7.05),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFF4EFDF) /* darkTokens-color-cardFace */,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1.41,
                                        color: const Color(0xFFD5CEBD),
                                      ),
                                      borderRadius: BorderRadius.circular(11.27),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'A',
                                        style: TextStyle(
                                          color: const Color(0xFFBF382A) /* darkTokens-color-suitRed */,
                                          fontSize: 28.18,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          height: 1.10,
                                        ),
                                      ),
                                      Text(
                                        '♦',
                                        style: TextStyle(
                                          color: const Color(0xFFBF382A) /* darkTokens-color-suitRed */,
                                          fontSize: 22.55,
                                          fontFamily: 'Noto Sans Symbols2',
                                          fontWeight: FontWeight.w400,
                                          height: 1.10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 909.20,
                                top: 10.50,
                                child: Container(
                                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(0.04),
                                  width: 62,
                                  height: 88,
                                  padding: const EdgeInsets.only(top: 4.23, left: 7.05),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFF4EFDF) /* darkTokens-color-cardFace */,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1.41,
                                        color: const Color(0xFFD5CEBD),
                                      ),
                                      borderRadius: BorderRadius.circular(11.27),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'K',
                                        style: TextStyle(
                                          color: const Color(0xFFBF382A) /* darkTokens-color-suitRed */,
                                          fontSize: 28.18,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          height: 1.10,
                                        ),
                                      ),
                                      Text(
                                        '♦',
                                        style: TextStyle(
                                          color: const Color(0xFFBF382A) /* darkTokens-color-suitRed */,
                                          fontSize: 22.55,
                                          fontFamily: 'Noto Sans Symbols2',
                                          fontWeight: FontWeight.w400,
                                          height: 1.10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 948.80,
                                top: 10.95,
                                child: Container(
                                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(0.04),
                                  width: 62,
                                  height: 88,
                                  padding: const EdgeInsets.only(top: 4.23, left: 7.05),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFF4EFDF) /* darkTokens-color-cardFace */,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1.41,
                                        color: const Color(0xFFD5CEBD),
                                      ),
                                      borderRadius: BorderRadius.circular(11.27),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '10',
                                        style: TextStyle(
                                          color: const Color(0xFFBF382A) /* darkTokens-color-suitRed */,
                                          fontSize: 28.18,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          height: 1.10,
                                        ),
                                      ),
                                      Text(
                                        '♦',
                                        style: TextStyle(
                                          color: const Color(0xFFBF382A) /* darkTokens-color-suitRed */,
                                          fontSize: 22.55,
                                          fontFamily: 'Noto Sans Symbols2',
                                          fontWeight: FontWeight.w400,
                                          height: 1.10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 988.40,
                                top: 11.40,
                                child: Container(
                                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(0.05),
                                  width: 62,
                                  height: 88,
                                  padding: const EdgeInsets.only(top: 4.23, left: 7.05),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFF4EFDF) /* darkTokens-color-cardFace */,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1.41,
                                        color: const Color(0xFFD5CEBD),
                                      ),
                                      borderRadius: BorderRadius.circular(11.27),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '8',
                                        style: TextStyle(
                                          color: const Color(0xFFBF382A) /* darkTokens-color-suitRed */,
                                          fontSize: 28.18,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          height: 1.10,
                                        ),
                                      ),
                                      Text(
                                        '♦',
                                        style: TextStyle(
                                          color: const Color(0xFFBF382A) /* darkTokens-color-suitRed */,
                                          fontSize: 22.55,
                                          fontFamily: 'Noto Sans Symbols2',
                                          fontWeight: FontWeight.w400,
                                          height: 1.10,
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
                      Positioned(
                        left: 8,
                        top: 132,
                        child: Container(
                          width: 1084,
                          height: 17,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '已选 ♠A ♠A · 对子',
                                style: TextStyle(
                                  color: const Color(0xFFE6C56A) /* darkTokens-color-goldBright */,
                                  fontSize: 12,
                                  fontFamily: 'Noto Sans SC',
                                  fontWeight: FontWeight.w400,
                                  height: 1.40,
                                ),
                              ),
                              Text(
                                '2 / J / A 为必打级',
                                style: TextStyle(
                                  color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                  fontSize: 10,
                                  fontFamily: 'Noto Sans SC',
                                  fontWeight: FontWeight.w400,
                                  height: 1.40,
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
              Positioned(
                left: 1156,
                top: 430,
                child: Container(
                  width: 424,
                  height: 110,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 206,
                          height: 38,
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            color: const Color(0x12C9A24B),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: const Color(0x45C9A24B),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '重选',
                                style: TextStyle(
                                  color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                  fontSize: 14,
                                  fontFamily: 'Noto Sans SC',
                                  fontWeight: FontWeight.w700,
                                  height: 1.40,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 218,
                        top: 0,
                        child: Container(
                          width: 206,
                          height: 38,
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            color: const Color(0x12C9A24B),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: const Color(0x45C9A24B),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '提示',
                                style: TextStyle(
                                  color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                  fontSize: 14,
                                  fontFamily: 'Noto Sans SC',
                                  fontWeight: FontWeight.w700,
                                  height: 1.40,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 46,
                        child: Container(
                          width: 424,
                          height: 50,
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
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '确认出牌 · 2张',
                                style: TextStyle(
                                  color: const Color(0xFF19212A),
                                  fontSize: 14,
                                  fontFamily: 'Noto Sans SC',
                                  fontWeight: FontWeight.w700,
                                  height: 1.40,
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
              Positioned(
                left: 1156,
                top: 72,
                child: Container(
                  width: 424,
                  height: 344,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 20,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '聊天',
                              style: TextStyle(
                                color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                fontSize: 14,
                                fontFamily: 'Noto Sans SC',
                                fontWeight: FontWeight.w700,
                                height: 1.40,
                              ),
                            ),
                            Text(
                              '3 条',
                              style: TextStyle(
                                color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                fontSize: 10,
                                fontFamily: 'Noto Sans SC',
                                fontWeight: FontWeight.w400,
                                height: 1.40,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 268,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        clipBehavior: Clip.antiAlias,
                        decoration: ShapeDecoration(
                          color: const Color(0xFF131A23) /* darkTokens-color-bgPanel */,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1,
                              color: const Color(0x45C9A24B),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 8,
                          children: [
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
                                    width: 24,
                                    height: 24,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          width: 0.80,
                                          color: const Color(0xFF8A6A2F) /* darkTokens-color-goldDark */,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
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
                                            fontSize: 12,
                                            fontFamily: 'Noto Serif SC',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        spacing: 2,
                                        children: [
                                          Text(
                                            '运河老周',
                                            style: TextStyle(
                                              color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                              fontSize: 10,
                                              fontFamily: 'Noto Sans SC',
                                              fontWeight: FontWeight.w400,
                                              height: 1.40,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 220,
                                            child: Text(
                                              '庄家先出 ♠2，主花色很稳。',
                                              style: TextStyle(
                                                color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                                fontSize: 12,
                                                fontFamily: 'Noto Sans SC',
                                                fontWeight: FontWeight.w400,
                                                height: 1.40,
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
                                    width: 24,
                                    height: 24,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          width: 0.80,
                                          color: const Color(0xFF8A6A2F) /* darkTokens-color-goldDark */,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
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
                                            fontSize: 12,
                                            fontFamily: 'Noto Serif SC',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        spacing: 2,
                                        children: [
                                          Text(
                                            '牌逢知己',
                                            style: TextStyle(
                                              color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                              fontSize: 10,
                                              fontFamily: 'Noto Sans SC',
                                              fontWeight: FontWeight.w400,
                                              height: 1.40,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 220,
                                            child: Text(
                                              '级牌 2 已经打出，下一句可以考虑对子。',
                                              style: TextStyle(
                                                color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                                fontSize: 12,
                                                fontFamily: 'Noto Sans SC',
                                                fontWeight: FontWeight.w400,
                                                height: 1.40,
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
                                    width: 24,
                                    height: 24,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFF2C2A22),
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          width: 0.80,
                                          color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
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
                                            fontSize: 12,
                                            fontFamily: 'Noto Serif SC',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        spacing: 2,
                                        children: [
                                          Text(
                                            '淮安阿淮',
                                            style: TextStyle(
                                              color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                              fontSize: 10,
                                              fontFamily: 'Noto Sans SC',
                                              fontWeight: FontWeight.w400,
                                              height: 1.40,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 220,
                                            child: Text(
                                              '我这边 ♠A ♠A 已经准备好，托管也可以手动切换。',
                                              style: TextStyle(
                                                color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                                fontSize: 12,
                                                fontFamily: 'Noto Sans SC',
                                                fontWeight: FontWeight.w400,
                                                height: 1.40,
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
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        clipBehavior: Clip.antiAlias,
                        decoration: ShapeDecoration(
                          color: const Color(0xFF131A23) /* darkTokens-color-bgPanel */,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1,
                              color: const Color(0x45C9A24B),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 8,
                          children: [
                            SizedBox(
                              width: 360,
                              child: Text(
                                '输入消息',
                                style: TextStyle(
                                  color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                  fontSize: 12,
                                  fontFamily: 'Noto Sans SC',
                                  fontWeight: FontWeight.w400,
                                  height: 1.40,
                                ),
                              ),
                            ),
                            Container(
                              width: 32,
                              height: 24,
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: const Color(0x12C9A24B),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '发送',
                                    style: TextStyle(
                                      color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                      fontSize: 10,
                                      fontFamily: 'Noto Sans SC',
                                      fontWeight: FontWeight.w700,
                                      height: 1.40,
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
              Positioned(
                left: 40,
                top: 578,
                child: Container(
                  width: 1540,
                  height: 172,
                  padding: const EdgeInsets.all(16),
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF131A23) /* darkTokens-color-bgPanel */,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: const Color(0x45C9A24B),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
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
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 8,
                                children: [
                                  Text(
                                    '结算',
                                    style: TextStyle(
                                      color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                      fontSize: 14,
                                      fontFamily: 'Noto Sans SC',
                                      fontWeight: FontWeight.w700,
                                      height: 1.40,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    clipBehavior: Clip.antiAlias,
                                    decoration: ShapeDecoration(
                                      color: const Color(0x12C9A24B),
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          width: 0.80,
                                          color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                        ),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '本局终局',
                                          style: TextStyle(
                                            color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                            fontSize: 10,
                                            fontFamily: 'Noto Sans SC',
                                            fontWeight: FontWeight.w700,
                                            height: 1.40,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '结算结果 · 春天 ×2.0',
                              style: TextStyle(
                                color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                fontSize: 10,
                                fontFamily: 'Noto Sans SC',
                                fontWeight: FontWeight.w400,
                                height: 1.40,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 108,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 16,
                          children: [
                            Container(
                              width: 360,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 8,
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
                                        Text(
                                          '我方',
                                          style: TextStyle(
                                            color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                            fontSize: 10,
                                            fontFamily: 'Noto Sans SC',
                                            fontWeight: FontWeight.w400,
                                            height: 1.40,
                                          ),
                                        ),
                                        Text(
                                          '对方',
                                          style: TextStyle(
                                            color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                            fontSize: 10,
                                            fontFamily: 'Noto Sans SC',
                                            fontWeight: FontWeight.w400,
                                            height: 1.40,
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
                                          '200',
                                          style: TextStyle(
                                            color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                            fontSize: 24,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w700,
                                            height: 1.33,
                                            letterSpacing: -0.20,
                                          ),
                                        ),
                                        Text(
                                          '0',
                                          style: TextStyle(
                                            color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                            fontSize: 24,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w700,
                                            height: 1.33,
                                            letterSpacing: -0.20,
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
                                          '2 → 5',
                                          style: TextStyle(
                                            color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                            fontSize: 10,
                                            fontFamily: 'Noto Sans SC',
                                            fontWeight: FontWeight.w400,
                                            height: 1.40,
                                          ),
                                        ),
                                        Text(
                                          '2 → 2',
                                          style: TextStyle(
                                            color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                            fontSize: 10,
                                            fontFamily: 'Noto Sans SC',
                                            fontWeight: FontWeight.w400,
                                            height: 1.40,
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
                                          '胜利',
                                          style: TextStyle(
                                            color: const Color(0xFFE6C56A) /* darkTokens-color-goldBright */,
                                            fontSize: 10,
                                            fontFamily: 'Noto Sans SC',
                                            fontWeight: FontWeight.w400,
                                            height: 1.40,
                                          ),
                                        ),
                                        Text(
                                          '失败',
                                          style: TextStyle(
                                            color: const Color(0xFFBF382A) /* darkTokens-color-suitRed */,
                                            fontSize: 10,
                                            fontFamily: 'Noto Sans SC',
                                            fontWeight: FontWeight.w400,
                                            height: 1.40,
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
                                          '级差 3级',
                                          style: TextStyle(
                                            color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                            fontSize: 10,
                                            fontFamily: 'Noto Sans SC',
                                            fontWeight: FontWeight.w400,
                                            height: 1.40,
                                          ),
                                        ),
                                        Text(
                                          '积分变动 ×2.0',
                                          style: TextStyle(
                                            color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                            fontSize: 10,
                                            fontFamily: 'Noto Sans SC',
                                            fontWeight: FontWeight.w400,
                                            height: 1.40,
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
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 8,
                                  children: [
                                    Text(
                                      '淮安阿淮 +40 · 清江月 +40 · 运河老周 −40 · 牌逢知己 −40',
                                      style: TextStyle(
                                        color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                        fontSize: 10,
                                        fontFamily: 'Noto Sans SC',
                                        fontWeight: FontWeight.w400,
                                        height: 1.40,
                                      ),
                                    ),
                                    Text(
                                      '自然级 / 翻盘未触发 · 下局淮安阿淮坐庄，我方打5',
                                      style: TextStyle(
                                        color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                        fontSize: 10,
                                        fontFamily: 'Noto Sans SC',
                                        fontWeight: FontWeight.w400,
                                        height: 1.40,
                                      ),
                                    ),
                                    Text(
                                      '规则说明：春天 ×2.0、翻盘 ×1.5、自然级 ×1.0',
                                      style: TextStyle(
                                        color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                        fontSize: 10,
                                        fontFamily: 'Noto Sans SC',
                                        fontWeight: FontWeight.w400,
                                        height: 1.40,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: 144,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 8,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 34,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: ShapeDecoration(
                                      color: const Color(0x12C9A24B),
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          width: 1,
                                          color: const Color(0x45C9A24B),
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          '返回房间',
                                          style: TextStyle(
                                            color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                            fontSize: 14,
                                            fontFamily: 'Noto Sans SC',
                                            fontWeight: FontWeight.w700,
                                            height: 1.40,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 44,
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
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          '准备下一局',
                                          style: TextStyle(
                                            color: const Color(0xFF19212A),
                                            fontSize: 14,
                                            fontFamily: 'Noto Sans SC',
                                            fontWeight: FontWeight.w700,
                                            height: 1.40,
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
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 350,
                top: 94,
                child: Container(
                  width: 760,
                  height: 306,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF212F3D) /* darkTokens-color-cardBack */,
                    shape: OvalBorder(
                      side: BorderSide(
                        width: 2,
                        color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 358,
                top: 102,
                child: Container(
                  width: 744,
                  height: 290,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF32171F),
                    shape: OvalBorder(),
                  ),
                ),
              ),
              Positioned(
                left: 730,
                top: 316,
                child: Opacity(
                  opacity: 0.38,
                  child: Container(
                    transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(1.57),
                    width: 28,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1.20,
                          color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 730,
                top: 151,
                child: Opacity(
                  opacity: 0.38,
                  child: Container(
                    transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(1.57),
                    width: 41,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1.20,
                          color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 730,
                top: 244,
                child: Opacity(
                  opacity: 0.38,
                  child: Container(
                    width: 238,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1.20,
                          color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 494,
                top: 244,
                child: Opacity(
                  opacity: 0.38,
                  child: Container(
                    width: 236,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1.20,
                          color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 560,
                top: 192,
                child: Container(
                  width: 340,
                  height: 124,
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF131A23) /* darkTokens-color-bgPanel */,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: const Color(0x45C9A24B),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 8,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 56,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(color: const Color(0xFF32171F)),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 4,
                          children: [
                            Text(
                              'HUAIAN · 80',
                              style: TextStyle(
                                color: const Color(0xFF8A6A2F) /* darkTokens-color-goldDark */,
                                fontSize: 7.20,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              '等待庄家首攻',
                              style: TextStyle(
                                color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                fontSize: 13.60,
                                fontFamily: 'Noto Sans SC',
                                fontWeight: FontWeight.w500,
                                height: 1.40,
                              ),
                            ),
                            Text(
                              '本墩 0 分 · 尚未出牌',
                              style: TextStyle(
                                color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                fontSize: 8,
                                fontFamily: 'Noto Sans SC',
                                fontWeight: FontWeight.w400,
                                height: 1.40,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 60,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 4,
                          children: [
                            Text(
                              '底牌 8 张 · 已扣底',
                              style: TextStyle(
                                color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                fontSize: 8,
                                fontFamily: 'Noto Sans SC',
                                fontWeight: FontWeight.w400,
                                height: 1.40,
                              ),
                            ),
                            Container(
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 1.60,
                                children: [
                                  Container(
                                    width: 19.20,
                                    height: 25.60,
                                    padding: const EdgeInsets.all(2.40),
                                    clipBehavior: Clip.antiAlias,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFF212F3D) /* darkTokens-color-cardBack */,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          width: 0.80,
                                          color: const Color(0x45C9A24B),
                                        ),
                                        borderRadius: BorderRadius.circular(3.20),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            width: double.infinity,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: ShapeDecoration(
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 0.80,
                                                  color: const Color(0x45C9A24B),
                                                ),
                                                borderRadius: BorderRadius.circular(1.60),
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
                                                    fontSize: 7.20,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 19.20,
                                    height: 25.60,
                                    padding: const EdgeInsets.all(2.40),
                                    clipBehavior: Clip.antiAlias,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFF212F3D) /* darkTokens-color-cardBack */,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          width: 0.80,
                                          color: const Color(0x45C9A24B),
                                        ),
                                        borderRadius: BorderRadius.circular(3.20),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            width: double.infinity,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: ShapeDecoration(
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 0.80,
                                                  color: const Color(0x45C9A24B),
                                                ),
                                                borderRadius: BorderRadius.circular(1.60),
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
                                                    fontSize: 7.20,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 19.20,
                                    height: 25.60,
                                    padding: const EdgeInsets.all(2.40),
                                    clipBehavior: Clip.antiAlias,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFF212F3D) /* darkTokens-color-cardBack */,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          width: 0.80,
                                          color: const Color(0x45C9A24B),
                                        ),
                                        borderRadius: BorderRadius.circular(3.20),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            width: double.infinity,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: ShapeDecoration(
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 0.80,
                                                  color: const Color(0x45C9A24B),
                                                ),
                                                borderRadius: BorderRadius.circular(1.60),
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
                                                    fontSize: 7.20,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 19.20,
                                    height: 25.60,
                                    padding: const EdgeInsets.all(2.40),
                                    clipBehavior: Clip.antiAlias,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFF212F3D) /* darkTokens-color-cardBack */,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          width: 0.80,
                                          color: const Color(0x45C9A24B),
                                        ),
                                        borderRadius: BorderRadius.circular(3.20),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            width: double.infinity,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: ShapeDecoration(
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 0.80,
                                                  color: const Color(0x45C9A24B),
                                                ),
                                                borderRadius: BorderRadius.circular(1.60),
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
                                                    fontSize: 7.20,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 19.20,
                                    height: 25.60,
                                    padding: const EdgeInsets.all(2.40),
                                    clipBehavior: Clip.antiAlias,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFF212F3D) /* darkTokens-color-cardBack */,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          width: 0.80,
                                          color: const Color(0x45C9A24B),
                                        ),
                                        borderRadius: BorderRadius.circular(3.20),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            width: double.infinity,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: ShapeDecoration(
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 0.80,
                                                  color: const Color(0x45C9A24B),
                                                ),
                                                borderRadius: BorderRadius.circular(1.60),
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
                                                    fontSize: 7.20,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 19.20,
                                    height: 25.60,
                                    padding: const EdgeInsets.all(2.40),
                                    clipBehavior: Clip.antiAlias,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFF212F3D) /* darkTokens-color-cardBack */,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          width: 0.80,
                                          color: const Color(0x45C9A24B),
                                        ),
                                        borderRadius: BorderRadius.circular(3.20),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            width: double.infinity,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: ShapeDecoration(
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 0.80,
                                                  color: const Color(0x45C9A24B),
                                                ),
                                                borderRadius: BorderRadius.circular(1.60),
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
                                                    fontSize: 7.20,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 19.20,
                                    height: 25.60,
                                    padding: const EdgeInsets.all(2.40),
                                    clipBehavior: Clip.antiAlias,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFF212F3D) /* darkTokens-color-cardBack */,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          width: 0.80,
                                          color: const Color(0x45C9A24B),
                                        ),
                                        borderRadius: BorderRadius.circular(3.20),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            width: double.infinity,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: ShapeDecoration(
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 0.80,
                                                  color: const Color(0x45C9A24B),
                                                ),
                                                borderRadius: BorderRadius.circular(1.60),
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
                                                    fontSize: 7.20,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 19.20,
                                    height: 25.60,
                                    padding: const EdgeInsets.all(2.40),
                                    clipBehavior: Clip.antiAlias,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFF212F3D) /* darkTokens-color-cardBack */,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          width: 0.80,
                                          color: const Color(0x45C9A24B),
                                        ),
                                        borderRadius: BorderRadius.circular(3.20),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            width: double.infinity,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: ShapeDecoration(
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 0.80,
                                                  color: const Color(0x45C9A24B),
                                                ),
                                                borderRadius: BorderRadius.circular(1.60),
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
                                                    fontSize: 7.20,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w400,
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
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 645,
                top: 100,
                child: Container(
                  width: 170,
                  height: 51.20,
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF131A23) /* darkTokens-color-bgPanel */,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: const Color(0x45C9A24B),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 4,
                    children: [
                      Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 6,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: const Color(0xFF2C2A22),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 0.80,
                                    color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
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
                                      fontSize: 16.80,
                                      fontFamily: 'Noto Serif SC',
                                      fontWeight: FontWeight.w400,
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
                                spacing: 0.80,
                                children: [
                                  Text(
                                    '清江月',
                                    style: TextStyle(
                                      color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                      fontSize: 10.40,
                                      fontFamily: 'Noto Sans SC',
                                      fontWeight: FontWeight.w700,
                                      height: 1.40,
                                    ),
                                  ),
                                  Text(
                                    '黄金 III · 0分 · 25张',
                                    style: TextStyle(
                                      color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                      fontSize: 8,
                                      fontFamily: 'Noto Sans SC',
                                      fontWeight: FontWeight.w400,
                                      height: 1.40,
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
                          spacing: 4,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5.60, vertical: 1.60),
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: const Color(0x12C9A24B),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 0.80,
                                    color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 2.40,
                                children: [
                                  Text(
                                    '2',
                                    style: TextStyle(
                                      color: const Color(0xFFE6C56A) /* darkTokens-color-goldBright */,
                                      fontSize: 9.60,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '必打',
                                    style: TextStyle(
                                      color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                      fontSize: 7.20,
                                      fontFamily: 'Noto Sans SC',
                                      fontWeight: FontWeight.w400,
                                      height: 1.40,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '我方 · 上下',
                              style: TextStyle(
                                color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                fontSize: 7.20,
                                fontFamily: 'Noto Sans SC',
                                fontWeight: FontWeight.w400,
                                height: 1.40,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 354,
                top: 218,
                child: Container(
                  width: 140,
                  height: 51.20,
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF131A23) /* darkTokens-color-bgPanel */,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: const Color(0x45C9A24B),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 4,
                    children: [
                      Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 6,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 0.80,
                                    color: const Color(0xFF8A6A2F) /* darkTokens-color-goldDark */,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
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
                                      fontSize: 16.80,
                                      fontFamily: 'Noto Serif SC',
                                      fontWeight: FontWeight.w400,
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
                                spacing: 0.80,
                                children: [
                                  Text(
                                    '运河老周',
                                    style: TextStyle(
                                      color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                      fontSize: 10.40,
                                      fontFamily: 'Noto Sans SC',
                                      fontWeight: FontWeight.w700,
                                      height: 1.40,
                                    ),
                                  ),
                                  Text(
                                    '黄金 II · 25张',
                                    style: TextStyle(
                                      color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                      fontSize: 8,
                                      fontFamily: 'Noto Sans SC',
                                      fontWeight: FontWeight.w400,
                                      height: 1.40,
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
                          spacing: 4,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5.60, vertical: 1.60),
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: const Color(0x12C9A24B),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 0.80,
                                    color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 2.40,
                                children: [
                                  Text(
                                    '2',
                                    style: TextStyle(
                                      color: const Color(0xFFE6C56A) /* darkTokens-color-goldBright */,
                                      fontSize: 9.60,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '必打',
                                    style: TextStyle(
                                      color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                      fontSize: 7.20,
                                      fontFamily: 'Noto Sans SC',
                                      fontWeight: FontWeight.w400,
                                      height: 1.40,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '0分',
                              style: TextStyle(
                                color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                fontSize: 8.80,
                                fontFamily: 'Noto Sans SC',
                                fontWeight: FontWeight.w400,
                                height: 1.40,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 968,
                top: 218,
                child: Container(
                  width: 140,
                  height: 51.20,
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF131A23) /* darkTokens-color-bgPanel */,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: const Color(0x45C9A24B),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 4,
                    children: [
                      Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 6,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 0.80,
                                    color: const Color(0xFF8A6A2F) /* darkTokens-color-goldDark */,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
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
                                      fontSize: 16.80,
                                      fontFamily: 'Noto Serif SC',
                                      fontWeight: FontWeight.w400,
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
                                spacing: 0.80,
                                children: [
                                  Text(
                                    '牌逢知己',
                                    style: TextStyle(
                                      color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                      fontSize: 10.40,
                                      fontFamily: 'Noto Sans SC',
                                      fontWeight: FontWeight.w700,
                                      height: 1.40,
                                    ),
                                  ),
                                  Text(
                                    '白银 I · 25张',
                                    style: TextStyle(
                                      color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                      fontSize: 8,
                                      fontFamily: 'Noto Sans SC',
                                      fontWeight: FontWeight.w400,
                                      height: 1.40,
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
                          spacing: 4,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5.60, vertical: 1.60),
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: const Color(0x12C9A24B),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 0.80,
                                    color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 2.40,
                                children: [
                                  Text(
                                    '2',
                                    style: TextStyle(
                                      color: const Color(0xFFE6C56A) /* darkTokens-color-goldBright */,
                                      fontSize: 9.60,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '必打',
                                    style: TextStyle(
                                      color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                      fontSize: 7.20,
                                      fontFamily: 'Noto Sans SC',
                                      fontWeight: FontWeight.w400,
                                      height: 1.40,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '0分',
                              style: TextStyle(
                                color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                fontSize: 8.80,
                                fontFamily: 'Noto Sans SC',
                                fontWeight: FontWeight.w400,
                                height: 1.40,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 639,
                top: 344,
                child: Container(
                  width: 182,
                  height: 51.20,
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF131A23) /* darkTokens-color-bgPanel */,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: const Color(0x45C9A24B),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 4,
                    children: [
                      Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 6,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: const Color(0xFF2C2A22),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 0.80,
                                    color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
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
                                      fontSize: 16.80,
                                      fontFamily: 'Noto Serif SC',
                                      fontWeight: FontWeight.w400,
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
                                spacing: 0.80,
                                children: [
                                  Container(
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      spacing: 2.40,
                                      children: [
                                        Container(
                                          width: 11.20,
                                          height: 10.40,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(),
                                          child: Stack(),
                                        ),
                                        Text(
                                          '淮安阿淮 · 我',
                                          style: TextStyle(
                                            color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                            fontSize: 10.40,
                                            fontFamily: 'Noto Sans SC',
                                            fontWeight: FontWeight.w700,
                                            height: 1.40,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '黄金 III · 0分 · 25张',
                                    style: TextStyle(
                                      color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                      fontSize: 8,
                                      fontFamily: 'Noto Sans SC',
                                      fontWeight: FontWeight.w400,
                                      height: 1.40,
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
                          spacing: 4,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5.60, vertical: 1.60),
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: const Color(0x12C9A24B),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 0.80,
                                    color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 2.40,
                                children: [
                                  Text(
                                    '2',
                                    style: TextStyle(
                                      color: const Color(0xFFE6C56A) /* darkTokens-color-goldBright */,
                                      fontSize: 9.60,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '必打',
                                    style: TextStyle(
                                      color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                      fontSize: 7.20,
                                      fontFamily: 'Noto Sans SC',
                                      fontWeight: FontWeight.w400,
                                      height: 1.40,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '我方 · 上下',
                              style: TextStyle(
                                color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                fontSize: 7.20,
                                fontFamily: 'Noto Sans SC',
                                fontWeight: FontWeight.w400,
                                height: 1.40,
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
      ],
    );
  }
}