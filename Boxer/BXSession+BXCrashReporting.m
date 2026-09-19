/*
 Copyright (c) 2013 Alun Bestor and contributors. All rights reserved.
 This source file is released under the GNU General Public License 2.0. A full copy of this license
 can be found in this XCode project at Resources/English.lproj/BoxerHelp/pages/legalese.html, or read
 online at [http://www.gnu.org/licenses/gpl-2.0.txt].
 */

//Crash reporting for unrecoverable emulator exceptions: writing crash dumps
//to disk and presenting the relaunch/close/save-report alert. Split out of
//BXSession.m so the session class stays focused on document lifecycle.

#import "BXSessionPrivate.h"
#import "BXDrive.h"
#import "BXEmulator.h"
#import "BXEmulator+BXDOSFileSystem.h"
#import "BXEmulatorErrors.h"
#import "NSError+ADBErrorHelpers.h"

#pragma mark -
#pragma mark Helper functions

static NSString *BXSessionCrashDumpDriveTypeDescription(BXDriveType type)
{
    switch (type)
    {
        case BXDriveHardDisk: return @"hard disk";
        case BXDriveFloppyDisk: return @"floppy disk";
        case BXDriveCDROM: return @"CD-ROM";
        case BXDriveVirtual: return @"virtual";
        case BXDriveAutodetect: return @"autodetect";
    }

    return @"unknown";
}

static NSString *BXSessionCrashDumpSafeFilenameComponent(NSString *string)
{
    NSMutableCharacterSet *allowedCharacters = [NSMutableCharacterSet alphanumericCharacterSet];
    [allowedCharacters addCharactersInString: @"-_. "];

    NSMutableString *result = [NSMutableString stringWithCapacity: string.length];
    for (NSUInteger index = 0; index < string.length; index++)
    {
        unichar character = [string characterAtIndex: index];
        if ([allowedCharacters characterIsMember: character])
            [result appendFormat: @"%C", character];
        else
            [result appendString: @"-"];
    }

    return result;
}

@implementation BXSession (BXCrashReporting)

- (NSURL *) _writeCrashDumpForEmulatorException: (NSException *)exception
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *applicationSupportURL = [manager URLsForDirectory: NSApplicationSupportDirectory
                                                   inDomains: NSUserDomainMask].firstObject;
    if (!applicationSupportURL)
        return nil;

    NSURL *dumpFolderURL = [[applicationSupportURL URLByAppendingPathComponent: @"Boxer"
                                                                   isDirectory: YES] URLByAppendingPathComponent: @"Crash Dumps"
                                                                                                      isDirectory: YES];

    NSError *folderError = nil;
    if (![manager createDirectoryAtURL: dumpFolderURL
           withIntermediateDirectories: YES
                            attributes: nil
                                 error: &folderError])
    {
        NSLog(@"Could not create Boxer crash dump folder at %@: %@", dumpFolderURL.path, folderError);
        return nil;
    }

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier: @"en_US_POSIX"];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH.mm.ss";

    NSString *processName = self.processDisplayName ?: @"MS-DOS Prompt";
    NSString *safeProcessName = BXSessionCrashDumpSafeFilenameComponent(processName);
    NSString *fileName = [NSString stringWithFormat: @"Boxer Emulator Crash %@ - %@.txt",
                                                    [dateFormatter stringFromDate: [NSDate date]],
                                                    safeProcessName];
    NSURL *dumpURL = [dumpFolderURL URLByAppendingPathComponent: fileName];

    NSMutableString *dump = [NSMutableString string];
    [dump appendString: @"Boxer Emulator Crash Dump\n"];
    [dump appendString: @"=========================\n\n"];
    [dump appendFormat: @"Created: %@\n", [NSDate date]];
    [dump appendFormat: @"Boxer version: %@ (%@)\n",
                        [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"] ?: @"unknown",
                        [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey] ?: @"unknown"];
    [dump appendFormat: @"Process: %@\n", processName];
    [dump appendFormat: @"Session: %@\n", self.displayName ?: @"unknown"];
    [dump appendFormat: @"Session file URL: %@\n", self.fileURL.path ?: @"none"];
    [dump appendFormat: @"Target URL: %@\n", self.targetURL.path ?: @"none"];
    [dump appendFormat: @"Launched program URL: %@\n", self.launchedProgramURL.path ?: @"none"];
    [dump appendFormat: @"Current DOS directory: %@\n", self.emulator.currentDirectory ?: @"unknown"];
    [dump appendFormat: @"Current DOS directory URL: %@\n", self.emulator.currentDirectoryURL.path ?: @"unknown"];
    [dump appendString: @"\nException\n"];
    [dump appendString: @"---------\n"];
    [dump appendFormat: @"Name: %@\n", exception.name];
    [dump appendFormat: @"Reason: %@\n", exception.reason ?: @"none"];
    [dump appendFormat: @"Source file: %@\n", [exception.userInfo objectForKey: @"file"] ?: @"unknown"];
    [dump appendFormat: @"Function: %@\n", [exception.userInfo objectForKey: @"function"] ?: @"unknown"];
    [dump appendFormat: @"Line: %@\n", [exception.userInfo objectForKey: @"line"] ?: @"unknown"];

    [dump appendString: @"\nRunning DOS processes\n"];
    [dump appendString: @"---------------------\n"];
    NSArray<NSDictionary<NSString *, id> *> *runningProcesses = self.emulator.runningProcesses;
    if (runningProcesses.count)
    {
        for (NSDictionary *processInfo in runningProcesses)
        {
            NSString *dosPath = [processInfo objectForKey: BXEmulatorDOSPathKey] ?: @"unknown";
            NSString *args = [processInfo objectForKey: BXEmulatorLaunchArgumentsKey] ?: @"";
            [dump appendFormat: @"%@ %@\n", dosPath, args];
        }
    }
    else
    {
        [dump appendString: @"none\n"];
    }

    [dump appendString: @"\nMounted DOS drives\n"];
    [dump appendString: @"------------------\n"];
    NSArray<BXDrive *> *mountedDrives = self.emulator.mountedDrives;
    if (mountedDrives.count)
    {
        for (BXDrive *drive in mountedDrives)
        {
            [dump appendFormat: @"%@ (%@): title=%@ source=%@ mountPoint=%@ shadow=%@ readOnly=%@\n",
                                drive.letter ?: @"?",
                                BXSessionCrashDumpDriveTypeDescription(drive.type),
                                drive.title ?: @"unknown",
                                drive.sourceURL.path ?: @"none",
                                drive.mountPointURL.path ?: @"none",
                                drive.shadowURL.path ?: @"none",
                                drive.isReadOnly ? @"YES" : @"NO"];
        }
    }
    else
    {
        [dump appendString: @"none\n"];
    }

    [dump appendString: @"\nException call stack symbols\n"];
    [dump appendString: @"----------------------------\n"];
    NSArray *exceptionStack = exception.callStackSymbols;
    if (exceptionStack.count)
        [dump appendFormat: @"%@\n", [exceptionStack componentsJoinedByString: @"\n"]];
    else
        [dump appendString: @"none\n"];

    [dump appendString: @"\nCurrent thread call stack symbols\n"];
    [dump appendString: @"---------------------------------\n"];
    [dump appendFormat: @"%@\n", [NSThread.callStackSymbols componentsJoinedByString: @"\n"]];

    NSError *writeError = nil;
    if (![dump writeToURL: dumpURL
               atomically: YES
                 encoding: NSUTF8StringEncoding
                    error: &writeError])
    {
        NSLog(@"Could not write Boxer crash dump to %@: %@", dumpURL.path, writeError);
        return nil;
    }

    NSLog(@"Saved Boxer emulator crash dump to %@", dumpURL.path);
    return dumpURL;
}

- (void) _reportEmulatorException: (NSException *)exception
{
    //Ensure it gets logged to the console, if nothing else
    [NSApp reportException: exception];
    NSURL *crashDumpURL = [self _writeCrashDumpForEmulatorException: exception];

    NSString *errorMessage;
    NSString *currentProcessName = self.processDisplayName;
    if (currentProcessName)
    {
        NSString *messageFormat = NSLocalizedString(@"%1$@ has encountered a serious error and must be relaunched.",
                                                    @"Bold message shown in alert when an unrecoverable emulation error is encountered while running a process. %1$@ is the name of the currently-active program");

        errorMessage = [NSString stringWithFormat: messageFormat, currentProcessName];
    }
    else
    {
        errorMessage = NSLocalizedString(@"The MS-DOS prompt has encountered a serious error and must be relaunched.",
                                         @"Bold message shown in alert when an unrecoverable emulation error while no process is running.");
    }

    NSString *suggestion = NSLocalizedString(@"If this continues to occur after relaunching, please send us an error report.", @"Suggestion text shown in alert when an unrecoverable emulation error is encountered.");
    if (crashDumpURL)
    {
        NSString *dumpSuggestionFormat = NSLocalizedString(@"%@\n\nA crash dump has been saved to:\n%@",
                                                           @"Suggestion text shown in alert when an unrecoverable emulation error is encountered and a crash dump was saved. The first placeholder is the normal suggestion and the second is the crash dump path.");
        suggestion = [NSString stringWithFormat: dumpSuggestionFormat, suggestion, crashDumpURL.path];
    }

    NSArray *options = @[NSLocalizedString(@"Relaunch", @"Button to restart the current session, shown in alert when Boxer encounters an unrecoverable emulation error."),

                         NSLocalizedString(@"Close", @"Button to close the current session, shown in alert when Boxer encounters an unrecoverable emulation error."),

                         NSLocalizedString(@"Save Report…", @"Button to save a local error report, shown in alert when Boxer encounters an unrecoverable emulation error."),
                         ];

    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary: @{NSLocalizedDescriptionKey: errorMessage,
                                                                                     NSLocalizedRecoverySuggestionErrorKey: suggestion,
                                                                                     NSLocalizedRecoveryOptionsErrorKey: options,
                                                                                     NSRecoveryAttempterErrorKey: self,
                                                                                     @"exception": exception,
                                                                                     }];
    if (crashDumpURL)
    {
        [userInfo setObject: crashDumpURL forKey: @"crashDumpURL"];
    }

    NSError *userError = [NSError errorWithDomain: BXEmulatorErrorDomain
                                             code: BXEmulatorUnrecoverableError
                                         userInfo: userInfo];

    [self presentError: userError
        modalForWindow: self.windowForSheet
              delegate: nil
    didPresentSelector: NULL
           contextInfo: NULL];
}

@end
