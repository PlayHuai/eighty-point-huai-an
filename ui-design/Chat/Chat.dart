class Chat extends StatelessWidget {
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
                height: 72,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: const Color(0xFF131A23) /* darkTokens-color-bgPanel */,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1,
                      color: const Color(0xFF1C2530),
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
                            width: 40,
                            height: 40,
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
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
                              spacing: 12,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Text(
                                        '周',
                                        style: TextStyle(
                                          color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                          fontSize: 16,
                                          fontFamily: 'Noto Sans SC',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Positioned(
                                        left: 32,
                                        top: 0,
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: ShapeDecoration(
                                            color: const Color(0xFFEA5B65),
                                            shape: OvalBorder(),
                                          ),
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
                                    spacing: 2,
                                    children: [
                                      Text(
                                        '牌友 · 老周',
                                        style: TextStyle(
                                          color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                          fontSize: 16,
                                          fontFamily: 'Noto Sans SC',
                                          fontWeight: FontWeight.w700,
                                          height: 1.38,
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
                                              width: 8,
                                              height: 8,
                                              decoration: ShapeDecoration(
                                                color: const Color(0xFF7C8798),
                                                shape: OvalBorder(),
                                              ),
                                            ),
                                            Text(
                                              '离线',
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
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 12,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(),
                                  child: Stack(),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 36,
                            height: 36,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
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
                        width: 280,
                        height: double.infinity,
                        clipBehavior: Clip.antiAlias,
                        decoration: ShapeDecoration(
                          color: const Color(0xFF131A23) /* darkTokens-color-bgPanel */,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1,
                              color: const Color(0xFF1C2530),
                            ),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 64,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '消息',
                                    style: TextStyle(
                                      color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                      height: 1.43,
                                    ),
                                  ),
                                  Container(
                                    width: 32,
                                    height: 32,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 16,
                                          height: 16,
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
                            Container(
                              width: double.infinity,
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 2,
                                children: [
                                  Container(
                                    width: 18,
                                    height: 18,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(),
                                    child: Stack(),
                                  ),
                                  SizedBox(
                                    width: 228,
                                    child: Text(
                                      '搜索聊天',
                                      style: TextStyle(
                                        color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                        fontSize: 14,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        height: 1.43,
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
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
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
                                          decoration: ShapeDecoration(
                                            color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                '周',
                                                style: TextStyle(
                                                  color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                                  fontSize: 16,
                                                  fontFamily: 'Noto Sans SC',
                                                  fontWeight: FontWeight.w700,
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
                                                SizedBox(
                                                  width: 164,
                                                  child: Text(
                                                    '牌友 · 老周',
                                                    style: TextStyle(
                                                      color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                                      fontSize: 14,
                                                      fontFamily: 'Inter',
                                                      fontWeight: FontWeight.w700,
                                                      height: 1.43,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  '今天 14:20',
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
                                          width: 20,
                                          height: 20,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: ShapeDecoration(
                                            color: const Color(0xFFEA5B65),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
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
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w700,
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
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF131A23) /* darkTokens-color-bgPanel */,
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
                                          decoration: ShapeDecoration(
                                            color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                '周',
                                                style: TextStyle(
                                                  color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                                  fontSize: 16,
                                                  fontFamily: 'Noto Sans SC',
                                                  fontWeight: FontWeight.w700,
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
                                                SizedBox(
                                                  width: 196,
                                                  child: Text(
                                                    '小红书',
                                                    style: TextStyle(
                                                      color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                                      fontSize: 14,
                                                      fontFamily: 'Inter',
                                                      fontWeight: FontWeight.w500,
                                                      height: 1.43,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  '昨天 20:15',
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
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF131A23) /* darkTokens-color-bgPanel */,
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
                                          decoration: ShapeDecoration(
                                            color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                '周',
                                                style: TextStyle(
                                                  color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                                  fontSize: 16,
                                                  fontFamily: 'Noto Sans SC',
                                                  fontWeight: FontWeight.w700,
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
                                                SizedBox(
                                                  width: 196,
                                                  child: Text(
                                                    '代码君',
                                                    style: TextStyle(
                                                      color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                                      fontSize: 14,
                                                      fontFamily: 'Inter',
                                                      fontWeight: FontWeight.w500,
                                                      height: 1.43,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  '3月10日',
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
                          height: double.infinity,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 40,
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF131A23) /* darkTokens-color-bgPanel */,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 1112,
                                      child: Text(
                                        '对方离线，消息将在上线后送达',
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
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 18,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '今天 14:20',
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
                                      Container(
                                        width: double.infinity,
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          spacing: 12,
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: ShapeDecoration(
                                                color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    '周',
                                                    style: TextStyle(
                                                      color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                                      fontSize: 16,
                                                      fontFamily: 'Noto Sans SC',
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: 320,
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                              clipBehavior: Clip.antiAlias,
                                              decoration: ShapeDecoration(
                                                color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(16),
                                                    topRight: Radius.circular(16),
                                                    bottomLeft: Radius.circular(4),
                                                    bottomRight: Radius.circular(16),
                                                  ),
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                spacing: 6,
                                                children: [
                                                  SizedBox(
                                                    width: 288,
                                                    child: Text(
                                                      '今晚还打80分吗？老地方等你。',
                                                      style: TextStyle(
                                                        color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                                        fontSize: 14,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w400,
                                                        height: 1.43,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    '14:20',
                                                    style: TextStyle(
                                                      color: const Color(0xFFAAB2BE),
                                                      fontSize: 11,
                                                      fontFamily: 'Noto Sans SC',
                                                      fontWeight: FontWeight.w400,
                                                      height: 1.27,
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
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          spacing: 12,
                                          children: [
                                            Container(
                                              width: 320,
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                              clipBehavior: Clip.antiAlias,
                                              decoration: ShapeDecoration(
                                                color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(16),
                                                    topRight: Radius.circular(16),
                                                    bottomLeft: Radius.circular(16),
                                                    bottomRight: Radius.circular(4),
                                                  ),
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                spacing: 6,
                                                children: [
                                                  SizedBox(
                                                    width: 288,
                                                    child: Text(
                                                      '当然！我吃完饭就来，给我留个位。',
                                                      style: TextStyle(
                                                        color: const Color(0xFF0A0E13) /* darkTokens-color-bgBase */,
                                                        fontSize: 14,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w400,
                                                        height: 1.43,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    '14:22',
                                                    style: TextStyle(
                                                      color: const Color(0xFF131A23) /* darkTokens-color-bgPanel */,
                                                      fontSize: 11,
                                                      fontFamily: 'Noto Sans SC',
                                                      fontWeight: FontWeight.w400,
                                                      height: 1.27,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: ShapeDecoration(
                                                color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    '我',
                                                    style: TextStyle(
                                                      color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                                      fontSize: 16,
                                                      fontFamily: 'Noto Sans SC',
                                                      fontWeight: FontWeight.w700,
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
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          spacing: 12,
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: ShapeDecoration(
                                                color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    '周',
                                                    style: TextStyle(
                                                      color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                                      fontSize: 16,
                                                      fontFamily: 'Noto Sans SC',
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: 320,
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                              clipBehavior: Clip.antiAlias,
                                              decoration: ShapeDecoration(
                                                color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(16),
                                                    topRight: Radius.circular(16),
                                                    bottomLeft: Radius.circular(4),
                                                    bottomRight: Radius.circular(16),
                                                  ),
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                spacing: 6,
                                                children: [
                                                  SizedBox(
                                                    width: 288,
                                                    child: Text(
                                                      '没问题，还是咱俩搭档，默契拿分。',
                                                      style: TextStyle(
                                                        color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                                        fontSize: 14,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w400,
                                                        height: 1.43,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    '14:24',
                                                    style: TextStyle(
                                                      color: const Color(0xFFAAB2BE),
                                                      fontSize: 11,
                                                      fontFamily: 'Noto Sans SC',
                                                      fontWeight: FontWeight.w400,
                                                      height: 1.27,
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
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          spacing: 12,
                                          children: [
                                            Container(
                                              width: 320,
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                              clipBehavior: Clip.antiAlias,
                                              decoration: ShapeDecoration(
                                                color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(16),
                                                    topRight: Radius.circular(16),
                                                    bottomLeft: Radius.circular(16),
                                                    bottomRight: Radius.circular(4),
                                                  ),
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                spacing: 6,
                                                children: [
                                                  SizedBox(
                                                    width: 288,
                                                    child: Text(
                                                      '好，今天争取一把过A！',
                                                      style: TextStyle(
                                                        color: const Color(0xFF0A0E13) /* darkTokens-color-bgBase */,
                                                        fontSize: 14,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w400,
                                                        height: 1.43,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    '14:25',
                                                    style: TextStyle(
                                                      color: const Color(0xFF131A23) /* darkTokens-color-bgPanel */,
                                                      fontSize: 11,
                                                      fontFamily: 'Noto Sans SC',
                                                      fontWeight: FontWeight.w400,
                                                      height: 1.27,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: ShapeDecoration(
                                                color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    '我',
                                                    style: TextStyle(
                                                      color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                                      fontSize: 16,
                                                      fontFamily: 'Noto Sans SC',
                                                      fontWeight: FontWeight.w700,
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
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          spacing: 12,
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: ShapeDecoration(
                                                color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    '周',
                                                    style: TextStyle(
                                                      color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                                      fontSize: 16,
                                                      fontFamily: 'Noto Sans SC',
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: 320,
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                              clipBehavior: Clip.antiAlias,
                                              decoration: ShapeDecoration(
                                                color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(16),
                                                    topRight: Radius.circular(16),
                                                    bottomLeft: Radius.circular(4),
                                                    bottomRight: Radius.circular(16),
                                                  ),
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                spacing: 6,
                                                children: [
                                                  SizedBox(
                                                    width: 288,
                                                    child: Text(
                                                      '我先下线一会儿，七点见。',
                                                      style: TextStyle(
                                                        color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                                        fontSize: 14,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w400,
                                                        height: 1.43,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    '14:26',
                                                    style: TextStyle(
                                                      color: const Color(0xFFAAB2BE),
                                                      fontSize: 11,
                                                      fontFamily: 'Noto Sans SC',
                                                      fontWeight: FontWeight.w400,
                                                      height: 1.27,
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
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          spacing: 12,
                                          children: [
                                            Container(
                                              width: 320,
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                              clipBehavior: Clip.antiAlias,
                                              decoration: ShapeDecoration(
                                                color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(16),
                                                    topRight: Radius.circular(16),
                                                    bottomLeft: Radius.circular(16),
                                                    bottomRight: Radius.circular(4),
                                                  ),
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                spacing: 6,
                                                children: [
                                                  SizedBox(
                                                    width: 288,
                                                    child: Text(
                                                      '收到，上线后喊我。',
                                                      style: TextStyle(
                                                        color: const Color(0xFF0A0E13) /* darkTokens-color-bgBase */,
                                                        fontSize: 14,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w400,
                                                        height: 1.43,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    '14:30 · 待送达',
                                                    style: TextStyle(
                                                      color: const Color(0xFF131A23) /* darkTokens-color-bgPanel */,
                                                      fontSize: 11,
                                                      fontFamily: 'Noto Sans SC',
                                                      fontWeight: FontWeight.w400,
                                                      height: 1.27,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: ShapeDecoration(
                                                color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    '我',
                                                    style: TextStyle(
                                                      color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                                      fontSize: 16,
                                                      fontFamily: 'Noto Sans SC',
                                                      fontWeight: FontWeight.w700,
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
                              Container(
                                width: double.infinity,
                                height: 80,
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  color: const Color(0xFF131A23) /* darkTokens-color-bgPanel */,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      width: 1,
                                      color: const Color(0xFF1C2530),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 16,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 48,
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        clipBehavior: Clip.antiAlias,
                                        decoration: ShapeDecoration(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
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
                                            SizedBox(
                                              width: 952,
                                              child: Text(
                                                '输入消息...',
                                                style: TextStyle(
                                                  color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                                  fontSize: 14,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w400,
                                                  height: 1.43,
                                                ),
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
                                    ),
                                    Container(
                                      width: 48,
                                      height: 48,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
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