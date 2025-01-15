import 'package:flutter/material.dart';

class ScrollInfinite extends StatefulWidget {
  const ScrollInfinite({
    required this.children,
    required this.onEndOfPage,
    required this.isMore,
    required this.onRefresh,
    super.key,
    this.scrollDown,
    this.scrollUp,
    this.controllerListener,
    this.axis = Axis.vertical,
    this.controller,
    this.widgetLoading,
    this.widgetEmptyLayout,
    this.loading = false,
    this.countLoading = 1,
    this.page = 8,
  });

  const ScrollInfinite.onlyRefresh({
    required this.children,
    required this.onRefresh,
    super.key,
    this.scrollDown,
    this.scrollUp,
    this.controllerListener,
    this.axis = Axis.vertical,
    this.controller,
    this.widgetLoading,
    this.widgetEmptyLayout,
    this.loading = false,
    this.countLoading = 1,
    this.page = 8,
  })  : isMore = false,
        onEndOfPage = null;

  final List<Widget> children;
  final Axis axis;

  final void Function()? onEndOfPage;
  final void Function()? scrollUp;
  final void Function()? scrollDown;
  final void Function(ScrollController?)? controllerListener;
  final Future<void> Function() onRefresh;

  final ScrollController? controller;

  final Widget? widgetEmptyLayout;
  final Widget? widgetLoading;

  final int page;
  final int countLoading;

  final bool isMore;
  final bool loading;

  @override
  ScrollInfiniteState createState() => ScrollInfiniteState();
}

class ScrollInfiniteState extends State<ScrollInfinite> {
  late ScrollController controller;

  late double lastPosition;
  late double minimalOffset;
  late double maximalOffset;

  late bool loading;
  late bool isMore;

  late int currentPosition;
  late int page;
  late int countLoading;

  late List<Widget> listWidget;

  int get getExtraLoading => loading ?? false ? countLoading : 1;
  int get cLoading => loading ? getExtraLoading : 0;
  int get countData =>
      isMore ? listWidget.length + cLoading : listWidget.length;

  @override
  void initState() {
    super.initState();

    controller = widget.controller ?? ScrollController();

    currentPosition = 5;
    lastPosition = 0;
    minimalOffset = 0;
    maximalOffset = 0;

    loading = widget.loading;
    page = widget.page;
    countLoading = widget.countLoading;
    isMore = widget.isMore;
    listWidget = widget.children;

    widget.controllerListener?.call(controller);

    controller
      ..addListener(listenerLoadMore)
      ..addListener(listenerScroll);
  }

  void listenerLoadMore() {
    final offset = controller.offset;
    final maxScroll = controller.position.maxScrollExtent;

    final isEnd = offset - 200 <= maxScroll && offset >= maxScroll;

    if (isEnd) {
      if (currentPosition < listWidget.length) {
        currentPosition = currentPosition + page;
      }
      if (isMore) widget.onEndOfPage?.call();
    }
  }

  void listenerScroll() {
    if (lastPosition > controller.offset) widget.scrollDown?.call();
    if (lastPosition < controller.offset) widget.scrollUp?.call();

    lastPosition = controller.offset;
  }

  @override
  void didUpdateWidget(covariant ScrollInfinite oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.loading != widget.loading) loading = widget.loading;
    if (oldWidget.isMore != widget.isMore) isMore = widget.isMore;
    if (oldWidget.children != widget.children) {
      listWidget = widget.children;
    }
    if (oldWidget.page != widget.page) page = widget.page;
    if (oldWidget.countLoading != widget.countLoading) {
      countLoading = widget.countLoading;
    }
  }

  @override
  Widget build(BuildContext context) {
    return (Axis.horizontal == widget.axis)
        ? countData == 0
            ? emptyLayout()
            : ListView.builder(
                controller: controller,
                scrollDirection: Axis.horizontal,
                itemCount: countData,
                padding: EdgeInsets.zero,
                itemBuilder: item,
              )
        : RefreshIndicator(
            onRefresh: widget.onRefresh,
            child: countData == 0
                ? emptyLayout()
                : ListView.builder(
                    controller: controller,
                    itemCount: countData,
                    padding: EdgeInsets.zero,
                    itemBuilder: item,
                  ),
          );
  }

  Widget item(BuildContext context, int index) {
    if (index >= listWidget.length) {
      return widget.widgetLoading ??
          Padding(
            padding: EdgeInsets.only(top: 20, bottom: 20),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
    }

    return listWidget[index];
  }

  Widget emptyLayout() {
    return widget.widgetEmptyLayout ??
        Center(
          child: Text("Nothing Children in here"),
        );
  }
}
