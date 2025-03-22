import os

HOME = os.path.expanduser("~")
NO_DYNAMIC_TILING_WORKSPACES = ("P", "I", "X", "K")

APPLICATIONS = {
    "btop": {
        "command": "kitty --single-instance --title 'btop' --class kitty_btop btop",
        "properties": [
            "floating enable",
            "resize set 800 800",
            "move position center"
        ]
    },
    "fzf_search": {
        "command": f"kitty --single-instance --title 'File Search' --class 'kitty_fzf' -e '{HOME}/coding/scripts/fzf-menu'",
        "properties": [
            "floating enable",
            "resize set 1200 800",
            "move position center"
        ]
    }
}

APP_GROUPS = {
    "D": {
        "command": "dex /home/medwatt/.local/share/applications/org.goldendict.GoldenDict.desktop",
        "wm_classes": ["Goldendict"],
        "desc": "Launch Goldendict",
    },
    "I": {
        "command": "/home/medwatt/Applications/bin/inkscape",
        # "command": "inkscape",
        "wm_classes": ["Inkscape", "Ld-linux-x86-64.so.2"],
        "desc": "Launch Inkscape",
    },
    "L": {
        "command": "dex /home/medwatt/.local/share/applications/wine/Programs/LTspice/LTspice.desktop",
        "wm_classes": ["ltspice.exe"],
        "desc": "Launch LTSpice",
    },
    "M": {
        "command": "thunderbird",
        "wm_classes": ["thunderbird"],
        "desc": "Launch mail",
    },
    "N": {
        "command": f"kitty --single-instance --class 'kitty_nvim' {HOME}/coding/scripts/nn",
        "wm_classes": ["kitty_nvim"],
        "desc": "Launch neovim",
    },
    "J": {
        "command": "google-chrome-stable --use-gl=desktop --app=http://localhost:8888/lab --enable-extensions",
        "wm_classes": ["Google-chrome", "chrome"],
        "desc": "Launch jupyter",
    },
    "O": {
        "command": "obs",
        "wm_classes": ["obs"],
        "desc": "Launch screen recorder",
    },
    "P": {
        "command": "dex /home/medwatt/.local/share/applications/wine/TrackerSoftware/PDF-XChange-Editor.desktop",
        "wm_classes": ["okular", "pdfxedit.exe"],
        "desc": "Launch pdf viewer",
    },
    "S": {
        "command": "QT_QPA_PLATFORMTHEME=1 XDG_CURRENT_DESKTOP=KDE systemsettings",
        "wm_classes": ["systemsettings5"],
        "desc": "Launch system settings",
    },
    "T": {
        "command": "google-chrome-stable --use-gl=desktop --app=http://deepl.com --enable-extensions",
        "wm_classes": ["Google-chrome", "chrome"],
        "desc": "Launch deepl",
    },
    "U": {
        "command": "vmware",
        "wm_classes": ["Vmware"],
        "desc": "Launch vmware",
    },
    "W": {
        "command": "google-chrome-stable --use-gl=desktop --app=http://web.whatsapp.com --enable-extensions",
        "wm_classes": ["Google-chrome", "chrome"],
        "desc": "Launch whatsapp",
    },
    "X": {
        "command": "/home/medwatt/Applications/extracted/mogan-custom/pkg/mogan-bin-custom/opt/mogan-bin-custom/usr/bin/mogan",
        "wm_classes": ["mogan", "MoganResearch"],
        "desc": "Launch mogan",
    },
    "Z": {
        "command": "zoom",
        "wm_classes": ["zoom"],
        "desc": "Launch zoom",
    },
}

COMMON_DIRECTORIES = {
    "C": f"{HOME}/.config/",
    "D": f"{HOME}/Downloads/",
    "E": "",
    "G": f"{HOME}/git/",
    "H": f"{HOME}/",
    "L": f"{HOME}/.local/",
    "R": f"{HOME}/Recordings/",
    "V": f"{HOME}/Videos/",
    "W": f"{HOME}/Writing/texmacs",
}
