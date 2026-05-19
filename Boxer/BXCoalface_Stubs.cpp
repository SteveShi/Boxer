#include "video.h"
#include "mixer.h"
#include "setup.h"
#include "programs.h"
#include <string>

// GFX Stubs
void GFX_NotifyProgramName(const std::string&, const std::string&) {}
void GFX_SetMouseVisibility(bool) {}
const char* GFX_GetRenderingBackend() { return "opengl"; }
void GFX_NotifyCyclesChanged() {}
void GFX_GetCanvasSizeInPixels(int& w, int& h) { w = 0; h = 0; }
int GFX_GetIntegerScalingMode() { return 0; }
void GFX_SetIntegerScalingMode(int) {}
bool GFX_HaveDesktopEnvironment() { return true; }
void GFX_NotifyAudioMutedStatus(bool) {}
void GFX_GetViewportSizeInPixels(int& w, int& h) { w = 0; h = 0; }
int GFX_GetTextureInterpolationMode() { return 0; }

// CAPTURE Stubs
bool CAPTURE_IsCapturingMidi() { return false; }
bool CAPTURE_IsCapturingAudio() { return false; }
bool CAPTURE_IsCapturingImage() { return false; }
bool CAPTURE_IsCapturingVideo() { return false; }
void CAPTURE_StopVideoCapture() {}
void CAPTURE_StartVideoCapture() {}
void CAPTURE_AddConfigSection(const std::unique_ptr<Config>&) {}

// IMFC Stubs
void IMFC_AddConfigSection(const std::unique_ptr<Config>&) {}

// MAPPER Stubs
void MAPPER_StopAutoTyping() {}

// CSerialMouse Stubs
// Wait, CSerialMouse is a class, we probably just shouldn't compile mouse_interfaces.cpp or program_serial.cpp if they require it?
