//
//  ZAHeroAnimationFrames.m
//  8bit-zombie-arcade
//
//  Created by William Kamp on 10/16/13.
//  Copyright (c) 2013 Will Kamp. All rights reserved.
//

#import "ZACharachterAnimationFrames.h"
#import <SpriteKit/SpriteKit.h>

@interface ZACharachterAnimationFrames ()

@property (nonatomic) BOOL loaded;

@end

@implementation ZACharachterAnimationFrames

+(ZACharachterAnimationFrames *)sharedFrames
{
    static dispatch_once_t predicate;
    static ZACharachterAnimationFrames *shared = nil;
    dispatch_once(&predicate, ^{
        shared = [[ZACharachterAnimationFrames alloc] init];
        shared.loaded = false;
    });
    return shared;
}

-(void)loadAsyncWithCallback:(void(^)(void))completionBlock
{
    if (!self.loaded) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.loaded = YES;
            
            NSDictionary *atlasActions = @{@"woman"   : @{@"die": @6, @"stance": @4, @"walk": @8},
                                           @"zombie"  : @{@"die": @8, @"walk": @8, @"attack": @4},
                                           @"skeleton": @{@"die": @8, @"walk": @8, @"attack": @4},
                                           @"goblin"  : @{@"die": @8, @"walk": @8, @"attack": @4}};
            [self buildAnimationActionDbWithAtlasActions:atlasActions];
            
            NSArray *soundFiles = @[@"warcry.caf", @"female_die.caf", @"level_up.caf", @"shoot.caf", @"zombie_die.caf",
                                    @"zombie_critdie.caf", @"zombie_hit.caf", @"zombie_ment.caf", @"zombie_phys.caf",
                                    @"skeleton_critdie.caf", @"skeleton_die.caf", @"skeleton_hit.caf", @"skeleton_ment.caf",
                                    @"skeleton_phys.caf", @"goblin_critdie.caf", @"goblin_hit.caf", @"goblin_ment.caf",
                                    @"goblin_phys.caf"];
            [self buildSoundActionDbWithSoundFiles:soundFiles];
            
            //put the completion block back on the mainQueue so UI stuff can happen
            [[NSOperationQueue mainQueue] addOperationWithBlock:completionBlock];
        });
    }
}

#pragma mark - animations

-(void)buildAnimationActionDbWithAtlasActions:(NSDictionary*)atlasActions
{
    NSArray *subCardinals = @[@"east", @"north", @"northeast", @"northwest",
                              @"south", @"southeast", @"southwest", @"west"];
    
    NSMutableDictionary *db = [[NSMutableDictionary alloc] init];
    
    //build frame arrays for each and every atlas
    for (NSString* charachter in [atlasActions keyEnumerator]) {
        for (NSString *action in [[atlasActions objectForKey:charachter] keyEnumerator]) {
            for (NSString *subC in subCardinals) {
                NSString *sequence = [NSString stringWithFormat:@"%@_%@_%@", charachter, action, subC];
                //NSLog(@"%@_%@_%@", charachter, action, subC);
                NSNumber *numFrames = [[atlasActions objectForKey:charachter] objectForKey:action];
                NSArray *frames = [self loadFramesFromAtlas:sequence withNumberOfFrames:numFrames.integerValue];
                
                [db setObject:frames forKey:sequence];
            }
        }
    }
    
    _animationFrames = [NSDictionary dictionaryWithDictionary:db];
}

-(SKAction*)animationForSequence:(NSString*)sequence withTimePerFrame:(CGFloat)tpf
{
    NSArray *textures = [_animationFrames objectForKey:sequence];
    
    if (textures)
        return [SKAction animateWithTextures:textures timePerFrame:tpf resize:YES restore:NO];
    
    return nil;
}

-(NSArray*)loadFramesFromAtlas:(NSString*)atlasName withNumberOfFrames:(NSInteger)numFrames
{
    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:numFrames];
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:atlasName];
    //NSLog(@"atlas: %@", atlas);
    for (int i = 0; i < numFrames; i++) {
        NSString *textureName = [NSString stringWithFormat:@"%@_%d.png", atlasName, i];
        //NSLog(@"texture name: %@", textureName);
        SKTexture *texture = [atlas textureNamed:textureName];
        [frames addObject:texture];
    }
    
    return frames;
}

#pragma mark - sounds

-(void)buildSoundActionDbWithSoundFiles:(NSArray*)soundFiles
{
    NSMutableDictionary *tempSoundSKActions = [[NSMutableDictionary alloc] init];;
    for (NSString *soundFile in soundFiles) {
        //NSLog(@"%@", soundFile);
        [tempSoundSKActions setObject:[SKAction playSoundFileNamed:soundFile waitForCompletion:NO] forKey:soundFile];
    }
    _sounds = [NSDictionary dictionaryWithDictionary:tempSoundSKActions];
}

-(SKAction*)getSoundActionForFile:(NSString*)soundFile
{
    return [(SKAction*) [self.sounds objectForKey:soundFile] copy];
}

@end
