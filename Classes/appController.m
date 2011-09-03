//
//  appController.m
//  spellingSwitcher
//
//  Created by Koenraad Van Nieuwenhove on 15/12/08.
//  Copyright 2008 CoCoa Crumbs. All rights reserved.
//
#import "appController.h"
#import "CCLog.h"

/*
    Based on an idea found at the following link:
        http://forums.macosxhints.com/showthread.php?t=26835
*/

/*
    Out of the ScriptableCocoaApplications.pdf document

    Steps for Turning On Cocoa Debugging Output 
    To turn on Cocoa’s debugging output for scripting, you do the following: 
         1. Open a Terminal window. Terminal is available in /Applications/Utilities. 
         2. Enter the following line and press Return to execute it: 
                 defaults write NSGlobalDomain NSScriptingDebugLogLevel 1 
            You can turn off debugging output with a line like this: 
                 defaults write NSGlobalDomain NSScriptingDebugLogLevel 0 
            You can display all the current values in the global domain with a line 
            like this: 
                 defaults read NSGlobalDomain 
         3. If your application is already running, quit the application. 
         4. If you launch your application from the Finder, look for debug information 
            in the Console application (available in /Applications/Utilities). If you 
            launch your application in Xcode, look for debug information in the Debug 
            Console pane or in the Run pane. 

    You will not see any debugging information until the application receives an Apple 
    event that causes it to execute a script command (and in turn, to load the 
    application’s scriptability information). You can view debugging information for 
    either a development or a deployment build of your application. 

    If you only want to turn on script debugging for a particular application, you can 
    use the application domain. The application domain is identified by the bundle 
    identifier of the application, typically a string in the form of a Java-style 
    package name (think of it as a reverse URL). For example, you could turn on script 
    debug logging for the Sketch sample application (available from Apple) by executing 
    the following line: 
         defaults write com.apple.CocoaExamples.Sketch NSScriptingDebugLogLevel 1 

    To read this value or to reset it to zero, use one of the following two lines: 
         defaults read com.apple.CocoaExamples.Sketch NSScriptingDebugLogLevel 
         defaults write com.apple.CocoaExamples.Sketch NSScriptingDebugLogLevel 0 
*/

@implementation appController

@synthesize languageIndex;

@synthesize chosenLanguage1;
@synthesize chosenLanguage2;

@synthesize languagesMenu;

- (BOOL)languageInShortList:(NSString*)theLanguage
{
    if ([theLanguage compare:[[self chosenLanguage1] title]] == NSOrderedSame)
        return YES;
    else if ([theLanguage compare:[[self chosenLanguage2] title]] == NSOrderedSame)
        return YES;
    else
        return NO;
} /* end languageInShortList */

- (NSString*)buildAppleScript:(NSUInteger)theChosenLanguageIndex
{
    NSString    *appleScriptString;

    appleScriptString = [NSString stringWithFormat:
        @"property name_of_spelling_window_Dutch   : \"Spelling en grammatica\"\n"
        @"property name_of_spelling_window_English : \"Spelling and Grammar\"\n"
        @"property name_of_spelling_window_French  : \"Orthographe et grammaire\"\n"
        @"property name_of_spelling_window_German  : \"Rechtschreibung und Grammatik\"\n"
        @"\n"
        @"property error_message : \"Spell options not available for this application!\"\n"
        @"\n"
        @"set app_name to my get_front_app()\n"
        @"if app_name = \"spellingSwitcher\"\n"
        @"      tell application \"System Events\"\n"
    	@"          keystroke \"h\" using command down\n"
    	@"	        delay 0.5 --need to adjust for your machine\n"
    	@"	        set app_name to my get_front_app()\n"
        @"      end tell\n"
        @"end if\n"
        @"\n"        
        @"tell application app_name\n"
        @"      activate\n"
        @"end tell\n"
        @"tell application \"System Events\"\n"
        @"      tell process app_name\n"
        @"          if not (exists (window name_of_spelling_window_Dutch)) then\n"
        @"              if not (exists (window name_of_spelling_window_English)) then\n"
        @"                  if not (exists (window name_of_spelling_window_French)) then\n"
        @"                      if not (exists (window name_of_spelling_window_German)) then\n"
        @"                          keystroke \":\" using {command down, shift down}\n"
        @"                          delay 0.5 --need to adjust for your machine\n"
        @"                      end if\n"
        @"                  end if\n"
        @"              end if\n"
        @"          end if\n"
        @"          if exists (window name_of_spelling_window_Dutch) then\n"
        @"              tell utilty to selectLanguage(app_name, name_of_spelling_window_Dutch)\n"        
        @"          else if exists (window name_of_spelling_window_English) then\n"
        @"              tell utilty to selectLanguage(app_name, name_of_spelling_window_English)\n"
        @"          else if exists (window name_of_spelling_window_French) then\n"
        @"              tell utilty to selectLanguage(app_name, name_of_spelling_window_French)\n"
        @"          else if exists (window name_of_spelling_window_German) then\n"
        @"              tell utilty to selectLanguage(app_name, name_of_spelling_window_German)\n"
        @"          else\n"
        @"              activate \"spellingSwitcher\"\n"
        @"              display dialog error_message with icon stop\n"
        @"          end if\n"
        @"      end tell\n"
        @"end tell\n"
        @"\n"
        @"on get_front_app()\n"
        @"    tell application \"System Events\"\n"
        @"        set appname to name of (first process whose frontmost is true) as string\n"
        @"    end tell\n"
        @"    return appname\n"
        @"end get_front_app\n"
        @"\n"
        @"script utilty\n"        
        @"      on selectLanguage(appName, name_of_spelling_window)\n"
        @"          tell application \"System Events\"\n"
        @"              tell process appName\n"        
        @"                  tell window name_of_spelling_window\n"
        @"                      tell pop up button 1\n"
        @"                          click\n"
        @"                          tell menu 1\n"
        @"                              click menu item %d\n"
        @"                          end tell\n"
        @"                      end tell\n"
        @"                      click (the first button whose subrole is \"AXCloseButton\")\n"
        @"                  end tell\n"        
        @"              end tell\n"        
        @"          end tell\n"        
        @"      end selectLanguage\n"
        @"end script", theChosenLanguageIndex];
    return appleScriptString;                                             
} /* end buildAppleScript */

- (void)buildMenu
{
    // Determine the language used by the OS.
    NSLocale        *currentLocale;
    NSString        *menuStatusBarString;
    
    currentLocale = [NSLocale currentLocale];
    menuStatusBarString = [currentLocale displayNameForKey:NSLocaleIdentifier
                                                     value:[currentLocale localeIdentifier]];

    // Set up the spell check item in the status bar.
    NSStatusBar     *statusBar;
    NSStatusItem    *spellingCheckerItem;

    statusBar = [NSStatusBar systemStatusBar];
    spellingCheckerItem = [statusBar statusItemWithLength:NSVariableStatusItemLength];
    [spellingCheckerItem retain];
    [spellingCheckerItem setTitle:menuStatusBarString];
    [spellingCheckerItem setEnabled:YES];

    // Determine the languages which are known by the Spell Checker.
    NSArray *availableLanguages;

    availableLanguages = [[NSSpellChecker sharedSpellChecker] availableLanguages];

    // Build the menu based on the list of available languages.
    NSMenuItem  *languageMenuItem;
    
    [self setLanguagesMenu:[[NSMenu alloc] initWithTitle:@""]];
    [[self languagesMenu] setAutoenablesItems:NO];

    // Make a slot for the first language.
    languageMenuItem = [[NSMenuItem alloc] autorelease];
    [languageMenuItem initWithTitle:@"Language 1"
                             action:@selector(selectedLanguage:)
                      keyEquivalent:@""];
    [languageMenuItem setTarget:self];
    [languageMenuItem setEnabled:NO];
    [[self languagesMenu] addItem:languageMenuItem];

    // Make a slot for the second language.
    languageMenuItem = [[NSMenuItem alloc] autorelease];
    [languageMenuItem initWithTitle:@"Language 2"
                             action:@selector(selectedLanguage:)
                      keyEquivalent:@""];
    [languageMenuItem setTarget:self];
    [languageMenuItem setEnabled:NO];
    [[self languagesMenu] addItem:languageMenuItem];

    // Make a sperator item.
    languageMenuItem = [NSMenuItem separatorItem];
    [[self languagesMenu] addItem:languageMenuItem];

    // Building the list of languages
    for (NSString *entry in availableLanguages)
    {
        NSString    *languageString;
        
        // Determine the displayName of the available languages
        languageString = [currentLocale displayNameForKey:NSLocaleIdentifier
                                                    value:entry];

        // CCLog(@"%s, %@ : %@", _cmd, entry, languageString);

        // The languageString can be nil, which happens when you
        // try the MultiLingual value above.
        if (languageString != nil)
        {
            languageMenuItem = [[NSMenuItem alloc] autorelease];
            [languageMenuItem initWithTitle:languageString
                                     action:@selector(selectedLanguage:)
                              keyEquivalent:@""];
            [languageMenuItem setTarget:self];
            [languageMenuItem setEnabled:YES];
            [[self languagesMenu] addItem:languageMenuItem];
        } /* end if */
    } /* end for */
    
    // Finally add this menu to the menuItem we created in the status bar.    
    [spellingCheckerItem setMenu:[self languagesMenu]];
} /* end buildMenu */

- (BOOL)executeAppleScript:(NSString*)theAppleScriptText
{
    NSAppleScript *appleScript;
    
    appleScript = [NSAppleScript alloc];
    [[appleScript initWithSource:theAppleScriptText] autorelease];
        
    NSDictionary            *errorInfo = nil;
    NSAppleEventDescriptor  *appleEventDescriptor;
    
    appleEventDescriptor = [appleScript executeAndReturnError:&errorInfo];

    if (appleEventDescriptor == nil)
        return NO;
    return YES;    
} /* end executeAppleScript */

- (void)selectedLanguage:(id)sender
{
    // Check if the language the user selected is already available
    // in the top 2 items of the menu list. If not then add this 
    // language to one of the 2 first entries of the menu list.
    if ([self languageInShortList:[sender title]] == NO)
    {
        NSMenuItem  *languageMenuItem;
        
        languageMenuItem = [[self languagesMenu] itemAtIndex:[self languageIndex]];
        [languageMenuItem setTitle:[sender title]];
        [languageMenuItem setEnabled:YES];
        if ([self languageIndex] == 0)
            [self setChosenLanguage1:sender];
        else
            [self setChosenLanguage2:sender];
        [self setLanguageIndex:([self languageIndex] + 1) % 2];
    } /* end if */
    
    // Execute the applescript.
    NSString    *theAppleScript;
    NSMenuItem  *chosenMenuItem;
    NSUInteger   indexOfChosenLanguage;
    
    if ([[sender menu] indexOfItem:sender] == 0)
        chosenMenuItem = [self chosenLanguage1];
    else if ([[sender menu] indexOfItem:sender] == 1)
        chosenMenuItem = [self chosenLanguage2];
    else
        chosenMenuItem = sender;

    indexOfChosenLanguage = [[chosenMenuItem menu] indexOfItem:chosenMenuItem];
    theAppleScript = [self buildAppleScript:indexOfChosenLanguage];
    
    if ([self executeAppleScript:theAppleScript] == NO)
    {
        // I should to something intelligent here...
        CCLog(@"%s ERROR", _cmd);
    } /* end if */
} /* end languagesMenuSelected */

- (id)init
{
    self = [super init];
    if (self)
    {
        [[NSThread currentThread] setName:@"Main Thread"];
        [self buildMenu];
        [self setLanguageIndex:0];
        [self setChosenLanguage1:nil];
        [self setChosenLanguage2:nil];
    } /* end if */
    return self;
} /* end init */

- (void)dealloc
{
    [chosenLanguage1 release];
    [chosenLanguage2 release];
    [languagesMenu release];
    [super dealloc];
} /* end dealloc */

@end /* implementation appController */
