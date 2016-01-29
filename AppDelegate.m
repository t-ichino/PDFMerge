//
//  AppDelegate.m
//  PDFMerge
//
//  Created by tamaki on 10/06/30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"


@implementation AppDelegate
-(void)dealloc
{
	[fileList release];
	[super dealloc];
}

-(void)awakeFromNib
{
	[myTable registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType,nil]];
	fileList=[[NSMutableArray alloc] initWithCapacity:1];
}

-(IBAction)clearList:(id)sender
{
	[fileList removeAllObjects];
	[myTable reloadData];
}

-(IBAction)merge:(id)sender
{
	NSUInteger i;
	NSUInteger max=0;
	for(i=0;i<[fileList count];i++){
		NSDictionary *dic=[fileList objectAtIndex:i];
		NSNumber *num=[dic valueForKey:@"page"];
		NSUInteger n=[num integerValue];
		if(n>max){
			max=n;
			mainDocNumber=i;
			mainDocPath=[dic valueForKey:@"path"];
		}
	}
	//NSLog(@"%d",mainDocNumber);
	NSString *destPath=[mainDocPath stringByDeletingLastPathComponent];
	NSSavePanel *savePanel=[NSSavePanel savePanel];
	[savePanel setRequiredFileType:@"pdf"];
	[savePanel beginSheetForDirectory:destPath
							file:@"merged.pdf"
							modalForWindow:[sender window] 
							modalDelegate:self
							didEndSelector:@selector(savePanelDidEnd:returnCode:contextInfo:)
							contextInfo:nil];
}

- (void)savePanelDidEnd:(NSSavePanel *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
	if(returnCode){
		NSURL *mainDocUrl=[NSURL fileURLWithPath:mainDocPath];
		PDFDocument *mainPdfDoc=[[PDFDocument alloc] initWithURL:mainDocUrl];
		NSUInteger i;
		for(i=0;i<[fileList count];i++){
			NSDictionary *dic=[fileList objectAtIndex:i];
			NSString *path=[dic valueForKey:@"path"];
			NSURL *url=[NSURL fileURLWithPath:path];
			PDFDocument *pdfdoc=[[PDFDocument alloc] initWithURL:url];
			NSUInteger n=[pdfdoc pageCount];
			NSUInteger j;
			if(i<mainDocNumber){
				for(j=n;j>0;j--){
					PDFPage *page=[pdfdoc pageAtIndex:j-1];
					[mainPdfDoc insertPage:page atIndex:0];
				}
			}else if(i>mainDocNumber){
				if(i==mainDocNumber+1){
					NSImage *img=[[NSImage alloc] initWithSize:NSMakeSize(1,1)];
					[mainPdfDoc insertPage:[[PDFPage alloc] initWithImage:img] atIndex:[mainPdfDoc pageCount]-1];
					[img release];
					[mainPdfDoc exchangePageAtIndex:[mainPdfDoc pageCount]-2 withPageAtIndex:[mainPdfDoc pageCount]-1];
				}
				for(j=0;j<n;j++){
					PDFPage *page=[pdfdoc pageAtIndex:j];
					[mainPdfDoc insertPage:page atIndex:[mainPdfDoc pageCount]-1];
				}
				if(i==[fileList count]-1){
					[mainPdfDoc removePageAtIndex:[mainPdfDoc pageCount]-1];
				}
			}
			[pdfdoc release];
		}
		[mainPdfDoc writeToFile:[sheet filename]];
		[mainPdfDoc release];
	}
}


#pragma mark tableView delegate
-(int)numberOfRowsInTableView:(NSTableView*)aTableView
{
	return [fileList count];
}

-(id)tableView:(NSTableView*)aTableView objectValueForTableColumn:(NSTableColumn*)aTableColumn row:(int)rowIndex
{
	NSDictionary *dic=[fileList objectAtIndex:rowIndex];
	if([[aTableColumn identifier] isEqualToString:@"path"]){
		return [dic valueForKey:@"path"];
	}else if([[aTableColumn identifier] isEqualToString:@"page"]) {
		return [dic valueForKey:@"page"];
    }
    return nil;
}

-(BOOL)tableView:(NSTableView*)aTableView shouldEditTableColumn:(NSTableColumn*)aTableColumn row:(int)rowIndex
{
	return NO;
}

-(BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSArray*)rows toPasteboard:(NSPasteboard*)pboard
{
	return YES;
}

- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op 
{		
    return NSDragOperationEvery;    
}

-(BOOL)tableView:(NSTableView*)tableView acceptDrop:(id)info row:(int)row dropOperation:(NSTableViewDropOperation)operation
{
	NSPasteboard* pboard = [info draggingPasteboard];
	NSArray *files=[pboard propertyListForType:NSFilenamesPboardType];
	NSUInteger i;
	for(i=0;i<[files count];i++){
		NSString *path=[files objectAtIndex:i];
		NSURL *url=[NSURL fileURLWithPath:path];
		PDFDocument *pdfdoc=[[PDFDocument alloc] initWithURL:url];
		NSUInteger n=[pdfdoc pageCount];
		NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:path,@"path",[NSNumber numberWithInt:n],@"page",nil];
		[fileList addObject:dic];
	}
	[tableView reloadData];
	return YES;
}
	
@end
