/*
 Copyright (c) 2013 Alun Bestor and contributors. All rights reserved.
 This source file is released under the GNU General Public License 2.0. A full copy of this license
 can be found in this XCode project at Resources/English.lproj/BoxerHelp/pages/legalese.html, or read
 online at [http://www.gnu.org/licenses/gpl-2.0.txt].
 */

//Private constants, macros and the class extension for BXEmulatedPrinter.
//Shared between BXEmulatedPrinter.mm and its categories so that the printer
//implementation can be split across files.

#import "BXEmulatedPrinter.h"
#import "BXPrintSession.h"

#pragma mark -
#pragma mark Private constants

//! Flags for the control register, as set and returned by \c BXEmulatedPrinter.controlRegister
typedef NS_OPTIONS(uint8_t, BXEmulatedPrinterControl) {
    BXEmulatedPrinterControlStrobe      = 1 << 0,   //!< 'Flashed' to indicate that data is waiting to be read.
    BXEmulatedPrinterControlAutoFeed    = 1 << 1,   //!< Tells the device to handle linebreaking automatically.
    BXEmulatedPrinterControlReset       = 1 << 2,   //!< Tells the device to initialize/reset.
    
    BXEmulatedPrinterControlSelect      = 1 << 3,   //!< Tells the device to select. Unsupported.
    BXEmulatedPrinterControlEnableIRQ   = 1 << 4,   //!< Tells the device to enable interrupts. Unsupported.
    BXEmulatedPrinterControlEnableBiDi  = 1 << 5,   //!< Tells the device to enable bidirectional communication. Unsupported.
    
    //Bits 6 and 7 are reserved
    
    //! Used when reporting the current control register, to mask unsupported bits 5, 6 and 7.
    BXEmulatedPrinterControlMask        = 0xe0,
};

//! Flags for the status register, as returned by \c BXEmulatedPrinter.statusRegister
typedef NS_OPTIONS(uint8_t, BXEmulatedPrinterStatus) {
    //Bits 0 and 1 are reserved
    
    BXEmulatedPrinterNoInterrupt        = 1 << 2,   //!< When *unset*, indicates an interrupt has occurred. Unsupported.
    BXEmulatedPrinterStatusNoError      = 1 << 3,   //!< When *unset*, indicates the device has encountered an error.
    BXEmulatedPrinterStatusSelected     = 1 << 4,   //!< Indicates the device is online and selected.
    BXEmulatedPrinterStatusPaperEmpty   = 1 << 5,   //!< Indicates there is no paper remaining.
    BXEmulatedPrinterStatusNoAck        = 1 << 6,   //!< When *unset*, indicates acknowledgement that data has been read.
    BXEmulatedPrinterStatusReady        = 1 << 7,   //!< When *unset*, the device is busy and no data should be sent.

    //! Used when reporting the current status register, to mask unsupported bits 0, 1, 2.
    BXEmulatedPrinterStatusMask         = 0x07,
};

//! Helper macro that returns two adjacent 8-bit parameters from an array, merged into a single 16-bit parameter
#define WIDEPARAM(p, i) (p[i] + (p[i+1] << 8))

//Used to flag extended ESC/P2 and IBM commands so that they can be handled with the same byte-eating logic
#define ESCP2_FLAG 0x200
#define IBM_FLAG 0x800

//! Used to flag ESC2 commands that we don't support but whose parameters we still need to eat from the bytestream
#define UNSUPPORTED_ESC2_COMMAND 0x101

#define VERTICAL_TABS_UNDEFINED 255
#define UNIT_SIZE_UNDEFINED -1

#pragma mark -
#pragma mark Private interface declaration

@interface BXEmulatedPrinter ()

#pragma mark -
#pragma mark Internal properties

//Overridden to make them read-write internally.
@property (strong, nonatomic) NSMutableDictionary<NSAttributedStringKey, id> *textAttributes;
@property (strong, nonatomic) BXPrintSession *currentSession;

//! The effective pitch in characters-per-inch, counting the current font settings.
@property (readonly, nonatomic) double effectivePitch;

//! The official width of one monospace character at the current pitch, in inches.
@property (readonly, nonatomic) double characterWidth;

//! The actual width of one monospace character at the current pitch,  in inches.
@property (readonly, nonatomic) double effectiveCharacterWidth;

//! The actual extra spacing to insert between characters.
//! This will be the same as letterSpacing unless one of the double-width modes
//! is active, in which case it will be doubled also.
@property (readonly, nonatomic) double effectiveLetterSpacing;

@property (strong, nonatomic) NSMutableData *bitmapData;


#pragma mark -
#pragma mark Helper class methods

//! Returns the ASCII->Unicode character mapping to use for the specified codepage.
+ (const uint16_t * const) _charmapForCodepage: (NSUInteger)codepage;

//! Returns a CMYK-gamut NSColor suitable for the specified color code.
+ (NSColor *) _colorForColorCode: (BXESCPColor)colorCode;

//! Returns a font descriptor object that can be used to identify a suitable font for the specified typeface.
+ (NSFontDescriptor *) _fontDescriptorForEmulatedTypeface: (BXESCPTypeface)typeface
                                                     bold: (BOOL)bold
                                                   italic: (BOOL)italic;

#pragma mark -
#pragma mark Initialization

//! Called when the DOS session first communicates the intent to print.
- (void) _prepareForPrinting;

//! Called when the DOS session changes parameters for text printing.
- (void) _updateTextAttributes;

//! Called when the printer first draws to the page, if no print session is currently active.
- (void) _startNewPrintSession;

//! Called when the DOS session formfeeds or the print head goes off the extents of the current page.
//! Finishes the current page in the session (if one was present) and advances printing to the next page.
//! If discardPreviousPageIfBlank is YES, and nothing was printed to the previous page, then the previous
//! page will be discarded unused. Otherwise a blank page will be inserted into the session before the new page.
- (void) _startNewPageWithCarriageReturn: (BOOL)insertCarriageReturn
                       discardBlankPages: (BOOL)discardPreviousPageIfBlank;

//! Called when we first need to draw to the current page.
//! The print session and page canvas are created at this time and the paper size is locked.
- (void) _prepareCanvasForPrinting;

//! Called when the DOS session prepares a bitmap drawing context.
- (void) _prepareForBitmapWithDensity: (NSUInteger)density columns: (NSUInteger)numColumns;

//! Draws the specified bitmap data (expected to be 8-bits-per-pixel black and white) as a bitmap image
//! into the preview and PDF contexts. This gives slightly fuzzier output than the vectorized technique
//! below, but better rendering speeds and smaller PDF filesizes.
- (void) _drawImageWithBitmapData: (NSData *)bitmapData
                            width: (NSUInteger)pixelWidth
                           height: (NSUInteger)pixelHeight
                           inRect: (CGRect)imageRect
                            color: (CGColorRef)color;

//! Draws the specified bitmap data (expected to be 8-bits-per-pixel black and white) as a series of
//! horizontal vector lines into the preview and PDF contexts. This is crisper than the bitmap technique
//! above at large magnifications, but slower and produces larger PDF files.
- (void) _drawVectorizedBitmapData: (NSData *)bitmapData
                             width: (NSUInteger)pixelWidth
                            height: (NSUInteger)pixelHeight
                            inRect: (CGRect)imageRect
                             color: (CGColorRef)color;

#pragma mark -
#pragma mark Character mapping functions

//! Switch to the specified codepage for ASCII->Unicode mappings.
- (void) _selectCodepage: (NSUInteger)codepage;

//! Switch to the specified international character set using the current codepage.
- (void) _selectInternationalCharset: (BXESCPCharset)charsetID;

//! Set the specified chartable entry to point to the specified codepage.
//! If this chartable is active, the current ASCII mapping will be updated accordingly.
- (void) _assignCodepage: (NSUInteger)codepage
             toCharTable: (BXESCPCharTable)charTable;


#pragma mark -
#pragma mark Input handling

//! Returns YES if the specified byte was handled as part of a bitmap,
//! or NO otherwise.
- (BOOL) _handleBitmapData: (uint8_t)byte;

//! Returns YES if the specified byte was handled as part of a control command,
//! or NO if it should be treated as character data to print.
- (BOOL) _handleControlCharacter: (uint8_t)byte;

//! Prints the specified character to the page.
- (void) _printCharacter: (uint8_t)byte;


#pragma mark -
#pragma mark Command handling

//Open a context for parsing an ESC/P (or FS) command code.
- (void) _beginESCPCommandWithCode: (uint8_t)commandCode isFSCommand: (BOOL)isFS;

//Add the specified byte as a parameter to the current ESC/P command.
- (void) _parseESCPCommandParameter: (uint8_t)parameter;

//Called after command processing is complete, to close up the command context.
- (void) _endESCPCommand;


#pragma mark -
#pragma mark Geometry

//Move the print head to the specified X or Y offset in page coordinates.
//This notifies the delegate that the print head has moved.
- (void) _moveHeadToX: (CGFloat)xOffset;
- (void) _moveHeadToY: (CGFloat)yOffset;

@end
