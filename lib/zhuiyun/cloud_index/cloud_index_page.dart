import 'package:fl_clash/gen/assets.gen.dart';
import 'package:fl_clash/zhuiyun/cloud_mine/cloud_mine_page.dart';
import 'package:fl_clash/zhuiyun/cloud_speed/cloud_speed_page.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_colors.dart';
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_theme_asset.dart';
import 'package:fl_clash/zhuiyun/cloud_vip/cloud_vip_page.dart';
import 'package:flutter/material.dart';

class CloudIndexPage extends StatefulWidget {
  const CloudIndexPage({super.key});

  @override
  State<CloudIndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<CloudIndexPage>
    with WidgetsBindingObserver {
  int _curPage = 0;
  final PageController _page = PageController(initialPage: 0);
  final List<MenuRouteItem> cloudMenuList = [
    MenuRouteItem(
      title: "加速",
      icon: Assets.images.iconSpeed.path,
      selectedIcon: Assets.images.iconSpeedSelected.path,
      path: "/cloud_speed",
    ),
    MenuRouteItem(
      title: "会员",
      icon: Assets.images.iconVip.path,
      selectedIcon: Assets.images.iconVipSelected.path,
      path: "/cloud_vip",
    ),
    MenuRouteItem(
      title: "我的",
      icon: Assets.images.iconMine.path,
      selectedIcon: Assets.images.iconMineSelected.path,
      path: "/cloud_mine",
    ),
  ];
  @override
  void initState() {
    super.initState();

    // 移动端前后台监听
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 处理在移动端前后台
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    appListener(state == AppLifecycleState.inactive);
  }

  /// 统一处理前后台改变
  void appListener(bool state) {
    if (state) {
      debugPrint("应用前台");
    } else {
      debugPrint("应用后台");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CloudColors.bg,
      body: Column(children: [
        Expanded(
          child: PageView(
            controller: _page,
            physics: const NeverScrollableScrollPhysics(),
            // itemCount: cloudMenu.size,
            onPageChanged: (i) {
              setState(() {
                _curPage = i;
              });
            },
            children: const [
              CloudSpeedPage(),
              CloudVipPage(),
              CloudMinePage(),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(cloudMenuList.length, (index) {
            final MenuRouteItem item = cloudMenuList[index];
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                setState(() {
                  _curPage = index;
                  _page.jumpToPage(index);
                });
              },
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 3.0,
                child: Column(
                  children: [
                    CloudThemeAsset(
                      _curPage == index ? item.selectedIcon : item.icon,
                      width: 22,
                      height: 22,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      item.title,
                      style: TextStyle(
                          fontSize: 10,
                          color: _curPage == index
                              ? CloudColors.c3254FF
                              : CloudColors.c5D5D6D),
                    )
                  ],
                ),
              ),
            );
          }),
        ),
        const SizedBox(
          height: 20,
        ),
      ]),
    );
  }
}

class MenuRouteItem {
  final String title;
  final String icon;
  final String selectedIcon;
  final String path;

  const MenuRouteItem({
    required this.title,
    required this.icon,
    required this.selectedIcon,
    required this.path,
  });
}
