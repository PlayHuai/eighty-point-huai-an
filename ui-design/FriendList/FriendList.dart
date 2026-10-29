class Friendlist extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: 1000),
          child: Container(
            width: 1440,
            height: 1000,
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
                              child: Stack(),
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
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 912),
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
                                      '游戏大厅',
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
                                      '好友',
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
                                              '好友',
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
                                              '牌友常在，好局随开。',
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
                                        width: 476,
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          spacing: 12,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                height: 44,
                                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                                clipBehavior: Clip.antiAlias,
                                                decoration: ShapeDecoration(
                                                  color: const Color(0xFF131A23) /* darkTokens-color-bgPanel */,
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
                                                  spacing: 10,
                                                  children: [
                                                    Container(
                                                      width: 20,
                                                      height: 20,
                                                      clipBehavior: Clip.antiAlias,
                                                      decoration: BoxDecoration(),
                                                      child: Stack(),
                                                    ),
                                                    SizedBox(
                                                      width: 255,
                                                      child: Text(
                                                        '搜索好友昵称 / ID / 手机号',
                                                        style: TextStyle(
                                                          color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                                          fontSize: 14,
                                                          fontFamily: 'Inter',
                                                          fontWeight: FontWeight.w400,
                                                          height: 1.43,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      '⌘ K',
                                                      style: TextStyle(
                                                        color: const Color(0xFF84909E),
                                                        fontSize: 12,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
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
                                                    '添加好友',
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
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 24,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            spacing: 12,
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.symmetric(vertical: 14),
                                                clipBehavior: Clip.antiAlias,
                                                decoration: BoxDecoration(),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  spacing: 30,
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
                                                            '全部好友  6',
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
                                                      '在线  3',
                                                      style: TextStyle(
                                                        color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                                        fontSize: 14,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w400,
                                                        height: 1.43,
                                                      ),
                                                    ),
                                                    Text(
                                                      '离线  3',
                                                      style: TextStyle(
                                                        color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                                        fontSize: 14,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w400,
                                                        height: 1.43,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 623,
                                                      child: Text(
                                                        '在线优先 ↓',
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
                                                  spacing: 14,
                                                  children: [
                                                    Container(
                                                      width: double.infinity,
                                                      clipBehavior: Clip.antiAlias,
                                                      decoration: BoxDecoration(),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        spacing: 16,
                                                        children: [
                                                          Container(
                                                            width: 56,
                                                            height: 56,
                                                            decoration: ShapeDecoration(
                                                              image: DecorationImage(
                                                                image: NetworkImage("https://placehold.co/56x56"),
                                                                fit: BoxFit.cover,
                                                              ),
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(12),
                                                              ),
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
                                                                spacing: 6,
                                                                children: [
                                                                  Container(
                                                                    width: double.infinity,
                                                                    clipBehavior: Clip.antiAlias,
                                                                    decoration: BoxDecoration(),
                                                                    child: Row(
                                                                      mainAxisSize: MainAxisSize.min,
                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                      spacing: 10,
                                                                      children: [
                                                                        Text(
                                                                          '清风徐来',
                                                                          style: TextStyle(
                                                                            color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                                                            fontSize: 16,
                                                                            fontFamily: 'Inter',
                                                                            fontWeight: FontWeight.w500,
                                                                            height: 1.50,
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
                                                                              Container(
                                                                                width: 6,
                                                                                height: 6,
                                                                                decoration: ShapeDecoration(
                                                                                  color: const Color(0xFF65B88A),
                                                                                  shape: OvalBorder(),
                                                                                ),
                                                                              ),
                                                                              Text(
                                                                                '在线',
                                                                                style: TextStyle(
                                                                                  color: const Color(0xFF65B88A),
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
                                                                  SizedBox(
                                                                    width: 442,
                                                                    child: Text(
                                                                      '经典大厅 · 房间 8006',
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
                                                                  Text(
                                                                    'ID 800126',
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
                                                          ),
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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
                                                                  '雀圣 · 九段',
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
                                                            width: 202,
                                                            clipBehavior: Clip.antiAlias,
                                                            decoration: BoxDecoration(),
                                                            child: Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              spacing: 8,
                                                              children: [
                                                                Container(
                                                                  height: 34,
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
                                                                    spacing: 7,
                                                                    children: [
                                                                      Container(
                                                                        width: 15,
                                                                        height: 15,
                                                                        clipBehavior: Clip.antiAlias,
                                                                        decoration: BoxDecoration(),
                                                                        child: Stack(),
                                                                      ),
                                                                      Text(
                                                                        '聊天',
                                                                        style: TextStyle(
                                                                          color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
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
                                                                  height: 34,
                                                                  padding: const EdgeInsets.symmetric(horizontal: 12),
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
                                                                      Text(
                                                                        '邀请入房',
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
                                                                Container(
                                                                  width: 32,
                                                                  height: 34,
                                                                  clipBehavior: Clip.antiAlias,
                                                                  decoration: BoxDecoration(),
                                                                  child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                      Container(
                                                                        width: 17,
                                                                        height: 17,
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
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                width: double.infinity,
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
                                                  spacing: 14,
                                                  children: [
                                                    Container(
                                                      width: double.infinity,
                                                      clipBehavior: Clip.antiAlias,
                                                      decoration: BoxDecoration(),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        spacing: 16,
                                                        children: [
                                                          Container(
                                                            width: 56,
                                                            height: 56,
                                                            decoration: ShapeDecoration(
                                                              image: DecorationImage(
                                                                image: NetworkImage("https://placehold.co/56x56"),
                                                                fit: BoxFit.cover,
                                                              ),
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(12),
                                                              ),
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
                                                                spacing: 6,
                                                                children: [
                                                                  Container(
                                                                    width: double.infinity,
                                                                    clipBehavior: Clip.antiAlias,
                                                                    decoration: BoxDecoration(),
                                                                    child: Row(
                                                                      mainAxisSize: MainAxisSize.min,
                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                      spacing: 10,
                                                                      children: [
                                                                        Text(
                                                                          '淮上老友',
                                                                          style: TextStyle(
                                                                            color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                                                            fontSize: 16,
                                                                            fontFamily: 'Inter',
                                                                            fontWeight: FontWeight.w500,
                                                                            height: 1.50,
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
                                                                              Container(
                                                                                width: 6,
                                                                                height: 6,
                                                                                decoration: ShapeDecoration(
                                                                                  color: const Color(0xFF65B88A),
                                                                                  shape: OvalBorder(),
                                                                                ),
                                                                              ),
                                                                              Text(
                                                                                '在线',
                                                                                style: TextStyle(
                                                                                  color: const Color(0xFF65B88A),
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
                                                                  SizedBox(
                                                                    width: 442,
                                                                    child: Text(
                                                                      '休闲大厅 · 等待开局',
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
                                                                  Text(
                                                                    'ID 806688',
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
                                                          ),
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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
                                                                  '大师 · 七段',
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
                                                            width: 202,
                                                            clipBehavior: Clip.antiAlias,
                                                            decoration: BoxDecoration(),
                                                            child: Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              spacing: 8,
                                                              children: [
                                                                Container(
                                                                  height: 34,
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
                                                                    spacing: 7,
                                                                    children: [
                                                                      Container(
                                                                        width: 15,
                                                                        height: 15,
                                                                        clipBehavior: Clip.antiAlias,
                                                                        decoration: BoxDecoration(),
                                                                        child: Stack(),
                                                                      ),
                                                                      Text(
                                                                        '聊天',
                                                                        style: TextStyle(
                                                                          color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
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
                                                                  height: 34,
                                                                  padding: const EdgeInsets.symmetric(horizontal: 12),
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
                                                                      Text(
                                                                        '邀请入房',
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
                                                                Container(
                                                                  width: 32,
                                                                  height: 34,
                                                                  clipBehavior: Clip.antiAlias,
                                                                  decoration: BoxDecoration(),
                                                                  child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                      Container(
                                                                        width: 17,
                                                                        height: 17,
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
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                width: double.infinity,
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
                                                  spacing: 14,
                                                  children: [
                                                    Container(
                                                      width: double.infinity,
                                                      clipBehavior: Clip.antiAlias,
                                                      decoration: BoxDecoration(),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        spacing: 16,
                                                        children: [
                                                          Container(
                                                            width: 56,
                                                            height: 56,
                                                            decoration: ShapeDecoration(
                                                              image: DecorationImage(
                                                                image: NetworkImage("https://placehold.co/56x56"),
                                                                fit: BoxFit.cover,
                                                              ),
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(12),
                                                              ),
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
                                                                spacing: 6,
                                                                children: [
                                                                  Container(
                                                                    width: double.infinity,
                                                                    clipBehavior: Clip.antiAlias,
                                                                    decoration: BoxDecoration(),
                                                                    child: Row(
                                                                      mainAxisSize: MainAxisSize.min,
                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                      spacing: 10,
                                                                      children: [
                                                                        Text(
                                                                          '一叶知秋',
                                                                          style: TextStyle(
                                                                            color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                                                            fontSize: 16,
                                                                            fontFamily: 'Inter',
                                                                            fontWeight: FontWeight.w500,
                                                                            height: 1.50,
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
                                                                              Container(
                                                                                width: 6,
                                                                                height: 6,
                                                                                decoration: ShapeDecoration(
                                                                                  color: const Color(0xFF65B88A),
                                                                                  shape: OvalBorder(),
                                                                                ),
                                                                              ),
                                                                              Text(
                                                                                '在线',
                                                                                style: TextStyle(
                                                                                  color: const Color(0xFF65B88A),
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
                                                                  SizedBox(
                                                                    width: 442,
                                                                    child: Text(
                                                                      '所在位置未公开',
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
                                                                  Text(
                                                                    'ID 801729',
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
                                                          ),
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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
                                                                  '高手 · 五段',
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
                                                            width: 202,
                                                            clipBehavior: Clip.antiAlias,
                                                            decoration: BoxDecoration(),
                                                            child: Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              spacing: 8,
                                                              children: [
                                                                Container(
                                                                  height: 34,
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
                                                                    spacing: 7,
                                                                    children: [
                                                                      Container(
                                                                        width: 15,
                                                                        height: 15,
                                                                        clipBehavior: Clip.antiAlias,
                                                                        decoration: BoxDecoration(),
                                                                        child: Stack(),
                                                                      ),
                                                                      Text(
                                                                        '聊天',
                                                                        style: TextStyle(
                                                                          color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
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
                                                                  height: 34,
                                                                  padding: const EdgeInsets.symmetric(horizontal: 12),
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
                                                                      Text(
                                                                        '邀请入房',
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
                                                                Container(
                                                                  width: 32,
                                                                  height: 34,
                                                                  clipBehavior: Clip.antiAlias,
                                                                  decoration: BoxDecoration(),
                                                                  child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                      Container(
                                                                        width: 17,
                                                                        height: 17,
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
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                width: double.infinity,
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
                                                  spacing: 14,
                                                  children: [
                                                    Container(
                                                      width: double.infinity,
                                                      clipBehavior: Clip.antiAlias,
                                                      decoration: BoxDecoration(),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        spacing: 16,
                                                        children: [
                                                          Container(
                                                            width: 56,
                                                            height: 56,
                                                            decoration: ShapeDecoration(
                                                              image: DecorationImage(
                                                                image: NetworkImage("https://placehold.co/56x56"),
                                                                fit: BoxFit.cover,
                                                              ),
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(12),
                                                              ),
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
                                                                spacing: 6,
                                                                children: [
                                                                  Container(
                                                                    width: double.infinity,
                                                                    clipBehavior: Clip.antiAlias,
                                                                    decoration: BoxDecoration(),
                                                                    child: Row(
                                                                      mainAxisSize: MainAxisSize.min,
                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                      spacing: 10,
                                                                      children: [
                                                                        Text(
                                                                          '运河听雨',
                                                                          style: TextStyle(
                                                                            color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                                                            fontSize: 16,
                                                                            fontFamily: 'Inter',
                                                                            fontWeight: FontWeight.w500,
                                                                            height: 1.50,
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
                                                                              Container(
                                                                                width: 6,
                                                                                height: 6,
                                                                                decoration: ShapeDecoration(
                                                                                  color: const Color(0xFF74808E),
                                                                                  shape: OvalBorder(),
                                                                                ),
                                                                              ),
                                                                              Text(
                                                                                '离线',
                                                                                style: TextStyle(
                                                                                  color: const Color(0xFF74808E),
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
                                                                  SizedBox(
                                                                    width: 442,
                                                                    child: Text(
                                                                      '最近在线：20分钟前',
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
                                                                  Text(
                                                                    'ID 803021',
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
                                                          ),
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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
                                                                  '大师 · 六段',
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
                                                            width: 202,
                                                            clipBehavior: Clip.antiAlias,
                                                            decoration: BoxDecoration(),
                                                            child: Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              spacing: 8,
                                                              children: [
                                                                Container(
                                                                  height: 34,
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
                                                                    spacing: 7,
                                                                    children: [
                                                                      Container(
                                                                        width: 15,
                                                                        height: 15,
                                                                        clipBehavior: Clip.antiAlias,
                                                                        decoration: BoxDecoration(),
                                                                        child: Stack(),
                                                                      ),
                                                                      Text(
                                                                        '聊天',
                                                                        style: TextStyle(
                                                                          color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
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
                                                                  width: 80,
                                                                  height: 34,
                                                                  clipBehavior: Clip.antiAlias,
                                                                  decoration: BoxDecoration(),
                                                                ),
                                                                Container(
                                                                  width: 32,
                                                                  height: 34,
                                                                  clipBehavior: Clip.antiAlias,
                                                                  decoration: BoxDecoration(),
                                                                  child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                      Container(
                                                                        width: 17,
                                                                        height: 17,
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
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                width: double.infinity,
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
                                                  spacing: 14,
                                                  children: [
                                                    Container(
                                                      width: double.infinity,
                                                      clipBehavior: Clip.antiAlias,
                                                      decoration: BoxDecoration(),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        spacing: 16,
                                                        children: [
                                                          Container(
                                                            width: 56,
                                                            height: 56,
                                                            decoration: ShapeDecoration(
                                                              image: DecorationImage(
                                                                image: NetworkImage("https://placehold.co/56x56"),
                                                                fit: BoxFit.cover,
                                                              ),
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(12),
                                                              ),
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
                                                                spacing: 6,
                                                                children: [
                                                                  Container(
                                                                    width: double.infinity,
                                                                    clipBehavior: Clip.antiAlias,
                                                                    decoration: BoxDecoration(),
                                                                    child: Row(
                                                                      mainAxisSize: MainAxisSize.min,
                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                      spacing: 10,
                                                                      children: [
                                                                        Text(
                                                                          '牌逢知己',
                                                                          style: TextStyle(
                                                                            color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                                                            fontSize: 16,
                                                                            fontFamily: 'Inter',
                                                                            fontWeight: FontWeight.w500,
                                                                            height: 1.50,
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
                                                                              Container(
                                                                                width: 6,
                                                                                height: 6,
                                                                                decoration: ShapeDecoration(
                                                                                  color: const Color(0xFF74808E),
                                                                                  shape: OvalBorder(),
                                                                                ),
                                                                              ),
                                                                              Text(
                                                                                '离线',
                                                                                style: TextStyle(
                                                                                  color: const Color(0xFF74808E),
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
                                                                  SizedBox(
                                                                    width: 442,
                                                                    child: Text(
                                                                      '最近在线：2小时前',
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
                                                                  Text(
                                                                    'ID 809512',
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
                                                          ),
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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
                                                                  '高手 · 四段',
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
                                                            width: 202,
                                                            clipBehavior: Clip.antiAlias,
                                                            decoration: BoxDecoration(),
                                                            child: Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              spacing: 8,
                                                              children: [
                                                                Container(
                                                                  height: 34,
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
                                                                    spacing: 7,
                                                                    children: [
                                                                      Container(
                                                                        width: 15,
                                                                        height: 15,
                                                                        clipBehavior: Clip.antiAlias,
                                                                        decoration: BoxDecoration(),
                                                                        child: Stack(),
                                                                      ),
                                                                      Text(
                                                                        '聊天',
                                                                        style: TextStyle(
                                                                          color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
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
                                                                  width: 80,
                                                                  height: 34,
                                                                  clipBehavior: Clip.antiAlias,
                                                                  decoration: BoxDecoration(),
                                                                ),
                                                                Container(
                                                                  width: 32,
                                                                  height: 34,
                                                                  clipBehavior: Clip.antiAlias,
                                                                  decoration: BoxDecoration(),
                                                                  child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                      Container(
                                                                        width: 17,
                                                                        height: 17,
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
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                width: double.infinity,
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
                                                  spacing: 14,
                                                  children: [
                                                    Container(
                                                      width: double.infinity,
                                                      clipBehavior: Clip.antiAlias,
                                                      decoration: BoxDecoration(),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        spacing: 16,
                                                        children: [
                                                          Container(
                                                            width: 56,
                                                            height: 56,
                                                            decoration: ShapeDecoration(
                                                              image: DecorationImage(
                                                                image: NetworkImage("https://placehold.co/56x56"),
                                                                fit: BoxFit.cover,
                                                              ),
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(12),
                                                              ),
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
                                                                spacing: 6,
                                                                children: [
                                                                  Container(
                                                                    width: double.infinity,
                                                                    clipBehavior: Clip.antiAlias,
                                                                    decoration: BoxDecoration(),
                                                                    child: Row(
                                                                      mainAxisSize: MainAxisSize.min,
                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                      spacing: 10,
                                                                      children: [
                                                                        Text(
                                                                          '月落乌啼',
                                                                          style: TextStyle(
                                                                            color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                                                            fontSize: 16,
                                                                            fontFamily: 'Inter',
                                                                            fontWeight: FontWeight.w500,
                                                                            height: 1.50,
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
                                                                              Container(
                                                                                width: 6,
                                                                                height: 6,
                                                                                decoration: ShapeDecoration(
                                                                                  color: const Color(0xFF74808E),
                                                                                  shape: OvalBorder(),
                                                                                ),
                                                                              ),
                                                                              Text(
                                                                                '离线',
                                                                                style: TextStyle(
                                                                                  color: const Color(0xFF74808E),
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
                                                                  SizedBox(
                                                                    width: 442,
                                                                    child: Text(
                                                                      '最近在线：昨天',
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
                                                                  Text(
                                                                    'ID 802376',
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
                                                          ),
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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
                                                                  '新秀 · 三段',
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
                                                            width: 202,
                                                            clipBehavior: Clip.antiAlias,
                                                            decoration: BoxDecoration(),
                                                            child: Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              spacing: 8,
                                                              children: [
                                                                Container(
                                                                  height: 34,
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
                                                                    spacing: 7,
                                                                    children: [
                                                                      Container(
                                                                        width: 15,
                                                                        height: 15,
                                                                        clipBehavior: Clip.antiAlias,
                                                                        decoration: BoxDecoration(),
                                                                        child: Stack(),
                                                                      ),
                                                                      Text(
                                                                        '聊天',
                                                                        style: TextStyle(
                                                                          color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
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
                                                                  width: 80,
                                                                  height: 34,
                                                                  clipBehavior: Clip.antiAlias,
                                                                  decoration: BoxDecoration(),
                                                                ),
                                                                Container(
                                                                  width: 32,
                                                                  height: 34,
                                                                  clipBehavior: Clip.antiAlias,
                                                                  decoration: BoxDecoration(),
                                                                  child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                      Container(
                                                                        width: 17,
                                                                        height: 17,
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
                                                      '共 6 位好友 · 在线好友优先显示',
                                                      style: TextStyle(
                                                        color: const Color(0xFF84909E),
                                                        fontSize: 12,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w400,
                                                        height: 1.33,
                                                        letterSpacing: 0.20,
                                                      ),
                                                    ),
                                                    Text(
                                                      '已显示全部好友',
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
                                      ),
                                      Container(
                                        width: 260,
                                        padding: const EdgeInsets.only(top: 14),
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          spacing: 20,
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(20),
                                              clipBehavior: Clip.antiAlias,
                                              decoration: ShapeDecoration(
                                                color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
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
                                                    width: 40,
                                                    height: 40,
                                                    clipBehavior: Clip.antiAlias,
                                                    decoration: ShapeDecoration(
                                                      color: const Color(0x10C9A24B),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                    ),
                                                    child: Stack(
                                                      children: [
                                                        Container(
                                                          width: 20,
                                                          height: 20,
                                                          clipBehavior: Clip.antiAlias,
                                                          decoration: BoxDecoration(),
                                                          child: Stack(),
                                                        ),
                                                        Positioned(
                                                          left: 31,
                                                          top: -2,
                                                          child: Container(
                                                            width: 9,
                                                            height: 9,
                                                            decoration: ShapeDecoration(
                                                              color: const Color(0xFF8A1A2A) /* darkTokens-color-redAccent */,
                                                              shape: OvalBorder(
                                                                side: BorderSide(
                                                                  width: 0.50,
                                                                  color: const Color(0xFFE6C56A) /* darkTokens-color-goldBright */,
                                                                ),
                                                              ),
                                                            ),
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
                                                        spacing: 5,
                                                        children: [
                                                          Text(
                                                            '好友申请',
                                                            style: TextStyle(
                                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                                              fontSize: 16,
                                                              fontFamily: 'Inter',
                                                              fontWeight: FontWeight.w500,
                                                              height: 1.50,
                                                            ),
                                                          ),
                                                          Text(
                                                            '3 位牌友想认识你',
                                                            style: TextStyle(
                                                              color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
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
                                                  ),
                                                  Container(
                                                    width: 17,
                                                    height: 17,
                                                    clipBehavior: Clip.antiAlias,
                                                    decoration: BoxDecoration(),
                                                    child: Stack(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(20),
                                              clipBehavior: Clip.antiAlias,
                                              decoration: ShapeDecoration(
                                                color: const Color(0xFF131A23) /* darkTokens-color-bgPanel */,
                                                shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                    width: 1,
                                                    color: const Color(0x40C9A24B),
                                                  ),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                spacing: 20,
                                                children: [
                                                  Container(
                                                    width: double.infinity,
                                                    clipBehavior: Clip.antiAlias,
                                                    decoration: BoxDecoration(),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      spacing: 10,
                                                      children: [
                                                        Container(
                                                          width: 18,
                                                          height: 18,
                                                          clipBehavior: Clip.antiAlias,
                                                          decoration: BoxDecoration(),
                                                          child: Stack(),
                                                        ),
                                                        Text(
                                                          '我的房间',
                                                          style: TextStyle(
                                                            color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
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
                                                    clipBehavior: Clip.antiAlias,
                                                    decoration: BoxDecoration(),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      spacing: 8,
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
                                                          '经典80分 · 好友房',
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
                                                      spacing: 9,
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
                                                            color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
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
                                                            color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
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
                                                            color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
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
                                                  SizedBox(
                                                    width: 220,
                                                    child: Text(
                                                      '还差 3 位牌友即可开局，点击好友旁的「邀请入房」一起玩。',
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
                                                  Container(
                                                    height: 44,
                                                    padding: const EdgeInsets.symmetric(horizontal: 18),
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
                                                          '返回房间',
                                                          style: TextStyle(
                                                            color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
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
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.symmetric(horizontal: 4),
                                              clipBehavior: Clip.antiAlias,
                                              decoration: BoxDecoration(),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                spacing: 8,
                                                children: [
                                                  Container(
                                                    width: 14,
                                                    height: 14,
                                                    clipBehavior: Clip.antiAlias,
                                                    decoration: BoxDecoration(),
                                                    child: Stack(),
                                                  ),
                                                  SizedBox(
                                                    width: 230,
                                                    child: Text(
                                                      '仅展示好友公开的大厅与房间信息，尊重每一位牌友的隐私。',
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
        ),
      ],
    );
  }
}