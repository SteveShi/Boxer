/*
 Copyright (c) 2013 Alun Bestor and contributors. All rights reserved.
 This source file is released under the GNU General Public License 2.0. A full copy of this license
 can be found in this XCode project at Resources/English.lproj/BoxerHelp/pages/legalese.html, or read
 online at [http://www.gnu.org/licenses/gpl-2.0.txt].
 */

#import "BXSession+BXCaptures.h"

#import "BXSessionPrivate.h"
#import "BXBaseAppController.h"
#import "BXBaseAppController+BXSupportFiles.h"

@implementation BXSession (BXCaptures)

- (NSURL *) URLForCaptureOfType: (NSString *)typeDescription fileExtension: (NSString *)extension
{
    NSString *descriptiveSuffix = @"";
    //Remap certain of DOSBox's file type suggestions.
    if ([typeDescription isEqualToString: @"Parallel Port Stream"]) //Parallel-port dumps
    {
        descriptiveSuffix = @" LPT output";
        extension = @"txt";
    }

    //Work out an appropriate filename, based on the title of the session and the current date and time.
    NSValueTransformer *transformer = [NSValueTransformer valueTransformerForName: @"BXCaptureDateTransformer"];
    NSString *formattedDate = [transformer transformedValue: [NSDate date]];

    NSString *nameFormat = NSLocalizedString(@"%1$@%2$@ %3$@",
                                             @"Filename pattern for captures: %1$@ is the display name of the DOS session, %2$@ is the type of capture being created, %3$@ is the current date and time in a notation suitable for chronologically-ordered filenames.");

    //Name the captured file after the current gamebox, or - failing that - the application itself.
    NSString *sessionName = self.displayName;
    if (sessionName.length == 0)
        sessionName = [BXBaseAppController appName];

    NSString *baseName = [NSString stringWithFormat: nameFormat, sessionName, descriptiveSuffix, formattedDate];
    NSString *fileName = [baseName stringByAppendingPathExtension: extension];


    //Sanitise the filename in case it contains characters that are disallowed for file paths.
    //TODO: move this off to an NSFileManager/NSString category.
    fileName = [fileName stringByReplacingOccurrencesOfString: @":" withString: @"-"];
    fileName = [fileName stringByReplacingOccurrencesOfString: @"/" withString: @"-"];

    NSURL *baseURL = [(BXBaseAppController *)[NSApp delegate] recordingsURLCreatingIfMissing: YES error: NULL];
    NSURL *destinationURL = [baseURL URLByAppendingPathComponent: fileName];

    return destinationURL;
}

- (FILE *) emulator: (BXEmulator *)emulator openCaptureFileOfType: (NSString *)captureType extension: (NSString *)extension
{
    NSURL *URL = [self URLForCaptureOfType: captureType fileExtension: extension];
    if (URL != nil)
    {
        const char *fsRepresentation = URL.fileSystemRepresentation;
        FILE *handle = fopen(fsRepresentation, "wb");
        //TODO: should we hide the file extension for common file types like txt and png?
        return handle;
    }
    else
    {
        return nil;
    }
}

@end
