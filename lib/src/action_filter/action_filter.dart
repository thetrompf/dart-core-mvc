part of action_filter;

abstract class ActionFilter {
  Future executeActionFilter(FilterContext context);
}

class CompositeFilter implements ActionFilter {

  final Iterable<ActionFilter> filters;
  const CompositeFilter(this.filters);

  @override
  Future executeActionFilter(FilterContext context) {
    return filters.fold(null, (prev, filter) async {
      await prev;
      return filter.executeActionFilter(context);
    });
  }
}
