//
//  AppDelegate.h
//  PDFMerge
//
//  Created by tamaki on 10/06/30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>


@interface AppDelegate : NSObject {
	IBOutlet NSWindow *myWindow;
	IBOutlet NSTableView *myTable;
	NSString *mainDocPath;
	NSMutableArray *fileList;
	NSUInteger mainDocNumber;
}

-(IBAction)clearList:(id)sender;
-(IBAction)merge:(id)sender;


@end
