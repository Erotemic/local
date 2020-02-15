def sager_install_drivers(m):
    sager_dir = m.installer_dir + "\\Sager Driver Unzip"
    sager_install_list = [
        '01Camera\\setup.exe',
        '02Chipset\\Setup.exe',
        '02Video64\\INTEL\\Setup.exe',
        '02Video64\\NVIDIA\\setup.exe',
        '02WLAN\\RTL8188CE\\WLAN\\Setup.exe',
        '03Lan\\setup.exe',
        '04CReader\\setup.exe',
        '05Touchpad\\Setup.exe',
        '06Hotkey\\setup.exe',
        '06IR_Storage\\setup.exe',
        '07IR_Start\\setup.exe',
        '07USB30\\Setup.exe',
        '08IME\\Setup.exe',
        '08XTU\\Setup.exe',
        '64bit\\setup.exe'
    ]
    for to_install in sager_install_list:
        submodule.call(to_install)
        import ctypes
        MessageBox = ctypes.windll.user32.MessageBoxA
        MessageBox(None, 'Done installing Sager Stuff', 'DONE', 0)
