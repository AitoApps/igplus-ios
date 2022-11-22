import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:igshark/domain/entities/media.dart';
import 'package:igshark/presentation/blocs/insight/media_insight/cubit/media_list_cubit.dart';
import 'package:igshark/presentation/resources/colors_manager.dart';
import 'package:igshark/presentation/resources/theme_manager.dart';
import 'package:igshark/presentation/views/insight/media/media_list/media_list_item.dart';
import 'package:igshark/presentation/views/insight/media/media_list/media_search.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class MediaList extends StatefulWidget {
  const MediaList({Key? key, required this.type}) : super(key: key);

  final String type;

  @override
  State<MediaList> createState() => _MediaListState();
}

class _MediaListState extends State<MediaList> {
  static const _pageSize = 30;
  static const int _initialPageKey = 0;
  final PagingController<int, Media> _pagingController = PagingController(firstPageKey: _initialPageKey);
  String? _searchTerm;
  bool _showSearchForm = false;
  late ScrollController _scrollController;
  late FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });

    _pagingController.addStatusListener((status) {
      if (status == PagingStatus.subsequentPageError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Something went wrong while fetching a new page.',
            ),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _pagingController.retryLastFailedRequest(),
            ),
          ),
        );
      }
    });

    _scrollController = ScrollController();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _scrollController.dispose(); // dispose the controller
    _pagingController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(pageKey) async {
    try {
      final List<Media>? mediaList = await context.read<MediaListCubit>().getMediaListFromLocal(
          boxKey: Media.boxKey, pageKey: pageKey, pageSize: _pageSize, searchTerm: _searchTerm, type: widget.type);

      if (mediaList == null || mediaList.isEmpty) {
        _pagingController.appendLastPage([]);
      } else {
        final isLastPage = mediaList.length < _pageSize;
        if (isLastPage) {
          _pagingController.appendLastPage(mediaList);
        } else {
          final nextPageKey = pageKey + mediaList.length;
          _pagingController.appendPage(mediaList, nextPageKey);
        }
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String pageTitle;
    switch (widget.type) {
      case "mostPopularMedia":
        pageTitle = "Most Popular Media";
        break;
      case "mostLikedMedia":
        pageTitle = "Most Liked Media";
        break;
      case "mostCommentedMedia":
        pageTitle = "Most Commented Media";
        break;
      case "mostViewedMedia":
        pageTitle = "Most Viewed Media";
        break;
      default:
        pageTitle = "";
        break;
    }
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: ColorsManager.appBack,
        leading: GestureDetector(
            onTap: () => GoRouter.of(context).pop(),
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 26.0,
            )),
        middle: Text(pageTitle, style: const TextStyle(fontSize: 16, color: Colors.white)),
        trailing: GestureDetector(
          onTap: () {
            if (_showSearchForm == false) {
              _scrollToTop();
              try {
                _searchFocusNode.requestFocus();
              } catch (e) {
                // print(e);
              }
            }
            setState(() {
              _showSearchForm = !_showSearchForm;
            });
          },
          child: const Icon(
            Icons.search,
            color: ColorsManager.textColor,
            size: 26.0,
          ),
        ),
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: appMaterialTheme(),
        home: Scaffold(
          backgroundColor: ColorsManager.appBack,
          body: BlocBuilder<MediaListCubit, MediaListState>(
            builder: (context, state) {
              return (_showSearchForm)
                  ? CustomScrollView(
                      controller: _scrollController,
                      slivers: <Widget>[
                        MediaSearch(
                          onChanged: (searchTerm) => _updateSearchTerm(searchTerm),
                          searchFocusNode: _searchFocusNode,
                        ),
                        PagedSliverGrid<int, Media>(
                          pagingController: _pagingController,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 100 / 100,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            crossAxisCount: 3,
                          ),
                          builderDelegate: PagedChildBuilderDelegate<Media>(
                            itemBuilder: (context, item, index) => MediaListItem(
                              media: item,
                              index: index,
                              type: widget.type,
                            ),
                          ),
                        ),
                      ],
                    )
                  : CustomScrollView(
                      slivers: <Widget>[
                        PagedSliverGrid<int, Media>(
                          pagingController: _pagingController,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 100 / 100,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            crossAxisCount: 3,
                          ),
                          builderDelegate: PagedChildBuilderDelegate<Media>(
                            itemBuilder: (context, item, index) => MediaListItem(
                              media: item,
                              index: index,
                              type: widget.type,
                            ),
                          ),
                        ),
                      ],
                    );
            },
          ),
        ),
      ),
    );
  }

  void _updateSearchTerm(String searchTerm) {
    _searchTerm = searchTerm;
    _pagingController.refresh();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.linear,
      );
    }
  }
}
