class FriendprofileDesktop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 1440,
          padding: const EdgeInsets.all(48),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0E13) /* darkTokens-color-bgBase */,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 48,
            children: [
              Container(
                width: 1000,
                padding: const EdgeInsets.all(32),
                decoration: ShapeDecoration(
                  color: const Color(0xFF131A23) /* darkTokens-color-bgPanel */,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  shadows: [
                    BoxShadow(
                      color: Color(0x66000000),
                      blurRadius: 24,
                      offset: Offset(0, 12),
                      spreadRadius: 0,
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 24,
                  children: [
                    Container(
                      width: double.infinity,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 20,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: ShapeDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage("https://placehold.co/80x80"),
                                    fit: BoxFit.cover,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      width: 2,
                                      color: const Color(0xFFC9A24B),
                                    ),
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 6,
                                children: [
                                  Text(
                                    '淮上牌友',
                                    style: TextStyle(
                                      color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                      fontSize: 24,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    clipBehavior: Clip.antiAlias,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFF302C21),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '黄金 III',
                                          style: TextStyle(
                                            color: const Color(0xFFE6C56A) /* darkTokens-color-goldBright */,
                                            fontSize: 12,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    spacing: 8,
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: ShapeDecoration(
                                          color: const Color(0xFF497BA5) /* darkTokens-color-infoBlue */,
                                          shape: OvalBorder(),
                                        ),
                                      ),
                                      Text(
                                        '在线',
                                        style: TextStyle(
                                          color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                          fontSize: 14,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 12,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: ShapeDecoration(
                                  color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      width: 1,
                                      color: const Color(0xFF929EAC),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '聊天',
                                      style: TextStyle(
                                        color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                        fontSize: 14,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: ShapeDecoration(
                                  color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '邀请',
                                      style: TextStyle(
                                        color: const Color(0xFF0A0E13) /* darkTokens-color-bgBase */,
                                        fontSize: 14,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: ShapeDecoration(
                                  color: const Color(0xFF8B1A2B),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '删除',
                                      style: TextStyle(
                                        color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                        fontSize: 14,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: ShapeDecoration(
                        color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 8,
                            children: [
                              Text(
                                '总场数',
                                style: TextStyle(
                                  color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                '128',
                                style: TextStyle(
                                  color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                  fontSize: 24,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 8,
                            children: [
                              Text(
                                '胜场',
                                style: TextStyle(
                                  color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                '84',
                                style: TextStyle(
                                  color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                  fontSize: 24,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 8,
                            children: [
                              Text(
                                '负场',
                                style: TextStyle(
                                  color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                '44',
                                style: TextStyle(
                                  color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                  fontSize: 24,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 8,
                            children: [
                              Text(
                                '胜率',
                                style: TextStyle(
                                  color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                '65.6%',
                                style: TextStyle(
                                  color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                  fontSize: 24,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 8,
                            children: [
                              Text(
                                '当前积分',
                                style: TextStyle(
                                  color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                '1,240',
                                style: TextStyle(
                                  color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                  fontSize: 24,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 8,
                            children: [
                              Text(
                                '段位',
                                style: TextStyle(
                                  color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                '黄金 III',
                                style: TextStyle(
                                  color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                  fontSize: 24,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 16,
                        children: [
                          Text(
                            '最近战绩 · 20局',
                            style: TextStyle(
                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                              fontSize: 18,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '对手 / 级差',
                                  style: TextStyle(
                                    color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                    fontSize: 12,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '胜负 / 积分变动',
                                  style: TextStyle(
                                    color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                    fontSize: 12,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 8,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 12,
                                        children: [
                                          Text(
                                            '小白',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '级差 +2',
                                            style: TextStyle(
                                              color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 24,
                                        children: [
                                          Text(
                                            '胜',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '+12',
                                            style: TextStyle(
                                              color: const Color(0xFFE6C56A) /* darkTokens-color-goldBright */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 12,
                                        children: [
                                          Text(
                                            '老王',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '级差 -1',
                                            style: TextStyle(
                                              color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 24,
                                        children: [
                                          Text(
                                            '负',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '-8',
                                            style: TextStyle(
                                              color: const Color(0xFFB3273D) /* darkTokens-color-redBright */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 12,
                                        children: [
                                          Text(
                                            '小明',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '级差 +0',
                                            style: TextStyle(
                                              color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 24,
                                        children: [
                                          Text(
                                            '胜',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '+15',
                                            style: TextStyle(
                                              color: const Color(0xFFE6C56A) /* darkTokens-color-goldBright */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 12,
                                        children: [
                                          Text(
                                            '小红',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '级差 -2',
                                            style: TextStyle(
                                              color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 24,
                                        children: [
                                          Text(
                                            '负',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '-12',
                                            style: TextStyle(
                                              color: const Color(0xFFB3273D) /* darkTokens-color-redBright */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 12,
                                        children: [
                                          Text(
                                            '小蓝',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '级差 +1',
                                            style: TextStyle(
                                              color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 24,
                                        children: [
                                          Text(
                                            '胜',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '+10',
                                            style: TextStyle(
                                              color: const Color(0xFFE6C56A) /* darkTokens-color-goldBright */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 12,
                                        children: [
                                          Text(
                                            '小绿',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '级差 -3',
                                            style: TextStyle(
                                              color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 24,
                                        children: [
                                          Text(
                                            '负',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '-15',
                                            style: TextStyle(
                                              color: const Color(0xFFB3273D) /* darkTokens-color-redBright */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 12,
                                        children: [
                                          Text(
                                            '小黄',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '级差 +0',
                                            style: TextStyle(
                                              color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 24,
                                        children: [
                                          Text(
                                            '胜',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '+12',
                                            style: TextStyle(
                                              color: const Color(0xFFE6C56A) /* darkTokens-color-goldBright */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 12,
                                        children: [
                                          Text(
                                            '小紫',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '级差 -1',
                                            style: TextStyle(
                                              color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 24,
                                        children: [
                                          Text(
                                            '负',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '-8',
                                            style: TextStyle(
                                              color: const Color(0xFFB3273D) /* darkTokens-color-redBright */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 12,
                                        children: [
                                          Text(
                                            '小橙',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '级差 +2',
                                            style: TextStyle(
                                              color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 24,
                                        children: [
                                          Text(
                                            '胜',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '+15',
                                            style: TextStyle(
                                              color: const Color(0xFFE6C56A) /* darkTokens-color-goldBright */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 12,
                                        children: [
                                          Text(
                                            '小黑',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '级差 -2',
                                            style: TextStyle(
                                              color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 24,
                                        children: [
                                          Text(
                                            '负',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '-12',
                                            style: TextStyle(
                                              color: const Color(0xFFB3273D) /* darkTokens-color-redBright */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 12,
                                        children: [
                                          Text(
                                            '小灰',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '级差 +1',
                                            style: TextStyle(
                                              color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 24,
                                        children: [
                                          Text(
                                            '胜',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '+10',
                                            style: TextStyle(
                                              color: const Color(0xFFE6C56A) /* darkTokens-color-goldBright */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 12,
                                        children: [
                                          Text(
                                            '小白',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '级差 -3',
                                            style: TextStyle(
                                              color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 24,
                                        children: [
                                          Text(
                                            '负',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '-15',
                                            style: TextStyle(
                                              color: const Color(0xFFB3273D) /* darkTokens-color-redBright */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 12,
                                        children: [
                                          Text(
                                            '小白',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '级差 +2',
                                            style: TextStyle(
                                              color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 24,
                                        children: [
                                          Text(
                                            '胜',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '+12',
                                            style: TextStyle(
                                              color: const Color(0xFFE6C56A) /* darkTokens-color-goldBright */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 12,
                                        children: [
                                          Text(
                                            '小白',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '级差 -1',
                                            style: TextStyle(
                                              color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 24,
                                        children: [
                                          Text(
                                            '负',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '-8',
                                            style: TextStyle(
                                              color: const Color(0xFFB3273D) /* darkTokens-color-redBright */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 12,
                                        children: [
                                          Text(
                                            '小白',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '级差 +0',
                                            style: TextStyle(
                                              color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 24,
                                        children: [
                                          Text(
                                            '胜',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '+15',
                                            style: TextStyle(
                                              color: const Color(0xFFE6C56A) /* darkTokens-color-goldBright */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 12,
                                        children: [
                                          Text(
                                            '小白',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '级差 -2',
                                            style: TextStyle(
                                              color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 24,
                                        children: [
                                          Text(
                                            '负',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '-12',
                                            style: TextStyle(
                                              color: const Color(0xFFB3273D) /* darkTokens-color-redBright */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 12,
                                        children: [
                                          Text(
                                            '小蓝',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '级差 +1',
                                            style: TextStyle(
                                              color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 24,
                                        children: [
                                          Text(
                                            '胜',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '+10',
                                            style: TextStyle(
                                              color: const Color(0xFFE6C56A) /* darkTokens-color-goldBright */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 12,
                                        children: [
                                          Text(
                                            '老王',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '级差 -3',
                                            style: TextStyle(
                                              color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 24,
                                        children: [
                                          Text(
                                            '负',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '-15',
                                            style: TextStyle(
                                              color: const Color(0xFFB3273D) /* darkTokens-color-redBright */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 12,
                                        children: [
                                          Text(
                                            '小明',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '级差 +2',
                                            style: TextStyle(
                                              color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 24,
                                        children: [
                                          Text(
                                            '胜',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '+12',
                                            style: TextStyle(
                                              color: const Color(0xFFE6C56A) /* darkTokens-color-goldBright */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 12,
                                        children: [
                                          Text(
                                            '小红',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '级差 +0',
                                            style: TextStyle(
                                              color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 24,
                                        children: [
                                          Text(
                                            '胜',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '+15',
                                            style: TextStyle(
                                              color: const Color(0xFFE6C56A) /* darkTokens-color-goldBright */,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
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
            ],
          ),
        ),
      ],
    );
  }
}