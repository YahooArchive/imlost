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
#import "Person.h"
#import "DataManager.h"


@interface PeopleViewController ()


@end

@implementation PeopleViewController

@synthesize people;
@synthesize automaticEditControlsDidShow;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];    
    
    people = [DataManager readFromPlist:@"people.plist"];
    for(int i=0;i<[people count];i++)
    {
        Person* p=((Person*)[people objectAtIndex:i]);
        if([p.name length]==0&&[p.numbers count]==0)
        {
            [self.people removeObjectAtIndex:i];
            NSUInteger indexes[] = { 0, i+(self.editing?1:0) };
            NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes
                                                                length:2];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [DataManager writeToPlist:@"people.plist" withData:people];
            i--;
        }
    }
    // Uncomment the following line to preserve selection between presentations.
    //self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.allowsSelectionDuringEditing=TRUE;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    for(int i=0;i<[people count];i++)
    {
        Person* p=((Person*)[people objectAtIndex:i]);
        if([p.name length]==0&&[p.numbers count]==0)
        {
            [self.people removeObjectAtIndex:i];
            NSUInteger indexes[] = { 0, i+(self.editing?1:0) };
            NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes
                                                                length:2];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [DataManager writeToPlist:@"people.plist" withData:people];
            i--;
        }
    }
}
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row=indexPath.row-(self.editing?1:0);
    PersonViewController *controller = [[PersonViewController alloc]
                                      initWithStyle:UITableViewStyleGrouped];
    if(row>=0)
        controller.myPerson=[people objectAtIndex:row];
    else
    {
        Person *person = [[Person alloc] init];
        person.name = @"";
        person.numbers=[[NSMutableArray alloc] init];
        [people insertObject:person atIndex:0];
		[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        [DataManager writeToPlist:@"people.plist" withData:people];
        controller.myPerson=person;
    }
    if(self.editing){
        [controller setEditing:YES];
    }
    [[self navigationController] pushViewController:controller
                                           animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
        return [self.people count]+(self.editing?1:0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row=indexPath.row-(self.editing?1:0);
    if (row>=0) {
        UITableViewCell *cell = [tableView
                                 dequeueReusableCellWithIdentifier:@"PersonCell"];
        Person *person = [self.people objectAtIndex:row];
        if(person.name == nil || person.name.length==0){
            cell.textLabel.text = @"";
            //cell.textLabel.text = @"(No Name)";
        }else{
            cell.textLabel.text = person.name;
        }
        if(person.numbers.count==0||((NSString*)[person.numbers objectAtIndex:0]).length==0){
            cell.detailTextLabel.text = @"";
            //cell.detailTextLabel.text = @"(No Phone Number)";
        }else{
            cell.detailTextLabel.text = [person.numbers objectAtIndex:0];
        }
        return cell;
    } else {
        return [tableView dequeueReusableCellWithIdentifier:@"AddPerson"];
    }
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		[self.people removeObjectAtIndex:(indexPath.row-1)];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [DataManager writeToPlist:@"people.plist" withData:people];
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/
-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
    automaticEditControlsDidShow = NO;
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
    if(editing) {
        automaticEditControlsDidShow = YES;
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
    } else {
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
        // place here anything else to do when the done button is clicked
        
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tv
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.editing) {
        if (indexPath.row==0 && automaticEditControlsDidShow)
            return UITableViewCellEditingStyleInsert;
        return UITableViewCellEditingStyleDelete;
    }else{
        return UITableViewCellEditingStyleNone;
    }
}

@end
