import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:igshark/domain/entities/media_liker.dart';
import 'package:igshark/domain/entities/media_likers.dart';
import 'package:igshark/presentation/blocs/engagement/cubit/engagement_cubit.dart';
import 'package:igshark/presentation/blocs/engagement/media_likers/cubit/media_likers_cubit.dart';
import 'package:igshark/presentation/resources/colors_manager.dart';
import 'package:igshark/presentation/resources/theme_manager.dart';
import 'package:igshark/presentation/views/engagement/media_likers/media_likers_list_item.dart';
import 'package:igshark/presentation/views/engagement/media_likers/media_likers_search.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class MediaLikersList extends StatefulWidget {
  const MediaLikersList({Key? key, required this.type}) : super(key: key);

  final String type;

  @override
  State<MediaLikersList> createState() => _MediaLikersListState();
}

class _MediaLikersListState extends State<MediaLikersList> {
  static const _pageSize = 15;
  static const int _initialPageKey = 0;
  final PagingController<int, MediaLikers> _pagingController = PagingController(firstPageKey: _initialPageKey);
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
      late List<MediaLikers>? mediaLikersList;

      if (widget.type == "likersNotFollow") {
        mediaLikersList = await context.read<MediaLikersCubit>().getLikesUsersButNotFollow(
            boxKey: MediaLiker.boxKey, pageKey: pageKey, pageSize: _pageSize, searchTerm: _searchTerm);
      } else if (widget.type == "leastLikesGiven") {
        mediaLikersList = await context.read<MediaLikersCubit>().getMostLikesUsers(
            boxKey: MediaLiker.boxKey, pageKey: pageKey, pageSize: _pageSize, searchTerm: _searchTerm, reverse: true);
      } else {
        mediaLikersList = await context.read<MediaLikersCubit>().getMostLikesUsers(
            boxKey: MediaLiker.boxKey, pageKey: pageKey, pageSize: _pageSize, searchTerm: _searchTerm);
      }

      if (mediaLikersList == null || mediaLikersList.isEmpty) {
        _pagingController.appendLastPage([]);
      } else {
        final isLastPage = mediaLikersList.length < _pageSize;
        if (isLastPage) {
          _pagingController.appendLastPage(mediaLikersList);
        } else {
          final nextPageKey = pageKey + mediaLikersList.length;
          _pagingController.appendPage(mediaLikersList, nextPageKey);
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
          body: BlocConsumer<MediaLikersCubit, MediaLikersState>(
            listener: (context, state) {
              if (state is MediaLikersLoading) {
                BlocProvider.of<EngagementCubit>(context).emit(EngagementLoading());
              }
            },
            builder: (context, state) {
              return (_showSearchForm)
                  ? CustomScrollView(
                      controller: _scrollController,
                      slivers: <Widget>[
                        MediaLikersSearch(
                          onChanged: (searchTerm) => _updateSearchTerm(searchTerm),
                          searchFocusNode: _searchFocusNode,
                        ),
                        PagedSliverList<int, MediaLikers>(
                          pagingController: _pagingController,
                          builderDelegate: PagedChildBuilderDelegate<MediaLikers>(
                            animateTransitions: true,
                            itemBuilder: (context, item, index) => MediaLikersListItem(
                              mediaLikers: item,
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
                        PagedSliverList<int, MediaLikers>(
                          pagingController: _pagingController,
                          builderDelegate: PagedChildBuilderDelegate<MediaLikers>(
                            animateTransitions: true,
                            itemBuilder: (context, item, index) => MediaLikersListItem(
                              mediaLikers: item,
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
