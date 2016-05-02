/*
 * Author: Hossein Amin, aminbros.com
 */

#ifndef __Box2DConv_
#define __Box2DConv_

#define write_Bound_to_b2AABB(bound, aabb) {        \
        (aabb).lowerBound.x = (bound).lowerBound.x; \
        (aabb).lowerBound.y = (bound).lowerBound.y; \
        (aabb).upperBound.x = (bound).upperBound.x; \
        (aabb).upperBound.y = (bound).upperBound.y; \
    }

#define write_CGPoint_to_b2Vec2(point, vec) {   \
        (vec).x = (point).x;                    \
        (vec).y = (point).y;                    \
    }
#define write_b2Vec_to_CGPoint(vec, point) {    \
        (point).x = (vec).x;                    \
        (point).y = (vec).y;                    \
    }


#endif
