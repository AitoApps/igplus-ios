import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:igshark/domain/entities/story_viewer.dart';
import 'package:igshark/presentation/blocs/insight/stories_insight/story_viewers/cubit/story_viewers_cubit.dart';
import 'package:igshark/presentation/resources/colors_manager.dart';
import 'package:igshark/presentation/resources/theme_manager.dart';
import 'package:igshark/presentation/views/home/friends_list/friend_search.dart';
import 'package:igshark/presentation/views/insight/stories/story_viewers_list/story_viewers_list_item.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class StoryViewersList extends StatefulWidget {
  const StoryViewersList({Key? key, required this.type, this.mediaId}) : super(key: key);

  final String type;
  final String? mediaId;

  @override
  State<StoryViewersList> createState() => _StoryViewersState();
}

class _StoryViewersState extends State<StoryViewersList> {
  static const _pageSize = 15;
  static const int _initialPageKey = 0;
  final PagingController<int, StoryViewer> _pagingController = PagingController(firstPageKey: _initialPageKey);
  String? _searchTerm;
  bool _showSearchForm = false;
  late ScrollController _scrollController;
  late FocusNode _searchFocusNode;

  @override
  void initState() {
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

    super.initState();
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
      if (widget.mediaId != null) {
        final List<StoryViewer>? storyViewersList = await context.read<StoryViewersCubit>().getStoryViewersList(
              mediaId: widget.mediaId!,
              type: widget.type,
              pageKey: pageKey,
              pageSize: _pageSize,
              searchTerm: _searchTerm,
            );

        if (storyViewersList == null || storyViewersList.isEmpty) {
          _pagingController.appendLastPage([]);
        } else {
          final isLastPage = storyViewersList.length < _pageSize || storyViewersList.length > _pageSize;
          if (isLastPage) {
            _pagingController.appendLastPage(storyViewersList);
          } else {
            final nextPageKey = pageKey + storyViewersList.length;
            _pagingController.appendPage(storyViewersList, nextPageKey);
          }
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
      case "mostViewedStories":
        pageTitle = "Most Viewed Stories";
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
          body: BlocBuilder<StoryViewersCubit, StoryViewersState>(
            builder: (context, state) {
              return (_showSearchForm)
                  ? CustomScrollView(
                      controller: _scrollController,
                      slivers: <Widget>[
                        FriendSearch(
                          onChanged: (searchTerm) => _updateSearchTerm(searchTerm),
                          searchFocusNode: _searchFocusNode,
                        ),
                        PagedSliverList<int, StoryViewer>(
                          pagingController: _pagingController,
                          builderDelegate: PagedChildBuilderDelegate<StoryViewer>(
                            animateTransitions: true,
                            itemBuilder: (context, item, index) => StoryViewerListItem(
                              storyViewer: item,
                              index: index,
                              type: widget.type,
                            ),
                          ),
                        )
                      ],
                    )
                  : CustomScrollView(
                      controller: _scrollController,
                      slivers: <Widget>[
                        PagedSliverList<int, StoryViewer>(
                          pagingController: _pagingController,
                          builderDelegate: PagedChildBuilderDelegate<StoryViewer>(
                            animateTransitions: true,
                            itemBuilder: (context, item, index) => StoryViewerListItem(
                              storyViewer: item,
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
