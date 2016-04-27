/*
 * Author: Hossein Amin, aminbros.com
 */

#import <Foundation/Foundation.h>

typedef struct Bound {
    CGPoint upperBound;
    CGPoint lowerBound;
} Bound;

#define CGPointDifference(a, b) ((CGPoint){(a).x - (b).x, (a).y - (b).y})
#define CGPointMul(a, s) ((CGPoint){(a).x * (s), (a).y * (s)))
#define CGSizeMul(a, s) ((CGSize){(a).width * (s), (a).height * (s)})

extern Bound BoundFromRect(const CGRect *rect);
extern Bound BoundMakeWS(CGFloat lx, CGFloat ly, CGFloat ux, CGFloat uy);
extern Bound BoundMake(CGPoint lowerBound, CGPoint upperBound);
extern BOOL BoundsTestOverlap(Bound *a, Bound *b);

// extend should be bigger than zero
extern Bound BoundExtend(Bound *a, CGFloat extend);
