/*
 Copyright (c) 2013 Alun Bestor and contributors. All rights reserved.
 This source file is released under the GNU General Public License 2.0. A full copy of this license
 can be found in this XCode project at Resources/English.lproj/BoxerHelp/pages/legalese.html, or read
 online at [http://www.gnu.org/licenses/gpl-2.0.txt].
 */

//Capture-file handling: naming and opening the files that DOSBox writes
//screenshots, A/V captures and parallel-port dumps into. Split out of
//BXSession+BXFileManagement to keep drive/file management separate.

#import "BXSession.h"

NS_ASSUME_NONNULL_BEGIN

@interface BXSession (BXCaptures)

/// Returns a file URL suitable for capturing a file of the specified type and extension.
- (NSURL *) URLForCaptureOfType: (NSString *)typeDescription
                  fileExtension: (NSString *)extension;

@end

NS_ASSUME_NONNULL_END
