import WinSDK

// ฟังก์ชัน WindowProc สำหรับจัดการข้อความต่าง ๆ
func WindowProc(hWnd: HWND?, message: UINT, wParam: WPARAM, lParam: LPARAM) -> LRESULT {
    switch message {
    case UINT(WM_DESTROY):
        PostQuitMessage(0)
        return 0
    default:
        return DefWindowProcW(hWnd, message, wParam, lParam)
    }
}

// การแปลงสตริงเป็น wchar_t*
func toWideString(_ string: String) -> UnsafePointer<wchar_t> {
    let wideString = string.utf16.map { UInt16($0) } + [0]
    return wideString.withUnsafeBufferPointer { $0.baseAddress! }
}

// ฟังก์ชันสร้างตัวชี้ทรัพยากร
func MAKEINTRESOURCE(_ id: Int) -> UnsafePointer<wchar_t>? {
    return UnsafePointer(bitPattern: UInt(id))
}

// ชื่อคลาสของหน้าต่าง
let className = "MyWindowClass"
let wideClassName = toWideString(className)

// ลงทะเบียนคลาสของหน้าต่าง
var wc = WNDCLASSW()
wc.lpfnWndProc = WindowProc
wc.hInstance = GetModuleHandleW(nil)
wc.lpszClassName = wideClassName
wc.hCursor = LoadCursorW(nil, MAKEINTRESOURCE(32512)) // ใช้ฟังก์ชัน MAKEINTRESOURCE

// ใช้ GetStockObject และแปลงเป็น HBRUSH
let stockObject = GetStockObject(COLOR_WINDOW)
wc.hbrBackground = unsafeBitCast(stockObject, to: HBRUSH.self)

// ตรวจสอบการลงทะเบียนคลาส
if RegisterClassW(&wc) == 0 {
    fatalError("Failed to register window class")
}

// สร้างหน้าต่าง
let windowName = "Hello, Windows GUI!"
let wideWindowName = toWideString(windowName)
let hWnd = CreateWindowExW(
    0,
    wideClassName,
    wideWindowName,
    DWORD(WS_OVERLAPPEDWINDOW),
    CW_USEDEFAULT,
    CW_USEDEFAULT,
    800,
    600,
    nil,
    nil,
    wc.hInstance,
    nil
)

// ตรวจสอบการสร้างหน้าต่าง
if hWnd == nil {
    fatalError("Failed to create window")
}

// แสดงหน้าต่าง
ShowWindow(hWnd, SW_SHOW)
UpdateWindow(hWnd)

// วนลูปข้อความหลัก
var msg = MSG()
while Bool(GetMessageW(&msg, nil, 0, 0)) {
    TranslateMessage(&msg)
    DispatchMessageW(&msg)
}
