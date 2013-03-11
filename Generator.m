//
//  Generator.m
//  DungeonGenerator
//
//  Created by Hill Devil on 3/10/13.
//  Copyright 2013 Hill Devil. All rights reserved.
//

#import "Generator.h"


@implementation Generator

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	Generator *layer = [Generator node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	if( (self=[super init]) )
    {
        mapWidth=32;
        mapHeight=20;
        hallwayBuffer=3;
        if (hallwayBuffer<0 || hallwayBuffer>10)
        {
            hallwayBuffer=0;
        }
        dungeonWidth=mapWidth+hallwayBuffer;
        dungeonHeight=mapHeight+hallwayBuffer;
        maximumRoomSize = ccp(5, 5);
        minimumRoomSize = ccp(3, 3);
        size = [[CCDirector sharedDirector]winSize];
        tileSize = size.width/mapWidth;
        
        CCMenuItemImage *generateButton = [CCMenuItemImage itemWithNormalImage:@"generate.png" selectedImage:@"generate.png" target:self selector:@selector(generateMap)];
		CCMenu *generateMenu = [CCMenu menuWithItems:generateButton, nil];
        generateMenu.position=ccp(size.width-generateButton.boundingBox.size.width/2, size.height-generateButton.boundingBox.size.height/2);
        [self addChild:generateMenu z:100];
        
        
        //adds frames to cache to illustrate created dungeons
        CCSpriteFrameCache *frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        [frameCache addSpriteFrame:[CCSpriteFrame frameWithTextureFilename:@"white.png" rect:CGRectMake(0, 0, tileSize, tileSize)] name:@"white.png"];
        [frameCache addSpriteFrame:[CCSpriteFrame frameWithTextureFilename:@"brown.png" rect:CGRectMake(0, 0, tileSize, tileSize)] name:@"brown.png"];
        
       
        //init map sprites
        for (int x=hallwayBuffer; x<dungeonWidth; x++)
        {
            for (int y=hallwayBuffer; y<dungeonHeight; y++)
            {
                mapTiles[x][y] = [CCSprite spriteWithSpriteFrameName:@"brown.png"];
                mapTiles[x][y].position=ccp((x-hallwayBuffer)*tileSize+tileSize/2, (y-hallwayBuffer)*tileSize+tileSize/2);
                [self addChild:mapTiles[x][y]];
                map[x][y]=0;
            }
        }
	}
	return self;
}

-(void) generateMap
{
    roomIndex=0;
    for (int x=0; x<100; x++)
    {
        for (int y=0; y<100; y++)
        {
            map[x][y]=0;
            [mapTiles[x][y]setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"brown.png"]];
        }
    }
    //generate map with border
    for (int x=hallwayBuffer+1; x<dungeonWidth-1; x++)
    {
        for (int y=hallwayBuffer+1; y<dungeonHeight-1; y++)
        {
            //should generate a room here?
            if (arc4random()%4==0)
            {
                // generate random rectangular room and check if it is in a valid location
                Boolean validRoom=YES;
                int roomX = arc4random()%(int)(maximumRoomSize.x-minimumRoomSize.x)+minimumRoomSize.x;
                int roomY = arc4random()%(int)(maximumRoomSize.y-minimumRoomSize.y)+minimumRoomSize.y;
                if (roomX+x>=dungeonWidth || roomY+y>=dungeonHeight)
                {
                    
                }
                else
                {
                    //check room border for clipping other rooms
                    
                    
                    
                    for (int xx=-hallwayBuffer; xx<roomX+hallwayBuffer; xx++)
                    {
                        for (int yy=-hallwayBuffer; yy<roomY+hallwayBuffer; yy++)
                        {
                            
                            
                            if (map[x+xx][y+yy]!=0 || roomIndex>19)
                            {
                                validRoom=NO;
                            }
                        }
                    }
                    
                    if (validRoom)
                    {
                        for (int xx=0; xx<roomX; xx++)
                        {
                            for (int yy=0; yy<roomY; yy++)
                            {
                                map[x+xx][y+yy]=1;
                                [mapTiles[x+xx][y+yy]setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"white.png"]];
                                
                                
                            }
                        }
                        rooms[roomIndex]=CGRectMake(x, y, roomX, roomY);
                        roomIndex++;
                        //NSLog(@"%i",roomIndex);
                        
                    }
                    
                }
            }
        }
    }
    for (int i = 0 ; i<100; i++)
    {
        keepRoom[i]=NO;
    }
    //iterate through rooms and connect those that are the closest and
    //under or to the left of the current room
    for (int i=1; i<roomIndex; i++)
    {
        int differenceUnder=0;
        int roomToPathToUnder=0;
        int differenceLeft=0;
        int roomToPathToLeft=0;
        //Boolean foundPath
        for (int n =0; n<roomIndex; n++)
        {
            if (rooms[i].origin.x>rooms[n].origin.x && fabsf(rooms[i].origin.y-rooms[n].origin.y)<rooms[i].size.height)
            {
                if (differenceLeft>0)
                {
                    if (differenceLeft>rooms[i].origin.x-rooms[n].origin.x+fabsf(rooms[i].origin.y-rooms[n].origin.y))
                    {
                        differenceLeft=rooms[i].origin.x-rooms[n].origin.x+fabsf(rooms[i].origin.y-rooms[n].origin.y);
                        roomToPathToLeft=n;
                    }
                }
                else
                {
                    differenceLeft=rooms[i].origin.x-rooms[n].origin.x+fabsf(rooms[i].origin.y-rooms[n].origin.y);
                    roomToPathToLeft=n;
                }
            }
            if (rooms[i].origin.y>rooms[n].origin.y)
            {
                if (differenceUnder>rooms[i].origin.y-rooms[n].origin.y)
                {
                    differenceUnder=rooms[i].origin.y-rooms[n].origin.y;
                    roomToPathToUnder=n;
                }
                else
                {
                    differenceUnder=rooms[i].origin.y-rooms[n].origin.y;
                    roomToPathToUnder=n;
                }
            }
        }
        if (differenceLeft!=0)
        {
            CGPoint pathOrigin=ccp(rooms[i].origin.x-1, rooms[i].origin.y+arc4random()%(int)rooms[i].size.height);
            CGPoint pathEnd=ccp(rooms[roomToPathToLeft].origin.x+rooms[roomToPathToLeft].size.width, rooms[roomToPathToLeft].origin.y+arc4random()%(int)rooms[roomToPathToLeft].size.height);
            CGPoint arrayOfPoints[100];
            int arrayIndex=0;
            if (pathOrigin.y<pathEnd.y)
            {
                for (int p=0; p<=pathEnd.y-pathOrigin.y; p++)
                {
                    arrayOfPoints[arrayIndex]=ccp(pathOrigin.x-1, pathOrigin.y+p);
                    arrayIndex++;
                }
            }
            else if (pathOrigin.y>pathEnd.y)
            {
                for (int p=0; p>=pathEnd.y-pathOrigin.y; p--)
                {
                    arrayOfPoints[arrayIndex]=ccp(pathOrigin.x-1, pathOrigin.y+p);
                    arrayIndex++;
                }
            }
            else if (pathEnd.y==pathOrigin.y)
            {
                arrayOfPoints[arrayIndex]=ccp(pathOrigin.x-1, pathOrigin.y);
                arrayIndex++;
            }
            if (arrayOfPoints[arrayIndex].x-1!=pathEnd.x)
            {
                int temp=0;
                if (arrayIndex>0)
                {
                    temp=arrayIndex-1;
                }
                if (arrayOfPoints[temp].x-pathEnd.x>0)
                {
                    for (int p=0; p<=arrayOfPoints[temp].x-pathEnd.x; p++)
                    {
                        arrayOfPoints[arrayIndex]=ccp(arrayOfPoints[arrayIndex-1].x-1, arrayOfPoints[arrayIndex-1].y);
                        arrayIndex++;
                    }
                    
                }
                
            }
                        
            
            
            [mapTiles[(int)pathOrigin.x][(int)pathOrigin.y]setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"white.png"]];
            [mapTiles[(int)pathEnd.x][(int)pathEnd.y]setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"white.png"]];
            for (int p=0; p<arrayIndex; p++)
            {
                [mapTiles[(int)arrayOfPoints[p].x][(int)arrayOfPoints[p].y]setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"white.png"]];
                map[(int)arrayOfPoints[p].x][(int)arrayOfPoints[p].y]=1;
            }
        }
        
        if (differenceUnder!=0)
        {
            CGPoint pathOrigin=ccp(rooms[i].origin.x+arc4random()%(int)rooms[i].size.width, rooms[i].origin.y-1);
            CGPoint pathEnd=ccp(rooms[roomToPathToUnder].origin.x+arc4random()%(int)rooms[roomToPathToUnder].size.width, rooms[roomToPathToUnder].origin.y+rooms[roomToPathToUnder].size.height);
            CGPoint arrayOfPoints[100];
            int arrayIndex=0;
            if (pathOrigin.x<pathEnd.x)
            {
                for (int p=0; p<=pathEnd.x-pathOrigin.x; p++)
                {
                    arrayOfPoints[arrayIndex]=ccp(pathOrigin.x+p, pathOrigin.y-1);
                    arrayIndex++;
                }
            }
            else if (pathOrigin.x>pathEnd.x)
            {
                for (int p=0; p>=pathEnd.x-pathOrigin.x; p--)
                {
                    arrayOfPoints[arrayIndex]=ccp(pathOrigin.x+p, pathOrigin.y-1);
                    arrayIndex++;
                }
            }
            else if (pathEnd.x==pathOrigin.x)
            {
                arrayOfPoints[arrayIndex]=ccp(pathOrigin.x, pathOrigin.y-1);
                arrayIndex++;
            }
            if (arrayOfPoints[arrayIndex].y-1!=pathEnd.y)
            {
                int temp=0;
                if (arrayIndex>0)
                {
                    temp=arrayIndex-1;
                }
                if (arrayOfPoints[temp].y-pathEnd.y>0)
                {
                    for (int p=0; p<=arrayOfPoints[temp].y-pathEnd.y; p++)
                    {
                        arrayOfPoints[arrayIndex]=ccp(arrayOfPoints[arrayIndex-1].x , arrayOfPoints[arrayIndex-1].y-1);
                        arrayIndex++;
                    }
                    
                }
                
            }
            
            
            
            [mapTiles[(int)pathOrigin.x][(int)pathOrigin.y]setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"white.png"]];
            [mapTiles[(int)pathEnd.x][(int)pathEnd.y]setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"white.png"]];
            for (int p=0; p<arrayIndex; p++)
            {
                [mapTiles[(int)arrayOfPoints[p].x][(int)arrayOfPoints[p].y]setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"white.png"]];
                map[(int)arrayOfPoints[p].x][(int)arrayOfPoints[p].y]=1;
            }
        }

    }
    //create pathways
    
}

@end
