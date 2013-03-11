//
//  Generator.h
//  DungeonGenerator
//
//  Created by Hill Devil on 3/10/13.
//  Copyright 2013 Hill Devil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Generator : CCLayer
{
    CCSprite *mapTiles[100][100];
    CGSize size;
    int map[100][100];
    int mapWidth,mapHeight,tileSize,roomIndex,hallwayBuffer,dungeonWidth,dungeonHeight;
    CGPoint maximumRoomSize,minimumRoomSize;
    CGRect rooms[100];
    Boolean keepRoom[100];
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
-(void)generateMap;


@end
