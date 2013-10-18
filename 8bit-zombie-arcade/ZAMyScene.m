//
//  ZAMyScene.m
//  8bit-zombie-arcade
//
//  Created by William Kamp on 10/12/13.
//  Copyright (c) 2013 Will Kamp. All rights reserved.
//

#import "ZAMyScene.h"
#import "ZAZombieSpriteNode.h"
#import "ZAHeroSpriteNode.h"
#import "CGPointF.h"
#import "ZAHeroAnimationFrames.h"

@interface ZAMyScene ()

@property (nonatomic, strong) SKEmitterNode *bullet;

@end

@implementation ZAMyScene {
    
    
    
    NSTimeInterval lastUpdateTime;
    NSTimeInterval deltaTime;
    
    ZAHeroSpriteNode *heroSpriteNode;
    CGPoint firstTouchPoint;
    CGPoint velocity; //x = vector(direction) and y = length (speed in points per second)
    
//    SKEmitterNode *bullet;
}



-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.scaleMode = SKSceneScaleModeAspectFit;
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        
        myLabel.text = @"Zombie Arcade!";
        myLabel.fontSize = 30;
        myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame));
        [self addChild:myLabel];
        
        ZAHeroAnimationFrames *heroFrames = [ZAHeroAnimationFrames sharedFrames];
        [heroFrames buildFramesAsyncWithCallback:^{
            heroSpriteNode = [ZAHeroSpriteNode createHeroSprite];
            heroSpriteNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
            [self addChild:heroSpriteNode];
        }];
        
        _bullet = [self shootBullet];
        [self addChild:_bullet];

    }
    return self;
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    if (lastUpdateTime) {
        deltaTime = currentTime - lastUpdateTime;
    } else {
        deltaTime = 0;
    }
    
    lastUpdateTime = currentTime;
    //NSLog(@"%0.2f milliseconds since last update", deltaTime * 1000);
    
    //[self moveSprite:heroSpriteNode velocity:CGPointMake(HERO_MOVE_POINTS_PER_SEC, 0)];
    [self moveSprite:heroSpriteNode velocity:velocity];
    [self boundsCheckPlayer];
}

- (void)boundsCheckPlayer
{
    if (!heroSpriteNode)
        return;
    
    CGPoint newPosition = heroSpriteNode.position;
    CGPoint newVelocity = velocity;
    CGPoint bottomLeft = CGPointZero;
    CGPoint topRight = CGPointMake(self.size.width, self.size.height);
    if (newPosition.x <= bottomLeft.x) {
        newPosition.x = bottomLeft.x;
        newVelocity.x = -newVelocity.x;
    }
    if (newPosition.x >= topRight.x) {
        newPosition.x = topRight.x;
        newVelocity.x = -newVelocity.x;
    }
    if (newPosition.y <= bottomLeft.y) {
        newPosition.y = bottomLeft.y;
        newVelocity.y = -newVelocity.y;
    }
    if (newPosition.y >= topRight.y) {
        newPosition.y = topRight.y;
        newVelocity.y = -newVelocity.y;
    }
    heroSpriteNode.position = newPosition;
    if (!CGPointEqualToPoint(velocity, newVelocity)) {
        [heroSpriteNode  setAnimationSequenceByCardinal:[self getFortyFiveDegreeCardinalFromDegree:[self getVector:newVelocity]]];
    }
    velocity = newVelocity;
    
}

- (void)moveSprite:(SKSpriteNode *)sprite velocity:(CGPoint)vel
{
    CGPoint amountToMove = CGPointMultiplyScalar(vel, deltaTime);
    sprite.position = CGPointAdd(sprite.position, amountToMove);
   
}

- (void)moveSpriteToward:(CGPoint)location
{
    if (!heroSpriteNode)
        return;
    
    CGPoint offset = CGPointSubtract(location, heroSpriteNode.position);
    CGFloat length = CGPointLength(offset);
    CGPoint direction = CGPointMake(offset.x / length, offset.y / length);
    velocity = CGPointMultiplyScalar(direction, HERO_MOVE_POINTS_PER_SEC);
    [heroSpriteNode  setAnimationSequenceByCardinal:[self getFortyFiveDegreeCardinalFromDegree:[self getVector:velocity]]];
    NSLog(@"direction:%d", [self getVector:velocity]);
}

-(int)getVector:(CGPoint)point
{
    // Provides a directional bearing from (0,0) to the given point.
    // standard cartesian plain coords: X goes up, Y goes right
    // result returns degrees, -180 to 180 ish: 0 degrees = up, -90 = left, 90 = right
    CGFloat radians = atan2f(point.y, point.x);
    int degrees = radians * (180. / M_PI);
    
    if (degrees < 0)
        degrees = 360 + degrees;
    
    return degrees;
}

-(fourtyFiveDegreeCardinal)getFortyFiveDegreeCardinalFromDegree:(int)degree
{
    degree = degree % 360;
    
    if (degree >=0 && degree < 22) {
        return east;
    }
    if (degree >= 22 && degree < 67) {
        return northeast;
    }
    if (degree >= 67 && degree < 112) {
        return north;
    }
    if (degree >= 112 && degree < 157) {
        return northwest;
    }
    if (degree >= 157 && degree < 202) {
        return west;
    }
    if (degree >= 202 && degree < 247) {
        return southwest;
    }
    if (degree >= 247 && degree < 292) {
        return south;
    }
    if (degree >= 292 && degree < 337) {
        return southeast;
    }
    if (degree >= 337 && degree <= 360) {
        return east;
    }
    return north;
}

#pragma mark - touches

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    if (moveDegrees == -2 ) {
//        firstTouchPoint = [[touches anyObject] locationInView:self.view];
//        moveDegrees = -1;
//    }
    
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self.scene];
//    CGPoint endPoint = [touch locationInView:self.view];
//    CGPoint originPoint = CGPointMake(endPoint.x - heroSpriteNode.position.x, endPoint.y - heroSpriteNode.position.y);
//    [heroSpriteNode setAnimationSequenceByCardinal:[self getFortyFiveDegreeCardinalFromDegree:[self getVector:originPoint]]];
    
    [self moveSpriteToward:touchLocation];
    
//    _bullet.particleBirthRate = 5;
    _bullet.numParticlesToEmit = 5;
    _bullet.position = (heroSpriteNode.position);
    [_bullet runAction:[SKAction sequence:@[
//                                           [SKAction fadeInWithDuration:0.2],
                                           [SKAction moveTo:touchLocation duration:0.5],
//                                           [SKAction removeFromParent]
                                           ]]];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
//    if (moveDegrees >= -1) {
//        CGPoint endPoint = [[touches anyObject] locationInView:self.view];
//        CGPoint originPoint = CGPointMake(endPoint.x - firstTouchPoint.x, endPoint.y - firstTouchPoint.y);
//        NSLog(@"move degrees = %d", moveDegrees);
//        moveDegrees = [self getVector:originPoint];
//    }
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self.scene];
    [self moveSpriteToward:touchLocation];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//    moveDegrees = -2;
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self.scene];
    [self moveSpriteToward:touchLocation];
    
    
//    _bullet.particleBirthRate = 0;

}

- (SKEmitterNode *)shootBullet
{
    NSString *bulletPath = [[NSBundle mainBundle] pathForResource:@"bullet" ofType:@"sks"];
    _bullet = [NSKeyedUnarchiver unarchiveObjectWithFile:bulletPath];
    
    return _bullet;
}

@end
