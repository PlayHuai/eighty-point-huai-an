class Gametable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 1449,
          height: 918,
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
                padding: const EdgeInsets.symmetric(horizontal: 32),
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1, color: const Color(0xFF2C3035)),
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
                        spacing: 18,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(),
                            child: Stack(),
                          ),
                          Container(
                            width: 36,
                            height: 36,
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: const Color(
                                    0xFFC9A24B,
                                  ) /* goldPrimary */,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '80',
                                  style: TextStyle(
                                    color: const Color(
                                      0xFFC9A24B,
                                    ) /* goldPrimary */,
                                    fontSize: 22,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '淮安80分',
                            style: TextStyle(
                              color: const Color(
                                0xFFEDE8DB,
                              ) /* darkTokens-color-textPrimary */,
                              fontSize: 24,
                              fontFamily: 'Noto Sans SC',
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
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
                        spacing: 28,
                        children: [
                          Text(
                            '好友房  8026  ·  第 03 局',
                            style: TextStyle(
                              color: const Color(
                                0xFF9A917E,
                              ) /* darkTokens-color-textSecondary */,
                              fontSize: 13,
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
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                height: 88,
                padding: const EdgeInsets.symmetric(horizontal: 40),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFF131A23) /* darkTokens-color-bgPanel */,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 657.50,
                      top: 33,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 16,
                        children: [
                          Text(
                            '我方A',
                            style: TextStyle(
                              color: const Color(
                                0xFF9A917E,
                              ) /* darkTokens-color-textSecondary */,
                              fontSize: 18,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            ':',
                            style: TextStyle(
                              color: const Color(
                                0xFF9A917E,
                              ) /* darkTokens-color-textSecondary */,
                              fontSize: 18,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            '对方8',
                            style: TextStyle(
                              color: const Color(
                                0xFF9A917E,
                              ) /* darkTokens-color-textSecondary */,
                              fontSize: 18,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 1322,
                      top: 29.50,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 12,
                        children: [
                          Text(
                            '得分：',
                            style: TextStyle(
                              color: const Color(
                                0xFF9A917E,
                              ) /* darkTokens-color-textSecondary */,
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            '40',
                            style: TextStyle(
                              color: const Color(
                                0xFFEDE8DB,
                              ) /* darkTokens-color-textPrimary */,
                              fontSize: 24,
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
                width: 1449,
                height: 474,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0E13) /* darkTokens-color-bgBase */,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 210,
                      top: 65,
                      child: Container(
                        width: 1020,
                        height: 330,
                        decoration: ShapeDecoration(
                          color: const Color(0xFF31151E),
                          shape: OvalBorder(
                            side: BorderSide(
                              width: 1.20,
                              color: const Color(0xFFC9A24B) /* goldPrimary */,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 218,
                      top: 73,
                      child: Opacity(
                        opacity: 0.32,
                        child: Container(
                          width: 1004,
                          height: 314,
                          decoration: ShapeDecoration(
                            color: const Color(
                              0xFF8A1A2A,
                            ) /* darkTokens-color-redAccent */,
                            shape: OvalBorder(),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 227,
                      top: 81,
                      child: Opacity(
                        opacity: 0.23,
                        child: Container(
                          width: 986,
                          height: 298,
                          decoration: ShapeDecoration(
                            shape: OvalBorder(
                              side: BorderSide(
                                width: 0.50,
                                color: const Color(
                                  0xFFC9A24B,
                                ) /* goldPrimary */,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 53,
                      top: 380,
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 260,
                              height: 92,
                              padding: const EdgeInsets.all(12),
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: const Color(
                                  0xFF131A23,
                                ) /* darkTokens-color-bgPanel */,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    color: const Color(0xFF2C3035),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '底牌 · 8 张',
                                          style: TextStyle(
                                            color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
                                            fontSize: 12,
                                            fontFamily: 'Noto Sans SC',
                                            fontWeight: FontWeight.w400,
                                            height: 1.40,
                                          ),
                                        ),
                                        Text(
                                          '已扣底 · 未公开',
                                          style: TextStyle(
                                            color: const Color(
                                              0xFFC9A24B,
                                            ) /* goldPrimary */,
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
                                    width: 234,
                                    height: 40,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          left: 203,
                                          top: 0,
                                          child: Container(
                                            width: 24.18,
                                            height: 34.32,
                                            decoration: ShapeDecoration(
                                              color: const Color(
                                                0xFF22303E,
                                              ) /* cardBack */,
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 0.39,
                                                  color: const Color(
                                                    0xFFC9A24B,
                                                  ) /* goldPrimary */,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(3.12),
                                              ),
                                            ),
                                            child: Stack(
                                              children: [
                                                Positioned(
                                                  left: 1.17,
                                                  top: 1.17,
                                                  child: Container(
                                                    width: 21.84,
                                                    height: 31.98,
                                                    decoration: ShapeDecoration(
                                                      shape: RoundedRectangleBorder(
                                                        side: BorderSide(
                                                          width: 0.29,
                                                          color: const Color(
                                                            0xFFC9A24B,
                                                          ) /* goldPrimary */,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              1.95,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 3.90,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 7.02,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 10.14,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 13.26,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 16.38,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 19.50,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 22.62,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 25.74,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 28.86,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 31.98,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 12.09,
                                                  top: 14.11,
                                                  child: Container(
                                                    transform:
                                                        Matrix4.identity()
                                                          ..translate(0.0, 0.0)
                                                          ..rotateZ(-0.79),
                                                    width: 10.82,
                                                    height: 4,
                                                    decoration: ShapeDecoration(
                                                      shape: RoundedRectangleBorder(
                                                        side: BorderSide(
                                                          width: 0.29,
                                                          color: const Color(
                                                            0xFFC9A24B,
                                                          ) /* goldPrimary */,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              0.78,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 11.90,
                                                  top: 10.92,
                                                  child: Container(
                                                    width: 0.39,
                                                    height: 12.48,
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFC9A24B,
                                                      ) /* goldPrimary */,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 8.97,
                                                  top: 16.96,
                                                  child: Container(
                                                    width: 6.24,
                                                    height: 0.39,
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFC9A24B,
                                                      ) /* goldPrimary */,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 174,
                                          top: 0,
                                          child: Container(
                                            width: 24.18,
                                            height: 34.32,
                                            decoration: ShapeDecoration(
                                              color: const Color(
                                                0xFF22303E,
                                              ) /* cardBack */,
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 0.39,
                                                  color: const Color(
                                                    0xFFC9A24B,
                                                  ) /* goldPrimary */,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(3.12),
                                              ),
                                            ),
                                            child: Stack(
                                              children: [
                                                Positioned(
                                                  left: 1.17,
                                                  top: 1.17,
                                                  child: Container(
                                                    width: 21.84,
                                                    height: 31.98,
                                                    decoration: ShapeDecoration(
                                                      shape: RoundedRectangleBorder(
                                                        side: BorderSide(
                                                          width: 0.29,
                                                          color: const Color(
                                                            0xFFC9A24B,
                                                          ) /* goldPrimary */,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              1.95,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 3.90,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 7.02,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 10.14,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 13.26,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 16.38,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 19.50,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 22.62,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 25.74,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 28.86,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 31.98,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 12.09,
                                                  top: 14.11,
                                                  child: Container(
                                                    transform:
                                                        Matrix4.identity()
                                                          ..translate(0.0, 0.0)
                                                          ..rotateZ(-0.79),
                                                    width: 10.82,
                                                    height: 4,
                                                    decoration: ShapeDecoration(
                                                      shape: RoundedRectangleBorder(
                                                        side: BorderSide(
                                                          width: 0.29,
                                                          color: const Color(
                                                            0xFFC9A24B,
                                                          ) /* goldPrimary */,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              0.78,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 11.90,
                                                  top: 10.92,
                                                  child: Container(
                                                    width: 0.39,
                                                    height: 12.48,
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFC9A24B,
                                                      ) /* goldPrimary */,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 8.97,
                                                  top: 16.96,
                                                  child: Container(
                                                    width: 6.24,
                                                    height: 0.39,
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFC9A24B,
                                                      ) /* goldPrimary */,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 145,
                                          top: 0,
                                          child: Container(
                                            width: 24.18,
                                            height: 34.32,
                                            decoration: ShapeDecoration(
                                              color: const Color(
                                                0xFF22303E,
                                              ) /* cardBack */,
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 0.39,
                                                  color: const Color(
                                                    0xFFC9A24B,
                                                  ) /* goldPrimary */,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(3.12),
                                              ),
                                            ),
                                            child: Stack(
                                              children: [
                                                Positioned(
                                                  left: 1.17,
                                                  top: 1.17,
                                                  child: Container(
                                                    width: 21.84,
                                                    height: 31.98,
                                                    decoration: ShapeDecoration(
                                                      shape: RoundedRectangleBorder(
                                                        side: BorderSide(
                                                          width: 0.29,
                                                          color: const Color(
                                                            0xFFC9A24B,
                                                          ) /* goldPrimary */,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              1.95,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 3.90,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 7.02,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 10.14,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 13.26,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 16.38,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 19.50,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 22.62,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 25.74,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 28.86,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 31.98,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 12.09,
                                                  top: 14.11,
                                                  child: Container(
                                                    transform:
                                                        Matrix4.identity()
                                                          ..translate(0.0, 0.0)
                                                          ..rotateZ(-0.79),
                                                    width: 10.82,
                                                    height: 4,
                                                    decoration: ShapeDecoration(
                                                      shape: RoundedRectangleBorder(
                                                        side: BorderSide(
                                                          width: 0.29,
                                                          color: const Color(
                                                            0xFFC9A24B,
                                                          ) /* goldPrimary */,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              0.78,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 11.90,
                                                  top: 10.92,
                                                  child: Container(
                                                    width: 0.39,
                                                    height: 12.48,
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFC9A24B,
                                                      ) /* goldPrimary */,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 8.97,
                                                  top: 16.96,
                                                  child: Container(
                                                    width: 6.24,
                                                    height: 0.39,
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFC9A24B,
                                                      ) /* goldPrimary */,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 116,
                                          top: 0,
                                          child: Container(
                                            width: 24.18,
                                            height: 34.32,
                                            decoration: ShapeDecoration(
                                              color: const Color(
                                                0xFF22303E,
                                              ) /* cardBack */,
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 0.39,
                                                  color: const Color(
                                                    0xFFC9A24B,
                                                  ) /* goldPrimary */,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(3.12),
                                              ),
                                            ),
                                            child: Stack(
                                              children: [
                                                Positioned(
                                                  left: 1.17,
                                                  top: 1.17,
                                                  child: Container(
                                                    width: 21.84,
                                                    height: 31.98,
                                                    decoration: ShapeDecoration(
                                                      shape: RoundedRectangleBorder(
                                                        side: BorderSide(
                                                          width: 0.29,
                                                          color: const Color(
                                                            0xFFC9A24B,
                                                          ) /* goldPrimary */,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              1.95,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 3.90,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 7.02,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 10.14,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 13.26,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 16.38,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 19.50,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 22.62,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 25.74,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 28.86,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 31.98,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 12.09,
                                                  top: 14.11,
                                                  child: Container(
                                                    transform:
                                                        Matrix4.identity()
                                                          ..translate(0.0, 0.0)
                                                          ..rotateZ(-0.79),
                                                    width: 10.82,
                                                    height: 4,
                                                    decoration: ShapeDecoration(
                                                      shape: RoundedRectangleBorder(
                                                        side: BorderSide(
                                                          width: 0.29,
                                                          color: const Color(
                                                            0xFFC9A24B,
                                                          ) /* goldPrimary */,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              0.78,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 11.90,
                                                  top: 10.92,
                                                  child: Container(
                                                    width: 0.39,
                                                    height: 12.48,
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFC9A24B,
                                                      ) /* goldPrimary */,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 8.97,
                                                  top: 16.96,
                                                  child: Container(
                                                    width: 6.24,
                                                    height: 0.39,
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFC9A24B,
                                                      ) /* goldPrimary */,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 87,
                                          top: 0,
                                          child: Container(
                                            width: 24.18,
                                            height: 34.32,
                                            decoration: ShapeDecoration(
                                              color: const Color(
                                                0xFF22303E,
                                              ) /* cardBack */,
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 0.39,
                                                  color: const Color(
                                                    0xFFC9A24B,
                                                  ) /* goldPrimary */,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(3.12),
                                              ),
                                            ),
                                            child: Stack(
                                              children: [
                                                Positioned(
                                                  left: 1.17,
                                                  top: 1.17,
                                                  child: Container(
                                                    width: 21.84,
                                                    height: 31.98,
                                                    decoration: ShapeDecoration(
                                                      shape: RoundedRectangleBorder(
                                                        side: BorderSide(
                                                          width: 0.29,
                                                          color: const Color(
                                                            0xFFC9A24B,
                                                          ) /* goldPrimary */,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              1.95,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 3.90,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 7.02,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 10.14,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 13.26,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 16.38,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 19.50,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 22.62,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 25.74,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 28.86,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 31.98,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 12.09,
                                                  top: 14.11,
                                                  child: Container(
                                                    transform:
                                                        Matrix4.identity()
                                                          ..translate(0.0, 0.0)
                                                          ..rotateZ(-0.79),
                                                    width: 10.82,
                                                    height: 4,
                                                    decoration: ShapeDecoration(
                                                      shape: RoundedRectangleBorder(
                                                        side: BorderSide(
                                                          width: 0.29,
                                                          color: const Color(
                                                            0xFFC9A24B,
                                                          ) /* goldPrimary */,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              0.78,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 11.90,
                                                  top: 10.92,
                                                  child: Container(
                                                    width: 0.39,
                                                    height: 12.48,
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFC9A24B,
                                                      ) /* goldPrimary */,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 8.97,
                                                  top: 16.96,
                                                  child: Container(
                                                    width: 6.24,
                                                    height: 0.39,
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFC9A24B,
                                                      ) /* goldPrimary */,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 58,
                                          top: 0,
                                          child: Container(
                                            width: 24.18,
                                            height: 34.32,
                                            decoration: ShapeDecoration(
                                              color: const Color(
                                                0xFF22303E,
                                              ) /* cardBack */,
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 0.39,
                                                  color: const Color(
                                                    0xFFC9A24B,
                                                  ) /* goldPrimary */,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(3.12),
                                              ),
                                            ),
                                            child: Stack(
                                              children: [
                                                Positioned(
                                                  left: 1.17,
                                                  top: 1.17,
                                                  child: Container(
                                                    width: 21.84,
                                                    height: 31.98,
                                                    decoration: ShapeDecoration(
                                                      shape: RoundedRectangleBorder(
                                                        side: BorderSide(
                                                          width: 0.29,
                                                          color: const Color(
                                                            0xFFC9A24B,
                                                          ) /* goldPrimary */,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              1.95,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 3.90,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 7.02,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 10.14,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 13.26,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 16.38,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 19.50,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 22.62,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 25.74,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 28.86,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 31.98,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 12.09,
                                                  top: 14.11,
                                                  child: Container(
                                                    transform:
                                                        Matrix4.identity()
                                                          ..translate(0.0, 0.0)
                                                          ..rotateZ(-0.79),
                                                    width: 10.82,
                                                    height: 4,
                                                    decoration: ShapeDecoration(
                                                      shape: RoundedRectangleBorder(
                                                        side: BorderSide(
                                                          width: 0.29,
                                                          color: const Color(
                                                            0xFFC9A24B,
                                                          ) /* goldPrimary */,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              0.78,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 11.90,
                                                  top: 10.92,
                                                  child: Container(
                                                    width: 0.39,
                                                    height: 12.48,
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFC9A24B,
                                                      ) /* goldPrimary */,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 8.97,
                                                  top: 16.96,
                                                  child: Container(
                                                    width: 6.24,
                                                    height: 0.39,
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFC9A24B,
                                                      ) /* goldPrimary */,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 29,
                                          top: 0,
                                          child: Container(
                                            width: 24.18,
                                            height: 34.32,
                                            decoration: ShapeDecoration(
                                              color: const Color(
                                                0xFF22303E,
                                              ) /* cardBack */,
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 0.39,
                                                  color: const Color(
                                                    0xFFC9A24B,
                                                  ) /* goldPrimary */,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(3.12),
                                              ),
                                            ),
                                            child: Stack(
                                              children: [
                                                Positioned(
                                                  left: 1.17,
                                                  top: 1.17,
                                                  child: Container(
                                                    width: 21.84,
                                                    height: 31.98,
                                                    decoration: ShapeDecoration(
                                                      shape: RoundedRectangleBorder(
                                                        side: BorderSide(
                                                          width: 0.29,
                                                          color: const Color(
                                                            0xFFC9A24B,
                                                          ) /* goldPrimary */,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              1.95,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 3.90,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 7.02,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 10.14,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 13.26,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 16.38,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 19.50,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 22.62,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 25.74,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 28.86,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 31.98,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 12.09,
                                                  top: 14.11,
                                                  child: Container(
                                                    transform:
                                                        Matrix4.identity()
                                                          ..translate(0.0, 0.0)
                                                          ..rotateZ(-0.79),
                                                    width: 10.82,
                                                    height: 4,
                                                    decoration: ShapeDecoration(
                                                      shape: RoundedRectangleBorder(
                                                        side: BorderSide(
                                                          width: 0.29,
                                                          color: const Color(
                                                            0xFFC9A24B,
                                                          ) /* goldPrimary */,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              0.78,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 11.90,
                                                  top: 10.92,
                                                  child: Container(
                                                    width: 0.39,
                                                    height: 12.48,
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFC9A24B,
                                                      ) /* goldPrimary */,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 8.97,
                                                  top: 16.96,
                                                  child: Container(
                                                    width: 6.24,
                                                    height: 0.39,
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFC9A24B,
                                                      ) /* goldPrimary */,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          child: Container(
                                            width: 24.18,
                                            height: 34.32,
                                            decoration: ShapeDecoration(
                                              color: const Color(
                                                0xFF22303E,
                                              ) /* cardBack */,
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 0.39,
                                                  color: const Color(
                                                    0xFFC9A24B,
                                                  ) /* goldPrimary */,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(3.12),
                                              ),
                                            ),
                                            child: Stack(
                                              children: [
                                                Positioned(
                                                  left: 1.17,
                                                  top: 1.17,
                                                  child: Container(
                                                    width: 21.84,
                                                    height: 31.98,
                                                    decoration: ShapeDecoration(
                                                      shape: RoundedRectangleBorder(
                                                        side: BorderSide(
                                                          width: 0.29,
                                                          color: const Color(
                                                            0xFFC9A24B,
                                                          ) /* goldPrimary */,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              1.95,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 3.90,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 7.02,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 10.14,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 13.26,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 16.38,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 19.50,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 22.62,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 25.74,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 28.86,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 2.34,
                                                  top: 31.98,
                                                  child: Opacity(
                                                    opacity: 0.12,
                                                    child: Container(
                                                      width: 19.50,
                                                      height: 0.19,
                                                      decoration: ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.29,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 12.09,
                                                  top: 14.11,
                                                  child: Container(
                                                    transform:
                                                        Matrix4.identity()
                                                          ..translate(0.0, 0.0)
                                                          ..rotateZ(-0.79),
                                                    width: 10.82,
                                                    height: 4,
                                                    decoration: ShapeDecoration(
                                                      shape: RoundedRectangleBorder(
                                                        side: BorderSide(
                                                          width: 0.29,
                                                          color: const Color(
                                                            0xFFC9A24B,
                                                          ) /* goldPrimary */,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              0.78,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 11.90,
                                                  top: 10.92,
                                                  child: Container(
                                                    width: 0.39,
                                                    height: 12.48,
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFC9A24B,
                                                      ) /* goldPrimary */,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 8.97,
                                                  top: 16.96,
                                                  child: Container(
                                                    width: 6.24,
                                                    height: 0.39,
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFC9A24B,
                                                      ) /* goldPrimary */,
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
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Container(
                        width: 1440,
                        height: 474,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 264,
                              top: 225,
                              child: Opacity(
                                opacity: 0.22,
                                child: Container(
                                  width: 912,
                                  height: 1,
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFC9A24B,
                                    ) /* goldPrimary */,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 719.50,
                              top: 90,
                              child: Opacity(
                                opacity: 0.22,
                                child: Container(
                                  width: 1,
                                  height: 292,
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFC9A24B,
                                    ) /* goldPrimary */,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 64,
                              top: 382,
                              child: Container(width: 200, height: 86),
                            ),
                            Positioned(
                              left: 1176,
                              top: 182,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 200,
                                    height: 86,
                                    padding: const EdgeInsets.all(10),
                                    decoration: ShapeDecoration(
                                      color: const Color(
                                        0xFF131A23,
                                      ) /* darkTokens-color-bgPanel */,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          width: 1,
                                          color: const Color(0xFF2C3035),
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      spacing: 10,
                                      children: [
                                        Container(
                                          width: 54,
                                          height: 54,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: ShapeDecoration(
                                            color: const Color(0xFF29251C),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(13),
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Container(
                                                width: 34,
                                                height: 34,
                                                clipBehavior: Clip.antiAlias,
                                                decoration: BoxDecoration(),
                                                child: Stack(),
                                              ),
                                              Positioned(
                                                left: 0,
                                                top: 38,
                                                child: Container(
                                                  width: 16,
                                                  height: 16,
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFF1C242F,
                                                    ) /* darkTokens-color-bgCard */,
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        '4',
                                                        style: TextStyle(
                                                          color: const Color(
                                                            0xFF9A917E,
                                                          ) /* darkTokens-color-textSecondary */,
                                                          fontSize: 10,
                                                          fontFamily: 'Inter',
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            spacing: 3,
                                            children: [
                                              Container(
                                                clipBehavior: Clip.antiAlias,
                                                decoration: BoxDecoration(),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  spacing: 4,
                                                  children: [
                                                    Text(
                                                      '运河老友',
                                                      style: TextStyle(
                                                        color: const Color(
                                                          0xFFEDE8DB,
                                                        ) /* darkTokens-color-textPrimary */,
                                                        fontSize: 15,
                                                        fontFamily:
                                                            'Noto Sans SC',
                                                        fontWeight:
                                                            FontWeight.w700,
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
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  spacing: 6,
                                                  children: [
                                                    Text(
                                                      '钻石 I',
                                                      style: TextStyle(
                                                        color: const Color(
                                                          0xFF9A917E,
                                                        ) /* darkTokens-color-textSecondary */,
                                                        fontSize: 10,
                                                        fontFamily:
                                                            'Noto Sans SC',
                                                        fontWeight:
                                                            FontWeight.w400,
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
                            Positioned(
                              left: 64,
                              top: 182,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 200,
                                    height: 86,
                                    padding: const EdgeInsets.all(10),
                                    decoration: ShapeDecoration(
                                      color: const Color(
                                        0xFF131A23,
                                      ) /* darkTokens-color-bgPanel */,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          width: 1,
                                          color: const Color(0xFF2C3035),
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      spacing: 10,
                                      children: [
                                        Container(
                                          width: 54,
                                          height: 54,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: ShapeDecoration(
                                            color: const Color(0xFF29251C),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(13),
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Container(
                                                width: 34,
                                                height: 34,
                                                clipBehavior: Clip.antiAlias,
                                                decoration: BoxDecoration(),
                                                child: Stack(),
                                              ),
                                              Positioned(
                                                left: 0,
                                                top: 38,
                                                child: Container(
                                                  width: 16,
                                                  height: 16,
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFF1C242F,
                                                    ) /* darkTokens-color-bgCard */,
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        '2',
                                                        style: TextStyle(
                                                          color: const Color(
                                                            0xFF9A917E,
                                                          ) /* darkTokens-color-textSecondary */,
                                                          fontSize: 10,
                                                          fontFamily: 'Inter',
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            spacing: 3,
                                            children: [
                                              Container(
                                                clipBehavior: Clip.antiAlias,
                                                decoration: BoxDecoration(),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  spacing: 4,
                                                  children: [
                                                    Text(
                                                      '清江月',
                                                      style: TextStyle(
                                                        color: const Color(
                                                          0xFFEDE8DB,
                                                        ) /* darkTokens-color-textPrimary */,
                                                        fontSize: 15,
                                                        fontFamily:
                                                            'Noto Sans SC',
                                                        fontWeight:
                                                            FontWeight.w700,
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
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  spacing: 6,
                                                  children: [
                                                    Text(
                                                      '钻石 II',
                                                      style: TextStyle(
                                                        color: const Color(
                                                          0xFF9A917E,
                                                        ) /* darkTokens-color-textSecondary */,
                                                        fontSize: 10,
                                                        fontFamily:
                                                            'Noto Sans SC',
                                                        fontWeight:
                                                            FontWeight.w400,
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
                            Positioned(
                              left: 620,
                              top: 6,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 200,
                                    height: 86,
                                    padding: const EdgeInsets.all(10),
                                    decoration: ShapeDecoration(
                                      color: const Color(
                                        0xFF131A23,
                                      ) /* darkTokens-color-bgPanel */,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          width: 1,
                                          color: const Color(0xFF2C3035),
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      spacing: 10,
                                      children: [
                                        Container(
                                          width: 54,
                                          height: 54,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: ShapeDecoration(
                                            color: const Color(0xFF29251C),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(13),
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Container(
                                                width: 34,
                                                height: 34,
                                                clipBehavior: Clip.antiAlias,
                                                decoration: BoxDecoration(),
                                                child: Stack(),
                                              ),
                                              Positioned(
                                                left: 0,
                                                top: 38,
                                                child: Container(
                                                  width: 16,
                                                  height: 16,
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFF1C242F,
                                                    ) /* darkTokens-color-bgCard */,
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        '3',
                                                        style: TextStyle(
                                                          color: const Color(
                                                            0xFF9A917E,
                                                          ) /* darkTokens-color-textSecondary */,
                                                          fontSize: 10,
                                                          fontFamily: 'Inter',
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            spacing: 3,
                                            children: [
                                              Container(
                                                clipBehavior: Clip.antiAlias,
                                                decoration: BoxDecoration(),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  spacing: 4,
                                                  children: [
                                                    Text(
                                                      '淮上听风',
                                                      style: TextStyle(
                                                        color: const Color(
                                                          0xFFEDE8DB,
                                                        ) /* darkTokens-color-textPrimary */,
                                                        fontSize: 15,
                                                        fontFamily:
                                                            'Noto Sans SC',
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        height: 1.40,
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 16,
                                                      height: 16,
                                                      clipBehavior:
                                                          Clip.antiAlias,
                                                      decoration:
                                                          BoxDecoration(),
                                                      child: Stack(),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                clipBehavior: Clip.antiAlias,
                                                decoration: BoxDecoration(),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  spacing: 6,
                                                  children: [
                                                    Text(
                                                      '大师 III',
                                                      style: TextStyle(
                                                        color: const Color(
                                                          0xFF9A917E,
                                                        ) /* darkTokens-color-textSecondary */,
                                                        fontSize: 10,
                                                        fontFamily:
                                                            'Noto Sans SC',
                                                        fontWeight:
                                                            FontWeight.w400,
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
                            Positioned(
                              left: 667,
                              top: 321,
                              child: Opacity(
                                opacity: 0.45,
                                child: Text(
                                  'HUAIAN · 80',
                                  style: TextStyle(
                                    color: const Color(0xFFB88482),
                                    fontSize: 11,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 4,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 591,
                              top: 170,
                              child: Container(
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 36,
                                  children: [
                                    Container(
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        spacing: 8,
                                        children: [
                                          Container(
                                            width: 62,
                                            height: 88,
                                            decoration: ShapeDecoration(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 62,
                                                  height: 88,
                                                  decoration: ShapeDecoration(
                                                    color: const Color(
                                                      0xFFF5EFE0,
                                                    ) /* cardFace */,
                                                    shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                                                        width: 0.75,
                                                        color: const Color(
                                                          0xFFC8C3BA,
                                                        ),
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Positioned(
                                                        left: 44,
                                                        top: 71,
                                                        child: Text(
                                                          'A',
                                                          style: TextStyle(
                                                            color: const Color(
                                                              0xFFB74448,
                                                            ) /* suitRed */,
                                                            fontSize: 12,
                                                            fontFamily: 'Lora',
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            height: 1.17,
                                                          ),
                                                        ),
                                                      ),
                                                      Positioned(
                                                        left: 5,
                                                        top: 3,
                                                        child: Text(
                                                          'A',
                                                          style: TextStyle(
                                                            color: const Color(
                                                              0xFFB74448,
                                                            ) /* suitRed */,
                                                            fontSize: 20,
                                                            fontFamily: 'Lora',
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            height: 1.20,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            '清江月',
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
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        spacing: 8,
                                        children: [
                                          Container(
                                            width: 62,
                                            height: 88,
                                            decoration: ShapeDecoration(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 62,
                                                  height: 88,
                                                  decoration: ShapeDecoration(
                                                    color: const Color(
                                                      0xFFF5EFE0,
                                                    ) /* cardFace */,
                                                    shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                                                        width: 0.75,
                                                        color: const Color(
                                                          0xFFC8C3BA,
                                                        ),
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Positioned(
                                                        left: 44,
                                                        top: 71,
                                                        child: Text(
                                                          '10',
                                                          style: TextStyle(
                                                            color: const Color(
                                                              0xFFB74448,
                                                            ) /* suitRed */,
                                                            fontSize: 12,
                                                            fontFamily: 'Lora',
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            height: 1.17,
                                                          ),
                                                        ),
                                                      ),
                                                      Positioned(
                                                        left: 5,
                                                        top: 3,
                                                        child: Text(
                                                          '10',
                                                          style: TextStyle(
                                                            color: const Color(
                                                              0xFFB74448,
                                                            ) /* suitRed */,
                                                            fontSize: 20,
                                                            fontFamily: 'Lora',
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            height: 1.20,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            '淮上听风',
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
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        spacing: 8,
                                        children: [
                                          Container(
                                            width: 62,
                                            height: 88,
                                            decoration: ShapeDecoration(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 62,
                                                  height: 88,
                                                  decoration: ShapeDecoration(
                                                    color: const Color(
                                                      0xFFF5EFE0,
                                                    ) /* cardFace */,
                                                    shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                                                        width: 0.75,
                                                        color: const Color(
                                                          0xFFC8C3BA,
                                                        ),
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Positioned(
                                                        left: 44,
                                                        top: 71,
                                                        child: Text(
                                                          '7',
                                                          style: TextStyle(
                                                            color: const Color(
                                                              0xFFB74448,
                                                            ) /* suitRed */,
                                                            fontSize: 12,
                                                            fontFamily: 'Lora',
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            height: 1.17,
                                                          ),
                                                        ),
                                                      ),
                                                      Positioned(
                                                        left: 5,
                                                        top: 3,
                                                        child: Text(
                                                          '7',
                                                          style: TextStyle(
                                                            color: const Color(
                                                              0xFFB74448,
                                                            ) /* suitRed */,
                                                            fontSize: 20,
                                                            fontFamily: 'Lora',
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            height: 1.20,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            '运河老友',
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
                            ),
                            Positioned(
                              left: 632,
                              top: 114,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  color: const Color(0xFF31151E),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 8,
                                  children: [
                                    Container(
                                      width: 5,
                                      height: 5,
                                      decoration: ShapeDecoration(
                                        color: const Color(
                                          0xFFE6C56A,
                                        ) /* goldBright */,
                                        shape: OvalBorder(),
                                      ),
                                    ),
                                    Text(
                                      '第 01 墩 · 轮到你出牌',
                                      style: TextStyle(
                                        color: const Color(
                                          0xFFE6C56A,
                                        ) /* goldBright */,
                                        fontSize: 13,
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
                              left: 540,
                              top: 422,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 12,
                                children: [
                                  Container(
                                    height: 46,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 26,
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    decoration: ShapeDecoration(
                                      color: const Color(
                                        0xFF1C242F,
                                      ) /* darkTokens-color-bgCard */,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          width: 1,
                                          color: const Color(0xFF2C3035),
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      spacing: 8,
                                      children: [
                                        Container(
                                          width: 16,
                                          height: 16,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(),
                                          child: Stack(),
                                        ),
                                        Text(
                                          '提示',
                                          style: TextStyle(
                                            color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                            fontSize: 15,
                                            fontFamily: 'Noto Sans SC',
                                            fontWeight: FontWeight.w400,
                                            height: 1.40,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: 46,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 26,
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    decoration: ShapeDecoration(
                                      color: const Color(
                                        0xFF1C242F,
                                      ) /* darkTokens-color-bgCard */,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          width: 1,
                                          color: const Color(0xFF2C3035),
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      spacing: 8,
                                      children: [
                                        Text(
                                          '不出',
                                          style: TextStyle(
                                            color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                            fontSize: 15,
                                            fontFamily: 'Noto Sans SC',
                                            fontWeight: FontWeight.w400,
                                            height: 1.40,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: 46,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 26,
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    decoration: ShapeDecoration(
                                      color: const Color(
                                        0xFFC9A24B,
                                      ) /* goldPrimary */,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          width: 1,
                                          color: const Color(
                                            0xFFE6C56A,
                                          ) /* goldBright */,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      spacing: 8,
                                      children: [
                                        Text(
                                          '确认出牌 · 1 张',
                                          style: TextStyle(
                                            color: const Color(0xFF171A20),
                                            fontSize: 15,
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
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                height: 200,
                padding: const EdgeInsets.symmetric(horizontal: 40),
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
                      height: 172,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 145,
                            top: 55,
                            child: Container(
                              transform: Matrix4.identity()
                                ..translate(0.0, 0.0)
                                ..rotateZ(-0.10),
                              width: 62,
                              height: 88,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 70.86,
                                    height: 94,
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 70.86,
                                          height: 94,
                                          decoration: ShapeDecoration(
                                            color: const Color(
                                              0xFFF5EFE0,
                                            ) /* cardFace */,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                width: 0.75,
                                                color: const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 51.18,
                                                top: 71.66,
                                                child: Text(
                                                  'A',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFF22303E,
                                                    ) /* suitBlack */,
                                                    fontSize: 12,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.17,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 5.29,
                                                top: 7.48,
                                                child: Text(
                                                  'A',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFF22303E,
                                                    ) /* suitBlack */,
                                                    fontSize: 20,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.20,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          child: Container(
                                            width: 70.86,
                                            height: 94,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 70.86,
                                                  height: 94,
                                                  decoration: ShapeDecoration(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Positioned(
                                                        left: 10.83,
                                                        top: 60.29,
                                                        child: Container(
                                                          width: 14.29,
                                                          height: 14.29,
                                                          clipBehavior:
                                                              Clip.antiAlias,
                                                          decoration: ShapeDecoration(
                                                            color: const Color(
                                                              0xFFC9A24B,
                                                            ) /* goldPrimary */,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    3,
                                                                  ),
                                                            ),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                '主',
                                                                style: TextStyle(
                                                                  color: const Color(
                                                                    0xFF22303E,
                                                                  ) /* suitBlack */,
                                                                  fontSize: 7,
                                                                  fontFamily: 'Noto Sans SC',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  height: 1.86,
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
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 187,
                            top: 51.33,
                            child: Container(
                              transform: Matrix4.identity()
                                ..translate(0.0, 0.0)
                                ..rotateZ(-0.10),
                              width: 62,
                              height: 88,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 70.15,
                                    height: 93.54,
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 70.15,
                                          height: 93.54,
                                          decoration: ShapeDecoration(
                                            color: const Color(
                                              0xFFF5EFE0,
                                            ) /* cardFace */,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                width: 0.75,
                                                color: const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 50.60,
                                                top: 71.54,
                                                child: Text(
                                                  'K',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFF22303E,
                                                    ) /* suitBlack */,
                                                    fontSize: 12,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.17,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 5.26,
                                                top: 7.01,
                                                child: Text(
                                                  'K',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFF22303E,
                                                    ) /* suitBlack */,
                                                    fontSize: 20,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.20,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          child: Container(
                                            width: 70.15,
                                            height: 93.54,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 70.15,
                                                  height: 93.54,
                                                  decoration: ShapeDecoration(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Positioned(
                                                        left: 10.34,
                                                        top: 59.96,
                                                        child: Container(
                                                          width: 14.19,
                                                          height: 14.19,
                                                          clipBehavior:
                                                              Clip.antiAlias,
                                                          decoration: ShapeDecoration(
                                                            color: const Color(
                                                              0xFFC9A24B,
                                                            ) /* goldPrimary */,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    3,
                                                                  ),
                                                            ),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                '主',
                                                                style: TextStyle(
                                                                  color: const Color(
                                                                    0xFF22303E,
                                                                  ) /* suitBlack */,
                                                                  fontSize: 7,
                                                                  fontFamily: 'Noto Sans SC',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  height: 1.86,
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
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 229,
                            top: 47.97,
                            child: Container(
                              transform: Matrix4.identity()
                                ..translate(0.0, 0.0)
                                ..rotateZ(-0.09),
                              width: 62,
                              height: 88,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 69.43,
                                    height: 93.07,
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 69.43,
                                          height: 93.07,
                                          decoration: ShapeDecoration(
                                            color: const Color(
                                              0xFFF5EFE0,
                                            ) /* cardFace */,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                width: 0.75,
                                                color: const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 50.02,
                                                top: 71.51,
                                                child: Text(
                                                  'K',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFF22303E,
                                                    ) /* suitBlack */,
                                                    fontSize: 12,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.17,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 5.24,
                                                top: 6.65,
                                                child: Text(
                                                  'K',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFF22303E,
                                                    ) /* suitBlack */,
                                                    fontSize: 20,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.20,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          child: Container(
                                            width: 69.43,
                                            height: 93.07,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 69.43,
                                                  height: 93.07,
                                                  decoration: ShapeDecoration(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Positioned(
                                                        left: 9.86,
                                                        top: 59.62,
                                                        child: Container(
                                                          width: 14.08,
                                                          height: 14.08,
                                                          clipBehavior:
                                                              Clip.antiAlias,
                                                          decoration: ShapeDecoration(
                                                            color: const Color(
                                                              0xFFC9A24B,
                                                            ) /* goldPrimary */,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    3,
                                                                  ),
                                                            ),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                '主',
                                                                style: TextStyle(
                                                                  color: const Color(
                                                                    0xFF22303E,
                                                                  ) /* suitBlack */,
                                                                  fontSize: 7,
                                                                  fontFamily: 'Noto Sans SC',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  height: 1.86,
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
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 271,
                            top: 44.94,
                            child: Container(
                              transform: Matrix4.identity()
                                ..translate(0.0, 0.0)
                                ..rotateZ(-0.08),
                              width: 62,
                              height: 88,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 68.71,
                                    height: 92.59,
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 68.71,
                                          height: 92.59,
                                          decoration: ShapeDecoration(
                                            color: const Color(
                                              0xFFF5EFE0,
                                            ) /* cardFace */,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                width: 0.75,
                                                color: const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 49.43,
                                                top: 71.41,
                                                child: Text(
                                                  'Q',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFF22303E,
                                                    ) /* suitBlack */,
                                                    fontSize: 12,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.17,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 5.22,
                                                top: 6.21,
                                                child: Text(
                                                  'Q',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFF22303E,
                                                    ) /* suitBlack */,
                                                    fontSize: 20,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.20,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          child: Container(
                                            width: 68.71,
                                            height: 92.59,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 68.71,
                                                  height: 92.59,
                                                  decoration: ShapeDecoration(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Positioned(
                                                        left: 9.38,
                                                        top: 59.28,
                                                        child: Container(
                                                          width: 13.98,
                                                          height: 13.98,
                                                          clipBehavior:
                                                              Clip.antiAlias,
                                                          decoration: ShapeDecoration(
                                                            color: const Color(
                                                              0xFFC9A24B,
                                                            ) /* goldPrimary */,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    3,
                                                                  ),
                                                            ),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                '主',
                                                                style: TextStyle(
                                                                  color: const Color(
                                                                    0xFF22303E,
                                                                  ) /* suitBlack */,
                                                                  fontSize: 7,
                                                                  fontFamily: 'Noto Sans SC',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  height: 1.86,
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
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 313,
                            top: 42.22,
                            child: Container(
                              transform: Matrix4.identity()
                                ..translate(0.0, 0.0)
                                ..rotateZ(-0.07),
                              width: 62,
                              height: 88,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 67.99,
                                    height: 92.11,
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 67.99,
                                          height: 92.11,
                                          decoration: ShapeDecoration(
                                            color: const Color(
                                              0xFFF5EFE0,
                                            ) /* cardFace */,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                width: 0.75,
                                                color: const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 48.85,
                                                top: 71.39,
                                                child: Text(
                                                  'Q',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFF22303E,
                                                    ) /* suitBlack */,
                                                    fontSize: 12,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.17,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 5.20,
                                                top: 5.85,
                                                child: Text(
                                                  'Q',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFF22303E,
                                                    ) /* suitBlack */,
                                                    fontSize: 20,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.20,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          child: Container(
                                            width: 67.99,
                                            height: 92.11,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 67.99,
                                                  height: 92.11,
                                                  decoration: ShapeDecoration(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Positioned(
                                                        left: 8.89,
                                                        top: 58.93,
                                                        child: Container(
                                                          width: 13.88,
                                                          height: 13.88,
                                                          clipBehavior:
                                                              Clip.antiAlias,
                                                          decoration: ShapeDecoration(
                                                            color: const Color(
                                                              0xFFC9A24B,
                                                            ) /* goldPrimary */,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    3,
                                                                  ),
                                                            ),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                '主',
                                                                style: TextStyle(
                                                                  color: const Color(
                                                                    0xFF22303E,
                                                                  ) /* suitBlack */,
                                                                  fontSize: 7,
                                                                  fontFamily: 'Noto Sans SC',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  height: 1.86,
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
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 355,
                            top: 39.83,
                            child: Container(
                              transform: Matrix4.identity()
                                ..translate(0.0, 0.0)
                                ..rotateZ(-0.06),
                              width: 62,
                              height: 88,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 67.26,
                                    height: 91.62,
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 67.26,
                                          height: 91.62,
                                          decoration: ShapeDecoration(
                                            color: const Color(
                                              0xFFF5EFE0,
                                            ) /* cardFace */,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                width: 0.75,
                                                color: const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 48.25,
                                                top: 71.66,
                                                child: Text(
                                                  'J',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFF22303E,
                                                    ) /* suitBlack */,
                                                    fontSize: 12,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.17,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 5.17,
                                                top: 5.86,
                                                child: Text(
                                                  'J',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFF22303E,
                                                    ) /* suitBlack */,
                                                    fontSize: 20,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.20,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          child: Container(
                                            width: 67.26,
                                            height: 91.62,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 67.26,
                                                  height: 91.62,
                                                  decoration: ShapeDecoration(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Positioned(
                                                        left: 8.41,
                                                        top: 58.58,
                                                        child: Container(
                                                          width: 13.77,
                                                          height: 13.77,
                                                          clipBehavior:
                                                              Clip.antiAlias,
                                                          decoration: ShapeDecoration(
                                                            color: const Color(
                                                              0xFFC9A24B,
                                                            ) /* goldPrimary */,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    3,
                                                                  ),
                                                            ),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                '主',
                                                                style: TextStyle(
                                                                  color: const Color(
                                                                    0xFF22303E,
                                                                  ) /* suitBlack */,
                                                                  fontSize: 7,
                                                                  fontFamily: 'Noto Sans SC',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  height: 1.86,
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
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 397,
                            top: 37.75,
                            child: Container(
                              transform: Matrix4.identity()
                                ..translate(0.0, 0.0)
                                ..rotateZ(-0.05),
                              width: 62,
                              height: 88,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 66.52,
                                    height: 91.12,
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 66.52,
                                          height: 91.12,
                                          decoration: ShapeDecoration(
                                            color: const Color(
                                              0xFFF5EFE0,
                                            ) /* cardFace */,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                width: 0.75,
                                                color: const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 47.66,
                                                top: 71.22,
                                                child: Text(
                                                  '10',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFF22303E,
                                                    ) /* suitBlack */,
                                                    fontSize: 12,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.17,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 5.15,
                                                top: 4.88,
                                                child: Text(
                                                  '10',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFF22303E,
                                                    ) /* suitBlack */,
                                                    fontSize: 20,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.20,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          child: Container(
                                            width: 66.52,
                                            height: 91.12,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 66.52,
                                                  height: 91.12,
                                                  decoration: ShapeDecoration(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Positioned(
                                                        left: 7.92,
                                                        top: 58.23,
                                                        child: Container(
                                                          width: 13.66,
                                                          height: 13.66,
                                                          clipBehavior:
                                                              Clip.antiAlias,
                                                          decoration: ShapeDecoration(
                                                            color: const Color(
                                                              0xFFC9A24B,
                                                            ) /* goldPrimary */,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    3,
                                                                  ),
                                                            ),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                '主',
                                                                style: TextStyle(
                                                                  color: const Color(
                                                                    0xFF22303E,
                                                                  ) /* suitBlack */,
                                                                  fontSize: 7,
                                                                  fontFamily: 'Noto Sans SC',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  height: 1.86,
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
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 439,
                            top: 35.99,
                            child: Container(
                              transform: Matrix4.identity()
                                ..translate(0.0, 0.0)
                                ..rotateZ(-0.04),
                              width: 62,
                              height: 88,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 65.78,
                                    height: 90.62,
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 65.78,
                                          height: 90.62,
                                          decoration: ShapeDecoration(
                                            color: const Color(
                                              0xFFF5EFE0,
                                            ) /* cardFace */,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                width: 0.75,
                                                color: const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 47.06,
                                                top: 71.41,
                                                child: Text(
                                                  '9',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFF22303E,
                                                    ) /* suitBlack */,
                                                    fontSize: 12,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.17,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 5.13,
                                                top: 4.96,
                                                child: Text(
                                                  '9',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFF22303E,
                                                    ) /* suitBlack */,
                                                    fontSize: 20,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.20,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          child: Container(
                                            width: 65.78,
                                            height: 90.62,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 65.78,
                                                  height: 90.62,
                                                  decoration: ShapeDecoration(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Positioned(
                                                        left: 7.44,
                                                        top: 57.87,
                                                        child: Container(
                                                          width: 13.55,
                                                          height: 13.55,
                                                          clipBehavior:
                                                              Clip.antiAlias,
                                                          decoration: ShapeDecoration(
                                                            color: const Color(
                                                              0xFFC9A24B,
                                                            ) /* goldPrimary */,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    3,
                                                                  ),
                                                            ),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                '主',
                                                                style: TextStyle(
                                                                  color: const Color(
                                                                    0xFF22303E,
                                                                  ) /* suitBlack */,
                                                                  fontSize: 7,
                                                                  fontFamily: 'Noto Sans SC',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  height: 1.86,
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
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 481,
                            top: 34.56,
                            child: Container(
                              transform: Matrix4.identity()
                                ..translate(0.0, 0.0)
                                ..rotateZ(-0.03),
                              width: 62,
                              height: 88,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 65.03,
                                    height: 90.11,
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 65.03,
                                          height: 90.11,
                                          decoration: ShapeDecoration(
                                            color: const Color(
                                              0xFFF5EFE0,
                                            ) /* cardFace */,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                width: 0.75,
                                                color: const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 46.45,
                                                top: 71.34,
                                                child: Text(
                                                  '2',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFF22303E,
                                                    ) /* suitBlack */,
                                                    fontSize: 12,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.17,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 5.10,
                                                top: 4.60,
                                                child: Text(
                                                  '2',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFF22303E,
                                                    ) /* suitBlack */,
                                                    fontSize: 20,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.20,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          child: Container(
                                            width: 65.03,
                                            height: 90.11,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 65.03,
                                                  height: 90.11,
                                                  decoration: ShapeDecoration(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Positioned(
                                                        left: 0.78,
                                                        top: 0.78,
                                                        child: Container(
                                                          width: 63.48,
                                                          height: 88.56,
                                                          decoration: ShapeDecoration(
                                                            shape: RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.75,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Positioned(
                                                        left: 7.02,
                                                        top: 59.33,
                                                        child: Container(
                                                          width: 18.37,
                                                          height: 11.62,
                                                          clipBehavior:
                                                              Clip.antiAlias,
                                                          decoration: ShapeDecoration(
                                                            color: const Color(
                                                              0xFFC9A24B,
                                                            ) /* goldPrimary */,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    2,
                                                                  ),
                                                            ),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                '级',
                                                                style: TextStyle(
                                                                  color: const Color(
                                                                    0xFF22303E,
                                                                  ) /* suitBlack */,
                                                                  fontSize: 7,
                                                                  fontFamily: 'Noto Sans SC',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  height: 1.57,
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
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 523,
                            top: 33.44,
                            child: Container(
                              transform: Matrix4.identity()
                                ..translate(0.0, 0.0)
                                ..rotateZ(-0.03),
                              width: 62,
                              height: 88,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 64.28,
                                    height: 89.59,
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 64.28,
                                          height: 89.59,
                                          decoration: ShapeDecoration(
                                            color: const Color(
                                              0xFFF5EFE0,
                                            ) /* cardFace */,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                width: 0.75,
                                                color: const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 45.84,
                                                top: 71.26,
                                                child: Text(
                                                  '2',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFFB74448,
                                                    ) /* suitRed */,
                                                    fontSize: 12,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.17,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 5.08,
                                                top: 4.20,
                                                child: Text(
                                                  '2',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFFB74448,
                                                    ) /* suitRed */,
                                                    fontSize: 20,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.20,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          child: Container(
                                            width: 64.28,
                                            height: 89.59,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 64.28,
                                                  height: 89.59,
                                                  decoration: ShapeDecoration(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Positioned(
                                                        left: 0.77,
                                                        top: 0.77,
                                                        child: Container(
                                                          width: 62.74,
                                                          height: 88.05,
                                                          decoration: ShapeDecoration(
                                                            shape: RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.75,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Positioned(
                                                        left: 6.52,
                                                        top: 59,
                                                        child: Container(
                                                          width: 18.28,
                                                          height: 11.47,
                                                          clipBehavior:
                                                              Clip.antiAlias,
                                                          decoration: ShapeDecoration(
                                                            color: const Color(
                                                              0xFFC9A24B,
                                                            ) /* goldPrimary */,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    2,
                                                                  ),
                                                            ),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                '级',
                                                                style: TextStyle(
                                                                  color: const Color(
                                                                    0xFF22303E,
                                                                  ) /* suitBlack */,
                                                                  fontSize: 7,
                                                                  fontFamily: 'Noto Sans SC',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  height: 1.57,
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
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 565,
                            top: 32.64,
                            child: Container(
                              transform: Matrix4.identity()
                                ..translate(0.0, 0.0)
                                ..rotateZ(-0.02),
                              width: 62,
                              height: 88,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 63.53,
                                    height: 89.07,
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 63.53,
                                          height: 89.07,
                                          decoration: ShapeDecoration(
                                            color: const Color(
                                              0xFFF5EFE0,
                                            ) /* cardFace */,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                width: 0.75,
                                                color: const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 45.23,
                                                top: 71.18,
                                                child: Text(
                                                  '2',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFFB74448,
                                                    ) /* suitRed */,
                                                    fontSize: 12,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.17,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 5.05,
                                                top: 3.80,
                                                child: Text(
                                                  '2',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFFB74448,
                                                    ) /* suitRed */,
                                                    fontSize: 20,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.20,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          child: Container(
                                            width: 63.53,
                                            height: 89.07,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 63.53,
                                                  height: 89.07,
                                                  decoration: ShapeDecoration(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Positioned(
                                                        left: 0.76,
                                                        top: 0.76,
                                                        child: Container(
                                                          width: 62,
                                                          height: 87.54,
                                                          decoration: ShapeDecoration(
                                                            shape: RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.75,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Positioned(
                                                        left: 6.01,
                                                        top: 58.67,
                                                        child: Container(
                                                          width: 18.19,
                                                          height: 11.31,
                                                          clipBehavior:
                                                              Clip.antiAlias,
                                                          decoration: ShapeDecoration(
                                                            color: const Color(
                                                              0xFFC9A24B,
                                                            ) /* goldPrimary */,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    2,
                                                                  ),
                                                            ),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                '级',
                                                                style: TextStyle(
                                                                  color: const Color(
                                                                    0xFF22303E,
                                                                  ) /* suitBlack */,
                                                                  fontSize: 7,
                                                                  fontFamily: 'Noto Sans SC',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  height: 1.57,
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
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 607,
                            top: 32.16,
                            child: Container(
                              width: 62,
                              height: 88,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 62.77,
                                    height: 88.54,
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 62.77,
                                          height: 88.54,
                                          decoration: ShapeDecoration(
                                            color: const Color(
                                              0xFFF5EFE0,
                                            ) /* cardFace */,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                width: 0.75,
                                                color: const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 44.62,
                                                top: 71.09,
                                                child: Text(
                                                  '2',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFF22303E,
                                                    ) /* suitBlack */,
                                                    fontSize: 12,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.17,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 5.03,
                                                top: 3.40,
                                                child: Text(
                                                  '2',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFF22303E,
                                                    ) /* suitBlack */,
                                                    fontSize: 20,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.20,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          child: Container(
                                            width: 62.77,
                                            height: 88.54,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 62.77,
                                                  height: 88.54,
                                                  decoration: ShapeDecoration(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Positioned(
                                                        left: 0.76,
                                                        top: 0.76,
                                                        child: Container(
                                                          width: 61.25,
                                                          height: 87.02,
                                                          decoration: ShapeDecoration(
                                                            shape: RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                width: 0.75,
                                                                color:
                                                                    const Color(
                                                                      0xFFC9A24B,
                                                                    ) /* goldPrimary */,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Positioned(
                                                        left: 5.51,
                                                        top: 58.34,
                                                        child: Container(
                                                          width: 18.10,
                                                          height: 11.16,
                                                          clipBehavior:
                                                              Clip.antiAlias,
                                                          decoration: ShapeDecoration(
                                                            color: const Color(
                                                              0xFFC9A24B,
                                                            ) /* goldPrimary */,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    2,
                                                                  ),
                                                            ),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                '级',
                                                                style: TextStyle(
                                                                  color: const Color(
                                                                    0xFF22303E,
                                                                  ) /* suitBlack */,
                                                                  fontSize: 7,
                                                                  fontFamily: 'Noto Sans SC',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  height: 1.57,
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
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 649,
                            top: 32,
                            child: Container(
                              width: 62,
                              height: 88,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 62,
                                    height: 88,
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 62,
                                          height: 88,
                                          decoration: ShapeDecoration(
                                            color: const Color(
                                              0xFFF5EFE0,
                                            ) /* cardFace */,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                width: 0.75,
                                                color: const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 44,
                                                top: 71,
                                                child: Text(
                                                  'A',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFFB74448,
                                                    ) /* suitRed */,
                                                    fontSize: 12,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.17,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 5,
                                                top: 3,
                                                child: Text(
                                                  'A',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFFB74448,
                                                    ) /* suitRed */,
                                                    fontSize: 20,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.20,
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
                          ),
                          Positioned(
                            left: 691,
                            top: 32.16,
                            child: Container(
                              width: 62,
                              height: 88,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 62.77,
                                    height: 88.54,
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 62.77,
                                          height: 88.54,
                                          decoration: ShapeDecoration(
                                            color: const Color(
                                              0xFFF5EFE0,
                                            ) /* cardFace */,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                width: 0.75,
                                                color: const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 44.02,
                                                top: 71.38,
                                                child: Text(
                                                  'K',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFFB74448,
                                                    ) /* suitRed */,
                                                    fontSize: 12,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.17,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 5.53,
                                                top: 3.04,
                                                child: Text(
                                                  'K',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFFB74448,
                                                    ) /* suitRed */,
                                                    fontSize: 20,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.20,
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
                          ),
                          Positioned(
                            left: 733,
                            top: 32.64,
                            child: Container(
                              transform: Matrix4.identity()
                                ..translate(0.0, 0.0)
                                ..rotateZ(0.02),
                              width: 62,
                              height: 88,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 63.53,
                                    height: 89.07,
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 63.53,
                                          height: 89.07,
                                          decoration: ShapeDecoration(
                                            color: const Color(
                                              0xFFF5EFE0,
                                            ) /* cardFace */,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                width: 0.75,
                                                color: const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 44.05,
                                                top: 71.76,
                                                child: Text(
                                                  '10',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFFB74448,
                                                    ) /* suitRed */,
                                                    fontSize: 12,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.17,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 6.06,
                                                top: 3.09,
                                                child: Text(
                                                  '10',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFFB74448,
                                                    ) /* suitRed */,
                                                    fontSize: 20,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.20,
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
                          ),
                          Positioned(
                            left: 775,
                            top: 13.44,
                            child: Container(
                              transform: Matrix4.identity()
                                ..translate(0.0, 0.0)
                                ..rotateZ(0.03),
                              width: 62,
                              height: 88,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 64.28,
                                    height: 89.59,
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          width: 2,
                                          color: const Color(
                                            0xFFE6C56A,
                                          ) /* goldBright */,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 64.28,
                                          height: 89.59,
                                          decoration: ShapeDecoration(
                                            color: const Color(
                                              0xFFF5EFE0,
                                            ) /* cardFace */,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                width: 0.75,
                                                color: const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 44.06,
                                                top: 72.13,
                                                child: Text(
                                                  '5',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFFB74448,
                                                    ) /* suitRed */,
                                                    fontSize: 12,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.17,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 6.60,
                                                top: 3.13,
                                                child: Text(
                                                  '5',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFFB74448,
                                                    ) /* suitRed */,
                                                    fontSize: 20,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.20,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          child: Container(
                                            width: 64.28,
                                            height: 89.59,
                                            decoration: ShapeDecoration(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: Stack(
                                              children: [
                                                Positioned(
                                                  left: 0.77,
                                                  top: 0.77,
                                                  child: Container(
                                                    width: 62.74,
                                                    height: 88.05,
                                                    decoration: ShapeDecoration(
                                                      shape: RoundedRectangleBorder(
                                                        side: BorderSide(
                                                          width: 0.75,
                                                          color: const Color(
                                                            0xFFE6C56A,
                                                          ) /* goldBright */,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      shadows: [
                                                        BoxShadow(
                                                          color: Color(
                                                            0x66E6C56A,
                                                          ),
                                                          blurRadius: 12,
                                                          offset: Offset(0, 0),
                                                          spreadRadius: 2,
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
                              ),
                            ),
                          ),
                          Positioned(
                            left: 817,
                            top: 34.56,
                            child: Container(
                              transform: Matrix4.identity()
                                ..translate(0.0, 0.0)
                                ..rotateZ(0.03),
                              width: 62,
                              height: 88,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 65.03,
                                    height: 90.11,
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 65.03,
                                          height: 90.11,
                                          decoration: ShapeDecoration(
                                            color: const Color(
                                              0xFFF5EFE0,
                                            ) /* cardFace */,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                width: 0.75,
                                                color: const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 44.08,
                                                top: 72.49,
                                                child: Text(
                                                  'A',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFF22303E,
                                                    ) /* suitBlack */,
                                                    fontSize: 12,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.17,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 7.13,
                                                top: 3.17,
                                                child: Text(
                                                  'A',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFF22303E,
                                                    ) /* suitBlack */,
                                                    fontSize: 20,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.20,
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
                          ),
                          Positioned(
                            left: 859,
                            top: 35.99,
                            child: Container(
                              transform: Matrix4.identity()
                                ..translate(0.0, 0.0)
                                ..rotateZ(0.04),
                              width: 62,
                              height: 88,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 65.78,
                                    height: 90.62,
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 65.78,
                                          height: 90.62,
                                          decoration: ShapeDecoration(
                                            color: const Color(
                                              0xFFF5EFE0,
                                            ) /* cardFace */,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                width: 0.75,
                                                color: const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 44.09,
                                                top: 72.85,
                                                child: Text(
                                                  'Q',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFF22303E,
                                                    ) /* suitBlack */,
                                                    fontSize: 12,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.17,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 7.66,
                                                top: 3.22,
                                                child: Text(
                                                  'Q',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFF22303E,
                                                    ) /* suitBlack */,
                                                    fontSize: 20,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.20,
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
                          ),
                          Positioned(
                            left: 901,
                            top: 37.75,
                            child: Container(
                              transform: Matrix4.identity()
                                ..translate(0.0, 0.0)
                                ..rotateZ(0.05),
                              width: 62,
                              height: 88,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 66.52,
                                    height: 91.12,
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 66.52,
                                          height: 91.12,
                                          decoration: ShapeDecoration(
                                            color: const Color(
                                              0xFFF5EFE0,
                                            ) /* cardFace */,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                width: 0.75,
                                                color: const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 44.10,
                                                top: 73.21,
                                                child: Text(
                                                  '10',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFF22303E,
                                                    ) /* suitBlack */,
                                                    fontSize: 12,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.17,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 8.19,
                                                top: 3.26,
                                                child: Text(
                                                  '10',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFF22303E,
                                                    ) /* suitBlack */,
                                                    fontSize: 20,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.20,
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
                          ),
                          Positioned(
                            left: 943,
                            top: 39.83,
                            child: Container(
                              transform: Matrix4.identity()
                                ..translate(0.0, 0.0)
                                ..rotateZ(0.06),
                              width: 62,
                              height: 88,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 67.26,
                                    height: 91.62,
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 67.26,
                                          height: 91.62,
                                          decoration: ShapeDecoration(
                                            color: const Color(
                                              0xFFF5EFE0,
                                            ) /* cardFace */,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                width: 0.75,
                                                color: const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 44.10,
                                                top: 73.55,
                                                child: Text(
                                                  '7',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFF22303E,
                                                    ) /* suitBlack */,
                                                    fontSize: 12,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.17,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 8.71,
                                                top: 3.30,
                                                child: Text(
                                                  '7',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFF22303E,
                                                    ) /* suitBlack */,
                                                    fontSize: 20,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.20,
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
                          ),
                          Positioned(
                            left: 985,
                            top: 42.22,
                            child: Container(
                              transform: Matrix4.identity()
                                ..translate(0.0, 0.0)
                                ..rotateZ(0.07),
                              width: 62,
                              height: 88,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 67.99,
                                    height: 92.11,
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 67.99,
                                          height: 92.11,
                                          decoration: ShapeDecoration(
                                            color: const Color(
                                              0xFFF5EFE0,
                                            ) /* cardFace */,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                width: 0.75,
                                                color: const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 44.10,
                                                top: 73.90,
                                                child: Text(
                                                  '6',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFF22303E,
                                                    ) /* suitBlack */,
                                                    fontSize: 12,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.17,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 9.24,
                                                top: 3.34,
                                                child: Text(
                                                  '6',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFF22303E,
                                                    ) /* suitBlack */,
                                                    fontSize: 20,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.20,
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
                          ),
                          Positioned(
                            left: 1027,
                            top: 44.94,
                            child: Container(
                              transform: Matrix4.identity()
                                ..translate(0.0, 0.0)
                                ..rotateZ(0.08),
                              width: 62,
                              height: 88,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 68.71,
                                    height: 92.59,
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 68.71,
                                          height: 92.59,
                                          decoration: ShapeDecoration(
                                            color: const Color(
                                              0xFFF5EFE0,
                                            ) /* cardFace */,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                width: 0.75,
                                                color: const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 44.10,
                                                top: 74.23,
                                                child: Text(
                                                  'K',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFFB74448,
                                                    ) /* suitRed */,
                                                    fontSize: 12,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.17,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 9.77,
                                                top: 3.38,
                                                child: Text(
                                                  'K',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFFB74448,
                                                    ) /* suitRed */,
                                                    fontSize: 20,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.20,
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
                          ),
                          Positioned(
                            left: 1069,
                            top: 47.97,
                            child: Container(
                              transform: Matrix4.identity()
                                ..translate(0.0, 0.0)
                                ..rotateZ(0.09),
                              width: 62,
                              height: 88,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 69.43,
                                    height: 93.07,
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 69.43,
                                          height: 93.07,
                                          decoration: ShapeDecoration(
                                            color: const Color(
                                              0xFFF5EFE0,
                                            ) /* cardFace */,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                width: 0.75,
                                                color: const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 44.09,
                                                top: 74.56,
                                                child: Text(
                                                  'Q',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFFB74448,
                                                    ) /* suitRed */,
                                                    fontSize: 12,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.17,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 10.30,
                                                top: 3.42,
                                                child: Text(
                                                  'Q',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFFB74448,
                                                    ) /* suitRed */,
                                                    fontSize: 20,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.20,
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
                          ),
                          Positioned(
                            left: 1111,
                            top: 51.33,
                            child: Container(
                              transform: Matrix4.identity()
                                ..translate(0.0, 0.0)
                                ..rotateZ(0.10),
                              width: 62,
                              height: 88,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 70.15,
                                    height: 93.54,
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 70.15,
                                          height: 93.54,
                                          decoration: ShapeDecoration(
                                            color: const Color(
                                              0xFFF5EFE0,
                                            ) /* cardFace */,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                width: 0.75,
                                                color: const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 44.09,
                                                top: 74.89,
                                                child: Text(
                                                  '8',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFFB74448,
                                                    ) /* suitRed */,
                                                    fontSize: 12,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.17,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 10.82,
                                                top: 3.47,
                                                child: Text(
                                                  '8',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFFB74448,
                                                    ) /* suitRed */,
                                                    fontSize: 20,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.20,
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
                          ),
                          Positioned(
                            left: 1153,
                            top: 55,
                            child: Container(
                              transform: Matrix4.identity()
                                ..translate(0.0, 0.0)
                                ..rotateZ(0.10),
                              width: 62,
                              height: 88,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 70.86,
                                    height: 94,
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 70.86,
                                          height: 94,
                                          decoration: ShapeDecoration(
                                            color: const Color(
                                              0xFFF5EFE0,
                                            ) /* cardFace */,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                width: 0.75,
                                                color: const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 44.07,
                                                top: 75.21,
                                                child: Text(
                                                  '3',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFFB74448,
                                                    ) /* suitRed */,
                                                    fontSize: 12,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.17,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 11.35,
                                                top: 3.51,
                                                child: Text(
                                                  '3',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFFB74448,
                                                    ) /* suitRed */,
                                                    fontSize: 20,
                                                    fontFamily: 'Lora',
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.20,
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
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                height: 84,
                padding: const EdgeInsets.symmetric(horizontal: 32),
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: const Color(0xFF131A23) /* darkTokens-color-bgPanel */,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1, color: const Color(0xFF2C3035)),
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
                        spacing: 20,
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
                                Text(
                                  '主视角',
                                  style: TextStyle(
                                    color: const Color(
                                      0xFF9A917E,
                                    ) /* darkTokens-color-textSecondary */,
                                    fontSize: 11,
                                    fontFamily: 'Noto Sans SC',
                                    fontWeight: FontWeight.w400,
                                    height: 1.40,
                                  ),
                                ),
                                Container(
                                  width: 26,
                                  height: 30,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFF29251C),
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1,
                                        color: const Color(
                                          0xFFC9A24B,
                                        ) /* goldPrimary */,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        '1',
                                        style: TextStyle(
                                          color: const Color(
                                            0xFFE6C56A,
                                          ) /* goldBright */,
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
                                  width: 26,
                                  height: 30,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: const Color(
                                      0xFF131A23,
                                    ) /* darkTokens-color-bgPanel */,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1,
                                        color: const Color(0xFF2C3035),
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        '2',
                                        style: TextStyle(
                                          color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
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
                                  width: 26,
                                  height: 30,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: const Color(
                                      0xFF131A23,
                                    ) /* darkTokens-color-bgPanel */,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1,
                                        color: const Color(0xFF2C3035),
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        '3',
                                        style: TextStyle(
                                          color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
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
                                  width: 26,
                                  height: 30,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: const Color(
                                      0xFF131A23,
                                    ) /* darkTokens-color-bgPanel */,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1,
                                        color: const Color(0xFF2C3035),
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        '4',
                                        style: TextStyle(
                                          color: const Color(0xFF9A917E) /* darkTokens-color-textSecondary */,
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
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: 5,
                              children: [
                                Container(
                                  width: 19,
                                  height: 19,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(),
                                  child: Stack(),
                                ),
                                Text(
                                  '开牌 / 关牌',
                                  style: TextStyle(
                                    color: const Color(
                                      0xFF9A917E,
                                    ) /* darkTokens-color-textSecondary */,
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
