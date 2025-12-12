#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>
#include <string>

#include "flutter_window.h"
#include "utils.h"

// app_links message ID (must match app_links_plugin.h)
#define APPLINK_MSG_ID (WM_USER + 2)

// Unique identifier for this application
static const wchar_t* kAppMutexName = L"FullStop_SingleInstance_Mutex";
static const wchar_t* kWindowClassName = L"FLUTTER_RUNNER_WIN32_WINDOW";
static const wchar_t* kWindowTitle = L"FullStop";

// Callback for EnumWindows to find our window
static HWND g_foundWindow = nullptr;

BOOL CALLBACK EnumWindowsCallback(HWND hwnd, LPARAM lParam) {
  wchar_t className[256];
  wchar_t windowTitle[256];

  if (::GetClassName(hwnd, className, 256) == 0) {
    return TRUE;  // Continue enumeration
  }

  // Check if it's a Flutter window
  if (wcscmp(className, kWindowClassName) != 0) {
    return TRUE;  // Continue enumeration
  }

  // Get window title
  if (::GetWindowText(hwnd, windowTitle, 256) == 0) {
    return TRUE;  // Continue enumeration
  }

  // Check if title matches
  if (wcscmp(windowTitle, kWindowTitle) == 0) {
    g_foundWindow = hwnd;
    return FALSE;  // Stop enumeration
  }

  return TRUE;  // Continue enumeration
}

// Find the existing application window
HWND FindExistingWindow() {
  g_foundWindow = nullptr;
  ::EnumWindows(EnumWindowsCallback, 0);
  return g_foundWindow;
}

// Convert wide string to UTF-8
std::string WideToUtf8(const std::wstring& wstr) {
  if (wstr.empty()) return std::string();
  int size_needed = WideCharToMultiByte(CP_UTF8, 0, &wstr[0], (int)wstr.size(), nullptr, 0, nullptr, nullptr);
  std::string strTo(size_needed, 0);
  WideCharToMultiByte(CP_UTF8, 0, &wstr[0], (int)wstr.size(), &strTo[0], size_needed, nullptr, nullptr);
  return strTo;
}

// Extract the deep link URL from command line
std::string ExtractDeepLink(const wchar_t* cmdLine) {
  if (cmdLine == nullptr) return "";

  std::wstring cmd(cmdLine);

  // Find fullstop:// in the command line
  size_t pos = cmd.find(L"fullstop://");
  if (pos != std::wstring::npos) {
    // Extract from fullstop:// to end or next quote/space
    std::wstring link = cmd.substr(pos);
    // Remove trailing quote if present
    size_t endPos = link.find(L'"');
    if (endPos != std::wstring::npos) {
      link = link.substr(0, endPos);
    }
    // Remove trailing space if present
    endPos = link.find(L' ');
    if (endPos != std::wstring::npos) {
      link = link.substr(0, endPos);
    }
    return WideToUtf8(link);
  }
  return "";
}

// Send deep link to existing instance using app_links format
bool SendDeepLinkToExistingInstance(HWND hwnd, const std::string& deepLink) {
  if (hwnd == nullptr || deepLink.empty()) {
    return false;
  }

  // Bring the existing window to foreground
  ::SetForegroundWindow(hwnd);
  if (::IsIconic(hwnd)) {
    ::ShowWindow(hwnd, SW_RESTORE);
  }

  // Send the deep link via WM_COPYDATA using app_links format
  COPYDATASTRUCT cds = { 0 };
  cds.dwData = APPLINK_MSG_ID;
  cds.cbData = (DWORD)(deepLink.size() + 1);  // Include null terminator
  cds.lpData = (PVOID)deepLink.c_str();

  LRESULT result = ::SendMessage(hwnd, WM_COPYDATA, (WPARAM)hwnd, (LPARAM)&cds);
  return result != 0;
}

// Debug output helper
void DebugLog(const wchar_t* message) {
  OutputDebugStringW(message);
  OutputDebugStringW(L"\n");
}

void DebugLog(const char* message) {
  OutputDebugStringA(message);
  OutputDebugStringA("\n");
}

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  DebugLog(L"[FullStop] Application starting...");
  DebugLog(L"[FullStop] Command line:");
  DebugLog(command_line);

  // Try to create a mutex to ensure single instance
  HANDLE hMutex = ::CreateMutex(nullptr, TRUE, kAppMutexName);
  bool alreadyRunning = (::GetLastError() == ERROR_ALREADY_EXISTS);

  if (alreadyRunning) {
    DebugLog(L"[FullStop] Another instance is already running");

    // Another instance is already running
    // Extract deep link from command line
    std::string deepLink = ExtractDeepLink(command_line);
    DebugLog("[FullStop] Extracted deep link:");
    DebugLog(deepLink.empty() ? "(empty)" : deepLink.c_str());

    // Find the existing window
    HWND existingWindow = FindExistingWindow();
    if (existingWindow != nullptr) {
      DebugLog(L"[FullStop] Found existing window");
      if (!deepLink.empty()) {
        DebugLog(L"[FullStop] Sending deep link to existing instance...");
        // Send deep link to existing instance
        bool sent = SendDeepLinkToExistingInstance(existingWindow, deepLink);
        DebugLog(sent ? L"[FullStop] Deep link sent successfully" : L"[FullStop] Failed to send deep link");
      } else {
        DebugLog(L"[FullStop] No deep link, just bringing window to front");
        // No deep link, just bring existing window to front
        ::SetForegroundWindow(existingWindow);
        if (::IsIconic(existingWindow)) {
          ::ShowWindow(existingWindow, SW_RESTORE);
        }
      }
    } else {
      DebugLog(L"[FullStop] Could not find existing window!");
    }

    // Close mutex handle and exit
    if (hMutex != nullptr) {
      ::CloseHandle(hMutex);
    }
    return EXIT_SUCCESS;
  }

  DebugLog(L"[FullStop] This is the first instance");

  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(kWindowTitle, origin, size)) {
    if (hMutex != nullptr) {
      ::CloseHandle(hMutex);
    }
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();

  // Release the mutex
  if (hMutex != nullptr) {
    ::CloseHandle(hMutex);
  }

  return EXIT_SUCCESS;
}
