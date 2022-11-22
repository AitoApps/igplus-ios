import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:igshark/domain/entities/likes_and_comments.dart';
import 'package:igshark/presentation/blocs/engagement/media_likers/cubit/media_likers_cubit.dart';
import 'package:igshark/presentation/resources/colors_manager.dart';
import 'package:igshark/presentation/resources/theme_manager.dart';
import 'package:igshark/presentation/views/home/who_admires_you/who_admires_you_list_item.dart';
import 'package:igshark/presentation/views/home/who_admires_you/who_admires_you_search.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class WhoAdmiresYouList extends StatefulWidget {
  const WhoAdmiresYouList({Key? key, required this.type}) : super(key: key);

  final String type;

  @override
  State<WhoAdmiresYouList> createState() => _WhoAdmiresYouListState();
}

class _WhoAdmiresYouListState extends State<WhoAdmiresYouList> {
  static const _pageSize = 15;
  static const int _initialPageKey = 0;
  final PagingController<int, LikesAndComments> _pagingController = PagingController(firstPageKey: _initialPageKey);
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
      late List<LikesAndComments>? whoAdmiresYou;
      whoAdmiresYou = await context.read<MediaLikersCubit>().getWhoAdmiresYou(
          boxKey: LikesAndComments.boxKey, pageKey: pageKey, pageSize: _pageSize, searchTerm: _searchTerm);

      if (whoAdmiresYou == null || whoAdmiresYou.isEmpty) {
        _pagingController.appendLastPage([]);
      } else {
        final isLastPage = whoAdmiresYou.length < _pageSize;
        if (isLastPage) {
          _pagingController.appendLastPage(whoAdmiresYou);
        } else {
          final nextPageKey = pageKey + whoAdmiresYou.length;
          _pagingController.appendPage(whoAdmiresYou, nextPageKey);
        }
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
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
        middle: const Text("Who Admires You", style: TextStyle(fontSize: 16, color: Colors.white)),
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
          body: BlocBuilder<MediaLikersCubit, MediaLikersState>(
            builder: (context, state) {
              return (_showSearchForm)
                  ? CustomScrollView(
                      controller: _scrollController,
                      slivers: <Widget>[
                        WhoAdmiresYouSearch(
                          onChanged: (searchTerm) => _updateSearchTerm(searchTerm),
                          searchFocusNode: _searchFocusNode,
                        ),
                        PagedSliverList<int, LikesAndComments>(
                          pagingController: _pagingController,
                          builderDelegate: PagedChildBuilderDelegate<LikesAndComments>(
                            animateTransitions: true,
                            itemBuilder: (context, item, index) => WhoAdmiresYouListItem(
                              whoAdmiresYou: item,
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
                        PagedSliverList<int, LikesAndComments>(
                          pagingController: _pagingController,
                          builderDelegate: PagedChildBuilderDelegate<LikesAndComments>(
                            animateTransitions: true,
                            itemBuilder: (context, item, index) => WhoAdmiresYouListItem(
                              whoAdmiresYou: item,
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
