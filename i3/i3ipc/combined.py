# ./workspace_manager.py
import math

class VisitedWorkspaces:
    def __init__(self, previous, current):
        self.previous = previous
        self.current = current

    def update(self, previous, current):
        self.previous = previous
        self.current = current

    def __str__(self):
        return f"current: {self.current.name}, previous: {self.previous.name}"

class WorkspaceManager:
    def __init__(self, i3, utils, no_dynamic):
        self.i3 = i3
        self.utils = utils
        self.no_dynamic = no_dynamic
        self.history = {}
        self.num_columns = 1

    async def initialize(self):
        self.focused_monitor = await self.utils.get_focused_monitor()
        focused_workspace = await self.utils.get_focused_workspace_object()
        if self.focused_monitor and focused_workspace:
            self.history[self.focused_monitor] = VisitedWorkspaces(focused_workspace, focused_workspace)

    async def track_workspace(self, i3, event):
        mon = await self.utils.get_focused_monitor()

        if mon:

            # if the focus is currently on monitor A, and we switch to a different
            # workspace on monitor A, we should update the history
            if self.focused_monitor == mon:
                if event.old and event.old.name != "__i3_scratch":
                    self.history[self.focused_monitor].update(event.old, event.current)
                    self.focused_workspace = event.current

            # if the focus is on monitor A, but we switch the focus to a workspace on monitor B
            # other than the one that is currently on focus on monitor B, then we should also update
            # the history
            else:
                self.focused_monitor = mon

                if mon in self.history:
                    focused_workspace = self.history[self.focused_monitor].current
                    if event.current.name != focused_workspace.name:
                        self.history[self.focused_monitor].update(focused_workspace, event.current)
                else:
                    self.history[self.focused_monitor] = VisitedWorkspaces(event.old, event.current)

    async def go_to_previous_workspace(self):
        if self.focused_monitor in self.history:
            prev = self.history[self.focused_monitor].previous.name
            await self.utils.command(f"workspace {prev}")

    async def setup_new_workspace(self, ws):
        windows = [w for w in ws.leaves() if w.window and w.floating not in ["user_on", "auto_on"]]
        if not windows:
            return
        if len(windows) == 1:
            await ws.command("split h")
        elif len(windows) == 2:
            for window in windows:
                await window.command("split v")
            self.num_columns = 2

    async def fix_workspace_on_removing_window(self, focus_win, focus_ws, windows):
        if not windows:
            return
        self.num_columns = math.floor(focus_ws.rect.width / focus_win.rect.width)
        if len(windows) == 1:
            await windows[0].command("split h")
        elif len(windows) > 1:
            container = windows[0].parent
            if container.layout == "splitv" and container.leaves()[-1] == windows[-1]:
                await windows[0].command("move left")
                await windows[0].command("split v")

    async def on_window_new(self, i3, event):
        focus_ws = await self.utils.get_focused_workspace_object()
        if focus_ws and focus_ws.name not in self.no_dynamic:
            await self.setup_new_workspace(focus_ws)

    async def on_window_close(self, i3, event):
        focus_win, focus_ws = await self.utils.get_focused_window_and_workspace_objects()
        if focus_ws and focus_ws.name not in self.no_dynamic:
            windows = [w for w in focus_ws.leaves() if w.window and w.floating not in ["user_on", "auto_on"]]
            await self.fix_workspace_on_removing_window(focus_win, focus_ws, windows)

    async def on_window_move(self, i3, event):
        if event.container.scratchpad_state == "changed":
            return
        focus_win, focus_ws = await self.utils.get_focused_window_and_workspace_objects()
        if focus_ws and focus_ws.name not in self.no_dynamic and focus_win.floating == "auto_off":
            new_cols = math.floor(focus_ws.rect.width / focus_win.rect.width)
            if event.container and event.container.layout == "splith" and new_cols > self.num_columns:
                await event.container.command("splitv")
            self.num_columns = new_cols
            tree = await self.utils.get_tree()
            dest_ws = tree.find_by_id(event.container.id).workspace()
            await self.setup_new_workspace(dest_ws)
            if new_cols == 1 and focus_ws.descendants():
                await focus_ws.descendants()[-1].command("splith")


# ./utils.py
import json
import functools
import time
import i3ipc

def async_debounce(wait):
    def decorator(fn):
        last_call = 0
        @functools.wraps(fn)
        async def wrapper(*args, **kwargs):
            nonlocal last_call
            now = time.time()
            if now - last_call < wait:
                return
            last_call = now
            return await fn(*args, **kwargs)
        return wrapper
    return decorator

class Utils:
    def __init__(self, i3):
        self.i3 = i3

    def i3_synchronous(self):
        return i3ipc.Connection()

    async def command(self, cmd):
        try:
            return await self.i3.command(cmd)
        except (AssertionError) as e:
            print("Running command synchronously due to error:", e)
            self.i3_synchronous().command(cmd)

    async def get_tree(self):
        try:
            return await self.i3.get_tree()
        except (json.JSONDecodeError, Exception) as e:
            print("Getting tree synchronously due to error:", e)
            self.i3_synchronous().get_tree()

    async def get_focused_window_object(self):
        tree = await self.get_tree()
        return tree.find_focused()

    async def get_focused_workspace_object(self):
        focused = await self.get_focused_window_object()
        if focused:
            return focused.workspace()
        return None

    async def get_focused_window_and_workspace_objects(self):
        focused = await self.get_focused_window_object()
        if focused:
            return focused, focused.workspace()
        return None, None

    async def get_focused_monitor(self):
        node = await self.get_focused_window_object()
        if node:
            while node.type != 'output' and node.parent:
                node = node.parent
            if node.type == 'output':
                return node.name
        return None


# ./combined.py


# ./config.py
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
        # "command": "/home/medwatt/Applications/bin/inkscape",
        "command": "inkscape",
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
        "wm_classes": ["mogan"],
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


# ./app_manager.py
from utils import Utils
from config import APP_GROUPS, APPLICATIONS, COMMON_DIRECTORIES

class AppManager:
    def __init__(self, i3, utils):
        self.i3 = i3
        self.utils = utils
        self.scratchpad_flag = False

    async def launch_app(self, name):
        if name in APPLICATIONS:
            cmd = APPLICATIONS[name]["command"]
            await self.utils.command(f"exec {cmd}")

    async def launch_in_named_workspace(self, key):
        if key in APP_GROUPS:
            await self.utils.command(f"workspace {key}")
            wm_classes = APP_GROUPS[key]["wm_classes"]
            ws = await self.utils.get_focused_workspace_object()
            if ws and not any(win.window_class in wm_classes for win in ws.leaves()):
                await self.utils.command(f"exec {APP_GROUPS[key]['command']}")
        else:
            await self.utils.command(f"workspace {key}")

    async def launch_dolphin(self, key):
        dolphin_ws = "E"
        await self.utils.command(f"workspace {dolphin_ws}")
        if key in COMMON_DIRECTORIES:
            if key == dolphin_ws:
                focused = await self.utils.get_focused_window_object()
                ws = focused.workspace() if focused else None
                if ws and not ws.leaves():
                    await self.utils.command("exec XDG_CURRENT_DESKTOP=KDE dolphin")
            else:
                directory = COMMON_DIRECTORIES[key]
                await self.utils.command(f"exec XDG_CURRENT_DESKTOP=KDE dolphin --select {directory}/.directory")

    async def toggle_application(self, class_name, cmd):
        mark = f"sc_{class_name}"
        tree = await self.utils.get_tree()
        windows = tree.find_marked(mark)
        if windows:
            await self.utils.command(f"[con_mark={mark}] scratchpad show")
        else:
            self.scratchpad_flag = True
            await self.utils.command(f"exec {cmd}")
            async def on_window(i3, event):
                if event.container.window_class == class_name:
                    win_id = event.container.window
                    cmds = (
                        f"[id={win_id}] floating enable",
                        "mark " + mark,
                        "resize set 1000 px 800 px",
                        "move position center",
                        "border pixel 5",
                        "move scratchpad",
                        "scratchpad show",
                    )
                    await self.utils.command(",".join(cmds))
                    self.i3.off(on_window)
            self.i3.on("window::new", on_window)


# ./main_i3ipc.py
#!/usr/bin/python3

import asyncio
from i3ipc.aio import Connection
from i3ipc import Event

from workspace_manager import WorkspaceManager
from app_manager import AppManager
from display_manager import DisplayManager
from utils import Utils
from config import NO_DYNAMIC_TILING_WORKSPACES


class I3Controller:
    def __init__(self, no_dynamic):
        self.no_dynamic = no_dynamic

    async def run(self):
        self.i3 = await Connection(auto_reconnect=True).connect()
        self.utils = Utils(self.i3)
        await self.initalize_display_manager()
        await self.initalize_workspace_manager()
        self.app_mgr = AppManager(self.i3, self.utils)
        self.i3.on(Event.BINDING, self.on_binding)
        await self.i3.main()

    async def initalize_display_manager(self):
        self.display_mgr = DisplayManager(self.i3, self.utils)
        await self.display_mgr.initialize()
        self.i3.on(Event.OUTPUT, self.display_mgr.set_display_mode)

    async def initalize_workspace_manager(self):
        self.workspace_mgr = WorkspaceManager(self.i3, self.utils, self.no_dynamic)
        await self.workspace_mgr.initialize()
        self.i3.on(Event.WORKSPACE_FOCUS, self.workspace_mgr.track_workspace)
        self.i3.on(Event.WINDOW_NEW, self.workspace_mgr.on_window_new)
        self.i3.on(Event.WINDOW_CLOSE, self.workspace_mgr.on_window_close)
        self.i3.on(Event.WINDOW_MOVE, self.workspace_mgr.on_window_move)

    async def on_binding(self, i3, event):
        parts = event.binding.command.split()
        sym = event.binding.symbol.upper()
        if parts[0] != "nop":
            return
        cmd = parts[1]
        if cmd == "mode_launch_app_in_named_workspace":
            await self.app_mgr.launch_in_named_workspace(sym)
        elif cmd == "mode_launch_app":
            await self.app_mgr.launch_app(parts[2])
        elif cmd == "mode_workspace_back_and_forth":
            await self.workspace_mgr.go_to_previous_workspace()
        elif cmd == "mode_toggle_scratchpad":
            await self.app_mgr.toggle_application(parts[2], " ".join(parts[3:]))
        elif cmd.startswith("mode_launch_dolphin"):
            await self.app_mgr.launch_dolphin(sym)
        elif cmd == "mode_choose_display_mode":
            await self.display_mgr.choose_display_mode()


if __name__ == "__main__":
    controller = I3Controller(NO_DYNAMIC_TILING_WORKSPACES)
    asyncio.run(controller.run())


# ./combined_old.py
# ./workspace_manager.py
import math

class VisitedWorkspaces:
    def __init__(self, previous, current):
        self.previous = previous
        self.current = current

    def update(self, previous, current):
        self.previous = previous
        self.current = current

    def __str__(self):
        return f"current: {self.current.name}, previous: {self.previous.name}"

class WorkspaceManager:
    def __init__(self, i3, no_dynamic):
        self.i3 = i3
        self.no_dynamic = no_dynamic
        self.history = {}
        self.num_columns = 1

    async def get_tree(self):
        return await self.i3.get_tree()

    async def get_focused(self):
        tree = await self.get_tree()
        return tree.find_focused()

    async def get_focused_window_and_workspace(self):
        focused = await self.get_focused()
        if focused:
            return focused, focused.workspace()
        return None, None

    async def get_focused_monitor(self):
        node = await self.get_focused()
        if node:
            while node.type != 'output' and node.parent:
                node = node.parent
            if node.type == 'output':
                return node.name
        return None

    async def initialize(self):
        self.focused_monitor = await self.get_focused_monitor()
        _, focused_workspace = await self.get_focused_window_and_workspace()
        if self.focused_monitor and focused_workspace:
            self.history[self.focused_monitor] = VisitedWorkspaces(focused_workspace, focused_workspace)

    # async def track_workspace(self, i3, event):
    #     mon = await self.get_focused_monitor()
    #     if mon:
    #         if mon in self.history and event.old and event.old.name != "__i3_scratch":
    #             self.history[mon].update(event.old, event.current)
    #         else:
    #             self.history[mon] = VisitedWorkspaces(event.old, event.current)
    #             print(self.history)
    #     print(mon, self.history[mon])

    async def track_workspace(self, i3, event):
        mon = await self.get_focused_monitor()

        # if the focus is currently on monitor A, and we switch to a different
        # workspace on monitor A, we should update the history
        if self.focused_monitor == mon:
            if event.old and event.old.name != "__i3_scratch":
                self.history[self.focused_monitor].update(event.old, event.current)
                self.focused_workspace = event.current

        # if the focus is on monitor A, but we switch the focus to a workspace on monitor B
        # other than the one that is currently on focus on monitor B, then we should also update
        # the history
        else:
            self.focused_monitor = mon

            if mon in self.history:
                focused_workspace = self.history[self.focused_monitor].current
                if event.current.name != focused_workspace.name:
                    self.history[self.focused_monitor].update(focused_workspace, event.current)
            else:
                self.history[self.focused_monitor] = VisitedWorkspaces(event.old, event.current)

    async def go_to_previous_workspace(self):
        if self.focused_monitor in self.history:
            prev = self.history[self.focused_monitor].previous.name
            await self.i3.command(f"workspace {prev}")

    async def setup_new_workspace(self, ws):
        windows = [w for w in ws.leaves() if w.window and w.floating not in ["user_on", "auto_on"]]
        if not windows:
            return
        if len(windows) == 1:
            await ws.command("split h")
        elif len(windows) == 2:
            for window in windows:
                await window.command("split v")
            self.num_columns = 2

    async def fix_workspace_on_removing_window(self, focused, ws, windows):
        if not windows:
            return
        self.num_columns = math.floor(ws.rect.width / focused.rect.width)
        if len(windows) == 1:
            await windows[0].command("split h")
        elif len(windows) > 1:
            container = windows[0].parent
            if container.layout == "splitv" and container.leaves()[-1] == windows[-1]:
                await windows[0].command("move left")
                await windows[0].command("split v")

    async def on_window_new(self, i3, event):
        _, ws = await self.get_focused_window_and_workspace()
        if ws and ws.name not in self.no_dynamic:
            await self.setup_new_workspace(ws)

    async def on_window_close(self, i3, event):
        focused, ws = await self.get_focused_window_and_workspace()
        if ws and ws.name not in self.no_dynamic:
            windows = [w for w in ws.leaves() if w.window and w.floating not in ["user_on", "auto_on"]]
            await self.fix_workspace_on_removing_window(focused, ws, windows)

    async def on_window_move(self, i3, event):
        if event.container.scratchpad_state == "changed":
            return
        focused, ws = await self.get_focused_window_and_workspace()
        if ws and ws.name not in self.no_dynamic and focused.floating == "auto_off":
            new_cols = math.floor(ws.rect.width / focused.rect.width)
            if event.container and event.container.layout == "splith" and new_cols > self.num_columns:
                await event.container.command("splitv")
            self.num_columns = new_cols
            tree = await self.get_tree()
            dest_ws = tree.find_by_id(event.container.id).workspace()
            await self.setup_new_workspace(dest_ws)
            if new_cols == 1 and ws.descendants():
                await ws.descendants()[-1].command("splith")


# ./combined.py


# ./config.py
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
        # "command": "/home/medwatt/Applications/bin/inkscape",
        "command": "inkscape",
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
        "wm_classes": ["mogan"],
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


# ./app_manager.py
from config import APP_GROUPS, APPLICATIONS, COMMON_DIRECTORIES

class AppManager:
    def __init__(self, i3):
        self.i3 = i3
        self.scratchpad_flag = False

    async def launch_app(self, name):
        if name in APPLICATIONS:
            cmd = APPLICATIONS[name]["command"]
            await self.i3.command(f"exec {cmd}")

    async def launch_in_named_workspace(self, key, workspace_mgr):
        if key in APP_GROUPS:
            await self.i3.command(f"workspace {key}")
            wm_classes = APP_GROUPS[key]["wm_classes"]
            _, ws = await workspace_mgr.get_focused_window_and_workspace()
            if not any(win.window_class in wm_classes for win in ws.leaves()):
                await self.i3.command(f"exec {APP_GROUPS[key]['command']}")
        else:
            await self.i3.command(f"workspace {key}")

    async def launch_dolphin(self, key):
        dolphin_ws = "E"
        await self.i3.command(f"workspace {dolphin_ws}")
        if key in COMMON_DIRECTORIES:
            if key == dolphin_ws:
                focused = (await self.i3.get_tree()).find_focused()
                ws = focused.workspace() if focused else None
                if ws and not ws.leaves():
                    await self.i3.command("exec XDG_CURRENT_DESKTOP=KDE dolphin")
            else:
                directory = COMMON_DIRECTORIES[key]
                await self.i3.command(f"exec XDG_CURRENT_DESKTOP=KDE dolphin --select {directory}/.directory")

    async def toggle_application(self, class_name, cmd):
        mark = f"sc_{class_name}"
        tree = await self.i3.get_tree()
        windows = tree.find_marked(mark)
        if windows:
            await self.i3.command(f"[con_mark={mark}] scratchpad show")
        else:
            self.scratchpad_flag = True
            await self.i3.command(f"exec {cmd}")
            async def on_window(i3, event):
                if event.container.window_class == class_name:
                    win_id = event.container.window
                    cmds = (
                        f"[id={win_id}] floating enable",
                        "mark " + mark,
                        "resize set 1000 px 800 px",
                        "move position center",
                        "border pixel 5",
                        "move scratchpad",
                        "scratchpad show",
                    )
                    await self.i3.command(",".join(cmds))
                    self.i3.off(on_window)
            self.i3.on("window::new", on_window)


# ./main_i3ipc.py
#!/usr/bin/python3

import asyncio
from i3ipc.aio import Connection
from i3ipc import Event

from workspace_manager import WorkspaceManager
from app_manager import AppManager
from display_manager import DisplayManager
from config import NO_DYNAMIC_TILING_WORKSPACES


class I3Controller:
    def __init__(self, no_dynamic):
        self.no_dynamic = no_dynamic

    async def run(self):
        self.i3 = await Connection(auto_reconnect=True).connect()
        await self.initalize_display_manager()
        await self.initalize_workspace_manager()
        self.app_mgr = AppManager(self.i3)
        self.i3.on(Event.BINDING, self.on_binding)
        await self.i3.main()

    async def initalize_display_manager(self):
        self.display_mgr = DisplayManager()
        await self.display_mgr.initialize()
        self.i3.on(Event.OUTPUT, self.display_mgr.set_display_mode)

    async def initalize_workspace_manager(self):
        self.workspace_mgr = WorkspaceManager(self.i3, self.no_dynamic)
        await self.workspace_mgr.initialize()
        self.i3.on(Event.WORKSPACE_FOCUS, self.workspace_mgr.track_workspace)
        self.i3.on(Event.WINDOW_NEW, self.workspace_mgr.on_window_new)
        self.i3.on(Event.WINDOW_CLOSE, self.workspace_mgr.on_window_close)
        self.i3.on(Event.WINDOW_MOVE, self.workspace_mgr.on_window_move)

    async def on_binding(self, i3, event):
        parts = event.binding.command.split()
        sym = event.binding.symbol.upper()
        if parts[0] != "nop":
            return
        cmd = parts[1]
        if cmd == "mode_launch_app_in_named_workspace":
            await self.app_mgr.launch_in_named_workspace(sym, self.workspace_mgr)
        elif cmd == "mode_launch_app":
            await self.app_mgr.launch_app(parts[2])
        elif cmd == "mode_workspace_back_and_forth":
            await self.workspace_mgr.go_to_previous_workspace()
        elif cmd == "mode_toggle_scratchpad":
            await self.app_mgr.toggle_application(parts[2], " ".join(parts[3:]))
        elif cmd.startswith("mode_launch_dolphin"):
            await self.app_mgr.launch_dolphin(sym)
        elif cmd == "mode_choose_display_mode":
            await self.display_mgr.choose_display_mode()


if __name__ == "__main__":
    controller = I3Controller(NO_DYNAMIC_TILING_WORKSPACES)
    asyncio.run(controller.run())


# ./display_manager.py
import time
import asyncio
import functools

def async_debounce(wait):
    def decorator(fn):
        last_call = 0
        @functools.wraps(fn)
        async def wrapper(*args, **kwargs):
            nonlocal last_call
            now = time.time()
            if now - last_call < wait:
                return
            last_call = now
            return await fn(*args, **kwargs)
        return wrapper
    return decorator

class DisplayManager:
    def __init__(self):
        self.allow_set_display_mode = True
        self.is_display_mode_extended = True
        self.monitors = []

    async def initialize(self):
        await self.set_display_mode(None, None)

    @async_debounce(1)
    async def set_display_mode(self, i3, event):
        await self.get_connected_monitors()
        if self.allow_set_display_mode:
            if len(self.monitors) == 1:
                await self.run_xrandr("xrandr --auto")
            else:
                await self.extend_displays()
        else:
            self.allow_set_display_mode = True
        await self.set_wallpaper()
        await self.launch_polybar()

    async def get_connected_monitors(self):
        proc = await asyncio.create_subprocess_shell(
            "xrandr",
            stdout=asyncio.subprocess.PIPE
        )
        stdout, _ = await proc.communicate()
        output = stdout.decode().splitlines()
        self.monitors = [line.split()[0] for line in output if " connected" in line]

    async def choose_display_mode(self):
        self.allow_set_display_mode = False
        menu = "Clone displays\nExtend displays\nSet primary display"
        choice = await self.run_rofi(menu)
        if choice == "Clone displays":
            await self.clone_displays()
        elif choice == "Extend displays":
            await self.extend_displays()
        elif choice == "Set primary display":
            await self.set_primary_display()
        else:
            await self.show_notification("No valid option chosen. Defaulting to extend mode.")
            await self.extend_displays()

    async def clone_displays(self):
        self.is_display_mode_extended = False
        primary = self.monitors[0]
        cmd = f"xrandr --output {primary} --auto --primary"
        for display in self.monitors[1:]:
            cmd += f" --output {display} --auto --same-as {primary}"
        await self.run_xrandr(cmd)

    async def extend_displays(self):
        primary = self.monitors[0]
        cmd = f"xrandr --output {primary} --auto --primary"
        for display in self.monitors[1:]:
            cmd += f" --output {display} --auto --right-of {primary}"
        await self.run_xrandr(cmd)

    async def set_primary_display(self):
        options = "\n".join(self.monitors)
        choice = await self.run_rofi(options)
        if choice in self.monitors:
            primary = choice
            cmd = f"xrandr --output {primary} --auto --primary"
            for display in self.monitors:
                if display != primary:
                    cmd += f" --output {display} --auto --right-of {primary}"
            await self.run_xrandr(cmd)
        else:
            await self.show_notification("Invalid input. No changes made.")

    async def run_xrandr(self, cmd):
        proc = await asyncio.create_subprocess_shell(cmd)
        await proc.wait()

    async def run_rofi(self, options):
        proc = await asyncio.create_subprocess_shell(
            f"echo -e '{options}' | rofi -dmenu -p 'Choose display mode:'",
            stdout=asyncio.subprocess.PIPE
        )
        stdout, _ = await proc.communicate()
        return stdout.decode().strip()

    async def show_notification(self, message):
        await asyncio.create_subprocess_shell(f"notify-send 'Display Setup' '{message}'")

    async def set_wallpaper(self):
        wallpaper = "/home/medwatt/Pictures/astro.jpg"
        cmd = f"feh --bg-fill {wallpaper}"
        await asyncio.create_subprocess_shell(
            cmd,
            stdout=asyncio.subprocess.DEVNULL,
            stderr=asyncio.subprocess.DEVNULL
        )

    async def launch_polybar(self):
        proc = await asyncio.create_subprocess_exec("killall", "-q", "polybar")
        await proc.wait()
        monitors = [self.monitors[0]] if not self.is_display_mode_extended else self.monitors
        for m in monitors:
            cmd = f"MONITOR={m} polybar --reload top"
            await asyncio.create_subprocess_shell(
                cmd,
                stdout=asyncio.subprocess.DEVNULL,
                stderr=asyncio.subprocess.DEVNULL
            )
        self.is_display_mode_extended = True




# ./display_manager.py
import asyncio
from utils import async_debounce

class DisplayManager:
    def __init__(self, i3, utils):
        self.i3 = i3
        self.utils = utils
        self.allow_set_display_mode = True
        self.is_display_mode_extended = True
        self.monitors = []

    async def initialize(self):
        await self.set_display_mode(None, None)

    async def get_connected_monitors(self):
        proc = await asyncio.create_subprocess_shell(
            "xrandr",
            stdout=asyncio.subprocess.PIPE
        )
        stdout, _ = await proc.communicate()
        output = stdout.decode().splitlines()
        self.monitors = [line.split()[0] for line in output if " connected" in line]

    @async_debounce(1)
    async def set_display_mode(self, i3, event):
        await self.get_connected_monitors()
        if self.allow_set_display_mode:
            if len(self.monitors) == 1:
                await self.run_xrandr("xrandr --auto")
            else:
                await self.extend_displays()
        else:
            self.allow_set_display_mode = True
        await self.set_wallpaper()
        await self.launch_polybar()

    async def choose_display_mode(self):
        self.allow_set_display_mode = False
        menu = "Clone displays\nExtend displays\nSet primary display"
        choice = await self.run_rofi(menu)
        if choice == "Clone displays":
            await self.clone_displays()
        elif choice == "Extend displays":
            await self.extend_displays()
        elif choice == "Set primary display":
            await self.set_primary_display()
        else:
            await self.show_notification("No valid option chosen. Defaulting to extend mode.")
            await self.extend_displays()

    async def clone_displays(self):
        self.is_display_mode_extended = False
        primary = self.monitors[0]
        cmd = f"xrandr --output {primary} --auto --primary"
        for display in self.monitors[1:]:
            cmd += f" --output {display} --auto --same-as {primary}"
        await self.run_xrandr(cmd)

    async def extend_displays(self):
        primary = self.monitors[0]
        cmd = f"xrandr --output {primary} --auto --primary"
        for display in self.monitors[1:]:
            cmd += f" --output {display} --auto --right-of {primary}"
        await self.run_xrandr(cmd)

    async def set_primary_display(self):
        options = "\n".join(self.monitors)
        choice = await self.run_rofi(options)
        if choice in self.monitors:
            primary = choice
            cmd = f"xrandr --output {primary} --auto --primary"
            for display in self.monitors:
                if display != primary:
                    cmd += f" --output {display} --auto --right-of {primary}"
            await self.run_xrandr(cmd)
        else:
            await self.show_notification("Invalid input. No changes made.")

    async def run_xrandr(self, cmd):
        proc = await asyncio.create_subprocess_shell(cmd)
        await proc.wait()

    async def run_rofi(self, options):
        proc = await asyncio.create_subprocess_shell(
            f"echo -e '{options}' | rofi -dmenu -p 'Choose display mode:'",
            stdout=asyncio.subprocess.PIPE
        )
        stdout, _ = await proc.communicate()
        return stdout.decode().strip()

    async def show_notification(self, message):
        await asyncio.create_subprocess_shell(f"notify-send 'Display Setup' '{message}'")

    async def set_wallpaper(self):
        wallpaper = "/home/medwatt/Pictures/astro.jpg"
        cmd = f"feh --bg-fill {wallpaper}"
        await asyncio.create_subprocess_shell(
            cmd,
            stdout=asyncio.subprocess.DEVNULL,
            stderr=asyncio.subprocess.DEVNULL
        )

    async def launch_polybar(self):
        proc = await asyncio.create_subprocess_exec("killall", "-q", "polybar")
        await proc.wait()
        monitors = [self.monitors[0]] if not self.is_display_mode_extended else self.monitors
        for m in monitors:
            cmd = f"MONITOR={m} polybar --reload top"
            await asyncio.create_subprocess_shell(
                cmd,
                stdout=asyncio.subprocess.DEVNULL,
                stderr=asyncio.subprocess.DEVNULL
            )
        self.is_display_mode_extended = True


