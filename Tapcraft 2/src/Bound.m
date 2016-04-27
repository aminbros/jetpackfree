/*
 * Author: Hossein Amin, aminbros.com
 */

#import "Bound.h"

Bound BoundFromRect(const CGRect *rect)
{
    Bound bound;
    bound.lowerBound = rect->origin;
    bound.upperBound.x = rect->origin.x + rect->size.width;
    bound.upperBound.y = rect->origin.y + rect->size.height;
	return bound;
}

Bound BoundMakeWS(CGFloat lx, CGFloat ly, CGFloat ux, CGFloat uy)
{
    Bound bound;
    bound.upperBound.x = ux;
    bound.upperBound.y = uy;
    bound.lowerBound.x = lx;
    bound.lowerBound.y = ly;
	return bound;	
}

Bound BoundMake(CGPoint lowerBound, CGPoint upperBound)
{
    Bound bound;
    bound.upperBound = upperBound;
    bound.lowerBound = lowerBound;
    return bound;
}

BOOL BoundsTestOverlap(Bound *a, Bound *b)
{
	CGPoint d1, d2;
	d1 = CGPointDifference(b->lowerBound, a->lowerBound);
	d2 = CGPointDifference(b->upperBound, a->upperBound);
    
	if (d1.x > 0.0 || d1.y > 0.0)
		return false;

	if (d2.x > 0.0 || d2.y > 0.0)
		return false;

	return true;
}

Bound BoundExtend(Bound *a, CGFloat extend)
{
    return BoundMake(CGPointMake(a->lowerBound.x - extend,
                                 a->lowerBound.y - extend),
                     CGPointMake(a->upperBound.x + extend,
                                 a->upperBound.y + extend));
                     
}
