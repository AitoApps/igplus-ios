import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:igshark/domain/entities/media_commenter.dart';
import 'package:igshark/domain/entities/media_commenters.dart';
import 'package:igshark/presentation/blocs/engagement/cubit/engagement_cubit.dart';
import 'package:igshark/presentation/blocs/engagement/media_commeters/cubit/media_commenters_cubit.dart';
import 'package:igshark/presentation/resources/colors_manager.dart';
import 'package:igshark/presentation/resources/theme_manager.dart';
import 'package:igshark/presentation/views/engagement/media_commenters/media_commenters_list_item.dart';
import 'package:igshark/presentation/views/engagement/media_commenters/media_commenters_search.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class MediaCommentersList extends StatefulWidget {
  const MediaCommentersList({Key? key, required this.type}) : super(key: key);

  final String type;

  @override
  State<MediaCommentersList> createState() => _MediaCommentersListState();
}

class _MediaCommentersListState extends State<MediaCommentersList> {
  static const _pageSize = 15;
  static const int _initialPageKey = 0;
  final PagingController<int, MediaCommenters> _pagingController = PagingController(firstPageKey: _initialPageKey);
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
      late List<MediaCommenters>? mediaCommentersList;
      if (widget.type == "commentersNotFollow") {
        mediaCommentersList = await context.read<MediaCommentersCubit>().getCommentsUsersButNotFollow(
            boxKey: MediaCommenter.boxKey, pageKey: pageKey, pageSize: _pageSize, searchTerm: _searchTerm);
      } else if (widget.type == "leastCommentsGiven") {
        mediaCommentersList = await context.read<MediaCommentersCubit>().getMostCommentsUsers(
            boxKey: MediaCommenter.boxKey,
            pageKey: pageKey,
            pageSize: _pageSize,
            searchTerm: _searchTerm,
            reverse: true);
      } else {
        mediaCommentersList = await context.read<MediaCommentersCubit>().getMostCommentsUsers(
            boxKey: MediaCommenter.boxKey, pageKey: pageKey, pageSize: _pageSize, searchTerm: _searchTerm);
      }

      if (mediaCommentersList == null || mediaCommentersList.isEmpty) {
        _pagingController.appendLastPage([]);
      } else {
        final isLastPage = mediaCommentersList.length < _pageSize;
        if (isLastPage) {
          _pagingController.appendLastPage(mediaCommentersList);
        } else {
          final nextPageKey = pageKey + mediaCommentersList.length;
          _pagingController.appendPage(mediaCommentersList, nextPageKey);
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
      case "mostLikes":
        pageTitle = "Most Likes";
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
            if (mounted) {
              setState(() {
                _showSearchForm = !_showSearchForm;
              });
            }
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
          body: BlocConsumer<MediaCommentersCubit, MediaCommentersState>(
            listener: (context, state) {
              if (state is MediaCommentersLoading) {
                BlocProvider.of<EngagementCubit>(context).emit(EngagementLoading());
              }
            },
            builder: (context, state) {
              return (_showSearchForm)
                  ? CustomScrollView(
                      controller: _scrollController,
                      slivers: <Widget>[
                        MediaCommentersSearch(
                          onChanged: (searchTerm) => _updateSearchTerm(searchTerm),
                          searchFocusNode: _searchFocusNode,
                        ),
                        PagedSliverList<int, MediaCommenters>(
                          pagingController: _pagingController,
                          builderDelegate: PagedChildBuilderDelegate<MediaCommenters>(
                            animateTransitions: true,
                            itemBuilder: (context, item, index) => MediaCommentersListItem(
                              mediaCommenters: item,
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
                        PagedSliverList<int, MediaCommenters>(
                          pagingController: _pagingController,
                          builderDelegate: PagedChildBuilderDelegate<MediaCommenters>(
                            animateTransitions: true,
                            itemBuilder: (context, item, index) => MediaCommentersListItem(
                              mediaCommenters: item,
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
