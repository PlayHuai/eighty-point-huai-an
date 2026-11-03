class GametableStart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children [
        Container(
          width 1440,
          height 900,
          clipBehavior Clip.antiAlias,
          decoration BoxDecoration(
            color const Color(0xFF0A0E13)  darkTokens-color-bgBase ,
          ),
          child Column(
            mainAxisSize MainAxisSize.min,
            mainAxisAlignment MainAxisAlignment.start,
            crossAxisAlignment CrossAxisAlignment.start,
            children [
              Container(
                width double.infinity,
                height 72,
                padding const EdgeInsets.symmetric(horizontal 32),
                clipBehavior Clip.antiAlias,
                decoration ShapeDecoration(
                  shape RoundedRectangleBorder(
                    side BorderSide(
                      width 1,
                      color const Color(0xFF2C3035),
                    ),
                  ),
                ),
                child Row(
                  mainAxisSize MainAxisSize.min,
                  mainAxisAlignment MainAxisAlignment.spaceBetween,
                  crossAxisAlignment CrossAxisAlignment.center,
                  children [
                    Container(
                      clipBehavior Clip.antiAlias,
                      decoration BoxDecoration(),
                      child Row(
                        mainAxisSize MainAxisSize.min,
                        mainAxisAlignment MainAxisAlignment.start,
                        crossAxisAlignment CrossAxisAlignment.center,
                        spacing 18,
                        children [
                          Container(
                            width 20,
                            height 20,
                            clipBehavior Clip.antiAlias,
                            decoration BoxDecoration(),
                            child Stack(),
                          ),
                          Container(
                            width 36,
                            height 36,
                            clipBehavior Clip.antiAlias,
                            decoration ShapeDecoration(
                              shape RoundedRectangleBorder(
                                side BorderSide(
                                  width 1,
                                  color const Color(0xFFC9A24B)  goldPrimary ,
                                ),
                                borderRadius BorderRadius.circular(8),
                              ),
                            ),
                            child Row(
                              mainAxisSize MainAxisSize.min,
                              mainAxisAlignment MainAxisAlignment.center,
                              crossAxisAlignment CrossAxisAlignment.center,
                              children [
                                Text(
                                  '80',
                                  style TextStyle(
                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                    fontSize 22,
                                    fontFamily 'Inter',
                                    fontWeight FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '淮安80分',
                            style TextStyle(
                              color const Color(0xFFEDE8DB)  darkTokens-color-textPrimary ,
                              fontSize 24,
                              fontFamily 'Noto Sans SC',
                              fontWeight FontWeight.w700,
                              letterSpacing 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      clipBehavior Clip.antiAlias,
                      decoration BoxDecoration(),
                      child Row(
                        mainAxisSize MainAxisSize.min,
                        mainAxisAlignment MainAxisAlignment.start,
                        crossAxisAlignment CrossAxisAlignment.center,
                        spacing 26,
                        children [
                          Text(
                            '好友房 8026 · 第 08 局',
                            style TextStyle(
                              color const Color(0xFF9A917E)  darkTokens-color-textSecondary ,
                              fontSize 13,
                              fontFamily 'Noto Sans SC',
                              fontWeight FontWeight.w400,
                            ),
                          ),
                          Container(
                            width 20,
                            height 20,
                            clipBehavior Clip.antiAlias,
                            decoration BoxDecoration(),
                            child Stack(),
                          ),
                          Container(
                            width 20,
                            height 20,
                            clipBehavior Clip.antiAlias,
                            decoration BoxDecoration(),
                            child Stack(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width double.infinity,
                height 64,
                padding const EdgeInsets.symmetric(horizontal 32),
                clipBehavior Clip.antiAlias,
                decoration BoxDecoration(
                  color const Color(0xFF131A23)  darkTokens-color-bgPanel ,
                ),
                child Row(
                  mainAxisSize MainAxisSize.min,
                  mainAxisAlignment MainAxisAlignment.spaceBetween,
                  crossAxisAlignment CrossAxisAlignment.center,
                  children [
                    Container(
                      clipBehavior Clip.antiAlias,
                      decoration BoxDecoration(),
                      child Row(
                        mainAxisSize MainAxisSize.min,
                        mainAxisAlignment MainAxisAlignment.start,
                        crossAxisAlignment CrossAxisAlignment.center,
                        spacing 24,
                        children [
                          Container(
                            clipBehavior Clip.antiAlias,
                            decoration BoxDecoration(),
                            child Row(
                              mainAxisSize MainAxisSize.min,
                              mainAxisAlignment MainAxisAlignment.start,
                              crossAxisAlignment CrossAxisAlignment.center,
                              spacing 12,
                              children [
                                Text(
                                  '我方',
                                  style TextStyle(
                                    color const Color(0xFF9A917E)  darkTokens-color-textSecondary ,
                                    fontSize 14,
                                    fontFamily 'Noto Sans SC',
                                    fontWeight FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  '2',
                                  style TextStyle(
                                    color const Color(0xFFEDE8DB)  darkTokens-color-textPrimary ,
                                    fontSize 22,
                                    fontFamily 'Noto Sans SC',
                                    fontWeight FontWeight.w700,
                                  ),
                                ),
                                Container(
                                  width 1,
                                  height 20,
                                  decoration BoxDecoration(color const Color(0xFF2C3035)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            clipBehavior Clip.antiAlias,
                            decoration BoxDecoration(),
                            child Row(
                              mainAxisSize MainAxisSize.min,
                              mainAxisAlignment MainAxisAlignment.start,
                              crossAxisAlignment CrossAxisAlignment.center,
                              spacing 12,
                              children [
                                Text(
                                  '对方',
                                  style TextStyle(
                                    color const Color(0xFF9A917E)  darkTokens-color-textSecondary ,
                                    fontSize 14,
                                    fontFamily 'Noto Sans SC',
                                    fontWeight FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  '2',
                                  style TextStyle(
                                    color const Color(0xFFEDE8DB)  darkTokens-color-textPrimary ,
                                    fontSize 22,
                                    fontFamily 'Noto Sans SC',
                                    fontWeight FontWeight.w700,
                                  ),
                                ),
                                Container(
                                  width 1,
                                  height 20,
                                  decoration BoxDecoration(color const Color(0xFF2C3035)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            clipBehavior Clip.antiAlias,
                            decoration BoxDecoration(),
                            child Row(
                              mainAxisSize MainAxisSize.min,
                              mainAxisAlignment MainAxisAlignment.start,
                              crossAxisAlignment CrossAxisAlignment.center,
                              spacing 12,
                              children [
                                Text(
                                  '主花色',
                                  style TextStyle(
                                    color const Color(0xFF9A917E)  darkTokens-color-textSecondary ,
                                    fontSize 14,
                                    fontFamily 'Noto Sans SC',
                                    fontWeight FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  '♠',
                                  style TextStyle(
                                    color const Color(0xFFE6C56A)  goldBright ,
                                    fontSize 26,
                                    fontFamily 'Noto Sans SC',
                                    fontWeight FontWeight.w700,
                                  ),
                                ),
                                Container(
                                  width 1,
                                  height 20,
                                  decoration BoxDecoration(color const Color(0xFF2C3035)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            clipBehavior Clip.antiAlias,
                            decoration BoxDecoration(),
                            child Row(
                              mainAxisSize MainAxisSize.min,
                              mainAxisAlignment MainAxisAlignment.start,
                              crossAxisAlignment CrossAxisAlignment.center,
                              spacing 12,
                              children [
                                Text(
                                  '得分',
                                  style TextStyle(
                                    color const Color(0xFF9A917E)  darkTokens-color-textSecondary ,
                                    fontSize 14,
                                    fontFamily 'Noto Sans SC',
                                    fontWeight FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  '40',
                                  style TextStyle(
                                    color const Color(0xFFE6C56A)  goldBright ,
                                    fontSize 22,
                                    fontFamily 'Noto Sans SC',
                                    fontWeight FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      clipBehavior Clip.antiAlias,
                      decoration BoxDecoration(),
                      child Row(
                        mainAxisSize MainAxisSize.min,
                        mainAxisAlignment MainAxisAlignment.start,
                        crossAxisAlignment CrossAxisAlignment.center,
                        spacing 8,
                        children [
                          Container(
                            width 5,
                            height 5,
                            decoration ShapeDecoration(
                              color const Color(0xFFC9A24B)  goldPrimary ,
                              shape RoundedRectangleBorder(borderRadius BorderRadius.circular(3)),
                            ),
                          ),
                          Text(
                            '发牌  亮主',
                            style TextStyle(
                              color const Color(0xFF9A917E)  darkTokens-color-textSecondary ,
                              fontSize 13,
                              fontFamily 'Noto Sans SC',
                              fontWeight FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width 1440,
                height 460,
                clipBehavior Clip.antiAlias,
                decoration BoxDecoration(
                  color const Color(0xFF0A0E13)  darkTokens-color-bgBase ,
                ),
                child Stack(
                  children [
                    Positioned(
                      left 16,
                      top 16,
                      child Container(
                        width 1408,
                        height 428,
                        clipBehavior Clip.antiAlias,
                        decoration ShapeDecoration(
                          color const Color(0xFF131A23)  darkTokens-color-bgPanel ,
                          shape RoundedRectangleBorder(
                            side BorderSide(
                              width 1,
                              color const Color(0xFF2C3035),
                            ),
                            borderRadius BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left 650,
                      top 282,
                      child Opacity(
                        opacity 0.30,
                        child Text(
                          'HUAIAN · 80',
                          style TextStyle(
                            color const Color(0xFF9A917E)  darkTokens-color-textSecondary ,
                            fontSize 11,
                            fontFamily 'Inter',
                            fontWeight FontWeight.w400,
                            letterSpacing 4,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left 232,
                      top 234,
                      child Container(
                        width 976,
                        height 1,
                        decoration BoxDecoration(color const Color(0x26C9A24B)),
                      ),
                    ),
                    Positioned(
                      left 719,
                      top 104,
                      child Container(
                        width 1,
                        height 302,
                        decoration BoxDecoration(color const Color(0x26C9A24B)),
                      ),
                    ),
                    Positioned(
                      left 472,
                      top 294,
                      child Container(
                        width 496,
                        padding const EdgeInsets.all(16),
                        clipBehavior Clip.antiAlias,
                        decoration ShapeDecoration(
                          color const Color(0xFF0A0E13)  darkTokens-color-bgBase ,
                          shape RoundedRectangleBorder(
                            side BorderSide(
                              width 1,
                              color const Color(0xFF2C3035),
                            ),
                            borderRadius BorderRadius.circular(12),
                          ),
                        ),
                        child Column(
                          mainAxisSize MainAxisSize.min,
                          mainAxisAlignment MainAxisAlignment.start,
                          crossAxisAlignment CrossAxisAlignment.center,
                          spacing 12,
                          children [
                            Container(
                              width double.infinity,
                              clipBehavior Clip.antiAlias,
                              decoration BoxDecoration(),
                              child Row(
                                mainAxisSize MainAxisSize.min,
                                mainAxisAlignment MainAxisAlignment.spaceBetween,
                                crossAxisAlignment CrossAxisAlignment.center,
                                children [
                                  Text(
                                    '亮主',
                                    style TextStyle(
                                      color const Color(0xFFEDE8DB)  darkTokens-color-textPrimary ,
                                      fontSize 16,
                                      fontFamily 'Noto Sans SC',
                                      fontWeight FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '选择花色，点击确认',
                                    style TextStyle(
                                      color const Color(0xFF9A917E)  darkTokens-color-textSecondary ,
                                      fontSize 12,
                                      fontFamily 'Noto Sans SC',
                                      fontWeight FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              clipBehavior Clip.antiAlias,
                              decoration BoxDecoration(),
                              child Row(
                                mainAxisSize MainAxisSize.min,
                                mainAxisAlignment MainAxisAlignment.start,
                                crossAxisAlignment CrossAxisAlignment.start,
                                spacing 12,
                                children [
                                  Container(
                                    width 106,
                                    height 48,
                                    clipBehavior Clip.antiAlias,
                                    decoration ShapeDecoration(
                                      color const Color(0xFF29251C),
                                      shape RoundedRectangleBorder(
                                        side BorderSide(
                                          width 1,
                                          color const Color(0xFFC9A24B)  goldPrimary ,
                                        ),
                                        borderRadius BorderRadius.circular(8),
                                      ),
                                    ),
                                    child Row(
                                      mainAxisSize MainAxisSize.min,
                                      mainAxisAlignment MainAxisAlignment.center,
                                      crossAxisAlignment CrossAxisAlignment.center,
                                      children [
                                        Text(
                                          '♠',
                                          style TextStyle(
                                            color const Color(0xFFE6C56A)  goldBright ,
                                            fontSize 30,
                                            fontFamily 'Noto Sans SC',
                                            fontWeight FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width 106,
                                    height 48,
                                    clipBehavior Clip.antiAlias,
                                    decoration ShapeDecoration(
                                      color const Color(0xFF131A23)  darkTokens-color-bgPanel ,
                                      shape RoundedRectangleBorder(
                                        side BorderSide(
                                          width 1,
                                          color const Color(0xFF2C3035),
                                        ),
                                        borderRadius BorderRadius.circular(8),
                                      ),
                                    ),
                                    child Row(
                                      mainAxisSize MainAxisSize.min,
                                      mainAxisAlignment MainAxisAlignment.center,
                                      crossAxisAlignment CrossAxisAlignment.center,
                                      children [
                                        Text(
                                          '♥',
                                          style TextStyle(
                                            color const Color(0xFFB74448)  suitRed ,
                                            fontSize 30,
                                            fontFamily 'Noto Sans SC',
                                            fontWeight FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width 106,
                                    height 48,
                                    clipBehavior Clip.antiAlias,
                                    decoration ShapeDecoration(
                                      color const Color(0xFF131A23)  darkTokens-color-bgPanel ,
                                      shape RoundedRectangleBorder(
                                        side BorderSide(
                                          width 1,
                                          color const Color(0xFF2C3035),
                                        ),
                                        borderRadius BorderRadius.circular(8),
                                      ),
                                    ),
                                    child Row(
                                      mainAxisSize MainAxisSize.min,
                                      mainAxisAlignment MainAxisAlignment.center,
                                      crossAxisAlignment CrossAxisAlignment.center,
                                      children [
                                        Text(
                                          '♣',
                                          style TextStyle(
                                            color const Color(0xFFEDE8DB)  darkTokens-color-textPrimary ,
                                            fontSize 30,
                                            fontFamily 'Noto Sans SC',
                                            fontWeight FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width 106,
                                    height 48,
                                    clipBehavior Clip.antiAlias,
                                    decoration ShapeDecoration(
                                      color const Color(0xFF131A23)  darkTokens-color-bgPanel ,
                                      shape RoundedRectangleBorder(
                                        side BorderSide(
                                          width 1,
                                          color const Color(0xFF2C3035),
                                        ),
                                        borderRadius BorderRadius.circular(8),
                                      ),
                                    ),
                                    child Row(
                                      mainAxisSize MainAxisSize.min,
                                      mainAxisAlignment MainAxisAlignment.center,
                                      crossAxisAlignment CrossAxisAlignment.center,
                                      children [
                                        Text(
                                          '♦',
                                          style TextStyle(
                                            color const Color(0xFFB74448)  suitRed ,
                                            fontSize 30,
                                            fontFamily 'Noto Sans SC',
                                            fontWeight FontWeight.w400,
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
                      left 580,
                      top 133,
                      child Container(
                        width 280,
                        clipBehavior Clip.antiAlias,
                        decoration BoxDecoration(),
                        child Column(
                          mainAxisSize MainAxisSize.min,
                          mainAxisAlignment MainAxisAlignment.start,
                          crossAxisAlignment CrossAxisAlignment.center,
                          spacing 10,
                          children [
                            Container(
                              clipBehavior Clip.antiAlias,
                              decoration BoxDecoration(),
                              child Row(
                                mainAxisSize MainAxisSize.min,
                                mainAxisAlignment MainAxisAlignment.start,
                                crossAxisAlignment CrossAxisAlignment.center,
                                children [
                                  Container(
                                    width 62,
                                    height 88,
                                    decoration ShapeDecoration(
                                      color const Color(0xFF22303E)  cardBack ,
                                      shape RoundedRectangleBorder(
                                        side BorderSide(
                                          width 1,
                                          color const Color(0xFFC9A24B)  goldPrimary ,
                                        ),
                                        borderRadius BorderRadius.circular(8),
                                      ),
                                    ),
                                    child Stack(
                                      children [
                                        Positioned(
                                          left 3,
                                          top 3,
                                          child Container(
                                            width 56,
                                            height 82,
                                            decoration ShapeDecoration(
                                              shape RoundedRectangleBorder(
                                                side BorderSide(
                                                  width 0.75,
                                                  color const Color(0xFFC9A24B)  goldPrimary ,
                                                ),
                                                borderRadius BorderRadius.circular(5),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left 6,
                                          top 10,
                                          child Opacity(
                                            opacity 0.12,
                                            child Container(
                                              width 50,
                                              height 0.50,
                                              decoration ShapeDecoration(
                                                shape RoundedRectangleBorder(
                                                  side BorderSide(
                                                    width 0.75,
                                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left 6,
                                          top 18,
                                          child Opacity(
                                            opacity 0.12,
                                            child Container(
                                              width 50,
                                              height 0.50,
                                              decoration ShapeDecoration(
                                                shape RoundedRectangleBorder(
                                                  side BorderSide(
                                                    width 0.75,
                                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left 6,
                                          top 26,
                                          child Opacity(
                                            opacity 0.12,
                                            child Container(
                                              width 50,
                                              height 0.50,
                                              decoration ShapeDecoration(
                                                shape RoundedRectangleBorder(
                                                  side BorderSide(
                                                    width 0.75,
                                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left 6,
                                          top 34,
                                          child Opacity(
                                            opacity 0.12,
                                            child Container(
                                              width 50,
                                              height 0.50,
                                              decoration ShapeDecoration(
                                                shape RoundedRectangleBorder(
                                                  side BorderSide(
                                                    width 0.75,
                                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left 6,
                                          top 42,
                                          child Opacity(
                                            opacity 0.12,
                                            child Container(
                                              width 50,
                                              height 0.50,
                                              decoration ShapeDecoration(
                                                shape RoundedRectangleBorder(
                                                  side BorderSide(
                                                    width 0.75,
                                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left 6,
                                          top 50,
                                          child Opacity(
                                            opacity 0.12,
                                            child Container(
                                              width 50,
                                              height 0.50,
                                              decoration ShapeDecoration(
                                                shape RoundedRectangleBorder(
                                                  side BorderSide(
                                                    width 0.75,
                                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left 6,
                                          top 58,
                                          child Opacity(
                                            opacity 0.12,
                                            child Container(
                                              width 50,
                                              height 0.50,
                                              decoration ShapeDecoration(
                                                shape RoundedRectangleBorder(
                                                  side BorderSide(
                                                    width 0.75,
                                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left 6,
                                          top 66,
                                          child Opacity(
                                            opacity 0.12,
                                            child Container(
                                              width 50,
                                              height 0.50,
                                              decoration ShapeDecoration(
                                                shape RoundedRectangleBorder(
                                                  side BorderSide(
                                                    width 0.75,
                                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left 6,
                                          top 74,
                                          child Opacity(
                                            opacity 0.12,
                                            child Container(
                                              width 50,
                                              height 0.50,
                                              decoration ShapeDecoration(
                                                shape RoundedRectangleBorder(
                                                  side BorderSide(
                                                    width 0.75,
                                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left 6,
                                          top 82,
                                          child Opacity(
                                            opacity 0.12,
                                            child Container(
                                              width 50,
                                              height 0.50,
                                              decoration ShapeDecoration(
                                                shape RoundedRectangleBorder(
                                                  side BorderSide(
                                                    width 0.75,
                                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left 31,
                                          top 32.12,
                                          child Container(
                                            transform Matrix4.identity()..translate(0.0, 0.0)..rotateZ(-0.79),
                                            width 22,
                                            height 16,
                                            decoration ShapeDecoration(
                                              shape RoundedRectangleBorder(
                                                side BorderSide(
                                                  width 0.75,
                                                  color const Color(0xFFC9A24B)  goldPrimary ,
                                                ),
                                                borderRadius BorderRadius.circular(2),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left 30.50,
                                          top 28,
                                          child Container(
                                            width 1,
                                            height 32,
                                            decoration BoxDecoration(
                                              color const Color(0xFFC9A24B)  goldPrimary ,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left 23,
                                          top 43.50,
                                          child Container(
                                            width 16,
                                            height 1,
                                            decoration BoxDecoration(
                                              color const Color(0xFFC9A24B)  goldPrimary ,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width 62,
                                    height 88,
                                    decoration ShapeDecoration(
                                      color const Color(0xFF22303E)  cardBack ,
                                      shape RoundedRectangleBorder(
                                        side BorderSide(
                                          width 1,
                                          color const Color(0xFFC9A24B)  goldPrimary ,
                                        ),
                                        borderRadius BorderRadius.circular(8),
                                      ),
                                    ),
                                    child Stack(
                                      children [
                                        Positioned(
                                          left 3,
                                          top 3,
                                          child Container(
                                            width 56,
                                            height 82,
                                            decoration ShapeDecoration(
                                              shape RoundedRectangleBorder(
                                                side BorderSide(
                                                  width 0.75,
                                                  color const Color(0xFFC9A24B)  goldPrimary ,
                                                ),
                                                borderRadius BorderRadius.circular(5),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left 6,
                                          top 10,
                                          child Opacity(
                                            opacity 0.12,
                                            child Container(
                                              width 50,
                                              height 0.50,
                                              decoration ShapeDecoration(
                                                shape RoundedRectangleBorder(
                                                  side BorderSide(
                                                    width 0.75,
                                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left 6,
                                          top 18,
                                          child Opacity(
                                            opacity 0.12,
                                            child Container(
                                              width 50,
                                              height 0.50,
                                              decoration ShapeDecoration(
                                                shape RoundedRectangleBorder(
                                                  side BorderSide(
                                                    width 0.75,
                                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left 6,
                                          top 26,
                                          child Opacity(
                                            opacity 0.12,
                                            child Container(
                                              width 50,
                                              height 0.50,
                                              decoration ShapeDecoration(
                                                shape RoundedRectangleBorder(
                                                  side BorderSide(
                                                    width 0.75,
                                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left 6,
                                          top 34,
                                          child Opacity(
                                            opacity 0.12,
                                            child Container(
                                              width 50,
                                              height 0.50,
                                              decoration ShapeDecoration(
                                                shape RoundedRectangleBorder(
                                                  side BorderSide(
                                                    width 0.75,
                                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left 6,
                                          top 42,
                                          child Opacity(
                                            opacity 0.12,
                                            child Container(
                                              width 50,
                                              height 0.50,
                                              decoration ShapeDecoration(
                                                shape RoundedRectangleBorder(
                                                  side BorderSide(
                                                    width 0.75,
                                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left 6,
                                          top 50,
                                          child Opacity(
                                            opacity 0.12,
                                            child Container(
                                              width 50,
                                              height 0.50,
                                              decoration ShapeDecoration(
                                                shape RoundedRectangleBorder(
                                                  side BorderSide(
                                                    width 0.75,
                                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left 6,
                                          top 58,
                                          child Opacity(
                                            opacity 0.12,
                                            child Container(
                                              width 50,
                                              height 0.50,
                                              decoration ShapeDecoration(
                                                shape RoundedRectangleBorder(
                                                  side BorderSide(
                                                    width 0.75,
                                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left 6,
                                          top 66,
                                          child Opacity(
                                            opacity 0.12,
                                            child Container(
                                              width 50,
                                              height 0.50,
                                              decoration ShapeDecoration(
                                                shape RoundedRectangleBorder(
                                                  side BorderSide(
                                                    width 0.75,
                                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left 6,
                                          top 74,
                                          child Opacity(
                                            opacity 0.12,
                                            child Container(
                                              width 50,
                                              height 0.50,
                                              decoration ShapeDecoration(
                                                shape RoundedRectangleBorder(
                                                  side BorderSide(
                                                    width 0.75,
                                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left 6,
                                          top 82,
                                          child Opacity(
                                            opacity 0.12,
                                            child Container(
                                              width 50,
                                              height 0.50,
                                              decoration ShapeDecoration(
                                                shape RoundedRectangleBorder(
                                                  side BorderSide(
                                                    width 0.75,
                                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left 31,
                                          top 32.12,
                                          child Container(
                                            transform Matrix4.identity()..translate(0.0, 0.0)..rotateZ(-0.79),
                                            width 22,
                                            height 16,
                                            decoration ShapeDecoration(
                                              shape RoundedRectangleBorder(
                                                side BorderSide(
                                                  width 0.75,
                                                  color const Color(0xFFC9A24B)  goldPrimary ,
                                                ),
                                                borderRadius BorderRadius.circular(2),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left 30.50,
                                          top 28,
                                          child Container(
                                            width 1,
                                            height 32,
                                            decoration BoxDecoration(
                                              color const Color(0xFFC9A24B)  goldPrimary ,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left 23,
                                          top 43.50,
                                          child Container(
                                            width 16,
                                            height 1,
                                            decoration BoxDecoration(
                                              color const Color(0xFFC9A24B)  goldPrimary ,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width 62,
                                    height 88,
                                    decoration ShapeDecoration(
                                      color const Color(0xFF22303E)  cardBack ,
                                      shape RoundedRectangleBorder(
                                        side BorderSide(
                                          width 1,
                                          color const Color(0xFFC9A24B)  goldPrimary ,
                                        ),
                                        borderRadius BorderRadius.circular(8),
                                      ),
                                    ),
                                    child Stack(
                                      children [
                                        Positioned(
                                          left 3,
                                          top 3,
                                          child Container(
                                            width 56,
                                            height 82,
                                            decoration ShapeDecoration(
                                              shape RoundedRectangleBorder(
                                                side BorderSide(
                                                  width 0.75,
                                                  color const Color(0xFFC9A24B)  goldPrimary ,
                                                ),
                                                borderRadius BorderRadius.circular(5),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left 6,
                                          top 10,
                                          child Opacity(
                                            opacity 0.12,
                                            child Container(
                                              width 50,
                                              height 0.50,
                                              decoration ShapeDecoration(
                                                shape RoundedRectangleBorder(
                                                  side BorderSide(
                                                    width 0.75,
                                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left 6,
                                          top 18,
                                          child Opacity(
                                            opacity 0.12,
                                            child Container(
                                              width 50,
                                              height 0.50,
                                              decoration ShapeDecoration(
                                                shape RoundedRectangleBorder(
                                                  side BorderSide(
                                                    width 0.75,
                                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left 6,
                                          top 26,
                                          child Opacity(
                                            opacity 0.12,
                                            child Container(
                                              width 50,
                                              height 0.50,
                                              decoration ShapeDecoration(
                                                shape RoundedRectangleBorder(
                                                  side BorderSide(
                                                    width 0.75,
                                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left 6,
                                          top 34,
                                          child Opacity(
                                            opacity 0.12,
                                            child Container(
                                              width 50,
                                              height 0.50,
                                              decoration ShapeDecoration(
                                                shape RoundedRectangleBorder(
                                                  side BorderSide(
                                                    width 0.75,
                                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left 6,
                                          top 42,
                                          child Opacity(
                                            opacity 0.12,
                                            child Container(
                                              width 50,
                                              height 0.50,
                                              decoration ShapeDecoration(
                                                shape RoundedRectangleBorder(
                                                  side BorderSide(
                                                    width 0.75,
                                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left 6,
                                          top 50,
                                          child Opacity(
                                            opacity 0.12,
                                            child Container(
                                              width 50,
                                              height 0.50,
                                              decoration ShapeDecoration(
                                                shape RoundedRectangleBorder(
                                                  side BorderSide(
                                                    width 0.75,
                                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left 6,
                                          top 58,
                                          child Opacity(
                                            opacity 0.12,
                                            child Container(
                                              width 50,
                                              height 0.50,
                                              decoration ShapeDecoration(
                                                shape RoundedRectangleBorder(
                                                  side BorderSide(
                                                    width 0.75,
                                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left 6,
                                          top 66,
                                          child Opacity(
                                            opacity 0.12,
                                            child Container(
                                              width 50,
                                              height 0.50,
                                              decoration ShapeDecoration(
                                                shape RoundedRectangleBorder(
                                                  side BorderSide(
                                                    width 0.75,
                                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left 6,
                                          top 74,
                                          child Opacity(
                                            opacity 0.12,
                                            child Container(
                                              width 50,
                                              height 0.50,
                                              decoration ShapeDecoration(
                                                shape RoundedRectangleBorder(
                                                  side BorderSide(
                                                    width 0.75,
                                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left 6,
                                          top 82,
                                          child Opacity(
                                            opacity 0.12,
                                            child Container(
                                              width 50,
                                              height 0.50,
                                              decoration ShapeDecoration(
                                                shape RoundedRectangleBorder(
                                                  side BorderSide(
                                                    width 0.75,
                                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left 31,
                                          top 32.12,
                                          child Container(
                                            transform Matrix4.identity()..translate(0.0, 0.0)..rotateZ(-0.79),
                                            width 22,
                                            height 16,
                                            decoration ShapeDecoration(
                                              shape RoundedRectangleBorder(
                                                side BorderSide(
                                                  width 0.75,
                                                  color const Color(0xFFC9A24B)  goldPrimary ,
                                                ),
                                                borderRadius BorderRadius.circular(2),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left 30.50,
                                          top 28,
                                          child Container(
                                            width 1,
                                            height 32,
                                            decoration BoxDecoration(
                                              color const Color(0xFFC9A24B)  goldPrimary ,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left 23,
                                          top 43.50,
                                          child Container(
                                            width 16,
                                            height 1,
                                            decoration BoxDecoration(
                                              color const Color(0xFFC9A24B)  goldPrimary ,
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
                              '正在发牌…',
                              style TextStyle(
                                color const Color(0xFF9A917E)  darkTokens-color-textSecondary ,
                                fontSize 14,
                                fontFamily 'Noto Sans SC',
                                fontWeight FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left 32,
                      top 32,
                      child Container(
                        padding const EdgeInsets.all(12),
                        clipBehavior Clip.antiAlias,
                        decoration ShapeDecoration(
                          color const Color(0xFF131A23)  darkTokens-color-bgPanel ,
                          shape RoundedRectangleBorder(
                            side BorderSide(
                              width 1,
                              color const Color(0xFF2C3035),
                            ),
                            borderRadius BorderRadius.circular(12),
                          ),
                        ),
                        child Column(
                          mainAxisSize MainAxisSize.min,
                          mainAxisAlignment MainAxisAlignment.start,
                          crossAxisAlignment CrossAxisAlignment.start,
                          spacing 8,
                          children [
                            Text(
                              '底牌',
                              style TextStyle(
                                color const Color(0xFF9A917E)  darkTokens-color-textSecondary ,
                                fontSize 12,
                                fontFamily 'Noto Sans SC',
                                fontWeight FontWeight.w400,
                              ),
                            ),
                            Container(
                              clipBehavior Clip.antiAlias,
                              decoration BoxDecoration(),
                              child Row(
                                mainAxisSize MainAxisSize.min,
                                mainAxisAlignment MainAxisAlignment.start,
                                crossAxisAlignment CrossAxisAlignment.start,
                                spacing 5,
                                children [
                                  Container(
                                    width 24.18,
                                    height 34.32,
                                    clipBehavior Clip.antiAlias,
                                    decoration BoxDecoration(),
                                    child Stack(
                                      children [
                                        Positioned(
                                          left 0,
                                          top 0,
                                          child Container(
                                            width 24.18,
                                            height 34.32,
                                            decoration ShapeDecoration(
                                              color const Color(0xFF22303E)  cardBack ,
                                              shape RoundedRectangleBorder(
                                                side BorderSide(
                                                  width 0.39,
                                                  color const Color(0xFFC9A24B)  goldPrimary ,
                                                ),
                                                borderRadius BorderRadius.circular(3.12),
                                              ),
                                            ),
                                            child Stack(
                                              children [
                                                Positioned(
                                                  left 1.17,
                                                  top 1.17,
                                                  child Container(
                                                    width 21.84,
                                                    height 31.98,
                                                    decoration ShapeDecoration(
                                                      shape RoundedRectangleBorder(
                                                        side BorderSide(
                                                          width 0.29,
                                                          color const Color(0xFFC9A24B)  goldPrimary ,
                                                        ),
                                                        borderRadius BorderRadius.circular(1.95),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 3.90,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 7.02,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 10.14,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 13.26,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 16.38,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 19.50,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 22.62,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 25.74,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 28.86,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 31.98,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 12.09,
                                                  top 14.11,
                                                  child Container(
                                                    transform Matrix4.identity()..translate(0.0, 0.0)..rotateZ(-0.79),
                                                    width 10.82,
                                                    height 4,
                                                    decoration ShapeDecoration(
                                                      shape RoundedRectangleBorder(
                                                        side BorderSide(
                                                          width 0.29,
                                                          color const Color(0xFFC9A24B)  goldPrimary ,
                                                        ),
                                                        borderRadius BorderRadius.circular(0.78),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 11.90,
                                                  top 10.92,
                                                  child Container(
                                                    width 0.39,
                                                    height 12.48,
                                                    decoration BoxDecoration(
                                                      color const Color(0xFFC9A24B)  goldPrimary ,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 8.97,
                                                  top 16.97,
                                                  child Container(
                                                    width 6.24,
                                                    height 0.39,
                                                    decoration BoxDecoration(
                                                      color const Color(0xFFC9A24B)  goldPrimary ,
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
                                    width 24.18,
                                    height 34.32,
                                    clipBehavior Clip.antiAlias,
                                    decoration BoxDecoration(),
                                    child Stack(
                                      children [
                                        Positioned(
                                          left 0,
                                          top 0,
                                          child Container(
                                            width 24.18,
                                            height 34.32,
                                            decoration ShapeDecoration(
                                              color const Color(0xFF22303E)  cardBack ,
                                              shape RoundedRectangleBorder(
                                                side BorderSide(
                                                  width 0.39,
                                                  color const Color(0xFFC9A24B)  goldPrimary ,
                                                ),
                                                borderRadius BorderRadius.circular(3.12),
                                              ),
                                            ),
                                            child Stack(
                                              children [
                                                Positioned(
                                                  left 1.17,
                                                  top 1.17,
                                                  child Container(
                                                    width 21.84,
                                                    height 31.98,
                                                    decoration ShapeDecoration(
                                                      shape RoundedRectangleBorder(
                                                        side BorderSide(
                                                          width 0.29,
                                                          color const Color(0xFFC9A24B)  goldPrimary ,
                                                        ),
                                                        borderRadius BorderRadius.circular(1.95),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 3.90,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 7.02,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 10.14,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 13.26,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 16.38,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 19.50,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 22.62,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 25.74,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 28.86,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 31.98,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 12.09,
                                                  top 14.11,
                                                  child Container(
                                                    transform Matrix4.identity()..translate(0.0, 0.0)..rotateZ(-0.79),
                                                    width 10.82,
                                                    height 4,
                                                    decoration ShapeDecoration(
                                                      shape RoundedRectangleBorder(
                                                        side BorderSide(
                                                          width 0.29,
                                                          color const Color(0xFFC9A24B)  goldPrimary ,
                                                        ),
                                                        borderRadius BorderRadius.circular(0.78),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 11.90,
                                                  top 10.92,
                                                  child Container(
                                                    width 0.39,
                                                    height 12.48,
                                                    decoration BoxDecoration(
                                                      color const Color(0xFFC9A24B)  goldPrimary ,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 8.97,
                                                  top 16.97,
                                                  child Container(
                                                    width 6.24,
                                                    height 0.39,
                                                    decoration BoxDecoration(
                                                      color const Color(0xFFC9A24B)  goldPrimary ,
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
                                    width 24.18,
                                    height 34.32,
                                    clipBehavior Clip.antiAlias,
                                    decoration BoxDecoration(),
                                    child Stack(
                                      children [
                                        Positioned(
                                          left 0,
                                          top 0,
                                          child Container(
                                            width 24.18,
                                            height 34.32,
                                            decoration ShapeDecoration(
                                              color const Color(0xFF22303E)  cardBack ,
                                              shape RoundedRectangleBorder(
                                                side BorderSide(
                                                  width 0.39,
                                                  color const Color(0xFFC9A24B)  goldPrimary ,
                                                ),
                                                borderRadius BorderRadius.circular(3.12),
                                              ),
                                            ),
                                            child Stack(
                                              children [
                                                Positioned(
                                                  left 1.17,
                                                  top 1.17,
                                                  child Container(
                                                    width 21.84,
                                                    height 31.98,
                                                    decoration ShapeDecoration(
                                                      shape RoundedRectangleBorder(
                                                        side BorderSide(
                                                          width 0.29,
                                                          color const Color(0xFFC9A24B)  goldPrimary ,
                                                        ),
                                                        borderRadius BorderRadius.circular(1.95),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 3.90,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 7.02,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 10.14,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 13.26,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 16.38,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 19.50,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 22.62,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 25.74,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 28.86,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 31.98,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 12.09,
                                                  top 14.11,
                                                  child Container(
                                                    transform Matrix4.identity()..translate(0.0, 0.0)..rotateZ(-0.79),
                                                    width 10.82,
                                                    height 4,
                                                    decoration ShapeDecoration(
                                                      shape RoundedRectangleBorder(
                                                        side BorderSide(
                                                          width 0.29,
                                                          color const Color(0xFFC9A24B)  goldPrimary ,
                                                        ),
                                                        borderRadius BorderRadius.circular(0.78),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 11.90,
                                                  top 10.92,
                                                  child Container(
                                                    width 0.39,
                                                    height 12.48,
                                                    decoration BoxDecoration(
                                                      color const Color(0xFFC9A24B)  goldPrimary ,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 8.97,
                                                  top 16.97,
                                                  child Container(
                                                    width 6.24,
                                                    height 0.39,
                                                    decoration BoxDecoration(
                                                      color const Color(0xFFC9A24B)  goldPrimary ,
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
                                    width 24.18,
                                    height 34.32,
                                    clipBehavior Clip.antiAlias,
                                    decoration BoxDecoration(),
                                    child Stack(
                                      children [
                                        Positioned(
                                          left 0,
                                          top 0,
                                          child Container(
                                            width 24.18,
                                            height 34.32,
                                            decoration ShapeDecoration(
                                              color const Color(0xFF22303E)  cardBack ,
                                              shape RoundedRectangleBorder(
                                                side BorderSide(
                                                  width 0.39,
                                                  color const Color(0xFFC9A24B)  goldPrimary ,
                                                ),
                                                borderRadius BorderRadius.circular(3.12),
                                              ),
                                            ),
                                            child Stack(
                                              children [
                                                Positioned(
                                                  left 1.17,
                                                  top 1.17,
                                                  child Container(
                                                    width 21.84,
                                                    height 31.98,
                                                    decoration ShapeDecoration(
                                                      shape RoundedRectangleBorder(
                                                        side BorderSide(
                                                          width 0.29,
                                                          color const Color(0xFFC9A24B)  goldPrimary ,
                                                        ),
                                                        borderRadius BorderRadius.circular(1.95),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 3.90,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 7.02,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 10.14,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 13.26,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 16.38,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 19.50,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 22.62,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 25.74,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 28.86,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 31.98,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 12.09,
                                                  top 14.11,
                                                  child Container(
                                                    transform Matrix4.identity()..translate(0.0, 0.0)..rotateZ(-0.79),
                                                    width 10.82,
                                                    height 4,
                                                    decoration ShapeDecoration(
                                                      shape RoundedRectangleBorder(
                                                        side BorderSide(
                                                          width 0.29,
                                                          color const Color(0xFFC9A24B)  goldPrimary ,
                                                        ),
                                                        borderRadius BorderRadius.circular(0.78),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 11.90,
                                                  top 10.92,
                                                  child Container(
                                                    width 0.39,
                                                    height 12.48,
                                                    decoration BoxDecoration(
                                                      color const Color(0xFFC9A24B)  goldPrimary ,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 8.97,
                                                  top 16.97,
                                                  child Container(
                                                    width 6.24,
                                                    height 0.39,
                                                    decoration BoxDecoration(
                                                      color const Color(0xFFC9A24B)  goldPrimary ,
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
                                    width 24.18,
                                    height 34.32,
                                    clipBehavior Clip.antiAlias,
                                    decoration BoxDecoration(),
                                    child Stack(
                                      children [
                                        Positioned(
                                          left 0,
                                          top 0,
                                          child Container(
                                            width 24.18,
                                            height 34.32,
                                            decoration ShapeDecoration(
                                              color const Color(0xFF22303E)  cardBack ,
                                              shape RoundedRectangleBorder(
                                                side BorderSide(
                                                  width 0.39,
                                                  color const Color(0xFFC9A24B)  goldPrimary ,
                                                ),
                                                borderRadius BorderRadius.circular(3.12),
                                              ),
                                            ),
                                            child Stack(
                                              children [
                                                Positioned(
                                                  left 1.17,
                                                  top 1.17,
                                                  child Container(
                                                    width 21.84,
                                                    height 31.98,
                                                    decoration ShapeDecoration(
                                                      shape RoundedRectangleBorder(
                                                        side BorderSide(
                                                          width 0.29,
                                                          color const Color(0xFFC9A24B)  goldPrimary ,
                                                        ),
                                                        borderRadius BorderRadius.circular(1.95),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 3.90,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 7.02,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 10.14,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 13.26,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 16.38,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 19.50,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 22.62,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 25.74,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 28.86,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 31.98,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 12.09,
                                                  top 14.11,
                                                  child Container(
                                                    transform Matrix4.identity()..translate(0.0, 0.0)..rotateZ(-0.79),
                                                    width 10.82,
                                                    height 4,
                                                    decoration ShapeDecoration(
                                                      shape RoundedRectangleBorder(
                                                        side BorderSide(
                                                          width 0.29,
                                                          color const Color(0xFFC9A24B)  goldPrimary ,
                                                        ),
                                                        borderRadius BorderRadius.circular(0.78),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 11.90,
                                                  top 10.92,
                                                  child Container(
                                                    width 0.39,
                                                    height 12.48,
                                                    decoration BoxDecoration(
                                                      color const Color(0xFFC9A24B)  goldPrimary ,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 8.97,
                                                  top 16.97,
                                                  child Container(
                                                    width 6.24,
                                                    height 0.39,
                                                    decoration BoxDecoration(
                                                      color const Color(0xFFC9A24B)  goldPrimary ,
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
                                    width 24.18,
                                    height 34.32,
                                    clipBehavior Clip.antiAlias,
                                    decoration BoxDecoration(),
                                    child Stack(
                                      children [
                                        Positioned(
                                          left 0,
                                          top 0,
                                          child Container(
                                            width 24.18,
                                            height 34.32,
                                            decoration ShapeDecoration(
                                              color const Color(0xFF22303E)  cardBack ,
                                              shape RoundedRectangleBorder(
                                                side BorderSide(
                                                  width 0.39,
                                                  color const Color(0xFFC9A24B)  goldPrimary ,
                                                ),
                                                borderRadius BorderRadius.circular(3.12),
                                              ),
                                            ),
                                            child Stack(
                                              children [
                                                Positioned(
                                                  left 1.17,
                                                  top 1.17,
                                                  child Container(
                                                    width 21.84,
                                                    height 31.98,
                                                    decoration ShapeDecoration(
                                                      shape RoundedRectangleBorder(
                                                        side BorderSide(
                                                          width 0.29,
                                                          color const Color(0xFFC9A24B)  goldPrimary ,
                                                        ),
                                                        borderRadius BorderRadius.circular(1.95),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 3.90,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 7.02,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 10.14,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 13.26,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 16.38,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 19.50,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 22.62,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 25.74,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 28.86,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 31.98,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 12.09,
                                                  top 14.11,
                                                  child Container(
                                                    transform Matrix4.identity()..translate(0.0, 0.0)..rotateZ(-0.79),
                                                    width 10.82,
                                                    height 4,
                                                    decoration ShapeDecoration(
                                                      shape RoundedRectangleBorder(
                                                        side BorderSide(
                                                          width 0.29,
                                                          color const Color(0xFFC9A24B)  goldPrimary ,
                                                        ),
                                                        borderRadius BorderRadius.circular(0.78),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 11.90,
                                                  top 10.92,
                                                  child Container(
                                                    width 0.39,
                                                    height 12.48,
                                                    decoration BoxDecoration(
                                                      color const Color(0xFFC9A24B)  goldPrimary ,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 8.97,
                                                  top 16.97,
                                                  child Container(
                                                    width 6.24,
                                                    height 0.39,
                                                    decoration BoxDecoration(
                                                      color const Color(0xFFC9A24B)  goldPrimary ,
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
                                    width 24.18,
                                    height 34.32,
                                    clipBehavior Clip.antiAlias,
                                    decoration BoxDecoration(),
                                    child Stack(
                                      children [
                                        Positioned(
                                          left 0,
                                          top 0,
                                          child Container(
                                            width 24.18,
                                            height 34.32,
                                            decoration ShapeDecoration(
                                              color const Color(0xFF22303E)  cardBack ,
                                              shape RoundedRectangleBorder(
                                                side BorderSide(
                                                  width 0.39,
                                                  color const Color(0xFFC9A24B)  goldPrimary ,
                                                ),
                                                borderRadius BorderRadius.circular(3.12),
                                              ),
                                            ),
                                            child Stack(
                                              children [
                                                Positioned(
                                                  left 1.17,
                                                  top 1.17,
                                                  child Container(
                                                    width 21.84,
                                                    height 31.98,
                                                    decoration ShapeDecoration(
                                                      shape RoundedRectangleBorder(
                                                        side BorderSide(
                                                          width 0.29,
                                                          color const Color(0xFFC9A24B)  goldPrimary ,
                                                        ),
                                                        borderRadius BorderRadius.circular(1.95),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 3.90,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 7.02,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 10.14,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 13.26,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 16.38,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 19.50,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 22.62,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 25.74,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 28.86,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 31.98,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 12.09,
                                                  top 14.11,
                                                  child Container(
                                                    transform Matrix4.identity()..translate(0.0, 0.0)..rotateZ(-0.79),
                                                    width 10.82,
                                                    height 4,
                                                    decoration ShapeDecoration(
                                                      shape RoundedRectangleBorder(
                                                        side BorderSide(
                                                          width 0.29,
                                                          color const Color(0xFFC9A24B)  goldPrimary ,
                                                        ),
                                                        borderRadius BorderRadius.circular(0.78),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 11.90,
                                                  top 10.92,
                                                  child Container(
                                                    width 0.39,
                                                    height 12.48,
                                                    decoration BoxDecoration(
                                                      color const Color(0xFFC9A24B)  goldPrimary ,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 8.97,
                                                  top 16.97,
                                                  child Container(
                                                    width 6.24,
                                                    height 0.39,
                                                    decoration BoxDecoration(
                                                      color const Color(0xFFC9A24B)  goldPrimary ,
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
                                    width 24.18,
                                    height 34.32,
                                    clipBehavior Clip.antiAlias,
                                    decoration BoxDecoration(),
                                    child Stack(
                                      children [
                                        Positioned(
                                          left 0,
                                          top 0,
                                          child Container(
                                            width 24.18,
                                            height 34.32,
                                            decoration ShapeDecoration(
                                              color const Color(0xFF22303E)  cardBack ,
                                              shape RoundedRectangleBorder(
                                                side BorderSide(
                                                  width 0.39,
                                                  color const Color(0xFFC9A24B)  goldPrimary ,
                                                ),
                                                borderRadius BorderRadius.circular(3.12),
                                              ),
                                            ),
                                            child Stack(
                                              children [
                                                Positioned(
                                                  left 1.17,
                                                  top 1.17,
                                                  child Container(
                                                    width 21.84,
                                                    height 31.98,
                                                    decoration ShapeDecoration(
                                                      shape RoundedRectangleBorder(
                                                        side BorderSide(
                                                          width 0.29,
                                                          color const Color(0xFFC9A24B)  goldPrimary ,
                                                        ),
                                                        borderRadius BorderRadius.circular(1.95),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 3.90,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 7.02,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 10.14,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 13.26,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 16.38,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 19.50,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 22.62,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 25.74,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 28.86,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 2.34,
                                                  top 31.98,
                                                  child Opacity(
                                                    opacity 0.12,
                                                    child Container(
                                                      width 19.50,
                                                      height 0.19,
                                                      decoration ShapeDecoration(
                                                        shape RoundedRectangleBorder(
                                                          side BorderSide(
                                                            width 0.29,
                                                            color const Color(0xFFC9A24B)  goldPrimary ,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 12.09,
                                                  top 14.11,
                                                  child Container(
                                                    transform Matrix4.identity()..translate(0.0, 0.0)..rotateZ(-0.79),
                                                    width 10.82,
                                                    height 4,
                                                    decoration ShapeDecoration(
                                                      shape RoundedRectangleBorder(
                                                        side BorderSide(
                                                          width 0.29,
                                                          color const Color(0xFFC9A24B)  goldPrimary ,
                                                        ),
                                                        borderRadius BorderRadius.circular(0.78),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 11.90,
                                                  top 10.92,
                                                  child Container(
                                                    width 0.39,
                                                    height 12.48,
                                                    decoration BoxDecoration(
                                                      color const Color(0xFFC9A24B)  goldPrimary ,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left 8.97,
                                                  top 16.97,
                                                  child Container(
                                                    width 6.24,
                                                    height 0.39,
                                                    decoration BoxDecoration(
                                                      color const Color(0xFFC9A24B)  goldPrimary ,
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
                      left 1208,
                      top 192,
                      child Container(
                        width 200,
                        height 84,
                        padding const EdgeInsets.all(10),
                        clipBehavior Clip.antiAlias,
                        decoration ShapeDecoration(
                          color const Color(0xFF131A23)  darkTokens-color-bgPanel ,
                          shape RoundedRectangleBorder(
                            side BorderSide(
                              width 1,
                              color const Color(0xFF2C3035),
                            ),
                            borderRadius BorderRadius.circular(12),
                          ),
                        ),
                        child Row(
                          mainAxisSize MainAxisSize.min,
                          mainAxisAlignment MainAxisAlignment.start,
                          crossAxisAlignment CrossAxisAlignment.center,
                          spacing 10,
                          children [
                            Container(
                              width 54,
                              height 54,
                              clipBehavior Clip.antiAlias,
                              decoration ShapeDecoration(
                                color const Color(0xFF29251C),
                                shape RoundedRectangleBorder(
                                  borderRadius BorderRadius.circular(13),
                                ),
                              ),
                              child Column(
                                mainAxisSize MainAxisSize.min,
                                mainAxisAlignment MainAxisAlignment.center,
                                crossAxisAlignment CrossAxisAlignment.center,
                                children [
                                  Container(
                                    width 30,
                                    height 30,
                                    clipBehavior Clip.antiAlias,
                                    decoration BoxDecoration(),
                                    child Stack(),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child Container(
                                clipBehavior Clip.antiAlias,
                                decoration BoxDecoration(),
                                child Column(
                                  mainAxisSize MainAxisSize.min,
                                  mainAxisAlignment MainAxisAlignment.start,
                                  crossAxisAlignment CrossAxisAlignment.start,
                                  spacing 4,
                                  children [
                                    Container(
                                      clipBehavior Clip.antiAlias,
                                      decoration BoxDecoration(),
                                      child Row(
                                        mainAxisSize MainAxisSize.min,
                                        mainAxisAlignment MainAxisAlignment.start,
                                        crossAxisAlignment CrossAxisAlignment.center,
                                        spacing 5,
                                        children [
                                          Text(
                                            '运河老友',
                                            style TextStyle(
                                              color const Color(0xFFEDE8DB)  darkTokens-color-textPrimary ,
                                              fontSize 14,
                                              fontFamily 'Noto Sans SC',
                                              fontWeight FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '正在接收手牌',
                                      style TextStyle(
                                        color const Color(0xFF9A917E)  darkTokens-color-textSecondary ,
                                        fontSize 11,
                                        fontFamily 'Noto Sans SC',
                                        fontWeight FontWeight.w400,
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
                      left 32,
                      top 192,
                      child Container(
                        width 200,
                        height 84,
                        padding const EdgeInsets.all(10),
                        clipBehavior Clip.antiAlias,
                        decoration ShapeDecoration(
                          color const Color(0xFF131A23)  darkTokens-color-bgPanel ,
                          shape RoundedRectangleBorder(
                            side BorderSide(
                              width 1,
                              color const Color(0xFF2C3035),
                            ),
                            borderRadius BorderRadius.circular(12),
                          ),
                        ),
                        child Row(
                          mainAxisSize MainAxisSize.min,
                          mainAxisAlignment MainAxisAlignment.start,
                          crossAxisAlignment CrossAxisAlignment.center,
                          spacing 10,
                          children [
                            Container(
                              width 54,
                              height 54,
                              clipBehavior Clip.antiAlias,
                              decoration ShapeDecoration(
                                color const Color(0xFF29251C),
                                shape RoundedRectangleBorder(
                                  borderRadius BorderRadius.circular(13),
                                ),
                              ),
                              child Column(
                                mainAxisSize MainAxisSize.min,
                                mainAxisAlignment MainAxisAlignment.center,
                                crossAxisAlignment CrossAxisAlignment.center,
                                children [
                                  Container(
                                    width 30,
                                    height 30,
                                    clipBehavior Clip.antiAlias,
                                    decoration BoxDecoration(),
                                    child Stack(),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child Container(
                                clipBehavior Clip.antiAlias,
                                decoration BoxDecoration(),
                                child Column(
                                  mainAxisSize MainAxisSize.min,
                                  mainAxisAlignment MainAxisAlignment.start,
                                  crossAxisAlignment CrossAxisAlignment.start,
                                  spacing 4,
                                  children [
                                    Container(
                                      clipBehavior Clip.antiAlias,
                                      decoration BoxDecoration(),
                                      child Row(
                                        mainAxisSize MainAxisSize.min,
                                        mainAxisAlignment MainAxisAlignment.start,
                                        crossAxisAlignment CrossAxisAlignment.center,
                                        spacing 5,
                                        children [
                                          Text(
                                            '清江月',
                                            style TextStyle(
                                              color const Color(0xFFEDE8DB)  darkTokens-color-textPrimary ,
                                              fontSize 14,
                                              fontFamily 'Noto Sans SC',
                                              fontWeight FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '正在接收手牌',
                                      style TextStyle(
                                        color const Color(0xFF9A917E)  darkTokens-color-textSecondary ,
                                        fontSize 11,
                                        fontFamily 'Noto Sans SC',
                                        fontWeight FontWeight.w400,
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
                      left 620,
                      top 24,
                      child Container(
                        width 200,
                        height 84,
                        padding const EdgeInsets.all(10),
                        clipBehavior Clip.antiAlias,
                        decoration ShapeDecoration(
                          color const Color(0xFF131A23)  darkTokens-color-bgPanel ,
                          shape RoundedRectangleBorder(
                            side BorderSide(
                              width 1,
                              color const Color(0xFF2C3035),
                            ),
                            borderRadius BorderRadius.circular(12),
                          ),
                        ),
                        child Row(
                          mainAxisSize MainAxisSize.min,
                          mainAxisAlignment MainAxisAlignment.start,
                          crossAxisAlignment CrossAxisAlignment.center,
                          spacing 10,
                          children [
                            Container(
                              width 54,
                              height 54,
                              clipBehavior Clip.antiAlias,
                              decoration ShapeDecoration(
                                color const Color(0xFF29251C),
                                shape RoundedRectangleBorder(
                                  borderRadius BorderRadius.circular(13),
                                ),
                              ),
                              child Column(
                                mainAxisSize MainAxisSize.min,
                                mainAxisAlignment MainAxisAlignment.center,
                                crossAxisAlignment CrossAxisAlignment.center,
                                children [
                                  Container(
                                    width 30,
                                    height 30,
                                    clipBehavior Clip.antiAlias,
                                    decoration BoxDecoration(),
                                    child Stack(),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child Container(
                                clipBehavior Clip.antiAlias,
                                decoration BoxDecoration(),
                                child Column(
                                  mainAxisSize MainAxisSize.min,
                                  mainAxisAlignment MainAxisAlignment.start,
                                  crossAxisAlignment CrossAxisAlignment.start,
                                  spacing 4,
                                  children [
                                    Container(
                                      clipBehavior Clip.antiAlias,
                                      decoration BoxDecoration(),
                                      child Row(
                                        mainAxisSize MainAxisSize.min,
                                        mainAxisAlignment MainAxisAlignment.start,
                                        crossAxisAlignment CrossAxisAlignment.center,
                                        spacing 5,
                                        children [
                                          Text(
                                            '淮上听风',
                                            style TextStyle(
                                              color const Color(0xFFEDE8DB)  darkTokens-color-textPrimary ,
                                              fontSize 14,
                                              fontFamily 'Noto Sans SC',
                                              fontWeight FontWeight.w700,
                                            ),
                                          ),
                                          Container(
                                            width 15,
                                            height 15,
                                            clipBehavior Clip.antiAlias,
                                            decoration BoxDecoration(),
                                            child Stack(),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '大师 III · 庄家',
                                      style TextStyle(
                                        color const Color(0xFF9A917E)  darkTokens-color-textSecondary ,
                                        fontSize 11,
                                        fontFamily 'Noto Sans SC',
                                        fontWeight FontWeight.w400,
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
                width 1440,
                height 252,
                clipBehavior Clip.antiAlias,
                decoration BoxDecoration(
                  color const Color(0xFF0A0E13)  darkTokens-color-bgBase ,
                ),
                child Stack(
                  children [
                    Positioned(
                      left 255,
                      top 94,
                      child Container(
                        width 930,
                        height 148,
                        child Stack(
                          children [
                            Positioned(
                              left 210,
                              top 126,
                              child Text(
                                '已发手牌 · 牌面仅自己可见',
                                style TextStyle(
                                  color const Color(0xFF9A917E)  darkTokens-color-textSecondary ,
                                  fontSize 11,
                                  fontFamily 'Noto Sans SC',
                                  fontWeight FontWeight.w400,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize MainAxisSize.min,
                              mainAxisAlignment MainAxisAlignment.start,
                              crossAxisAlignment CrossAxisAlignment.center,
                              children [
                                Container(
                                  width 62,
                                  height 88,
                                  child Stack(
                                    children [
                                      Positioned(
                                        left 0,
                                        top 0,
                                        child Container(
                                          width 62,
                                          height 88,
                                          decoration ShapeDecoration(
                                            color const Color(0xFFF5EFE0)  cardFace ,
                                            shape RoundedRectangleBorder(
                                              side BorderSide(
                                                width 0.75,
                                                color const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius BorderRadius.circular(8),
                                            ),
                                          ),
                                          child Stack(
                                            children [
                                              Positioned(
                                                left 5,
                                                top 67,
                                                child Container(
                                                  width 13,
                                                  height 12,
                                                  clipBehavior Clip.antiAlias,
                                                  decoration ShapeDecoration(
                                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                                    shape RoundedRectangleBorder(borderRadius BorderRadius.circular(3)),
                                                  ),
                                                  child Stack(
                                                    children [
                                                      Positioned(
                                                        left 2,
                                                        top 1,
                                                        child Text(
                                                          '主',
                                                          style TextStyle(
                                                            color const Color(0xFF22303E)  suitBlack ,
                                                            fontSize 8,
                                                            fontFamily 'Noto Sans SC',
                                                            fontWeight FontWeight.w400,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 49,
                                                top 70,
                                                child Text(
                                                  'A',
                                                  style TextStyle(
                                                    color const Color(0xFF22303E)  suitBlack ,
                                                    fontSize 12,
                                                    fontFamily 'Lora',
                                                    fontWeight FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 27,
                                                top 40,
                                                child Text(
                                                  '♠',
                                                  style TextStyle(
                                                    color const Color(0xFF22303E)  suitBlack ,
                                                    fontSize 30,
                                                    fontFamily 'Noto Sans SC',
                                                    fontWeight FontWeight.w400,
                                                    height 1,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 5,
                                                top 25,
                                                child Text(
                                                  '♠',
                                                  style TextStyle(
                                                    color const Color(0xFF22303E)  suitBlack ,
                                                    fontSize 19,
                                                    fontFamily 'Noto Sans SC',
                                                    fontWeight FontWeight.w400,
                                                    height 1,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 5,
                                                top 3,
                                                child Text(
                                                  'A',
                                                  style TextStyle(
                                                    color const Color(0xFF22303E)  suitBlack ,
                                                    fontSize 20,
                                                    fontFamily 'Lora',
                                                    fontWeight FontWeight.w700,
                                                    height 1,
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
                                  width 62,
                                  height 88,
                                  child Stack(
                                    children [
                                      Positioned(
                                        left 0,
                                        top 0,
                                        child Container(
                                          width 62,
                                          height 88,
                                          decoration ShapeDecoration(
                                            color const Color(0xFFF5EFE0)  cardFace ,
                                            shape RoundedRectangleBorder(
                                              side BorderSide(
                                                width 0.75,
                                                color const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius BorderRadius.circular(8),
                                            ),
                                          ),
                                          child Stack(
                                            children [
                                              Positioned(
                                                left 5,
                                                top 67,
                                                child Container(
                                                  width 13,
                                                  height 12,
                                                  clipBehavior Clip.antiAlias,
                                                  decoration ShapeDecoration(
                                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                                    shape RoundedRectangleBorder(borderRadius BorderRadius.circular(3)),
                                                  ),
                                                  child Stack(
                                                    children [
                                                      Positioned(
                                                        left 2,
                                                        top 1,
                                                        child Text(
                                                          '主',
                                                          style TextStyle(
                                                            color const Color(0xFF22303E)  suitBlack ,
                                                            fontSize 8,
                                                            fontFamily 'Noto Sans SC',
                                                            fontWeight FontWeight.w400,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 48,
                                                top 70,
                                                child Text(
                                                  'K',
                                                  style TextStyle(
                                                    color const Color(0xFF22303E)  suitBlack ,
                                                    fontSize 12,
                                                    fontFamily 'Lora',
                                                    fontWeight FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 27,
                                                top 40,
                                                child Text(
                                                  '♠',
                                                  style TextStyle(
                                                    color const Color(0xFF22303E)  suitBlack ,
                                                    fontSize 30,
                                                    fontFamily 'Noto Sans SC',
                                                    fontWeight FontWeight.w400,
                                                    height 1,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 5,
                                                top 25,
                                                child Text(
                                                  '♠',
                                                  style TextStyle(
                                                    color const Color(0xFF22303E)  suitBlack ,
                                                    fontSize 19,
                                                    fontFamily 'Noto Sans SC',
                                                    fontWeight FontWeight.w400,
                                                    height 1,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 5,
                                                top 3,
                                                child Text(
                                                  'K',
                                                  style TextStyle(
                                                    color const Color(0xFF22303E)  suitBlack ,
                                                    fontSize 20,
                                                    fontFamily 'Lora',
                                                    fontWeight FontWeight.w700,
                                                    height 1,
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
                                  width 62,
                                  height 88,
                                  child Stack(
                                    children [
                                      Positioned(
                                        left 0,
                                        top 0,
                                        child Container(
                                          width 62,
                                          height 88,
                                          decoration ShapeDecoration(
                                            color const Color(0xFFF5EFE0)  cardFace ,
                                            shape RoundedRectangleBorder(
                                              side BorderSide(
                                                width 0.75,
                                                color const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius BorderRadius.circular(8),
                                            ),
                                          ),
                                          child Stack(
                                            children [
                                              Positioned(
                                                left 5,
                                                top 67,
                                                child Container(
                                                  width 13,
                                                  height 12,
                                                  clipBehavior Clip.antiAlias,
                                                  decoration ShapeDecoration(
                                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                                    shape RoundedRectangleBorder(borderRadius BorderRadius.circular(3)),
                                                  ),
                                                  child Stack(
                                                    children [
                                                      Positioned(
                                                        left 2,
                                                        top 1,
                                                        child Text(
                                                          '主',
                                                          style TextStyle(
                                                            color const Color(0xFF22303E)  suitBlack ,
                                                            fontSize 8,
                                                            fontFamily 'Noto Sans SC',
                                                            fontWeight FontWeight.w400,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 47,
                                                top 70,
                                                child Text(
                                                  'Q',
                                                  style TextStyle(
                                                    color const Color(0xFF22303E)  suitBlack ,
                                                    fontSize 12,
                                                    fontFamily 'Lora',
                                                    fontWeight FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 27,
                                                top 40,
                                                child Text(
                                                  '♠',
                                                  style TextStyle(
                                                    color const Color(0xFF22303E)  suitBlack ,
                                                    fontSize 30,
                                                    fontFamily 'Noto Sans SC',
                                                    fontWeight FontWeight.w400,
                                                    height 1,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 5,
                                                top 25,
                                                child Text(
                                                  '♠',
                                                  style TextStyle(
                                                    color const Color(0xFF22303E)  suitBlack ,
                                                    fontSize 19,
                                                    fontFamily 'Noto Sans SC',
                                                    fontWeight FontWeight.w400,
                                                    height 1,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 5,
                                                top 3,
                                                child Text(
                                                  'Q',
                                                  style TextStyle(
                                                    color const Color(0xFF22303E)  suitBlack ,
                                                    fontSize 20,
                                                    fontFamily 'Lora',
                                                    fontWeight FontWeight.w700,
                                                    height 1,
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
                                  width 62,
                                  height 88,
                                  child Stack(
                                    children [
                                      Positioned(
                                        left 0,
                                        top 0,
                                        child Container(
                                          width 62,
                                          height 88,
                                          decoration ShapeDecoration(
                                            color const Color(0xFFF5EFE0)  cardFace ,
                                            shape RoundedRectangleBorder(
                                              side BorderSide(
                                                width 0.75,
                                                color const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius BorderRadius.circular(8),
                                            ),
                                          ),
                                          child Stack(
                                            children [
                                              Positioned(
                                                left 5,
                                                top 67,
                                                child Container(
                                                  width 13,
                                                  height 12,
                                                  clipBehavior Clip.antiAlias,
                                                  decoration ShapeDecoration(
                                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                                    shape RoundedRectangleBorder(borderRadius BorderRadius.circular(3)),
                                                  ),
                                                  child Stack(
                                                    children [
                                                      Positioned(
                                                        left 2,
                                                        top 1,
                                                        child Text(
                                                          '主',
                                                          style TextStyle(
                                                            color const Color(0xFF22303E)  suitBlack ,
                                                            fontSize 8,
                                                            fontFamily 'Noto Sans SC',
                                                            fontWeight FontWeight.w400,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 52,
                                                top 70,
                                                child Text(
                                                  'J',
                                                  style TextStyle(
                                                    color const Color(0xFF22303E)  suitBlack ,
                                                    fontSize 12,
                                                    fontFamily 'Lora',
                                                    fontWeight FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 27,
                                                top 40,
                                                child Text(
                                                  '♠',
                                                  style TextStyle(
                                                    color const Color(0xFF22303E)  suitBlack ,
                                                    fontSize 30,
                                                    fontFamily 'Noto Sans SC',
                                                    fontWeight FontWeight.w400,
                                                    height 1,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 5,
                                                top 25,
                                                child Text(
                                                  '♠',
                                                  style TextStyle(
                                                    color const Color(0xFF22303E)  suitBlack ,
                                                    fontSize 19,
                                                    fontFamily 'Noto Sans SC',
                                                    fontWeight FontWeight.w400,
                                                    height 1,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 5,
                                                top 3,
                                                child Text(
                                                  'J',
                                                  style TextStyle(
                                                    color const Color(0xFF22303E)  suitBlack ,
                                                    fontSize 20,
                                                    fontFamily 'Lora',
                                                    fontWeight FontWeight.w700,
                                                    height 1,
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
                                  width 62,
                                  height 88,
                                  child Stack(
                                    children [
                                      Positioned(
                                        left 0,
                                        top 0,
                                        child Container(
                                          width 62,
                                          height 88,
                                          decoration ShapeDecoration(
                                            color const Color(0xFFF5EFE0)  cardFace ,
                                            shape RoundedRectangleBorder(
                                              side BorderSide(
                                                width 0.75,
                                                color const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius BorderRadius.circular(8),
                                            ),
                                          ),
                                          child Stack(
                                            children [
                                              Positioned(
                                                left 5,
                                                top 67,
                                                child Container(
                                                  width 13,
                                                  height 12,
                                                  clipBehavior Clip.antiAlias,
                                                  decoration ShapeDecoration(
                                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                                    shape RoundedRectangleBorder(borderRadius BorderRadius.circular(3)),
                                                  ),
                                                  child Stack(
                                                    children [
                                                      Positioned(
                                                        left 2,
                                                        top 1,
                                                        child Text(
                                                          '主',
                                                          style TextStyle(
                                                            color const Color(0xFF22303E)  suitBlack ,
                                                            fontSize 8,
                                                            fontFamily 'Noto Sans SC',
                                                            fontWeight FontWeight.w400,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 45,
                                                top 70,
                                                child Text(
                                                  '10',
                                                  style TextStyle(
                                                    color const Color(0xFF22303E)  suitBlack ,
                                                    fontSize 12,
                                                    fontFamily 'Lora',
                                                    fontWeight FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 27,
                                                top 40,
                                                child Text(
                                                  '♠',
                                                  style TextStyle(
                                                    color const Color(0xFF22303E)  suitBlack ,
                                                    fontSize 30,
                                                    fontFamily 'Noto Sans SC',
                                                    fontWeight FontWeight.w400,
                                                    height 1,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 5,
                                                top 25,
                                                child Text(
                                                  '♠',
                                                  style TextStyle(
                                                    color const Color(0xFF22303E)  suitBlack ,
                                                    fontSize 19,
                                                    fontFamily 'Noto Sans SC',
                                                    fontWeight FontWeight.w400,
                                                    height 1,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 5,
                                                top 3,
                                                child Text(
                                                  '10',
                                                  style TextStyle(
                                                    color const Color(0xFF22303E)  suitBlack ,
                                                    fontSize 20,
                                                    fontFamily 'Lora',
                                                    fontWeight FontWeight.w700,
                                                    height 1,
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
                                  width 62,
                                  height 88,
                                  child Stack(
                                    children [
                                      Positioned(
                                        left 0,
                                        top 0,
                                        child Container(
                                          width 62,
                                          height 88,
                                          decoration ShapeDecoration(
                                            color const Color(0xFFF5EFE0)  cardFace ,
                                            shape RoundedRectangleBorder(
                                              side BorderSide(
                                                width 0.75,
                                                color const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius BorderRadius.circular(8),
                                            ),
                                          ),
                                          child Stack(
                                            children [
                                              Positioned(
                                                left 5,
                                                top 67,
                                                child Container(
                                                  width 13,
                                                  height 12,
                                                  clipBehavior Clip.antiAlias,
                                                  decoration ShapeDecoration(
                                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                                    shape RoundedRectangleBorder(borderRadius BorderRadius.circular(3)),
                                                  ),
                                                  child Stack(
                                                    children [
                                                      Positioned(
                                                        left 2,
                                                        top 1,
                                                        child Text(
                                                          '主',
                                                          style TextStyle(
                                                            color const Color(0xFF22303E)  suitBlack ,
                                                            fontSize 8,
                                                            fontFamily 'Noto Sans SC',
                                                            fontWeight FontWeight.w400,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 50,
                                                top 70,
                                                child Text(
                                                  '9',
                                                  style TextStyle(
                                                    color const Color(0xFF22303E)  suitBlack ,
                                                    fontSize 12,
                                                    fontFamily 'Lora',
                                                    fontWeight FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 27,
                                                top 40,
                                                child Text(
                                                  '♠',
                                                  style TextStyle(
                                                    color const Color(0xFF22303E)  suitBlack ,
                                                    fontSize 30,
                                                    fontFamily 'Noto Sans SC',
                                                    fontWeight FontWeight.w400,
                                                    height 1,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 5,
                                                top 25,
                                                child Text(
                                                  '♠',
                                                  style TextStyle(
                                                    color const Color(0xFF22303E)  suitBlack ,
                                                    fontSize 19,
                                                    fontFamily 'Noto Sans SC',
                                                    fontWeight FontWeight.w400,
                                                    height 1,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 5,
                                                top 3,
                                                child Text(
                                                  '9',
                                                  style TextStyle(
                                                    color const Color(0xFF22303E)  suitBlack ,
                                                    fontSize 20,
                                                    fontFamily 'Lora',
                                                    fontWeight FontWeight.w700,
                                                    height 1,
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
                                  width 62,
                                  height 88,
                                  child Stack(
                                    children [
                                      Positioned(
                                        left 0,
                                        top 0,
                                        child Container(
                                          width 62,
                                          height 88,
                                          decoration ShapeDecoration(
                                            color const Color(0xFFF5EFE0)  cardFace ,
                                            shape RoundedRectangleBorder(
                                              side BorderSide(
                                                width 0.75,
                                                color const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius BorderRadius.circular(8),
                                            ),
                                          ),
                                          child Stack(
                                            children [
                                              Positioned(
                                                left 5,
                                                top 67,
                                                child Container(
                                                  width 13,
                                                  height 12,
                                                  clipBehavior Clip.antiAlias,
                                                  decoration ShapeDecoration(
                                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                                    shape RoundedRectangleBorder(borderRadius BorderRadius.circular(3)),
                                                  ),
                                                  child Stack(
                                                    children [
                                                      Positioned(
                                                        left 2,
                                                        top 1,
                                                        child Text(
                                                          '级',
                                                          style TextStyle(
                                                            color const Color(0xFF22303E)  suitBlack ,
                                                            fontSize 8,
                                                            fontFamily 'Noto Sans SC',
                                                            fontWeight FontWeight.w400,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 50,
                                                top 70,
                                                child Text(
                                                  '2',
                                                  style TextStyle(
                                                    color const Color(0xFF22303E)  suitBlack ,
                                                    fontSize 12,
                                                    fontFamily 'Lora',
                                                    fontWeight FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 27,
                                                top 40,
                                                child Text(
                                                  '♠',
                                                  style TextStyle(
                                                    color const Color(0xFF22303E)  suitBlack ,
                                                    fontSize 30,
                                                    fontFamily 'Noto Sans SC',
                                                    fontWeight FontWeight.w400,
                                                    height 1,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 5,
                                                top 25,
                                                child Text(
                                                  '♠',
                                                  style TextStyle(
                                                    color const Color(0xFF22303E)  suitBlack ,
                                                    fontSize 19,
                                                    fontFamily 'Noto Sans SC',
                                                    fontWeight FontWeight.w400,
                                                    height 1,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 5,
                                                top 3,
                                                child Text(
                                                  '2',
                                                  style TextStyle(
                                                    color const Color(0xFF22303E)  suitBlack ,
                                                    fontSize 20,
                                                    fontFamily 'Lora',
                                                    fontWeight FontWeight.w700,
                                                    height 1,
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
                                  width 62,
                                  height 88,
                                  child Stack(
                                    children [
                                      Positioned(
                                        left 0,
                                        top 0,
                                        child Container(
                                          width 62,
                                          height 88,
                                          decoration ShapeDecoration(
                                            color const Color(0xFFF5EFE0)  cardFace ,
                                            shape RoundedRectangleBorder(
                                              side BorderSide(
                                                width 0.75,
                                                color const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius BorderRadius.circular(8),
                                            ),
                                          ),
                                          child Stack(
                                            children [
                                              Positioned(
                                                left 5,
                                                top 67,
                                                child Container(
                                                  width 13,
                                                  height 12,
                                                  clipBehavior Clip.antiAlias,
                                                  decoration ShapeDecoration(
                                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                                    shape RoundedRectangleBorder(borderRadius BorderRadius.circular(3)),
                                                  ),
                                                  child Stack(
                                                    children [
                                                      Positioned(
                                                        left 2,
                                                        top 1,
                                                        child Text(
                                                          '级',
                                                          style TextStyle(
                                                            color const Color(0xFF22303E)  suitBlack ,
                                                            fontSize 8,
                                                            fontFamily 'Noto Sans SC',
                                                            fontWeight FontWeight.w400,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 50,
                                                top 70,
                                                child Text(
                                                  '2',
                                                  style TextStyle(
                                                    color const Color(0xFFB74448)  suitRed ,
                                                    fontSize 12,
                                                    fontFamily 'Lora',
                                                    fontWeight FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 27,
                                                top 40,
                                                child Text(
                                                  '♥',
                                                  style TextStyle(
                                                    color const Color(0xFFB74448)  suitRed ,
                                                    fontSize 30,
                                                    fontFamily 'Noto Sans SC',
                                                    fontWeight FontWeight.w400,
                                                    height 1,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 5,
                                                top 25,
                                                child Text(
                                                  '♥',
                                                  style TextStyle(
                                                    color const Color(0xFFB74448)  suitRed ,
                                                    fontSize 19,
                                                    fontFamily 'Noto Sans SC',
                                                    fontWeight FontWeight.w400,
                                                    height 1,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 5,
                                                top 3,
                                                child Text(
                                                  '2',
                                                  style TextStyle(
                                                    color const Color(0xFFB74448)  suitRed ,
                                                    fontSize 20,
                                                    fontFamily 'Lora',
                                                    fontWeight FontWeight.w700,
                                                    height 1,
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
                                  width 62,
                                  height 88,
                                  child Stack(
                                    children [
                                      Positioned(
                                        left 0,
                                        top 0,
                                        child Container(
                                          width 62,
                                          height 88,
                                          decoration ShapeDecoration(
                                            color const Color(0xFFF5EFE0)  cardFace ,
                                            shape RoundedRectangleBorder(
                                              side BorderSide(
                                                width 0.75,
                                                color const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius BorderRadius.circular(8),
                                            ),
                                          ),
                                          child Stack(
                                            children [
                                              Positioned(
                                                left 5,
                                                top 67,
                                                child Container(
                                                  width 13,
                                                  height 12,
                                                  clipBehavior Clip.antiAlias,
                                                  decoration ShapeDecoration(
                                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                                    shape RoundedRectangleBorder(borderRadius BorderRadius.circular(3)),
                                                  ),
                                                  child Stack(
                                                    children [
                                                      Positioned(
                                                        left 2,
                                                        top 1,
                                                        child Text(
                                                          '级',
                                                          style TextStyle(
                                                            color const Color(0xFF22303E)  suitBlack ,
                                                            fontSize 8,
                                                            fontFamily 'Noto Sans SC',
                                                            fontWeight FontWeight.w400,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 50,
                                                top 70,
                                                child Text(
                                                  '2',
                                                  style TextStyle(
                                                    color const Color(0xFFB74448)  suitRed ,
                                                    fontSize 12,
                                                    fontFamily 'Lora',
                                                    fontWeight FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 27,
                                                top 40,
                                                child Text(
                                                  '♦',
                                                  style TextStyle(
                                                    color const Color(0xFFB74448)  suitRed ,
                                                    fontSize 30,
                                                    fontFamily 'Noto Sans SC',
                                                    fontWeight FontWeight.w400,
                                                    height 1,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 5,
                                                top 25,
                                                child Text(
                                                  '♦',
                                                  style TextStyle(
                                                    color const Color(0xFFB74448)  suitRed ,
                                                    fontSize 19,
                                                    fontFamily 'Noto Sans SC',
                                                    fontWeight FontWeight.w400,
                                                    height 1,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 5,
                                                top 3,
                                                child Text(
                                                  '2',
                                                  style TextStyle(
                                                    color const Color(0xFFB74448)  suitRed ,
                                                    fontSize 20,
                                                    fontFamily 'Lora',
                                                    fontWeight FontWeight.w700,
                                                    height 1,
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
                                  width 62,
                                  height 88,
                                  child Stack(
                                    children [
                                      Positioned(
                                        left 0,
                                        top 0,
                                        child Container(
                                          width 62,
                                          height 88,
                                          decoration ShapeDecoration(
                                            color const Color(0xFFF5EFE0)  cardFace ,
                                            shape RoundedRectangleBorder(
                                              side BorderSide(
                                                width 0.75,
                                                color const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius BorderRadius.circular(8),
                                            ),
                                          ),
                                          child Stack(
                                            children [
                                              Positioned(
                                                left 49,
                                                top 70,
                                                child Text(
                                                  'A',
                                                  style TextStyle(
                                                    color const Color(0xFFB74448)  suitRed ,
                                                    fontSize 12,
                                                    fontFamily 'Lora',
                                                    fontWeight FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 27,
                                                top 40,
                                                child Text(
                                                  '♥',
                                                  style TextStyle(
                                                    color const Color(0xFFB74448)  suitRed ,
                                                    fontSize 30,
                                                    fontFamily 'Noto Sans SC',
                                                    fontWeight FontWeight.w400,
                                                    height 1,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 5,
                                                top 25,
                                                child Text(
                                                  '♥',
                                                  style TextStyle(
                                                    color const Color(0xFFB74448)  suitRed ,
                                                    fontSize 19,
                                                    fontFamily 'Noto Sans SC',
                                                    fontWeight FontWeight.w400,
                                                    height 1,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 5,
                                                top 3,
                                                child Text(
                                                  'A',
                                                  style TextStyle(
                                                    color const Color(0xFFB74448)  suitRed ,
                                                    fontSize 20,
                                                    fontFamily 'Lora',
                                                    fontWeight FontWeight.w700,
                                                    height 1,
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
                                  width 62,
                                  height 88,
                                  child Stack(
                                    children [
                                      Positioned(
                                        left 0,
                                        top 0,
                                        child Container(
                                          width 62,
                                          height 88,
                                          decoration ShapeDecoration(
                                            color const Color(0xFFF5EFE0)  cardFace ,
                                            shape RoundedRectangleBorder(
                                              side BorderSide(
                                                width 0.75,
                                                color const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius BorderRadius.circular(8),
                                            ),
                                          ),
                                          child Stack(
                                            children [
                                              Positioned(
                                                left 48,
                                                top 70,
                                                child Text(
                                                  'K',
                                                  style TextStyle(
                                                    color const Color(0xFFB74448)  suitRed ,
                                                    fontSize 12,
                                                    fontFamily 'Lora',
                                                    fontWeight FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 27,
                                                top 40,
                                                child Text(
                                                  '♥',
                                                  style TextStyle(
                                                    color const Color(0xFFB74448)  suitRed ,
                                                    fontSize 30,
                                                    fontFamily 'Noto Sans SC',
                                                    fontWeight FontWeight.w400,
                                                    height 1,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 5,
                                                top 25,
                                                child Text(
                                                  '♥',
                                                  style TextStyle(
                                                    color const Color(0xFFB74448)  suitRed ,
                                                    fontSize 19,
                                                    fontFamily 'Noto Sans SC',
                                                    fontWeight FontWeight.w400,
                                                    height 1,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 5,
                                                top 3,
                                                child Text(
                                                  'K',
                                                  style TextStyle(
                                                    color const Color(0xFFB74448)  suitRed ,
                                                    fontSize 20,
                                                    fontFamily 'Lora',
                                                    fontWeight FontWeight.w700,
                                                    height 1,
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
                                  width 62,
                                  height 88,
                                  child Stack(
                                    children [
                                      Positioned(
                                        left 0,
                                        top 0,
                                        child Container(
                                          width 62,
                                          height 88,
                                          decoration ShapeDecoration(
                                            color const Color(0xFFF5EFE0)  cardFace ,
                                            shape RoundedRectangleBorder(
                                              side BorderSide(
                                                width 0.75,
                                                color const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius BorderRadius.circular(8),
                                            ),
                                          ),
                                          child Stack(
                                            children [
                                              Positioned(
                                                left 47,
                                                top 70,
                                                child Text(
                                                  'Q',
                                                  style TextStyle(
                                                    color const Color(0xFFB74448)  suitRed ,
                                                    fontSize 12,
                                                    fontFamily 'Lora',
                                                    fontWeight FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 27,
                                                top 40,
                                                child Text(
                                                  '♥',
                                                  style TextStyle(
                                                    color const Color(0xFFB74448)  suitRed ,
                                                    fontSize 30,
                                                    fontFamily 'Noto Sans SC',
                                                    fontWeight FontWeight.w400,
                                                    height 1,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 5,
                                                top 25,
                                                child Text(
                                                  '♥',
                                                  style TextStyle(
                                                    color const Color(0xFFB74448)  suitRed ,
                                                    fontSize 19,
                                                    fontFamily 'Noto Sans SC',
                                                    fontWeight FontWeight.w400,
                                                    height 1,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 5,
                                                top 3,
                                                child Text(
                                                  'Q',
                                                  style TextStyle(
                                                    color const Color(0xFFB74448)  suitRed ,
                                                    fontSize 20,
                                                    fontFamily 'Lora',
                                                    fontWeight FontWeight.w700,
                                                    height 1,
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
                                  width 62,
                                  height 88,
                                  child Stack(
                                    children [
                                      Positioned(
                                        left 0,
                                        top 0,
                                        child Container(
                                          width 62,
                                          height 88,
                                          decoration ShapeDecoration(
                                            color const Color(0xFFF5EFE0)  cardFace ,
                                            shape RoundedRectangleBorder(
                                              side BorderSide(
                                                width 0.75,
                                                color const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius BorderRadius.circular(8),
                                            ),
                                          ),
                                          child Stack(
                                            children [
                                              Positioned(
                                                left 50,
                                                top 70,
                                                child Text(
                                                  '8',
                                                  style TextStyle(
                                                    color const Color(0xFFB74448)  suitRed ,
                                                    fontSize 12,
                                                    fontFamily 'Lora',
                                                    fontWeight FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 27,
                                                top 40,
                                                child Text(
                                                  '♥',
                                                  style TextStyle(
                                                    color const Color(0xFFB74448)  suitRed ,
                                                    fontSize 30,
                                                    fontFamily 'Noto Sans SC',
                                                    fontWeight FontWeight.w400,
                                                    height 1,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 5,
                                                top 25,
                                                child Text(
                                                  '♥',
                                                  style TextStyle(
                                                    color const Color(0xFFB74448)  suitRed ,
                                                    fontSize 19,
                                                    fontFamily 'Noto Sans SC',
                                                    fontWeight FontWeight.w400,
                                                    height 1,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 5,
                                                top 3,
                                                child Text(
                                                  '8',
                                                  style TextStyle(
                                                    color const Color(0xFFB74448)  suitRed ,
                                                    fontSize 20,
                                                    fontFamily 'Lora',
                                                    fontWeight FontWeight.w700,
                                                    height 1,
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
                                  width 62,
                                  height 88,
                                  child Stack(
                                    children [
                                      Positioned(
                                        left 0,
                                        top 0,
                                        child Container(
                                          width 62,
                                          height 88,
                                          decoration ShapeDecoration(
                                            color const Color(0xFFF5EFE0)  cardFace ,
                                            shape RoundedRectangleBorder(
                                              side BorderSide(
                                                width 0.75,
                                                color const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius BorderRadius.circular(8),
                                            ),
                                          ),
                                          child Stack(
                                            children [
                                              Positioned(
                                                left 49,
                                                top 70,
                                                child Text(
                                                  'A',
                                                  style TextStyle(
                                                    color const Color(0xFF22303E)  suitBlack ,
                                                    fontSize 12,
                                                    fontFamily 'Lora',
                                                    fontWeight FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 27,
                                                top 40,
                                                child Text(
                                                  '♣',
                                                  style TextStyle(
                                                    color const Color(0xFF22303E)  suitBlack ,
                                                    fontSize 30,
                                                    fontFamily 'Noto Sans SC',
                                                    fontWeight FontWeight.w400,
                                                    height 1,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 5,
                                                top 25,
                                                child Text(
                                                  '♣',
                                                  style TextStyle(
                                                    color const Color(0xFF22303E)  suitBlack ,
                                                    fontSize 19,
                                                    fontFamily 'Noto Sans SC',
                                                    fontWeight FontWeight.w400,
                                                    height 1,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 5,
                                                top 3,
                                                child Text(
                                                  'A',
                                                  style TextStyle(
                                                    color const Color(0xFF22303E)  suitBlack ,
                                                    fontSize 20,
                                                    fontFamily 'Lora',
                                                    fontWeight FontWeight.w700,
                                                    height 1,
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
                                  width 62,
                                  height 88,
                                  child Stack(
                                    children [
                                      Positioned(
                                        left 0,
                                        top 0,
                                        child Container(
                                          width 62,
                                          height 88,
                                          decoration ShapeDecoration(
                                            color const Color(0xFFF5EFE0)  cardFace ,
                                            shape RoundedRectangleBorder(
                                              side BorderSide(
                                                width 0.75,
                                                color const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius BorderRadius.circular(8),
                                            ),
                                          ),
                                          child Stack(
                                            children [
                                              Positioned(
                                                left 45,
                                                top 70,
                                                child Text(
                                                  '10',
                                                  style TextStyle(
                                                    color const Color(0xFF22303E)  suitBlack ,
                                                    fontSize 12,
                                                    fontFamily 'Lora',
                                                    fontWeight FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 27,
                                                top 40,
                                                child Text(
                                                  '♣',
                                                  style TextStyle(
                                                    color const Color(0xFF22303E)  suitBlack ,
                                                    fontSize 30,
                                                    fontFamily 'Noto Sans SC',
                                                    fontWeight FontWeight.w400,
                                                    height 1,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 5,
                                                top 25,
                                                child Text(
                                                  '♣',
                                                  style TextStyle(
                                                    color const Color(0xFF22303E)  suitBlack ,
                                                    fontSize 19,
                                                    fontFamily 'Noto Sans SC',
                                                    fontWeight FontWeight.w400,
                                                    height 1,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 5,
                                                top 3,
                                                child Text(
                                                  '10',
                                                  style TextStyle(
                                                    color const Color(0xFF22303E)  suitBlack ,
                                                    fontSize 20,
                                                    fontFamily 'Lora',
                                                    fontWeight FontWeight.w700,
                                                    height 1,
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
                                  width 62,
                                  height 88,
                                  child Stack(
                                    children [
                                      Positioned(
                                        left 0,
                                        top 0,
                                        child Container(
                                          width 62,
                                          height 88,
                                          decoration ShapeDecoration(
                                            color const Color(0xFFF5EFE0)  cardFace ,
                                            shape RoundedRectangleBorder(
                                              side BorderSide(
                                                width 0.75,
                                                color const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius BorderRadius.circular(8),
                                            ),
                                          ),
                                          child Stack(
                                            children [
                                              Positioned(
                                                left 50,
                                                top 70,
                                                child Text(
                                                  '9',
                                                  style TextStyle(
                                                    color const Color(0xFFB74448)  suitRed ,
                                                    fontSize 12,
                                                    fontFamily 'Lora',
                                                    fontWeight FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 27,
                                                top 40,
                                                child Text(
                                                  '♦',
                                                  style TextStyle(
                                                    color const Color(0xFFB74448)  suitRed ,
                                                    fontSize 30,
                                                    fontFamily 'Noto Sans SC',
                                                    fontWeight FontWeight.w400,
                                                    height 1,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 5,
                                                top 25,
                                                child Text(
                                                  '♦',
                                                  style TextStyle(
                                                    color const Color(0xFFB74448)  suitRed ,
                                                    fontSize 19,
                                                    fontFamily 'Noto Sans SC',
                                                    fontWeight FontWeight.w400,
                                                    height 1,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 5,
                                                top 3,
                                                child Text(
                                                  '9',
                                                  style TextStyle(
                                                    color const Color(0xFFB74448)  suitRed ,
                                                    fontSize 20,
                                                    fontFamily 'Lora',
                                                    fontWeight FontWeight.w700,
                                                    height 1,
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
                                  width 62,
                                  height 88,
                                  child Stack(
                                    children [
                                      Positioned(
                                        left 0,
                                        top 0,
                                        child Container(
                                          width 62,
                                          height 88,
                                          decoration ShapeDecoration(
                                            color const Color(0xFFF5EFE0)  cardFace ,
                                            shape RoundedRectangleBorder(
                                              side BorderSide(
                                                width 0.75,
                                                color const Color(0xFFC8C3BA),
                                              ),
                                              borderRadius BorderRadius.circular(8),
                                            ),
                                          ),
                                          child Stack(
                                            children [
                                              Positioned(
                                                left 50,
                                                top 70,
                                                child Text(
                                                  '3',
                                                  style TextStyle(
                                                    color const Color(0xFFB74448)  suitRed ,
                                                    fontSize 12,
                                                    fontFamily 'Lora',
                                                    fontWeight FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 27,
                                                top 40,
                                                child Text(
                                                  '♦',
                                                  style TextStyle(
                                                    color const Color(0xFFB74448)  suitRed ,
                                                    fontSize 30,
                                                    fontFamily 'Noto Sans SC',
                                                    fontWeight FontWeight.w400,
                                                    height 1,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 5,
                                                top 25,
                                                child Text(
                                                  '♦',
                                                  style TextStyle(
                                                    color const Color(0xFFB74448)  suitRed ,
                                                    fontSize 19,
                                                    fontFamily 'Noto Sans SC',
                                                    fontWeight FontWeight.w400,
                                                    height 1,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left 5,
                                                top 3,
                                                child Text(
                                                  '3',
                                                  style TextStyle(
                                                    color const Color(0xFFB74448)  suitRed ,
                                                    fontSize 20,
                                                    fontFamily 'Lora',
                                                    fontWeight FontWeight.w700,
                                                    height 1,
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
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left 32,
                      top 110,
                      child Container(
                        width 200,
                        height 84,
                        padding const EdgeInsets.all(10),
                        clipBehavior Clip.antiAlias,
                        decoration ShapeDecoration(
                          color const Color(0xFF131A23)  darkTokens-color-bgPanel ,
                          shape RoundedRectangleBorder(
                            side BorderSide(
                              width 1,
                              color const Color(0xFF2C3035),
                            ),
                            borderRadius BorderRadius.circular(12),
                          ),
                        ),
                        child Row(
                          mainAxisSize MainAxisSize.min,
                          mainAxisAlignment MainAxisAlignment.start,
                          crossAxisAlignment CrossAxisAlignment.center,
                          spacing 10,
                          children [
                            Container(
                              width 54,
                              height 54,
                              clipBehavior Clip.antiAlias,
                              decoration ShapeDecoration(
                                color const Color(0xFF29251C),
                                shape RoundedRectangleBorder(
                                  borderRadius BorderRadius.circular(13),
                                ),
                              ),
                              child Column(
                                mainAxisSize MainAxisSize.min,
                                mainAxisAlignment MainAxisAlignment.center,
                                crossAxisAlignment CrossAxisAlignment.center,
                                children [
                                  Container(
                                    width 30,
                                    height 30,
                                    clipBehavior Clip.antiAlias,
                                    decoration BoxDecoration(),
                                    child Stack(),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child Container(
                                clipBehavior Clip.antiAlias,
                                decoration BoxDecoration(),
                                child Column(
                                  mainAxisSize MainAxisSize.min,
                                  mainAxisAlignment MainAxisAlignment.start,
                                  crossAxisAlignment CrossAxisAlignment.start,
                                  spacing 4,
                                  children [
                                    Container(
                                      clipBehavior Clip.antiAlias,
                                      decoration BoxDecoration(),
                                      child Row(
                                        mainAxisSize MainAxisSize.min,
                                        mainAxisAlignment MainAxisAlignment.start,
                                        crossAxisAlignment CrossAxisAlignment.center,
                                        spacing 5,
                                        children [
                                          Text(
                                            '我',
                                            style TextStyle(
                                              color const Color(0xFFEDE8DB)  darkTokens-color-textPrimary ,
                                              fontSize 14,
                                              fontFamily 'Noto Sans SC',
                                              fontWeight FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '已发 17 张',
                                      style TextStyle(
                                        color const Color(0xFF9A917E)  darkTokens-color-textSecondary ,
                                        fontSize 11,
                                        fontFamily 'Noto Sans SC',
                                        fontWeight FontWeight.w400,
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
                      left 430,
                      top 10,
                      child Container(
                        clipBehavior Clip.antiAlias,
                        decoration BoxDecoration(),
                        child Row(
                          mainAxisSize MainAxisSize.min,
                          mainAxisAlignment MainAxisAlignment.start,
                          crossAxisAlignment CrossAxisAlignment.center,
                          spacing 12,
                          children [
                            Container(
                              height 46,
                              padding const EdgeInsets.symmetric(horizontal 24),
                              clipBehavior Clip.antiAlias,
                              decoration ShapeDecoration(
                                color const Color(0xFF1C242F)  darkTokens-color-bgCard ,
                                shape RoundedRectangleBorder(
                                  side BorderSide(
                                    width 1,
                                    color const Color(0xFF2C3035),
                                  ),
                                  borderRadius BorderRadius.circular(8),
                                ),
                              ),
                              child Row(
                                mainAxisSize MainAxisSize.min,
                                mainAxisAlignment MainAxisAlignment.center,
                                crossAxisAlignment CrossAxisAlignment.center,
                                children [
                                  Text(
                                    '托管',
                                    style TextStyle(
                                      color const Color(0xFFEDE8DB)  darkTokens-color-textPrimary ,
                                      fontSize 15,
                                      fontFamily 'Noto Sans SC',
                                      fontWeight FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height 46,
                              padding const EdgeInsets.symmetric(horizontal 24),
                              clipBehavior Clip.antiAlias,
                              decoration ShapeDecoration(
                                color const Color(0xFF29251C),
                                shape RoundedRectangleBorder(
                                  side BorderSide(
                                    width 1,
                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                  ),
                                  borderRadius BorderRadius.circular(8),
                                ),
                              ),
                              child Row(
                                mainAxisSize MainAxisSize.min,
                                mainAxisAlignment MainAxisAlignment.center,
                                crossAxisAlignment CrossAxisAlignment.center,
                                children [
                                  Text(
                                    '抢主',
                                    style TextStyle(
                                      color const Color(0xFFE6C56A)  goldBright ,
                                      fontSize 15,
                                      fontFamily 'Noto Sans SC',
                                      fontWeight FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height 46,
                              padding const EdgeInsets.symmetric(horizontal 24),
                              clipBehavior Clip.antiAlias,
                              decoration ShapeDecoration(
                                color const Color(0xFF1C242F)  darkTokens-color-bgCard ,
                                shape RoundedRectangleBorder(
                                  side BorderSide(
                                    width 1,
                                    color const Color(0xFF2C3035),
                                  ),
                                  borderRadius BorderRadius.circular(8),
                                ),
                              ),
                              child Row(
                                mainAxisSize MainAxisSize.min,
                                mainAxisAlignment MainAxisAlignment.center,
                                crossAxisAlignment CrossAxisAlignment.center,
                                children [
                                  Text(
                                    '反主',
                                    style TextStyle(
                                      color const Color(0xFFEDE8DB)  darkTokens-color-textPrimary ,
                                      fontSize 15,
                                      fontFamily 'Noto Sans SC',
                                      fontWeight FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height 46,
                              padding const EdgeInsets.symmetric(horizontal 24),
                              clipBehavior Clip.antiAlias,
                              decoration ShapeDecoration(
                                color const Color(0xFF1C242F)  darkTokens-color-bgCard ,
                                shape RoundedRectangleBorder(
                                  side BorderSide(
                                    width 1,
                                    color const Color(0xFF2C3035),
                                  ),
                                  borderRadius BorderRadius.circular(8),
                                ),
                              ),
                              child Row(
                                mainAxisSize MainAxisSize.min,
                                mainAxisAlignment MainAxisAlignment.center,
                                crossAxisAlignment CrossAxisAlignment.center,
                                children [
                                  Text(
                                    '扣底',
                                    style TextStyle(
                                      color const Color(0xFFEDE8DB)  darkTokens-color-textPrimary ,
                                      fontSize 15,
                                      fontFamily 'Noto Sans SC',
                                      fontWeight FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ConstrainedBox(
                              constraints BoxConstraints(maxWidth 1505.90, maxHeight 55),
                              child Container(
                                width 220,
                                height 50,
                                padding const EdgeInsets.symmetric(horizontal 5, vertical 2),
                                child Row(
                                  mainAxisSize MainAxisSize.min,
                                  mainAxisAlignment MainAxisAlignment.center,
                                  crossAxisAlignment CrossAxisAlignment.center,
                                  spacing 12,
                                  children [
                                    Container(
                                      height 46,
                                      padding const EdgeInsets.symmetric(horizontal 26),
                                      clipBehavior Clip.antiAlias,
                                      decoration ShapeDecoration(
                                        color const Color(0xFF1C242F)  darkTokens-color-bgCard ,
                                        shape RoundedRectangleBorder(
                                          side BorderSide(
                                            width 1,
                                            color const Color(0xFF2C3035),
                                          ),
                                          borderRadius BorderRadius.circular(8),
                                        ),
                                      ),
                                      child Row(
                                        mainAxisSize MainAxisSize.min,
                                        mainAxisAlignment MainAxisAlignment.center,
                                        crossAxisAlignment CrossAxisAlignment.center,
                                        spacing 8,
                                        children [
                                          Container(
                                            width 16,
                                            height 16,
                                            clipBehavior Clip.antiAlias,
                                            decoration BoxDecoration(),
                                            child Stack(),
                                          ),
                                          Text(
                                            '提示',
                                            style TextStyle(
                                              color const Color(0xFFEDE8DB)  darkTokens-color-textPrimary ,
                                              fontSize 15,
                                              fontFamily 'Noto Sans SC',
                                              fontWeight FontWeight.w400,
                                              height 1.40,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height 46,
                                      padding const EdgeInsets.symmetric(horizontal 26),
                                      clipBehavior Clip.antiAlias,
                                      decoration ShapeDecoration(
                                        color const Color(0xFFC9A24B)  goldPrimary ,
                                        shape RoundedRectangleBorder(
                                          side BorderSide(
                                            width 1,
                                            color const Color(0xFFE6C56A)  goldBright ,
                                          ),
                                          borderRadius BorderRadius.circular(8),
                                        ),
                                      ),
                                      child Row(
                                        mainAxisSize MainAxisSize.min,
                                        mainAxisAlignment MainAxisAlignment.center,
                                        crossAxisAlignment CrossAxisAlignment.center,
                                        spacing 8,
                                        children [
                                          Text(
                                            '确认',
                                            style TextStyle(
                                              color const Color(0xFF171A20),
                                              fontSize 15,
                                              fontFamily 'Noto Sans SC',
                                              fontWeight FontWeight.w700,
                                              height 1.40,
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
              Container(
                width double.infinity,
                height 52,
                padding const EdgeInsets.symmetric(horizontal 24),
                clipBehavior Clip.antiAlias,
                decoration ShapeDecoration(
                  color const Color(0xFF131A23)  darkTokens-color-bgPanel ,
                  shape RoundedRectangleBorder(
                    side BorderSide(
                      width 1,
                      color const Color(0xFF2C3035),
                    ),
                  ),
                ),
                child Row(
                  mainAxisSize MainAxisSize.min,
                  mainAxisAlignment MainAxisAlignment.spaceBetween,
                  crossAxisAlignment CrossAxisAlignment.center,
                  children [
                    Container(
                      clipBehavior Clip.antiAlias,
                      decoration BoxDecoration(),
                      child Row(
                        mainAxisSize MainAxisSize.min,
                        mainAxisAlignment MainAxisAlignment.start,
                        crossAxisAlignment CrossAxisAlignment.center,
                        spacing 8,
                        children [
                          Text(
                            '主视角',
                            style TextStyle(
                              color const Color(0xFF9A917E)  darkTokens-color-textSecondary ,
                              fontSize 11,
                              fontFamily 'Noto Sans SC',
                              fontWeight FontWeight.w400,
                            ),
                          ),
                          Container(
                            width 26,
                            height 30,
                            clipBehavior Clip.antiAlias,
                            decoration ShapeDecoration(
                              color const Color(0xFF29251C),
                              shape RoundedRectangleBorder(
                                side BorderSide(
                                  width 1,
                                  color const Color(0xFFC9A24B)  goldPrimary ,
                                ),
                                borderRadius BorderRadius.circular(5),
                              ),
                            ),
                            child Row(
                              mainAxisSize MainAxisSize.min,
                              mainAxisAlignment MainAxisAlignment.center,
                              crossAxisAlignment CrossAxisAlignment.center,
                              children [
                                Text(
                                  '1',
                                  style TextStyle(
                                    color const Color(0xFFC9A24B)  goldPrimary ,
                                    fontSize 11,
                                    fontFamily 'Inter',
                                    fontWeight FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width 26,
                            height 30,
                            clipBehavior Clip.antiAlias,
                            decoration ShapeDecoration(
                              color const Color(0xFF131A23)  darkTokens-color-bgPanel ,
                              shape RoundedRectangleBorder(
                                side BorderSide(
                                  width 1,
                                  color const Color(0xFF2C3035),
                                ),
                                borderRadius BorderRadius.circular(5),
                              ),
                            ),
                            child Row(
                              mainAxisSize MainAxisSize.min,
                              mainAxisAlignment MainAxisAlignment.center,
                              crossAxisAlignment CrossAxisAlignment.center,
                              children [
                                Text(
                                  '2',
                                  style TextStyle(
                                    color const Color(0xFF9A917E)  darkTokens-color-textSecondary ,
                                    fontSize 11,
                                    fontFamily 'Inter',
                                    fontWeight FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width 26,
                            height 30,
                            clipBehavior Clip.antiAlias,
                            decoration ShapeDecoration(
                              color const Color(0xFF131A23)  darkTokens-color-bgPanel ,
                              shape RoundedRectangleBorder(
                                side BorderSide(
                                  width 1,
                                  color const Color(0xFF2C3035),
                                ),
                                borderRadius BorderRadius.circular(5),
                              ),
                            ),
                            child Row(
                              mainAxisSize MainAxisSize.min,
                              mainAxisAlignment MainAxisAlignment.center,
                              crossAxisAlignment CrossAxisAlignment.center,
                              children [
                                Text(
                                  '3',
                                  style TextStyle(
                                    color const Color(0xFF9A917E)  darkTokens-color-textSecondary ,
                                    fontSize 11,
                                    fontFamily 'Inter',
                                    fontWeight FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width 26,
                            height 30,
                            clipBehavior Clip.antiAlias,
                            decoration ShapeDecoration(
                              color const Color(0xFF131A23)  darkTokens-color-bgPanel ,
                              shape RoundedRectangleBorder(
                                side BorderSide(
                                  width 1,
                                  color const Color(0xFF2C3035),
                                ),
                                borderRadius BorderRadius.circular(5),
                              ),
                            ),
                            child Row(
                              mainAxisSize MainAxisSize.min,
                              mainAxisAlignment MainAxisAlignment.center,
                              crossAxisAlignment CrossAxisAlignment.center,
                              children [
                                Text(
                                  '4',
                                  style TextStyle(
                                    color const Color(0xFF9A917E)  darkTokens-color-textSecondary ,
                                    fontSize 11,
                                    fontFamily 'Inter',
                                    fontWeight FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width 20,
                            height 20,
                            clipBehavior Clip.antiAlias,
                            decoration BoxDecoration(),
                            child Stack(),
                          ),
                          Text(
                            '开牌  关牌',
                            style TextStyle(
                              color const Color(0xFF9A917E)  darkTokens-color-textSecondary ,
                              fontSize 12,
                              fontFamily 'Noto Sans SC',
                              fontWeight FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      clipBehavior Clip.antiAlias,
                      decoration BoxDecoration(),
                      child Row(
                        mainAxisSize MainAxisSize.min,
                        mainAxisAlignment MainAxisAlignment.start,
                        crossAxisAlignment CrossAxisAlignment.center,
                        spacing 20,
                        children [
                          Text(
                            '网络正常 · 24 ms',
                            style TextStyle(
                              color const Color(0xFF9A917E)  darkTokens-color-textSecondary ,
                              fontSize 11,
                              fontFamily 'Noto Sans SC',
                              fontWeight FontWeight.w400,
                            ),
                          ),
                          Container(
                            width 20,
                            height 20,
                            clipBehavior Clip.antiAlias,
                            decoration BoxDecoration(),
                            child Stack(),
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