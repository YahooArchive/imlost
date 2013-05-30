//
// Copyright (c) 2013, Sivan Goldstein
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * The names of its contributors may not be used to endorse or promote products
//       derived from this software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL Sivan Goldstein BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// 

#import "PeopleViewController.h"
#import "PersonViewController.h"
#import "DataManager.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface PersonViewController ()

@end

@implementation PersonViewController

@synthesize myPerson;
@synthesize automaticEditControlsDidShow;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setTitle:myPerson.name];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.allowsSelectionDuringEditing=TRUE;
    self.tableView.allowsSelection=FALSE;
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [[UIColor alloc]initWithRed:255 green:253 blue:241 alpha:255];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self resignAllResponders];
}
-(void)resignAllResponders
{
    for (NSUInteger section = 0; section < [[self tableView] numberOfSections]; section++)
    {
        for(NSUInteger row=0;row<[[self tableView] numberOfRowsInSection:section];row++)
        {
            NSUInteger indexes[] = { section, row };
            NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes
                                                                length:2];
            UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:indexPath];
            if ([[cell viewWithTag:42] isFirstResponder])
            {
                [[cell viewWithTag:42] resignFirstResponder];
            }
        }
    }
}
NSInteger previousCell=NSIntegerMax;
NSInteger selectedCell;
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    //here is supposed to add a text field and hide the text label.
    //It will only make it once because it is "tagged" 1234 and will only make it if no
    //item has that tag
    UITableViewCell* cell=[tableView cellForRowAtIndexPath:indexPath];
    
    UITextField* textField =(UITextField*)[cell viewWithTag:42];
    textField.clearsOnBeginEditing = (indexPath.row==0&&indexPath.section==1)?YES:NO;
    textField.keyboardType=(indexPath.section==1?UIKeyboardTypeNumbersAndPunctuation:UIKeyboardTypeAlphabet);
    textField.enabled=YES;
    [textField becomeFirstResponder];
    selectedCell=indexPath.section==0?NSIntegerMin:(indexPath.row==0?0:indexPath.row-1);
    if(selectedCell>previousCell)
        selectedCell--;
    if(indexPath.section==1&&indexPath.row==0)
    {
        
        [myPerson.numbers insertObject:[[NSString alloc] init] atIndex:0];
		[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationLeft];
    }
    
    NSUInteger indexes[] = { indexPath.section, selectedCell+1};
    indexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.enabled=NO;
    
    if (textField.keyboardType==UIKeyboardTypeNumbersAndPunctuation)
    {//phone number
        [myPerson.numbers setObject:textField.text atIndexedSubscript:(selectedCell)];
        if([textField.text length]==0)
        {
            previousCell=selectedCell;
            [myPerson.numbers removeObjectAtIndex:selectedCell];
            NSUInteger indexes[] = { 1, selectedCell+1};
            NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes
                                                                length:2];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }else{
            previousCell=NSIntegerMax;
        }
    }else{//name
        previousCell=NSIntegerMax;
        myPerson.name=textField.text;
        [self setTitle:myPerson.name];
    }
    [DataManager writeToPlist:@"people.plist" withData:
        ((PeopleViewController*)[self.navigationController.viewControllers objectAtIndex:0]).people];
    [((PeopleViewController*)[self.navigationController.viewControllers objectAtIndex:0]).tableView reloadData];
    
}
/*
- (void)tableView:(UITableView *)tableView
didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    //removing stuff from being editable and "saving" it
    
    UITableViewCell* cell=[tableView cellForRowAtIndexPath:indexPath];
    UITextField *textField = (UITextField*)[cell viewWithTag:1234];
    textField.hidden=TRUE;
    cell.textLabel.hidden=FALSE;
    cell.textLabel.text=textField.text;
    
}*/

-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
    automaticEditControlsDidShow = NO;
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
    [[self.navigationController.viewControllers objectAtIndex:0] setEditing:editing];
    if(editing) {
        automaticEditControlsDidShow = YES;
        
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
    } else {
        [self.tableView beginUpdates];
        [self resignAllResponders];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
        [self.view endEditing:YES];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch(section)
    {
        case 0: return 1;
        case 1:
            return [myPerson.numbers count]+(self.editing&&automaticEditControlsDidShow?1:0);
        //case 2: return 1;
    }
    return -1;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0: return @"Name";
        case 1: return @"Phone Number(s)";
        //case 2: return @"Address";
    }
    
    return nil;
}
/*
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self resignAllResponders];
}*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier];
    UITextField *textField;
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
        cell.textLabel.hidden=TRUE;
        CGRect bounds = [cell.contentView bounds];
        CGRect rect = CGRectInset(bounds, 10, 0);
        
        textField=[[UITextField alloc]initWithFrame:rect];
        textField.font=[UIFont fontWithName:@"Helvetica-Bold" size:17];
        //textField.textAlignment=cell.textLabel.textAlignment;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.tag=42;
        textField.enabled=false;
        textField.delegate = self;
        [cell.contentView addSubview:textField];
    }else{
        textField =(UITextField*)[cell viewWithTag:42];
    }
    
    int row = indexPath.row-(self.editing?1:0);
    NSUInteger section = [indexPath section];
    switch (section)
    {
        case 0:
            textField.text=myPerson.name;
            break;
        case 1:
            
            if(row>=0){
                textField.text=[myPerson.numbers objectAtIndex:row];
            }else{
                textField.text=@"New Phone Number";
            }
            
            break;
        //case 2:
        //    cell.textLabel.text=@"12345 Address place";
        //    break;
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (UITableViewCellEditingStyle)tableView:(UITableView *)tv
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==1) {
        if (self.editing) {
            if (indexPath.row==0 && automaticEditControlsDidShow)
                return UITableViewCellEditingStyleInsert;
            return UITableViewCellEditingStyleDelete;
        }else{
            return UITableViewCellEditingStyleNone;
        }
    }else{
        return UITableViewCellEditingStyleNone;
    }
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
        [self resignAllResponders];
        NSInteger row=indexPath.row;
        if(previousCell!=NSIntegerMin&&previousCell!=NSIntegerMax)
        {//cell deleted from responding
            NSLog(@"ASDF:%d,%d",previousCell,row);
            if(row-1==previousCell){
                return;
            }else{
                if(row-1>previousCell){
                    row--;
                    NSUInteger indexes[] = { 1, row };
                    indexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
                }
            }
        }
        [myPerson.numbers removeObjectAtIndex:row-1];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [DataManager writeToPlist:@"people.plist" withData:
            ((PeopleViewController*)[self.navigationController.viewControllers objectAtIndex:0]).people];
        [((PeopleViewController*)[self.navigationController.viewControllers objectAtIndex:0]).tableView reloadData];
        
    }
}
/*
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
      *detailViewController = [[ alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
 
}
*/
@end
