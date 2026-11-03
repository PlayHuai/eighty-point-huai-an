class GametableFinal extends StatelessWidget {
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
                            width: 20,
                            height: 20,
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
                        spacing: 26,
                        children: [
                          Text(
                            '好友房 8026 · 第 08 局',
                            style: TextStyle(
                              color: const Color(
                                0xFF9A917E,
                              ) /* darkTokens-color-textSecondary */,
                              fontSize: 13,
                              fontFamily: 'Noto Sans SC',
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
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 32),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFF131A23) /* darkTokens-color-bgPanel */,
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
                        spacing: 24,
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
                                Text(
                                  '我方',
                                  style: TextStyle(
                                    color: const Color(
                                      0xFF9A917E,
                                    ) /* darkTokens-color-textSecondary */,
                                    fontSize: 14,
                                    fontFamily: 'Noto Sans SC',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  '2',
                                  style: TextStyle(
                                    color: const Color(
                                      0xFFEDE8DB,
                                    ) /* darkTokens-color-textPrimary */,
                                    fontSize: 22,
                                    fontFamily: 'Noto Sans SC',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2C3035),
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
                              spacing: 12,
                              children: [
                                Text(
                                  '对方',
                                  style: TextStyle(
                                    color: const Color(
                                      0xFF9A917E,
                                    ) /* darkTokens-color-textSecondary */,
                                    fontSize: 14,
                                    fontFamily: 'Noto Sans SC',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  '2',
                                  style: TextStyle(
                                    color: const Color(
                                      0xFFEDE8DB,
                                    ) /* darkTokens-color-textPrimary */,
                                    fontSize: 22,
                                    fontFamily: 'Noto Sans SC',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2C3035),
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
                              spacing: 12,
                              children: [
                                Text(
                                  '主花色',
                                  style: TextStyle(
                                    color: const Color(
                                      0xFF9A917E,
                                    ) /* darkTokens-color-textSecondary */,
                                    fontSize: 14,
                                    fontFamily: 'Noto Sans SC',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  '♠',
                                  style: TextStyle(
                                    color: const Color(
                                      0xFFE6C56A,
                                    ) /* goldBright */,
                                    fontSize: 26,
                                    fontFamily: 'Noto Sans SC',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2C3035),
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
                              spacing: 12,
                              children: [
                                Text(
                                  '得分',
                                  style: TextStyle(
                                    color: const Color(
                                      0xFF9A917E,
                                    ) /* darkTokens-color-textSecondary */,
                                    fontSize: 14,
                                    fontFamily: 'Noto Sans SC',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  '55',
                                  style: TextStyle(
                                    color: const Color(
                                      0xFFE6C56A,
                                    ) /* goldBright */,
                                    fontSize: 22,
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
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(),
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
                              color: const Color(0xFFC9A24B) /* goldPrimary */,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                          Text(
                            '本局结算',
                            style: TextStyle(
                              color: const Color(
                                0xFF9A917E,
                              ) /* darkTokens-color-textSecondary */,
                              fontSize: 13,
                              fontFamily: 'Noto Sans SC',
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
                width: 1440,
                height: 460,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0E13) /* darkTokens-color-bgBase */,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 16,
                      top: 16,
                      child: Container(
                        width: 1408,
                        height: 428,
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
                      ),
                    ),
                    Positioned(
                      left: 410,
                      top: 135,
                      child: Container(
                        width: 620,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 18,
                          children: [
                            Container(
                              width: double.infinity,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 20,
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      decoration: BoxDecoration(
                                        color: const Color(0x26C9A24B),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '55分，我们输了',
                                    style: TextStyle(
                                      color: const Color(
                                        0xFFE6C56A,
                                      ) /* goldBright */,
                                      fontSize: 30,
                                      fontFamily: 'Noto Sans SC',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      decoration: BoxDecoration(
                                        color: const Color(0x26C9A24B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '本局底牌 · 已公开',
                              style: TextStyle(
                                color: const Color(
                                  0xFF9A917E,
                                ) /* darkTokens-color-textSecondary */,
                                fontSize: 12,
                                fontFamily: 'Noto Sans SC',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Container(
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 10,
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
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          left: 49,
                                          top: 70,
                                          child: Text(
                                            'A',
                                            style: TextStyle(
                                              color: const Color(
                                                0xFFB74448,
                                              ) /* suitRed */,
                                              fontSize: 12,
                                              fontFamily: 'Lora',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 27,
                                          top: 40,
                                          child: Text(
                                            '♦',
                                            style: TextStyle(
                                              color: const Color(
                                                0xFFB74448,
                                              ) /* suitRed */,
                                              fontSize: 30,
                                              fontFamily: 'Noto Sans SC',
                                              fontWeight: FontWeight.w400,
                                              height: 1,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 5,
                                          top: 25,
                                          child: Text(
                                            '♦',
                                            style: TextStyle(
                                              color: const Color(
                                                0xFFB74448,
                                              ) /* suitRed */,
                                              fontSize: 19,
                                              fontFamily: 'Noto Sans SC',
                                              fontWeight: FontWeight.w400,
                                              height: 1,
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
                                              height: 1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          left: 5,
                                          top: 67,
                                          child: Container(
                                            width: 13,
                                            height: 12,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: ShapeDecoration(
                                              color: const Color(
                                                0xFFC9A24B,
                                              ) /* goldPrimary */,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                              ),
                                            ),
                                            child: Stack(
                                              children: [
                                                Positioned(
                                                  left: 2,
                                                  top: 1,
                                                  child: Text(
                                                    '主',
                                                    style: TextStyle(
                                                      color: const Color(
                                                        0xFF22303E,
                                                      ) /* suitBlack */,
                                                      fontSize: 8,
                                                      fontFamily:
                                                          'Noto Sans SC',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 50,
                                          top: 70,
                                          child: Text(
                                            '3',
                                            style: TextStyle(
                                              color: const Color(
                                                0xFF22303E,
                                              ) /* suitBlack */,
                                              fontSize: 12,
                                              fontFamily: 'Lora',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 27,
                                          top: 40,
                                          child: Text(
                                            '♠',
                                            style: TextStyle(
                                              color: const Color(
                                                0xFF22303E,
                                              ) /* suitBlack */,
                                              fontSize: 30,
                                              fontFamily: 'Noto Sans SC',
                                              fontWeight: FontWeight.w400,
                                              height: 1,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 5,
                                          top: 25,
                                          child: Text(
                                            '♠',
                                            style: TextStyle(
                                              color: const Color(
                                                0xFF22303E,
                                              ) /* suitBlack */,
                                              fontSize: 19,
                                              fontFamily: 'Noto Sans SC',
                                              fontWeight: FontWeight.w400,
                                              height: 1,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 5,
                                          top: 3,
                                          child: Text(
                                            '3',
                                            style: TextStyle(
                                              color: const Color(
                                                0xFF22303E,
                                              ) /* suitBlack */,
                                              fontSize: 20,
                                              fontFamily: 'Lora',
                                              fontWeight: FontWeight.w700,
                                              height: 1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          left: 5,
                                          top: 67,
                                          child: Container(
                                            width: 13,
                                            height: 12,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: ShapeDecoration(
                                              color: const Color(
                                                0xFFC9A24B,
                                              ) /* goldPrimary */,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                              ),
                                            ),
                                            child: Stack(
                                              children: [
                                                Positioned(
                                                  left: 2,
                                                  top: 1,
                                                  child: Text(
                                                    '主',
                                                    style: TextStyle(
                                                      color: const Color(
                                                        0xFF22303E,
                                                      ) /* suitBlack */,
                                                      fontSize: 8,
                                                      fontFamily:
                                                          'Noto Sans SC',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 50,
                                          top: 70,
                                          child: Text(
                                            '5',
                                            style: TextStyle(
                                              color: const Color(
                                                0xFF22303E,
                                              ) /* suitBlack */,
                                              fontSize: 12,
                                              fontFamily: 'Lora',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 27,
                                          top: 40,
                                          child: Text(
                                            '♠',
                                            style: TextStyle(
                                              color: const Color(
                                                0xFF22303E,
                                              ) /* suitBlack */,
                                              fontSize: 30,
                                              fontFamily: 'Noto Sans SC',
                                              fontWeight: FontWeight.w400,
                                              height: 1,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 5,
                                          top: 25,
                                          child: Text(
                                            '♠',
                                            style: TextStyle(
                                              color: const Color(
                                                0xFF22303E,
                                              ) /* suitBlack */,
                                              fontSize: 19,
                                              fontFamily: 'Noto Sans SC',
                                              fontWeight: FontWeight.w400,
                                              height: 1,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 5,
                                          top: 3,
                                          child: Text(
                                            '5',
                                            style: TextStyle(
                                              color: const Color(
                                                0xFF22303E,
                                              ) /* suitBlack */,
                                              fontSize: 20,
                                              fontFamily: 'Lora',
                                              fontWeight: FontWeight.w700,
                                              height: 1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          left: 50,
                                          top: 70,
                                          child: Text(
                                            '5',
                                            style: TextStyle(
                                              color: const Color(
                                                0xFFB74448,
                                              ) /* suitRed */,
                                              fontSize: 12,
                                              fontFamily: 'Lora',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 27,
                                          top: 40,
                                          child: Text(
                                            '♥',
                                            style: TextStyle(
                                              color: const Color(
                                                0xFFB74448,
                                              ) /* suitRed */,
                                              fontSize: 30,
                                              fontFamily: 'Noto Sans SC',
                                              fontWeight: FontWeight.w400,
                                              height: 1,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 5,
                                          top: 25,
                                          child: Text(
                                            '♥',
                                            style: TextStyle(
                                              color: const Color(
                                                0xFFB74448,
                                              ) /* suitRed */,
                                              fontSize: 19,
                                              fontFamily: 'Noto Sans SC',
                                              fontWeight: FontWeight.w400,
                                              height: 1,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 5,
                                          top: 3,
                                          child: Text(
                                            '5',
                                            style: TextStyle(
                                              color: const Color(
                                                0xFFB74448,
                                              ) /* suitRed */,
                                              fontSize: 20,
                                              fontFamily: 'Lora',
                                              fontWeight: FontWeight.w700,
                                              height: 1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          left: 50,
                                          top: 70,
                                          child: Text(
                                            '8',
                                            style: TextStyle(
                                              color: const Color(
                                                0xFF22303E,
                                              ) /* suitBlack */,
                                              fontSize: 12,
                                              fontFamily: 'Lora',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 27,
                                          top: 40,
                                          child: Text(
                                            '♣',
                                            style: TextStyle(
                                              color: const Color(
                                                0xFF22303E,
                                              ) /* suitBlack */,
                                              fontSize: 30,
                                              fontFamily: 'Noto Sans SC',
                                              fontWeight: FontWeight.w400,
                                              height: 1,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 5,
                                          top: 25,
                                          child: Text(
                                            '♣',
                                            style: TextStyle(
                                              color: const Color(
                                                0xFF22303E,
                                              ) /* suitBlack */,
                                              fontSize: 19,
                                              fontFamily: 'Noto Sans SC',
                                              fontWeight: FontWeight.w400,
                                              height: 1,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 5,
                                          top: 3,
                                          child: Text(
                                            '8',
                                            style: TextStyle(
                                              color: const Color(
                                                0xFF22303E,
                                              ) /* suitBlack */,
                                              fontSize: 20,
                                              fontFamily: 'Lora',
                                              fontWeight: FontWeight.w700,
                                              height: 1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          left: 50,
                                          top: 70,
                                          child: Text(
                                            '9',
                                            style: TextStyle(
                                              color: const Color(
                                                0xFFB74448,
                                              ) /* suitRed */,
                                              fontSize: 12,
                                              fontFamily: 'Lora',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 27,
                                          top: 40,
                                          child: Text(
                                            '♥',
                                            style: TextStyle(
                                              color: const Color(
                                                0xFFB74448,
                                              ) /* suitRed */,
                                              fontSize: 30,
                                              fontFamily: 'Noto Sans SC',
                                              fontWeight: FontWeight.w400,
                                              height: 1,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 5,
                                          top: 25,
                                          child: Text(
                                            '♥',
                                            style: TextStyle(
                                              color: const Color(
                                                0xFFB74448,
                                              ) /* suitRed */,
                                              fontSize: 19,
                                              fontFamily: 'Noto Sans SC',
                                              fontWeight: FontWeight.w400,
                                              height: 1,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 5,
                                          top: 3,
                                          child: Text(
                                            '9',
                                            style: TextStyle(
                                              color: const Color(
                                                0xFFB74448,
                                              ) /* suitRed */,
                                              fontSize: 20,
                                              fontFamily: 'Lora',
                                              fontWeight: FontWeight.w700,
                                              height: 1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          left: 50,
                                          top: 70,
                                          child: Text(
                                            '8',
                                            style: TextStyle(
                                              color: const Color(
                                                0xFFB74448,
                                              ) /* suitRed */,
                                              fontSize: 12,
                                              fontFamily: 'Lora',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 27,
                                          top: 40,
                                          child: Text(
                                            '♦',
                                            style: TextStyle(
                                              color: const Color(
                                                0xFFB74448,
                                              ) /* suitRed */,
                                              fontSize: 30,
                                              fontFamily: 'Noto Sans SC',
                                              fontWeight: FontWeight.w400,
                                              height: 1,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 5,
                                          top: 25,
                                          child: Text(
                                            '♦',
                                            style: TextStyle(
                                              color: const Color(
                                                0xFFB74448,
                                              ) /* suitRed */,
                                              fontSize: 19,
                                              fontFamily: 'Noto Sans SC',
                                              fontWeight: FontWeight.w400,
                                              height: 1,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 5,
                                          top: 3,
                                          child: Text(
                                            '8',
                                            style: TextStyle(
                                              color: const Color(
                                                0xFFB74448,
                                              ) /* suitRed */,
                                              fontSize: 20,
                                              fontFamily: 'Lora',
                                              fontWeight: FontWeight.w700,
                                              height: 1,
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
                              '本局已结束，点击「准备」继续对局',
                              style: TextStyle(
                                color: const Color(
                                  0xFF9A917E,
                                ) /* darkTokens-color-textSecondary */,
                                fontSize: 13,
                                fontFamily: 'Noto Sans SC',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 1208,
                      top: 192,
                      child: Container(
                        width: 200,
                        height: 84,
                        padding: const EdgeInsets.all(10),
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 10,
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: const Color(0xFF29251C),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(),
                                    child: Stack(),
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
                                  spacing: 4,
                                  children: [
                                    Container(
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        spacing: 5,
                                        children: [
                                          Text(
                                            '运河老友',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Noto Sans SC',
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '等待准备',
                                      style: TextStyle(
                                        color: const Color(
                                          0xFF9A917E,
                                        ) /* darkTokens-color-textSecondary */,
                                        fontSize: 11,
                                        fontFamily: 'Noto Sans SC',
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
                    ),
                    Positioned(
                      left: 32,
                      top: 192,
                      child: Container(
                        width: 200,
                        height: 84,
                        padding: const EdgeInsets.all(10),
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 10,
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: const Color(0xFF29251C),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(),
                                    child: Stack(),
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
                                  spacing: 4,
                                  children: [
                                    Container(
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        spacing: 5,
                                        children: [
                                          Text(
                                            '清江月',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Noto Sans SC',
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '已准备',
                                      style: TextStyle(
                                        color: const Color(
                                          0xFF9A917E,
                                        ) /* darkTokens-color-textSecondary */,
                                        fontSize: 11,
                                        fontFamily: 'Noto Sans SC',
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
                    ),
                    Positioned(
                      left: 620,
                      top: 24,
                      child: Container(
                        width: 200,
                        height: 84,
                        padding: const EdgeInsets.all(10),
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 10,
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: const Color(0xFF29251C),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(),
                                    child: Stack(),
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
                                  spacing: 4,
                                  children: [
                                    Container(
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        spacing: 5,
                                        children: [
                                          Text(
                                            '淮上听风',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Noto Sans SC',
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Container(
                                            width: 15,
                                            height: 15,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(),
                                            child: Stack(),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '本局庄家 · 已结束',
                                      style: TextStyle(
                                        color: const Color(
                                          0xFF9A917E,
                                        ) /* darkTokens-color-textSecondary */,
                                        fontSize: 11,
                                        fontFamily: 'Noto Sans SC',
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
                    ),
                  ],
                ),
              ),
              Container(
                width: 1440,
                height: 252,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0E13) /* darkTokens-color-bgBase */,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 540,
                      top: 114,
                      child: Container(
                        width: 360,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 10,
                          children: [
                            Text(
                              '牌局结束，准备下一局',
                              style: TextStyle(
                                color: const Color(
                                  0xFFEDE8DB,
                                ) /* darkTokens-color-textPrimary */,
                                fontSize: 18,
                                fontFamily: 'Noto Sans SC',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              '已有 1 / 4 位玩家准备',
                              style: TextStyle(
                                color: const Color(
                                  0xFF9A917E,
                                ) /* darkTokens-color-textSecondary */,
                                fontSize: 13,
                                fontFamily: 'Noto Sans SC',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 32,
                      top: 110,
                      child: Container(
                        width: 200,
                        height: 84,
                        padding: const EdgeInsets.all(10),
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 10,
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: const Color(0xFF29251C),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(),
                                    child: Stack(),
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
                                  spacing: 4,
                                  children: [
                                    Container(
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        spacing: 5,
                                        children: [
                                          Text(
                                            '我',
                                            style: TextStyle(
                                              color: const Color(0xFFEDE8DB) /* darkTokens-color-textPrimary */,
                                              fontSize: 14,
                                              fontFamily: 'Noto Sans SC',
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '等待下一局',
                                      style: TextStyle(
                                        color: const Color(
                                          0xFF9A917E,
                                        ) /* darkTokens-color-textSecondary */,
                                        fontSize: 11,
                                        fontFamily: 'Noto Sans SC',
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
                    ),
                    Positioned(
                      left: 430,
                      top: 10,
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 12,
                          children: [
                            Container(
                              height: 46,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '托管',
                                    style: TextStyle(
                                      color: const Color(
                                        0xFFEDE8DB,
                                      ) /* darkTokens-color-textPrimary */,
                                      fontSize: 15,
                                      fontFamily: 'Noto Sans SC',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 46,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '抢主',
                                    style: TextStyle(
                                      color: const Color(
                                        0xFF595648,
                                      ) /* darkTokens-color-textDisabled */,
                                      fontSize: 15,
                                      fontFamily: 'Noto Sans SC',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 46,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '反主',
                                    style: TextStyle(
                                      color: const Color(
                                        0xFF595648,
                                      ) /* darkTokens-color-textDisabled */,
                                      fontSize: 15,
                                      fontFamily: 'Noto Sans SC',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 46,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '扣底',
                                    style: TextStyle(
                                      color: const Color(
                                        0xFF595648,
                                      ) /* darkTokens-color-textDisabled */,
                                      fontSize: 15,
                                      fontFamily: 'Noto Sans SC',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: 1505.90,
                                maxHeight: 55,
                              ),
                              child: Container(
                                width: 220,
                                height: 50,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
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
                                            '确认',
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
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
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
                                            '准备',
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
    );
  }
}
