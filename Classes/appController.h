//
//  appController.h
//  spellingSwitcher
//
//  Created by Koenraad Van Nieuwenhove on 15/12/08.
//  Copyright 2008 CoCoa Crumbs. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface appController : NSObject 
{
    NSUInteger   languageIndex;
    
    NSMenuItem  *chosenLanguage1;
    NSMenuItem  *chosenLanguage2;
    
    NSMenu      *languagesMenu;
}

@property (nonatomic, assign) NSUInteger  languageIndex;

@property (nonatomic, retain) NSMenuItem *chosenLanguage1;
@property (nonatomic, retain) NSMenuItem *chosenLanguage2;

@property (nonatomic, retain) NSMenu     *languagesMenu;

@end /* interface appController */
