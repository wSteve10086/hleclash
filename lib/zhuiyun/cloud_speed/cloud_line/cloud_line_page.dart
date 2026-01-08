
import 'package:fl_clash/zhuiyun/cloud_utils/cloud_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';


enum MenuType { Sort }

class CloudLinePage extends StatefulWidget {
  const CloudLinePage({super.key});

  @override
  State<CloudLinePage> createState() => _CloudLinePageState();
}

class _CloudLinePageState extends State<CloudLinePage> {
  final ScrollController _scrollController = ScrollController();
  // final ProxysController _controller = Modular.get<ProxysController>();
  bool _showFab = true;

  @override
  void initState() {
    super.initState();
    // _controller.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection ==
            ScrollDirection.reverse &&
        _showFab) {
      setState(() => _showFab = false);
    }
    if (_scrollController.position.userScrollDirection ==
            ScrollDirection.forward &&
        !_showFab) {
      setState(() => _showFab = true);
    }
  }

  void testDelay(TabController tabController) async {
    // var overlay = Loading.builder();
    // Asuka.addOverlay(overlay);
    // await _controller.delayGroup(
    //   _controller.model.groups[tabController.index],
    // );
    // overlay.remove();
  }

  moreMenu(MenuType type) {
    switch (type) {
      // 排序
      case MenuType.Sort:
        sortAction();
        break;
    }
  }

  sortAction() {
    change(sortType, BuildContext context) {
      // _controller.sort(sortType);
      Navigator.of(context).pop();
    }

    // Asuka.showModalBottomSheet(
    //   backgroundColor: Colors.transparent,
    //   builder: (cxt) => Material(
    //     borderRadius: const BorderRadius.only(
    //       topLeft: Radius.circular(16),
    //       topRight: Radius.circular(16),
    //     ),
    //     elevation: 7,
    //     child: SizedBox(
    //       height: SortType.values.length * 50,
    //       child: ListView.builder(
    //         itemCount: SortType.values.length,
    //         itemBuilder: (_, i) {
    //           return ListTile(
    //             contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    //             onTap: () => change(SortType.values[i], cxt),
    //             title: Text(SortType.values[i].showName),
    //             trailing: Radio<SortType>(
    //               value: SortType.values[i],
    //               groupValue: _controller.model.sortType,
    //               onChanged: (v) => change(v, cxt),
    //             ),
    //           );
    //         },
    //       ),
    //     ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    // return Observer(builder: (c) {
    //   var groups = _controller.model.groups;
    var groups = [];
    return DefaultTabController(
      length: groups.length,
      child: Scaffold(
        backgroundColor: CloudColors.bg,
        // appBar:
        // SysAppBar(
        //   toolbarHeight:kToolbarHeight + (( Platform.isMacOS || Platform.isWindows) ? 20 : 0),
        //   title: (groups.isNotEmpty && groups.length>1)
        //       ? TabBar(
        //     tabs: groups.map((e) => Tab(text: e.name)).toList(),
        //     isScrollable: true,
        //     dividerHeight: 0,
        //     indicatorColor: CloudColors.c3254FF,
        //     labelColor: CloudColors.c3254FF,
        //     labelStyle: const TextStyle(
        //       //选中label的Style
        //       fontSize: 15,
        //     ),
        //     unselectedLabelColor: Colors.grey, //未选中label颜色
        //     unselectedLabelStyle: const TextStyle(
        //       //未选中label的Style
        //         fontSize: 12),
        //   )
        //       : const Text(
        //     "线路列表",
        //     style: TextStyle(
        //         fontSize: 18,
        //         color: CloudColors.white
        //     ),
        //   ),
        //   actions: [
        //     IconButton(
        //       color: CloudColors.white,
        //       tooltip: "排序",
        //       icon: const Icon(Icons.sort_outlined),
        //       onPressed: sortAction,
        //     ),
        //   ],
        // ),
        body: groups.isNotEmpty
            ? TabBarView(
                children: groups.map((group) {
                  var groupName = group.name;
                  var groupNow = group.now;
                  // var list = _controller.getShowList(group);
                  var list = [];
                  return ListView.separated(
                    controller: _scrollController,
                    itemBuilder: (_, i) {
                      var show = list[i];
                      var name = show.name;
                      var delay = (show.delay / 3).ceil();
                      bool isTimeout = int.parse(delay.toString()) < 0;
                      var readlDelay = isTimeout
                          ? null
                          : Text(
                              delay == 0 ? "超时" : delay.toString(),
                              style: TextStyle(
                                color: delay == 0
                                    ? CloudColors.cEA0000
                                    : CloudColors.c32CD32,
                              ),
                            );
                      return Padding(
                        padding: const EdgeInsets.only(left: 0.0),
                        child: ListTile(
                          visualDensity: const VisualDensity(
                            vertical: VisualDensity.minimumDensity,
                          ),
                          selected: groupNow == name,
                          title: Text(
                            name.toString(),
                            style: TextStyle(
                                fontSize: 14,
                                color: (groupNow == name
                                    ? CloudColors.c3254FF
                                    : CloudColors.white)),
                          ),
                          subtitle: Text(
                            // show.subTitle,
                            'subTitle',
                            style: TextStyle(
                                fontSize: 12,
                                color: (groupNow == name
                                    ? CloudColors.c3254FF
                                    : CloudColors.white)),
                          ),
                          trailing: readlDelay,
                          // onTap: () => _controller.select(
                          //   name: groupName,
                          //   select: name,
                          // ),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(
                            height: 0.5,
                            indent: 15,
                            endIndent: 15,
                            color: CloudColors.c242738),
                    itemCount: list.length,
                  );
                }).toList(),
              )
            : const Center(child: Text("暂无可选代理节点")),
        floatingActionButton: _showFab
            ? Builder(
                builder: (cxt) {
                  var tabController = DefaultTabController.of(cxt);
                  return FloatingActionButton(
                    tooltip: "测延迟",
                    onPressed: () {
                      if (groups.isNotEmpty) {
                        testDelay(tabController);
                      }
                    },
                    child: const Icon(Icons.flash_on),
                  );
                },
              )
            : null,
      ),
    );
    // });
  }
}
