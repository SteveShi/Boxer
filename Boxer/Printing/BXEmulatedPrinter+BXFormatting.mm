/*
 Copyright (c) 2013 Alun Bestor and contributors. All rights reserved.
 This source file is released under the GNU General Public License 2.0. A full copy of this license
 can be found in this XCode project at Resources/English.lproj/BoxerHelp/pages/legalese.html, or read
 online at [http://www.gnu.org/licenses/gpl-2.0.txt].
 */

//Text formatting, font and codepage handling for the emulated ESC/P printer.
//Split from BXEmulatedPrinter.mm, which keeps the bytestream interpreter and
//page/print-session plumbing.

#import "BXEmulatedPrinterPrivate.h"
#import "BXCoalface.h"
#import "printer_charmaps.h"

@implementation BXEmulatedPrinter (BXFormatting)

#pragma mark -
#pragma mark Formatting

- (void) setBold: (BOOL)flag
{
    if (self.bold != flag)
    {
        _bold = flag;
        _textAttributesNeedUpdate = YES;
    }
}

- (void) setItalic: (BOOL)flag
{
    if (self.italic != flag)
    {
        _italic = flag;
        _textAttributesNeedUpdate = YES;
    }
}

- (void) setCondensed: (BOOL)flag
{
    if (self.condensed != flag)
    {
        _condensed = flag;
        self.characterAdvance = BXCharacterAdvanceAuto;
        _textAttributesNeedUpdate = YES;
    }
}

- (void) setFontPitch: (BXESCPFontPitch)pitch
{
    if (self.fontPitch != pitch)
    {
        _fontPitch = pitch;
        self.characterAdvance = BXCharacterAdvanceAuto;
        _textAttributesNeedUpdate = YES;
    }
}

- (void) setSubscript: (BOOL)flag
{
    if (self.subscript != flag)
    {
        _subscript = flag;
        _textAttributesNeedUpdate = YES;
    }
}

- (void) setSuperscript: (BOOL)flag
{
    if (self.superscript != flag)
    {
        _superscript = flag;
        _textAttributesNeedUpdate = YES;
    }
}

- (void) setMultipointEnabled: (BOOL)enable
{
    if (enable != self.multipointEnabled)
    {
        //If no multipoint pitch or size have been specified yet,
        //inherit them now from the fixed-point pitch and font size.
        if (enable)
        {
            if (_multipointFontPitch == 0)
                _multipointFontPitch = (CGFloat)self.fontPitch;
            
            if (_multipointFontSize == 0)
                self.multipointFontSize = BXESCPBaseFontSize;
            
            self.characterAdvance = BXCharacterAdvanceAuto;
        }
        
        _multipointEnabled = enable;
        _textAttributesNeedUpdate = YES;
    }
}

- (void) setLetterSpacing: (double)spacing
{
    _letterSpacing = spacing;
    self.characterAdvance = BXCharacterAdvanceAuto;
}

- (void) setDoubleWidth: (BOOL)flag
{
    if (self.doubleWidth != flag)
    {
        _doubleWidth = flag;
        self.characterAdvance = BXCharacterAdvanceAuto;
        _textAttributesNeedUpdate = YES;
    }
}

- (void) setDoubleHeight: (BOOL)flag
{
    if (self.doubleHeight != flag)
    {
        _doubleHeight = flag;
        _textAttributesNeedUpdate = YES;
    }
}

- (void) setDoubleWidthForLine: (BOOL)flag
{
    if (self.doubleWidthForLine != flag)
    {
        _doubleWidthForLine = flag;
        self.characterAdvance = BXCharacterAdvanceAuto;
        _textAttributesNeedUpdate = YES;
    }
}

- (void) setColor: (BXESCPColor)color
{
    if (BXESCPColorBlack < 0 || color > BXESCPColorGreen)
        color = BXESCPColorBlack;
    
    if (self.color != color)
    {
        _color = color;
        _textAttributesNeedUpdate = YES;
    }
}

- (void) setUnderlined: (BOOL)flag
{
    if (self.underlined != flag)
    {
        _underlined = flag;
        _textAttributesNeedUpdate = YES;
    }
}

- (void) setOverscored: (BOOL)flag
{
    if (self.overscored != flag)
    {
        _overscored = flag;
        _textAttributesNeedUpdate = YES;
    }
}

- (void) setLinethroughed: (BOOL)flag
{
    if (self.linethroughed != flag)
    {
        _linethroughed = flag;
        _textAttributesNeedUpdate = YES;
    }
}

- (void) setFontTypeface: (BXESCPTypeface)typeface
{
    switch (typeface)
    {
        case BXESCPTypefaceRoman:
        case BXESCPTypefaceSansSerif:
        case BXESCPTypefaceCourier:
        case BXESCPTypefacePrestige:
        case BXESCPTypefaceScript:
        case BXESCPTypefaceOCRB:
        case BXESCPTypefaceOCRA:
        case BXESCPTypefaceOrator:
        case BXESCPTypefaceOratorS:
        case BXESCPTypefaceScriptC:
        case BXESCPTypefaceRomanT:
        case BXESCPTypefaceSansSerifH:
        case BXESCPTypefaceSVBusaba:
        case BXESCPTypefaceSVJittra:
            _fontTypeface = (BXESCPTypeface)typeface;
            _textAttributesNeedUpdate = YES;
            break;
        default:
            break;
    }
}

- (void) _updateTextAttributes
{
    NSFontDescriptor *fontDescriptor = [self.class _fontDescriptorForEmulatedTypeface: self.fontTypeface
                                                                                 bold: self.bold
                                                                               italic: self.italic];
    
    //Work out the effective horizontal and vertical scale we need for the text.
    NSSize fontSize;
	if (self.multipointEnabled)
    {
        fontSize = NSMakeSize(self.multipointFontSize, self.multipointFontSize);
        _effectivePitch = self.multipointFontPitch;
        //TODO: apply width scaling to characters based on pitch?
    }
    else
    {
        _effectivePitch = (double)self.fontPitch;
        
        if (self.condensed)
        {
            if (self.proportional)
            {
                //Proportional condensed fonts are 50% of the width of standard fonts.
                _effectivePitch *= 2;
            }
            else if (self.fontPitch == BXFontPitch10CPI)
            {
                _effectivePitch = 17.14;
            }
            else if (self.fontPitch == BXFontPitch12CPI)
            {
                _effectivePitch = 20.0;
            }
            //15cpi pitch does not support condensed mode: evidently it's condensed enough already
        }
        
        //Start with a base font size of 10.5pts for non-multipoint characters.
        //This may then be scaled horizontally and/or vertically depending on the current font settings.
        fontSize = NSMakeSize(10.5, 10.5);
        fontSize.width *= ((double)BXFontPitch10CPI / _effectivePitch);
        //IMPLEMENTATION NOTE: there's no indication from the ESC/P docs that 10cpi, 12cpi and 15cpi fonts
        //differ in height: only in width.
        //fontSize.height *= (BXFontPitch10CPI / (CGFloat)self.fontPitch);
        
        //Apply double-width and double-height printing if desired
        if (self.doubleWidth || self.doubleWidthForLine)
        {
            fontSize.width *= 2.0;
            _effectivePitch *= 0.5;
        }
        if (self.doubleHeight)
        {
            fontSize.height *= 2.0;
        }
	}
    
    //Shrink superscripted and subscripted characters to 2/3rds their normal size,
    //unless we're below the minimum font-size threshold.
    if ((self.superscript || self.subscript) && fontSize.height > BXESCPSubscriptMinFontSize)
    {
        fontSize.width *= BXESCPSubscriptScale;
        fontSize.height *= BXESCPSubscriptScale;
        _effectivePitch /= BXESCPSubscriptScale;
    }
    
    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform scaleXBy: fontSize.width yBy: fontSize.height];
    
    //Apply the basic text attributes
    NSFont *font = [NSFont fontWithDescriptor: fontDescriptor textTransform: transform];
    NSColor *color = [self.class _colorForColorCode: self.color];
    
    self.textAttributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           font, NSFontAttributeName,
                           color, NSForegroundColorAttributeName,
                           nil];
    
    //Apply underlining and strikethroughing
    NSUnderlineStyle strikeStyle = NSUnderlineStyleNone;
    switch (self.lineStyle)
    {
        case BXESCPLineStyleSingle:
            strikeStyle |= NSUnderlineStyleSingle;
            break;
        case BXESCPLineStyleDouble:
            strikeStyle |= NSUnderlineStyleDouble;
            break;
        case BXESCPLineStyleBroken:
            strikeStyle |= NSUnderlineStyleSingle | NSUnderlineStylePatternDash;
            break;
        case BXESCPLineStyleDoubleBroken:
            strikeStyle |= NSUnderlineStyleDouble | NSUnderlineStylePatternDash;
            break;
    }
    
    if (self.underlined)
    {
        [self.textAttributes setObject: @(strikeStyle)
                                forKey: NSUnderlineStyleAttributeName];
    }
    
    if (self.linethroughed)
    {
        [self.textAttributes setObject: @(strikeStyle)
                                forKey: NSStrikethroughStyleAttributeName];
    }
    
    if (self.overscored)
    {
        //UNIMPLEMENTED: Cocoa's text attributes don't support overlining
    }
    
    //Apply super/subscripting
    if (self.superscript || self.subscript)
    {
        CGFloat offset = (self.superscript) ? -1 : 1;
        [self.textAttributes setObject: @(offset)
                                forKey: NSSuperscriptAttributeName];
    }
    
    _textAttributesNeedUpdate = NO;
}

+ (NSFontDescriptor *) _fontDescriptorForEmulatedTypeface: (BXESCPTypeface)typeface
                                                     bold: (BOOL)bold
                                                   italic: (BOOL)italic
{
    NSFontDescriptorSymbolicTraits traits = 0;
    if (bold) traits |= NSFontDescriptorTraitBold;
    if (italic) traits |= NSFontDescriptorTraitItalic;
    
    NSString *familyName = nil;
    switch (typeface)
    {
        case BXESCPTypefaceOCRA:
        case BXESCPTypefaceOCRB:
            familyName = @"OCR A Std";
            break;
            
        case BXESCPTypefaceCourier:
            familyName = @"Courier";
            break;
            
        case BXESCPTypefaceScript:
        case BXESCPTypefaceScriptC:
            familyName = @"Brush Script MT";
            break;
            
        case BXESCPTypefaceSansSerif:
        case BXESCPTypefaceSansSerifH:
            familyName = @"Helvetica Neue";
            break;
            
        case BXESCPTypefaceRoman:
        case BXESCPTypefaceRomanT:
        default:
            familyName = @"Times New Roman";
            break;
    }
    
    NSDictionary *traitDict = [NSDictionary dictionaryWithObject: @(traits)
                                                          forKey: NSFontSymbolicTrait];
    
    NSMutableDictionary *attribs = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    traitDict, NSFontTraitsAttribute,
                                    nil];
    
    if (familyName)
        [attribs setObject: familyName forKey: NSFontFamilyAttribute];
    
    NSFontDescriptor *partialDescriptor = [NSFontDescriptor fontDescriptorWithFontAttributes: attribs];
    
    //First try looking up by family name and traits
    NSFontDescriptor *matchedDescriptor = [partialDescriptor matchingFontDescriptorWithMandatoryKeys: [NSSet setWithObjects: NSFontFamilyAttribute, NSFontTraitsAttribute, nil]];
    
    //If that fails, look up by family name alone
    if (matchedDescriptor == nil)
    {
        NSLog(@"Family name %@ and traits %i not matched, falling back on family name alone", familyName, traits);
        matchedDescriptor = [partialDescriptor matchingFontDescriptorWithMandatoryKeys: [NSSet setWithObjects: NSFontFamilyAttribute, nil]];
    }
    
    //If that fails, look up by traits alone
    if (matchedDescriptor == nil)
    {
        NSLog(@"Family name %@ alone not matched, falling back on traits %i", familyName, traits);
        matchedDescriptor = [matchedDescriptor matchingFontDescriptorWithMandatoryKeys: [NSSet setWithObject: NSFontTraitsAttribute]];
    }
    
    else
    {
        //TODO: fall back on some failsafe font descriptor here
    }
    
    return matchedDescriptor;
}



#pragma mark -
#pragma mark Character mapping

- (void) _selectCodepage: (NSUInteger)codepage
{
    const uint16_t *mapToUse = [self.class _charmapForCodepage: codepage];
    
    if (mapToUse == NULL)
    {
        //If we have no matching map for this codepage then fall back on CP437,
        //which we know we have a map for.
        NSLog(@"Unsupported codepage %lu. Using CP437 instead.", (unsigned long)codepage);
        mapToUse = [self.class _charmapForCodepage: 437];
    }
    
    //Copy the bytes from the charmap we're using, rather than just using a pointer
    //to that charmap. This is because certain ESC/P commands will overwrite charmap data.
    memcpy(_charMap, mapToUse, sizeof(unichar)*256);
}

- (void) setActiveCharTable: (BXESCPCharTable)charTable
{
    if (_activeCharTable != charTable)
    {
        _activeCharTable = charTable;
        [self _selectCodepage: self.activeCodepage];
    }
}

- (NSUInteger) activeCodepage
{
    return _charTables[_activeCharTable];
}

- (void) _assignCodepage: (NSUInteger)codepage
             toCharTable: (BXESCPCharTable)charTable
{
    _charTables[charTable] = codepage;
    
    if (charTable == self.activeCharTable)
        [self _selectCodepage: codepage];
}

- (void) _selectInternationalCharset: (BXESCPCharset)charsetID
{
    NSUInteger charsetIndex = charsetID;
    if (charsetIndex == BXESCPCharsetLegal)
        charsetIndex = 14;
    
    if (charsetIndex <= 14)
    {
        const uint16_t *charsetChars = intCharSets[charsetIndex];
        
        //Replace certain codepoints in our ASCII->Unicode mapping table with
        //the characters appropriate for the specified international charset.
        const uint8_t charAddresses[12] = { 0x23, 0x24, 0x40, 0x5b, 0x5c, 0x5d, 0x5e, 0x60, 0x7b, 0x7c, 0x7d, 0x7e };
        for (NSInteger i=0; i<12; i++)
        {
            _charMap[charAddresses[i]] = charsetChars[i];
        }
    }
}



@end
