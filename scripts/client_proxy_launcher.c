#include <windows.h>
#include <stdio.h>
#include <string.h>

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
    char currentDir[MAX_PATH];
    GetModuleFileNameA(NULL, currentDir, MAX_PATH);
    char *lastSlash = strrchr(currentDir, '\\');
    if (lastSlash) {
        *lastSlash = '\0';
    }

    char targetExe[MAX_PATH];
    char targetDir[MAX_PATH];
    snprintf(targetDir, MAX_PATH, "%s\\vynex_client", currentDir);
    snprintf(targetExe, MAX_PATH, "%s\\vynex_client\\vynex_client.exe", currentDir);

    DWORD attr = GetFileAttributesA(targetExe);
    if (attr == INVALID_FILE_ATTRIBUTES) {
        snprintf(targetExe, MAX_PATH, "D:\\Dabeo\\work\\seminar_rustdk\\rustdesk\\flutter\\build\\windows\\x64\\runner\\Release\\vynex_client.exe");
        snprintf(targetDir, MAX_PATH, "D:\\Dabeo\\work\\seminar_rustdk\\rustdesk\\flutter\\build\\windows\\x64\\runner\\Release");
    }

    char cmdLine[4096];
    if (lpCmdLine && strlen(lpCmdLine) > 0) {
        snprintf(cmdLine, sizeof(cmdLine), "\"%s\" %s", targetExe, lpCmdLine);
    } else {
        snprintf(cmdLine, sizeof(cmdLine), "\"%s\"", targetExe);
    }

    STARTUPINFOA si;
    PROCESS_INFORMATION pi;
    ZeroMemory(&si, sizeof(si));
    si.cb = sizeof(si);
    ZeroMemory(&pi, sizeof(pi));

    if (CreateProcessA(NULL, cmdLine, NULL, NULL, FALSE, 0, NULL, targetDir, &si, &pi)) {
        CloseHandle(pi.hProcess);
        CloseHandle(pi.hThread);
        return 0;
    }

    MessageBoxA(NULL, "Không thể tìm thấy hoặc khởi chạy vynex_client.exe trong thư mục vynex_client!", "Vynex Client Error", MB_ICONERROR);
    return 1;
}
