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

#import "DataManager.h"

@implementation DataManager
+ (void) writeToPlist: (NSString*)fileName withData:(NSMutableArray *)data
{
    
    NSMutableArray *dataArr = [[NSMutableArray alloc]init];
    for (NSObject *d in data){
        NSData *encodedData = [NSKeyedArchiver archivedDataWithRootObject:d];
        [dataArr addObject:encodedData];
    }
    [dataArr writeToFile:[DataManager finalPath:fileName] atomically: YES];
    /* This would change the firmware version in the plist to 1.1.1 by initing the NSDictionary with the plist, then changing the value of the string in the key "ProductVersion" to what you specified */
    
}
+ (NSMutableArray *) readFromPlist: (NSString *)fileName {
    
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[DataManager finalPath:fileName]]) {
        
        NSMutableArray *arr = [[NSMutableArray alloc] initWithContentsOfFile:[DataManager finalPath:fileName]];
        
        NSMutableArray *dataArr = [[NSMutableArray alloc]init];
        for (NSData *d in arr){
            NSObject *data = [NSKeyedUnarchiver unarchiveObjectWithData:d];
            [dataArr addObject:data];
        }
        return dataArr;
    } else {
        return [[NSMutableArray alloc]init];
    }
}
+ (NSString*) finalPath: (NSString*)fileName
{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
 stringByAppendingPathComponent:fileName];
}

@end
