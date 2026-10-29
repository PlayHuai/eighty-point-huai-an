class Register extends StatelessWidget {
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
          child: Stack(
            children: [
              Positioned(
                left: -120,
                top: -120,
                child: Opacity(
                  opacity: 0.04,
                  child: Container(
                    width: 360,
                    height: 360,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                      shape: OvalBorder(),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 1160,
                top: 520,
                child: Opacity(
                  opacity: 0.03,
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                      shape: OvalBorder(),
                    ),
                  ),
                ),
              ),
              Container(
                width: 420,
                padding: const EdgeInsets.all(40),
                decoration: ShapeDecoration(
                  color: const Color(0xFF131A23) /* darkTokens-color-bgPanel */,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1,
                      color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  shadows: [
                    BoxShadow(
                      color: Color(0x66000000),
                      blurRadius: 32,
                      offset: Offset(0, 16),
                      spreadRadius: -8,
                    )BoxShadow(
                      color: Color(0x40000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                      spreadRadius: -4,
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 16,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: ShapeDecoration(
                              color: const Color(0xFF0A0E13) /* darkTokens-color-bgBase */,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Stack(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(),
                                  child: Stack(),
                                ),
                                Positioned(
                                  left: 16,
                                  top: 16,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(),
                                    child: Stack(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 340,
                            child: Text(
                              '淮安80分',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                fontSize: 40,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 340,
                            child: Text(
                              '注册账号并开始使用',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
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
                        spacing: 16,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: ShapeDecoration(
                              color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
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
                                  width: 276,
                                  child: Text(
                                    '请输入账号',
                                    style: TextStyle(
                                      color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: ShapeDecoration(
                              color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
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
                                  width: 244,
                                  child: Text(
                                    '请输入密码（≥8位含字母数字）',
                                    style: TextStyle(
                                      color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
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
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 4,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          height: 6,
                                          decoration: ShapeDecoration(
                                            color: const Color(0xFFBF382A) /* darkTokens-color-suitRed */,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(999),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 6,
                                          decoration: ShapeDecoration(
                                            color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(999),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 6,
                                          decoration: ShapeDecoration(
                                            color: const Color(0xFFE6C56A) /* darkTokens-color-goldBright */,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(999),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 340,
                                  child: Text(
                                    '弱 → 中 → 强（建议使用字母、数字和特殊字符）',
                                    style: TextStyle(
                                      color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: ShapeDecoration(
                              color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
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
                                  width: 244,
                                  child: Text(
                                    '请再次输入密码',
                                    style: TextStyle(
                                      color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
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
                          Container(
                            width: double.infinity,
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: ShapeDecoration(
                              color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
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
                                  width: 276,
                                  child: Text(
                                    '请输入昵称',
                                    style: TextStyle(
                                      color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
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
                              spacing: 12,
                              children: [
                                SizedBox(
                                  width: 340,
                                  child: Text(
                                    '选择头像',
                                    style: TextStyle(
                                      color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 12,
                                    children: [
                                      Container(
                                        width: 64,
                                        height: 64,
                                        decoration: ShapeDecoration(
                                          color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                              width: 2,
                                              color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                            ),
                                            borderRadius: BorderRadius.circular(32),
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 56,
                                              height: 56,
                                              decoration: ShapeDecoration(
                                                color: const Color(0xFF0A0E13) /* darkTokens-color-bgBase */,
                                                shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                    width: 1,
                                                    color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                                  ),
                                                  borderRadius: BorderRadius.circular(28),
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
                                      Container(
                                        width: 64,
                                        height: 64,
                                        decoration: ShapeDecoration(
                                          color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                              width: 1,
                                              color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                            ),
                                            borderRadius: BorderRadius.circular(32),
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 56,
                                              height: 56,
                                              decoration: ShapeDecoration(
                                                color: const Color(0xFF0A0E13) /* darkTokens-color-bgBase */,
                                                shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                    width: 1,
                                                    color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                                  ),
                                                  borderRadius: BorderRadius.circular(28),
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
                                      Container(
                                        width: 64,
                                        height: 64,
                                        decoration: ShapeDecoration(
                                          color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                              width: 1,
                                              color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                            ),
                                            borderRadius: BorderRadius.circular(32),
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 56,
                                              height: 56,
                                              decoration: ShapeDecoration(
                                                color: const Color(0xFF0A0E13) /* darkTokens-color-bgBase */,
                                                shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                    width: 1,
                                                    color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                                  ),
                                                  borderRadius: BorderRadius.circular(28),
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
                                      Container(
                                        width: 64,
                                        height: 64,
                                        decoration: ShapeDecoration(
                                          color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                              width: 1,
                                              color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                            ),
                                            borderRadius: BorderRadius.circular(32),
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 56,
                                              height: 56,
                                              decoration: ShapeDecoration(
                                                color: const Color(0xFF0A0E13) /* darkTokens-color-bgBase */,
                                                shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                    width: 1,
                                                    color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                                                  ),
                                                  borderRadius: BorderRadius.circular(28),
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
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: ShapeDecoration(
                              color: const Color(0xFF1C242F) /* darkTokens-color-bgCard */,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: const Color(0xFFBF382A) /* darkTokens-color-suitRed */,
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
                                SizedBox(
                                  width: 276,
                                  child: Text(
                                    '请输入账号',
                                    style: TextStyle(
                                      color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: ShapeDecoration(
                              color: const Color(0xFF3A1614),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: const Color(0xFFBF382A) /* darkTokens-color-suitRed */,
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
                                Container(
                                  width: 16,
                                  height: 16,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(),
                                  child: Stack(),
                                ),
                                SizedBox(
                                  width: 292,
                                  child: Text(
                                    '账号已存在，请换一个账号',
                                    style: TextStyle(
                                      color: const Color(0xFFBF382A) /* darkTokens-color-suitRed */,
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
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
                      height: 52,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFC9A24B) /* darkTokens-color-goldPrimary */,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '注册',
                            style: TextStyle(
                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 340,
                      child: Text(
                        '已有账号，去登录',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 703.50,
                top: 853,
                child: Text(
                  'v1.0.0',
                  style: TextStyle(
                    color: const Color(0xFF595648) /* darkTokens-color-textDisabled */,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
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