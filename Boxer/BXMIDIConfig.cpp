//
//  BXMIDIConfig.cpp
//  Boxer
//
//  Created by C.W. Betts on 2/10/21.
//  Copyright © 2021 Alun Bestor and contributors. All rights reserved.
//

#include "BXMIDIConfig.hpp"
#include "string_utils.h"


static void init_mt32_dosbox_settings(SectionProp &sec_prop)
{
    constexpr auto when_idle = Property::Changeable::WhenIdle;

    auto *str_prop = sec_prop.AddString("ReverseStereo", when_idle, "off");
    str_prop->SetValues({"off", "on"});
    str_prop->SetHelp("Reverse stereo channels for MT-32 output");

    str_prop = sec_prop.AddString("DAC", when_idle, "auto");
    str_prop->SetValues({"0", "1", "2", "3", "auto"});
    str_prop->SetHelp("MT-32 DAC input mode\n"
                      "Nice = 0 - default\n"
                      "Produces samples at double the volume, without tricks.\n"
                      "Higher quality than the real devices\n\n"
                      
                      "Pure = 1\n"
                      "Produces samples that exactly match the bits output from the emulated LA32.\n"
                      "Nicer overdrive characteristics than the DAC hacks (it simply clips samples within range)\n"
                      "Much less likely to overdrive than any other mode.\n"
                      "Half the volume of any of the other modes, meaning its volume relative to the reverb\n"
                      "output when mixed together directly will sound wrong. So, reverb level must be lowered.\n"
                      "Perfect for developers while debugging :)\n\n"
                      
                      "GENERATION1 = 2\n"
                      "Re-orders the LA32 output bits as in early generation MT-32s (according to Wikipedia).\n"
                      "Bit order at DAC (where each number represents the original LA32 output bit number, and XX means the bit is always low):\n"
                      "15 13 12 11 10 09 08 07 06 05 04 03 02 01 00 XX\n\n"
                      
                      "GENERATION2 = 3\n"
                      "Re-orders the LA32 output bits as in later generations (personally confirmed on my CM-32L - KG).\n"
                      "Bit order at DAC (where each number represents the original LA32 output bit number):\n"
                      "15 13 12 11 10 09 08 07 06 05 04 03 02 01 00 14\n\n");
    str_prop = sec_prop.AddString("reverbmode", when_idle, "auto");
    str_prop->SetValues({"0", "1", "2", "3", "auto"});
    str_prop->SetHelp("MT-32 reverb mode");

    auto *int_prop = sec_prop.AddInt("reverbtime", when_idle, 5);
    int_prop->SetValues({"0", "1", "2", "3", "4", "5", "6", "7"});
    int_prop->SetHelp("MT-32 reverb time");

    int_prop = sec_prop.AddInt("reverblevel", when_idle, 3);
    int_prop->SetValues({"0", "1", "2", "3", "4", "5", "6", "7"});
    int_prop->SetHelp("MT-32 reverb level");
}

void BXMIDIMT32_AddConfigSection(Config *conf)
{
    assert(conf);
    SectionProp *sec_prop = conf->AddSection("mt32");
    assert(sec_prop);
    init_mt32_dosbox_settings(*sec_prop);
}
