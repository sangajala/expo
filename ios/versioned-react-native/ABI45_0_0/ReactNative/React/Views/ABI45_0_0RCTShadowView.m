/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "ABI45_0_0RCTShadowView.h"

#import "ABI45_0_0RCTConvert.h"
#import "ABI45_0_0RCTI18nUtil.h"
#import "ABI45_0_0RCTLayout.h"
#import "ABI45_0_0RCTLog.h"
#import "ABI45_0_0RCTShadowView+Layout.h"
#import "ABI45_0_0RCTUtils.h"
#import "ABI45_0_0UIView+Private.h"
#import "ABI45_0_0UIView+React.h"

typedef void (^ABI45_0_0RCTActionBlock)(ABI45_0_0RCTShadowView *shadowViewSelf, id value);
typedef void (^ABI45_0_0RCTResetActionBlock)(ABI45_0_0RCTShadowView *shadowViewSelf);

typedef NS_ENUM(unsigned int, meta_prop_t) {
  META_PROP_LEFT,
  META_PROP_TOP,
  META_PROP_RIGHT,
  META_PROP_BOTTOM,
  META_PROP_START,
  META_PROP_END,
  META_PROP_HORIZONTAL,
  META_PROP_VERTICAL,
  META_PROP_ALL,
  META_PROP_COUNT,
};

@implementation ABI45_0_0RCTShadowView {
  NSDictionary *_lastParentProperties;
  NSMutableArray<ABI45_0_0RCTShadowView *> *_ABI45_0_0ReactSubviews;
  BOOL _recomputePadding;
  BOOL _recomputeMargin;
  BOOL _recomputeBorder;
  ABI45_0_0YGValue _paddingMetaProps[META_PROP_COUNT];
  ABI45_0_0YGValue _marginMetaProps[META_PROP_COUNT];
  ABI45_0_0YGValue _borderMetaProps[META_PROP_COUNT];
}

+ (ABI45_0_0YGConfigRef)yogaConfig
{
  static ABI45_0_0YGConfigRef yogaConfig;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    yogaConfig = ABI45_0_0YGConfigNew();
    ABI45_0_0YGConfigSetPointScaleFactor(yogaConfig, ABI45_0_0RCTScreenScale());
    ABI45_0_0YGConfigSetUseLegacyStretchBehaviour(yogaConfig, true);
  });
  return yogaConfig;
}

@synthesize ABI45_0_0ReactTag = _ABI45_0_0ReactTag;
@synthesize rootTag = _rootTag;

// YogaNode API

static void ABI45_0_0RCTPrint(ABI45_0_0YGNodeRef node)
{
  ABI45_0_0RCTShadowView *shadowView = (__bridge ABI45_0_0RCTShadowView *)ABI45_0_0YGNodeGetContext(node);
  printf("%s(%lld), ", shadowView.viewName.UTF8String, (long long)shadowView.ABI45_0_0ReactTag.integerValue);
}

#define ABI45_0_0RCT_SET_ABI45_0_0YGVALUE(ygvalue, setter, ...)      \
  switch (ygvalue.unit) {                          \
    case ABI45_0_0YGUnitAuto:                               \
    case ABI45_0_0YGUnitUndefined:                          \
      setter(__VA_ARGS__, ABI45_0_0YGUndefined);            \
      break;                                       \
    case ABI45_0_0YGUnitPoint:                              \
      setter(__VA_ARGS__, ygvalue.value);          \
      break;                                       \
    case ABI45_0_0YGUnitPercent:                            \
      setter##Percent(__VA_ARGS__, ygvalue.value); \
      break;                                       \
  }

#define ABI45_0_0RCT_SET_ABI45_0_0YGVALUE_AUTO(ygvalue, setter, ...) \
  switch (ygvalue.unit) {                          \
    case ABI45_0_0YGUnitAuto:                               \
      setter##Auto(__VA_ARGS__);                   \
      break;                                       \
    case ABI45_0_0YGUnitUndefined:                          \
      setter(__VA_ARGS__, ABI45_0_0YGUndefined);            \
      break;                                       \
    case ABI45_0_0YGUnitPoint:                              \
      setter(__VA_ARGS__, ygvalue.value);          \
      break;                                       \
    case ABI45_0_0YGUnitPercent:                            \
      setter##Percent(__VA_ARGS__, ygvalue.value); \
      break;                                       \
  }

static void ABI45_0_0RCTProcessMetaPropsPadding(const ABI45_0_0YGValue metaProps[META_PROP_COUNT], ABI45_0_0YGNodeRef node)
{
  if (![[ABI45_0_0RCTI18nUtil sharedInstance] doLeftAndRightSwapInRTL]) {
    ABI45_0_0RCT_SET_ABI45_0_0YGVALUE(metaProps[META_PROP_START], ABI45_0_0YGNodeStyleSetPadding, node, ABI45_0_0YGEdgeStart);
    ABI45_0_0RCT_SET_ABI45_0_0YGVALUE(metaProps[META_PROP_END], ABI45_0_0YGNodeStyleSetPadding, node, ABI45_0_0YGEdgeEnd);
    ABI45_0_0RCT_SET_ABI45_0_0YGVALUE(metaProps[META_PROP_LEFT], ABI45_0_0YGNodeStyleSetPadding, node, ABI45_0_0YGEdgeLeft);
    ABI45_0_0RCT_SET_ABI45_0_0YGVALUE(metaProps[META_PROP_RIGHT], ABI45_0_0YGNodeStyleSetPadding, node, ABI45_0_0YGEdgeRight);
  } else {
    ABI45_0_0YGValue start =
        metaProps[META_PROP_START].unit == ABI45_0_0YGUnitUndefined ? metaProps[META_PROP_LEFT] : metaProps[META_PROP_START];
    ABI45_0_0YGValue end =
        metaProps[META_PROP_END].unit == ABI45_0_0YGUnitUndefined ? metaProps[META_PROP_RIGHT] : metaProps[META_PROP_END];
    ABI45_0_0RCT_SET_ABI45_0_0YGVALUE(start, ABI45_0_0YGNodeStyleSetPadding, node, ABI45_0_0YGEdgeStart);
    ABI45_0_0RCT_SET_ABI45_0_0YGVALUE(end, ABI45_0_0YGNodeStyleSetPadding, node, ABI45_0_0YGEdgeEnd);
  }
  ABI45_0_0RCT_SET_ABI45_0_0YGVALUE(metaProps[META_PROP_TOP], ABI45_0_0YGNodeStyleSetPadding, node, ABI45_0_0YGEdgeTop);
  ABI45_0_0RCT_SET_ABI45_0_0YGVALUE(metaProps[META_PROP_BOTTOM], ABI45_0_0YGNodeStyleSetPadding, node, ABI45_0_0YGEdgeBottom);
  ABI45_0_0RCT_SET_ABI45_0_0YGVALUE(metaProps[META_PROP_HORIZONTAL], ABI45_0_0YGNodeStyleSetPadding, node, ABI45_0_0YGEdgeHorizontal);
  ABI45_0_0RCT_SET_ABI45_0_0YGVALUE(metaProps[META_PROP_VERTICAL], ABI45_0_0YGNodeStyleSetPadding, node, ABI45_0_0YGEdgeVertical);
  ABI45_0_0RCT_SET_ABI45_0_0YGVALUE(metaProps[META_PROP_ALL], ABI45_0_0YGNodeStyleSetPadding, node, ABI45_0_0YGEdgeAll);
}

static void ABI45_0_0RCTProcessMetaPropsMargin(const ABI45_0_0YGValue metaProps[META_PROP_COUNT], ABI45_0_0YGNodeRef node)
{
  if (![[ABI45_0_0RCTI18nUtil sharedInstance] doLeftAndRightSwapInRTL]) {
    ABI45_0_0RCT_SET_ABI45_0_0YGVALUE_AUTO(metaProps[META_PROP_START], ABI45_0_0YGNodeStyleSetMargin, node, ABI45_0_0YGEdgeStart);
    ABI45_0_0RCT_SET_ABI45_0_0YGVALUE_AUTO(metaProps[META_PROP_END], ABI45_0_0YGNodeStyleSetMargin, node, ABI45_0_0YGEdgeEnd);
    ABI45_0_0RCT_SET_ABI45_0_0YGVALUE_AUTO(metaProps[META_PROP_LEFT], ABI45_0_0YGNodeStyleSetMargin, node, ABI45_0_0YGEdgeLeft);
    ABI45_0_0RCT_SET_ABI45_0_0YGVALUE_AUTO(metaProps[META_PROP_RIGHT], ABI45_0_0YGNodeStyleSetMargin, node, ABI45_0_0YGEdgeRight);
  } else {
    ABI45_0_0YGValue start =
        metaProps[META_PROP_START].unit == ABI45_0_0YGUnitUndefined ? metaProps[META_PROP_LEFT] : metaProps[META_PROP_START];
    ABI45_0_0YGValue end =
        metaProps[META_PROP_END].unit == ABI45_0_0YGUnitUndefined ? metaProps[META_PROP_RIGHT] : metaProps[META_PROP_END];
    ABI45_0_0RCT_SET_ABI45_0_0YGVALUE_AUTO(start, ABI45_0_0YGNodeStyleSetMargin, node, ABI45_0_0YGEdgeStart);
    ABI45_0_0RCT_SET_ABI45_0_0YGVALUE_AUTO(end, ABI45_0_0YGNodeStyleSetMargin, node, ABI45_0_0YGEdgeEnd);
  }
  ABI45_0_0RCT_SET_ABI45_0_0YGVALUE_AUTO(metaProps[META_PROP_TOP], ABI45_0_0YGNodeStyleSetMargin, node, ABI45_0_0YGEdgeTop);
  ABI45_0_0RCT_SET_ABI45_0_0YGVALUE_AUTO(metaProps[META_PROP_BOTTOM], ABI45_0_0YGNodeStyleSetMargin, node, ABI45_0_0YGEdgeBottom);
  ABI45_0_0RCT_SET_ABI45_0_0YGVALUE_AUTO(metaProps[META_PROP_HORIZONTAL], ABI45_0_0YGNodeStyleSetMargin, node, ABI45_0_0YGEdgeHorizontal);
  ABI45_0_0RCT_SET_ABI45_0_0YGVALUE_AUTO(metaProps[META_PROP_VERTICAL], ABI45_0_0YGNodeStyleSetMargin, node, ABI45_0_0YGEdgeVertical);
  ABI45_0_0RCT_SET_ABI45_0_0YGVALUE_AUTO(metaProps[META_PROP_ALL], ABI45_0_0YGNodeStyleSetMargin, node, ABI45_0_0YGEdgeAll);
}

static void ABI45_0_0RCTProcessMetaPropsBorder(const ABI45_0_0YGValue metaProps[META_PROP_COUNT], ABI45_0_0YGNodeRef node)
{
  if (![[ABI45_0_0RCTI18nUtil sharedInstance] doLeftAndRightSwapInRTL]) {
    ABI45_0_0YGNodeStyleSetBorder(node, ABI45_0_0YGEdgeStart, metaProps[META_PROP_START].value);
    ABI45_0_0YGNodeStyleSetBorder(node, ABI45_0_0YGEdgeEnd, metaProps[META_PROP_END].value);
    ABI45_0_0YGNodeStyleSetBorder(node, ABI45_0_0YGEdgeLeft, metaProps[META_PROP_LEFT].value);
    ABI45_0_0YGNodeStyleSetBorder(node, ABI45_0_0YGEdgeRight, metaProps[META_PROP_RIGHT].value);
  } else {
    const float start = ABI45_0_0YGFloatIsUndefined(metaProps[META_PROP_START].value) ? metaProps[META_PROP_LEFT].value
                                                                             : metaProps[META_PROP_START].value;
    const float end = ABI45_0_0YGFloatIsUndefined(metaProps[META_PROP_END].value) ? metaProps[META_PROP_RIGHT].value
                                                                         : metaProps[META_PROP_END].value;
    ABI45_0_0YGNodeStyleSetBorder(node, ABI45_0_0YGEdgeStart, start);
    ABI45_0_0YGNodeStyleSetBorder(node, ABI45_0_0YGEdgeEnd, end);
  }
  ABI45_0_0YGNodeStyleSetBorder(node, ABI45_0_0YGEdgeTop, metaProps[META_PROP_TOP].value);
  ABI45_0_0YGNodeStyleSetBorder(node, ABI45_0_0YGEdgeBottom, metaProps[META_PROP_BOTTOM].value);
  ABI45_0_0YGNodeStyleSetBorder(node, ABI45_0_0YGEdgeHorizontal, metaProps[META_PROP_HORIZONTAL].value);
  ABI45_0_0YGNodeStyleSetBorder(node, ABI45_0_0YGEdgeVertical, metaProps[META_PROP_VERTICAL].value);
  ABI45_0_0YGNodeStyleSetBorder(node, ABI45_0_0YGEdgeAll, metaProps[META_PROP_ALL].value);
}

- (CGRect)measureLayoutRelativeToAncestor:(ABI45_0_0RCTShadowView *)ancestor
{
  CGPoint offset = CGPointZero;
  ABI45_0_0RCTShadowView *shadowView = self;
  while (shadowView && shadowView != ancestor) {
    offset.x += shadowView.layoutMetrics.frame.origin.x;
    offset.y += shadowView.layoutMetrics.frame.origin.y;
    shadowView = shadowView->_superview;
  }
  if (ancestor != shadowView) {
    return CGRectNull;
  }
  return (CGRect){offset, self.layoutMetrics.frame.size};
}

- (BOOL)viewIsDescendantOf:(ABI45_0_0RCTShadowView *)ancestor
{
  ABI45_0_0RCTShadowView *shadowView = self;
  while (shadowView && shadowView != ancestor) {
    shadowView = shadowView->_superview;
  }
  return ancestor == shadowView;
}

- (instancetype)init
{
  if (self = [super init]) {
    for (unsigned int ii = 0; ii < META_PROP_COUNT; ii++) {
      _paddingMetaProps[ii] = ABI45_0_0YGValueUndefined;
      _marginMetaProps[ii] = ABI45_0_0YGValueUndefined;
      _borderMetaProps[ii] = ABI45_0_0YGValueUndefined;
    }

    _intrinsicContentSize = CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);

    _newView = YES;

    _ABI45_0_0ReactSubviews = [NSMutableArray array];

    _yogaNode = ABI45_0_0YGNodeNewWithConfig([[self class] yogaConfig]);
    ABI45_0_0YGNodeSetContext(_yogaNode, (__bridge void *)self);
    ABI45_0_0YGNodeSetPrintFunc(_yogaNode, ABI45_0_0RCTPrint);
  }
  return self;
}

- (BOOL)isABI45_0_0ReactRootView
{
  return ABI45_0_0RCTIsABI45_0_0ReactRootView(self.ABI45_0_0ReactTag);
}

- (void)dealloc
{
  ABI45_0_0YGNodeFree(_yogaNode);
}

- (BOOL)canHaveSubviews
{
  return YES;
}

- (BOOL)isYogaLeafNode
{
  return NO;
}

- (void)insertABI45_0_0ReactSubview:(ABI45_0_0RCTShadowView *)subview atIndex:(NSInteger)atIndex
{
  ABI45_0_0RCTAssert(self.canHaveSubviews, @"Attempt to insert subview inside leaf view.");

  [_ABI45_0_0ReactSubviews insertObject:subview atIndex:atIndex];
  if (![self isYogaLeafNode]) {
    ABI45_0_0YGNodeInsertChild(_yogaNode, subview.yogaNode, (uint32_t)atIndex);
  }
  subview->_superview = self;
}

- (void)removeABI45_0_0ReactSubview:(ABI45_0_0RCTShadowView *)subview
{
  subview->_superview = nil;
  [_ABI45_0_0ReactSubviews removeObject:subview];
  if (![self isYogaLeafNode]) {
    ABI45_0_0YGNodeRemoveChild(_yogaNode, subview.yogaNode);
  }
}

- (NSArray<ABI45_0_0RCTShadowView *> *)ABI45_0_0ReactSubviews
{
  return _ABI45_0_0ReactSubviews;
}

- (ABI45_0_0RCTShadowView *)ABI45_0_0ReactSuperview
{
  return _superview;
}

#pragma mark - Layout

- (void)layoutWithMinimumSize:(CGSize)minimumSize
                  maximumSize:(CGSize)maximumSize
              layoutDirection:(UIUserInterfaceLayoutDirection)layoutDirection
                layoutContext:(ABI45_0_0RCTLayoutContext)layoutContext
{
  ABI45_0_0YGNodeRef yogaNode = _yogaNode;

  CGSize oldMinimumSize = (CGSize){
      ABI45_0_0RCTCoreGraphicsFloatFromYogaValue(ABI45_0_0YGNodeStyleGetMinWidth(yogaNode), 0.0),
      ABI45_0_0RCTCoreGraphicsFloatFromYogaValue(ABI45_0_0YGNodeStyleGetMinHeight(yogaNode), 0.0)};

  if (!CGSizeEqualToSize(oldMinimumSize, minimumSize)) {
    ABI45_0_0YGNodeStyleSetMinWidth(yogaNode, ABI45_0_0RCTYogaFloatFromCoreGraphicsFloat(minimumSize.width));
    ABI45_0_0YGNodeStyleSetMinHeight(yogaNode, ABI45_0_0RCTYogaFloatFromCoreGraphicsFloat(minimumSize.height));
  }

  ABI45_0_0YGNodeCalculateLayout(
      yogaNode,
      ABI45_0_0RCTYogaFloatFromCoreGraphicsFloat(maximumSize.width),
      ABI45_0_0RCTYogaFloatFromCoreGraphicsFloat(maximumSize.height),
      ABI45_0_0RCTYogaLayoutDirectionFromUIKitLayoutDirection(layoutDirection));

  ABI45_0_0RCTAssert(!ABI45_0_0YGNodeIsDirty(yogaNode), @"Attempt to get layout metrics from dirtied Yoga node.");

  if (!ABI45_0_0YGNodeGetHasNewLayout(yogaNode)) {
    return;
  }

  ABI45_0_0YGNodeSetHasNewLayout(yogaNode, false);

  ABI45_0_0RCTLayoutMetrics layoutMetrics = ABI45_0_0RCTLayoutMetricsFromYogaNode(yogaNode);

  layoutContext.absolutePosition.x += layoutMetrics.frame.origin.x;
  layoutContext.absolutePosition.y += layoutMetrics.frame.origin.y;

  [self layoutWithMetrics:layoutMetrics layoutContext:layoutContext];

  [self layoutSubviewsWithContext:layoutContext];
}

- (void)layoutWithMetrics:(ABI45_0_0RCTLayoutMetrics)layoutMetrics layoutContext:(ABI45_0_0RCTLayoutContext)layoutContext
{
  if (!ABI45_0_0RCTLayoutMetricsEqualToLayoutMetrics(self.layoutMetrics, layoutMetrics)) {
    self.layoutMetrics = layoutMetrics;
    [layoutContext.affectedShadowViews addObject:self];
  }
}

- (void)layoutSubviewsWithContext:(ABI45_0_0RCTLayoutContext)layoutContext
{
  ABI45_0_0RCTLayoutMetrics layoutMetrics = self.layoutMetrics;

  if (layoutMetrics.displayType == ABI45_0_0RCTDisplayTypeNone) {
    return;
  }

  for (ABI45_0_0RCTShadowView *childShadowView in _ABI45_0_0ReactSubviews) {
    ABI45_0_0YGNodeRef childYogaNode = childShadowView.yogaNode;

    ABI45_0_0RCTAssert(!ABI45_0_0YGNodeIsDirty(childYogaNode), @"Attempt to get layout metrics from dirtied Yoga node.");

    if (!ABI45_0_0YGNodeGetHasNewLayout(childYogaNode)) {
      continue;
    }

    ABI45_0_0YGNodeSetHasNewLayout(childYogaNode, false);

    ABI45_0_0RCTLayoutMetrics childLayoutMetrics = ABI45_0_0RCTLayoutMetricsFromYogaNode(childYogaNode);

    layoutContext.absolutePosition.x += childLayoutMetrics.frame.origin.x;
    layoutContext.absolutePosition.y += childLayoutMetrics.frame.origin.y;

    [childShadowView layoutWithMetrics:childLayoutMetrics layoutContext:layoutContext];

    // Recursive call.
    [childShadowView layoutSubviewsWithContext:layoutContext];
  }
}

- (CGSize)sizeThatFitsMinimumSize:(CGSize)minimumSize maximumSize:(CGSize)maximumSize
{
  ABI45_0_0YGNodeRef clonedYogaNode = ABI45_0_0YGNodeClone(self.yogaNode);
  ABI45_0_0YGNodeRef constraintYogaNode = ABI45_0_0YGNodeNewWithConfig([[self class] yogaConfig]);

  ABI45_0_0YGNodeInsertChild(constraintYogaNode, clonedYogaNode, 0);

  ABI45_0_0YGNodeStyleSetMinWidth(constraintYogaNode, ABI45_0_0RCTYogaFloatFromCoreGraphicsFloat(minimumSize.width));
  ABI45_0_0YGNodeStyleSetMinHeight(constraintYogaNode, ABI45_0_0RCTYogaFloatFromCoreGraphicsFloat(minimumSize.height));
  ABI45_0_0YGNodeStyleSetMaxWidth(constraintYogaNode, ABI45_0_0RCTYogaFloatFromCoreGraphicsFloat(maximumSize.width));
  ABI45_0_0YGNodeStyleSetMaxHeight(constraintYogaNode, ABI45_0_0RCTYogaFloatFromCoreGraphicsFloat(maximumSize.height));

  ABI45_0_0YGNodeCalculateLayout(
      constraintYogaNode,
      ABI45_0_0YGUndefined,
      ABI45_0_0YGUndefined,
      ABI45_0_0RCTYogaLayoutDirectionFromUIKitLayoutDirection(self.layoutMetrics.layoutDirection));

  CGSize measuredSize = (CGSize){
      ABI45_0_0RCTCoreGraphicsFloatFromYogaFloat(ABI45_0_0YGNodeLayoutGetWidth(constraintYogaNode)),
      ABI45_0_0RCTCoreGraphicsFloatFromYogaFloat(ABI45_0_0YGNodeLayoutGetHeight(constraintYogaNode)),
  };

  ABI45_0_0YGNodeRemoveChild(constraintYogaNode, clonedYogaNode);
  ABI45_0_0YGNodeFree(constraintYogaNode);
  ABI45_0_0YGNodeFree(clonedYogaNode);

  return measuredSize;
}

- (NSNumber *)ABI45_0_0ReactTagAtPoint:(CGPoint)point
{
  for (ABI45_0_0RCTShadowView *shadowView in _ABI45_0_0ReactSubviews) {
    if (CGRectContainsPoint(shadowView.layoutMetrics.frame, point)) {
      CGPoint relativePoint = point;
      CGPoint origin = shadowView.layoutMetrics.frame.origin;
      relativePoint.x -= origin.x;
      relativePoint.y -= origin.y;
      return [shadowView ABI45_0_0ReactTagAtPoint:relativePoint];
    }
  }
  return self.ABI45_0_0ReactTag;
}

- (NSString *)description
{
  NSString *description = super.description;
  description = [[description substringToIndex:description.length - 1]
      stringByAppendingFormat:@"; viewName: %@; ABI45_0_0ReactTag: %@; frame: %@>",
                              self.viewName,
                              self.ABI45_0_0ReactTag,
                              NSStringFromCGRect(self.layoutMetrics.frame)];
  return description;
}

- (void)addRecursiveDescriptionToString:(NSMutableString *)string atLevel:(NSUInteger)level
{
  for (NSUInteger i = 0; i < level; i++) {
    [string appendString:@"  | "];
  }

  [string appendString:self.description];
  [string appendString:@"\n"];

  for (ABI45_0_0RCTShadowView *subview in _ABI45_0_0ReactSubviews) {
    [subview addRecursiveDescriptionToString:string atLevel:level + 1];
  }
}

- (NSString *)recursiveDescription
{
  NSMutableString *description = [NSMutableString string];
  [self addRecursiveDescriptionToString:description atLevel:0];
  return description;
}

// Margin

#define ABI45_0_0RCT_MARGIN_PROPERTY(prop, metaProp)         \
  -(void)setMargin##prop : (ABI45_0_0YGValue)value           \
  {                                                 \
    _marginMetaProps[META_PROP_##metaProp] = value; \
    _recomputeMargin = YES;                         \
  }                                                 \
  -(ABI45_0_0YGValue)margin##prop                            \
  {                                                 \
    return _marginMetaProps[META_PROP_##metaProp];  \
  }

ABI45_0_0RCT_MARGIN_PROPERTY(, ALL)
ABI45_0_0RCT_MARGIN_PROPERTY(Vertical, VERTICAL)
ABI45_0_0RCT_MARGIN_PROPERTY(Horizontal, HORIZONTAL)
ABI45_0_0RCT_MARGIN_PROPERTY(Top, TOP)
ABI45_0_0RCT_MARGIN_PROPERTY(Left, LEFT)
ABI45_0_0RCT_MARGIN_PROPERTY(Bottom, BOTTOM)
ABI45_0_0RCT_MARGIN_PROPERTY(Right, RIGHT)
ABI45_0_0RCT_MARGIN_PROPERTY(Start, START)
ABI45_0_0RCT_MARGIN_PROPERTY(End, END)

// Padding

#define ABI45_0_0RCT_PADDING_PROPERTY(prop, metaProp)         \
  -(void)setPadding##prop : (ABI45_0_0YGValue)value           \
  {                                                  \
    _paddingMetaProps[META_PROP_##metaProp] = value; \
    _recomputePadding = YES;                         \
  }                                                  \
  -(ABI45_0_0YGValue)padding##prop                            \
  {                                                  \
    return _paddingMetaProps[META_PROP_##metaProp];  \
  }

ABI45_0_0RCT_PADDING_PROPERTY(, ALL)
ABI45_0_0RCT_PADDING_PROPERTY(Vertical, VERTICAL)
ABI45_0_0RCT_PADDING_PROPERTY(Horizontal, HORIZONTAL)
ABI45_0_0RCT_PADDING_PROPERTY(Top, TOP)
ABI45_0_0RCT_PADDING_PROPERTY(Left, LEFT)
ABI45_0_0RCT_PADDING_PROPERTY(Bottom, BOTTOM)
ABI45_0_0RCT_PADDING_PROPERTY(Right, RIGHT)
ABI45_0_0RCT_PADDING_PROPERTY(Start, START)
ABI45_0_0RCT_PADDING_PROPERTY(End, END)

// Border

#define ABI45_0_0RCT_BORDER_PROPERTY(prop, metaProp)               \
  -(void)setBorder##prop##Width : (float)value            \
  {                                                       \
    _borderMetaProps[META_PROP_##metaProp].value = value; \
    _recomputeBorder = YES;                               \
  }                                                       \
  -(float)border##prop##Width                             \
  {                                                       \
    return _borderMetaProps[META_PROP_##metaProp].value;  \
  }

ABI45_0_0RCT_BORDER_PROPERTY(, ALL)
ABI45_0_0RCT_BORDER_PROPERTY(Top, TOP)
ABI45_0_0RCT_BORDER_PROPERTY(Left, LEFT)
ABI45_0_0RCT_BORDER_PROPERTY(Bottom, BOTTOM)
ABI45_0_0RCT_BORDER_PROPERTY(Right, RIGHT)
ABI45_0_0RCT_BORDER_PROPERTY(Start, START)
ABI45_0_0RCT_BORDER_PROPERTY(End, END)

// Dimensions
#define ABI45_0_0RCT_DIMENSION_PROPERTY(setProp, getProp, cssProp)            \
  -(void)set##setProp : (ABI45_0_0YGValue)value                               \
  {                                                                  \
    ABI45_0_0RCT_SET_ABI45_0_0YGVALUE_AUTO(value, ABI45_0_0YGNodeStyleSet##cssProp, _yogaNode); \
  }                                                                  \
  -(ABI45_0_0YGValue)getProp                                                  \
  {                                                                  \
    return ABI45_0_0YGNodeStyleGet##cssProp(_yogaNode);                       \
  }

#define ABI45_0_0RCT_MIN_MAX_DIMENSION_PROPERTY(setProp, getProp, cssProp) \
  -(void)set##setProp : (ABI45_0_0YGValue)value                            \
  {                                                               \
    ABI45_0_0RCT_SET_ABI45_0_0YGVALUE(value, ABI45_0_0YGNodeStyleSet##cssProp, _yogaNode);   \
  }                                                               \
  -(ABI45_0_0YGValue)getProp                                               \
  {                                                               \
    return ABI45_0_0YGNodeStyleGet##cssProp(_yogaNode);                    \
  }

ABI45_0_0RCT_DIMENSION_PROPERTY(Width, width, Width)
ABI45_0_0RCT_DIMENSION_PROPERTY(Height, height, Height)
ABI45_0_0RCT_MIN_MAX_DIMENSION_PROPERTY(MinWidth, minWidth, MinWidth)
ABI45_0_0RCT_MIN_MAX_DIMENSION_PROPERTY(MinHeight, minHeight, MinHeight)
ABI45_0_0RCT_MIN_MAX_DIMENSION_PROPERTY(MaxWidth, maxWidth, MaxWidth)
ABI45_0_0RCT_MIN_MAX_DIMENSION_PROPERTY(MaxHeight, maxHeight, MaxHeight)

// Position

#define ABI45_0_0RCT_POSITION_PROPERTY(setProp, getProp, edge)                \
  -(void)set##setProp : (ABI45_0_0YGValue)value                               \
  {                                                                  \
    ABI45_0_0RCT_SET_ABI45_0_0YGVALUE(value, ABI45_0_0YGNodeStyleSetPosition, _yogaNode, edge); \
  }                                                                  \
  -(ABI45_0_0YGValue)getProp                                                  \
  {                                                                  \
    return ABI45_0_0YGNodeStyleGetPosition(_yogaNode, edge);                  \
  }

ABI45_0_0RCT_POSITION_PROPERTY(Top, top, ABI45_0_0YGEdgeTop)
ABI45_0_0RCT_POSITION_PROPERTY(Bottom, bottom, ABI45_0_0YGEdgeBottom)
ABI45_0_0RCT_POSITION_PROPERTY(Start, start, ABI45_0_0YGEdgeStart)
ABI45_0_0RCT_POSITION_PROPERTY(End, end, ABI45_0_0YGEdgeEnd)

- (void)setLeft:(ABI45_0_0YGValue)value
{
  ABI45_0_0YGEdge edge = [[ABI45_0_0RCTI18nUtil sharedInstance] doLeftAndRightSwapInRTL] ? ABI45_0_0YGEdgeStart : ABI45_0_0YGEdgeLeft;
  ABI45_0_0RCT_SET_ABI45_0_0YGVALUE(value, ABI45_0_0YGNodeStyleSetPosition, _yogaNode, edge);
}
- (ABI45_0_0YGValue)left
{
  ABI45_0_0YGEdge edge = [[ABI45_0_0RCTI18nUtil sharedInstance] doLeftAndRightSwapInRTL] ? ABI45_0_0YGEdgeStart : ABI45_0_0YGEdgeLeft;
  return ABI45_0_0YGNodeStyleGetPosition(_yogaNode, edge);
}

- (void)setRight:(ABI45_0_0YGValue)value
{
  ABI45_0_0YGEdge edge = [[ABI45_0_0RCTI18nUtil sharedInstance] doLeftAndRightSwapInRTL] ? ABI45_0_0YGEdgeEnd : ABI45_0_0YGEdgeRight;
  ABI45_0_0RCT_SET_ABI45_0_0YGVALUE(value, ABI45_0_0YGNodeStyleSetPosition, _yogaNode, edge);
}
- (ABI45_0_0YGValue)right
{
  ABI45_0_0YGEdge edge = [[ABI45_0_0RCTI18nUtil sharedInstance] doLeftAndRightSwapInRTL] ? ABI45_0_0YGEdgeEnd : ABI45_0_0YGEdgeRight;
  return ABI45_0_0YGNodeStyleGetPosition(_yogaNode, edge);
}

// Size

- (CGSize)size
{
  ABI45_0_0YGValue width = ABI45_0_0YGNodeStyleGetWidth(_yogaNode);
  ABI45_0_0YGValue height = ABI45_0_0YGNodeStyleGetHeight(_yogaNode);

  return CGSizeMake(width.unit == ABI45_0_0YGUnitPoint ? width.value : NAN, height.unit == ABI45_0_0YGUnitPoint ? height.value : NAN);
}

- (void)setSize:(CGSize)size
{
  ABI45_0_0YGNodeStyleSetWidth(_yogaNode, size.width);
  ABI45_0_0YGNodeStyleSetHeight(_yogaNode, size.height);
}

// IntrinsicContentSize

static inline ABI45_0_0YGSize
ABI45_0_0RCTShadowViewMeasure(ABI45_0_0YGNodeRef node, float width, ABI45_0_0YGMeasureMode widthMode, float height, ABI45_0_0YGMeasureMode heightMode)
{
  ABI45_0_0RCTShadowView *shadowView = (__bridge ABI45_0_0RCTShadowView *)ABI45_0_0YGNodeGetContext(node);

  CGSize intrinsicContentSize = shadowView->_intrinsicContentSize;
  // Replace `UIViewNoIntrinsicMetric` (which equals `-1`) with zero.
  intrinsicContentSize.width = MAX(0, intrinsicContentSize.width);
  intrinsicContentSize.height = MAX(0, intrinsicContentSize.height);

  ABI45_0_0YGSize result;

  switch (widthMode) {
    case ABI45_0_0YGMeasureModeUndefined:
      result.width = intrinsicContentSize.width;
      break;
    case ABI45_0_0YGMeasureModeExactly:
      result.width = width;
      break;
    case ABI45_0_0YGMeasureModeAtMost:
      result.width = MIN(width, intrinsicContentSize.width);
      break;
  }

  switch (heightMode) {
    case ABI45_0_0YGMeasureModeUndefined:
      result.height = intrinsicContentSize.height;
      break;
    case ABI45_0_0YGMeasureModeExactly:
      result.height = height;
      break;
    case ABI45_0_0YGMeasureModeAtMost:
      result.height = MIN(height, intrinsicContentSize.height);
      break;
  }

  return result;
}

- (void)setIntrinsicContentSize:(CGSize)intrinsicContentSize
{
  if (CGSizeEqualToSize(_intrinsicContentSize, intrinsicContentSize)) {
    return;
  }

  _intrinsicContentSize = intrinsicContentSize;

  if (CGSizeEqualToSize(_intrinsicContentSize, CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric))) {
    ABI45_0_0YGNodeSetMeasureFunc(_yogaNode, NULL);
  } else {
    ABI45_0_0YGNodeSetMeasureFunc(_yogaNode, ABI45_0_0RCTShadowViewMeasure);
  }

  ABI45_0_0YGNodeMarkDirty(_yogaNode);
}

// Local Data

- (void)setLocalData:(__unused NSObject *)localData
{
  // Do nothing by default.
}

// Flex

- (void)setFlexBasis:(ABI45_0_0YGValue)value
{
  ABI45_0_0RCT_SET_ABI45_0_0YGVALUE_AUTO(value, ABI45_0_0YGNodeStyleSetFlexBasis, _yogaNode);
}

- (ABI45_0_0YGValue)flexBasis
{
  return ABI45_0_0YGNodeStyleGetFlexBasis(_yogaNode);
}

#define ABI45_0_0RCT_STYLE_PROPERTY(setProp, getProp, cssProp, type) \
  -(void)set##setProp : (type)value                         \
  {                                                         \
    ABI45_0_0YGNodeStyleSet##cssProp(_yogaNode, value);              \
  }                                                         \
  -(type)getProp                                            \
  {                                                         \
    return ABI45_0_0YGNodeStyleGet##cssProp(_yogaNode);              \
  }

ABI45_0_0RCT_STYLE_PROPERTY(Flex, flex, Flex, float)
ABI45_0_0RCT_STYLE_PROPERTY(FlexGrow, flexGrow, FlexGrow, float)
ABI45_0_0RCT_STYLE_PROPERTY(FlexShrink, flexShrink, FlexShrink, float)
ABI45_0_0RCT_STYLE_PROPERTY(FlexDirection, flexDirection, FlexDirection, ABI45_0_0YGFlexDirection)
ABI45_0_0RCT_STYLE_PROPERTY(JustifyContent, justifyContent, JustifyContent, ABI45_0_0YGJustify)
ABI45_0_0RCT_STYLE_PROPERTY(AlignSelf, alignSelf, AlignSelf, ABI45_0_0YGAlign)
ABI45_0_0RCT_STYLE_PROPERTY(AlignItems, alignItems, AlignItems, ABI45_0_0YGAlign)
ABI45_0_0RCT_STYLE_PROPERTY(AlignContent, alignContent, AlignContent, ABI45_0_0YGAlign)
ABI45_0_0RCT_STYLE_PROPERTY(Position, position, PositionType, ABI45_0_0YGPositionType)
ABI45_0_0RCT_STYLE_PROPERTY(FlexWrap, flexWrap, FlexWrap, ABI45_0_0YGWrap)
ABI45_0_0RCT_STYLE_PROPERTY(Overflow, overflow, Overflow, ABI45_0_0YGOverflow)
ABI45_0_0RCT_STYLE_PROPERTY(Display, display, Display, ABI45_0_0YGDisplay)
ABI45_0_0RCT_STYLE_PROPERTY(Direction, direction, Direction, ABI45_0_0YGDirection)
ABI45_0_0RCT_STYLE_PROPERTY(AspectRatio, aspectRatio, AspectRatio, float)

- (void)didUpdateABI45_0_0ReactSubviews
{
  // Does nothing by default
}

- (void)didSetProps:(__unused NSArray<NSString *> *)changedProps
{
  if (_recomputePadding) {
    ABI45_0_0RCTProcessMetaPropsPadding(_paddingMetaProps, _yogaNode);
  }
  if (_recomputeMargin) {
    ABI45_0_0RCTProcessMetaPropsMargin(_marginMetaProps, _yogaNode);
  }
  if (_recomputeBorder) {
    ABI45_0_0RCTProcessMetaPropsBorder(_borderMetaProps, _yogaNode);
  }
  _recomputeMargin = NO;
  _recomputePadding = NO;
  _recomputeBorder = NO;
}

@end
