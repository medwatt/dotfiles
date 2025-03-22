from config import APP_GROUPS, APPLICATIONS, COMMON_DIRECTORIES

class AppManager:
    def __init__(self, i3, utils):
        self.i3 = i3
        self.utils = utils
        self.scratchpad_flag = False

    def launch_app(self, name):
        if name in APPLICATIONS:
            cmd = APPLICATIONS[name]["command"]
            self.utils.command(f"exec {cmd}")

    def launch_in_named_workspace(self, key):
        if key in APP_GROUPS:
            self.utils.command(f"workspace {key}")
            wm_classes = APP_GROUPS[key]["wm_classes"]
            ws = self.utils.get_focused_workspace_object()
            if ws and not any(win.window_class in wm_classes for win in ws.leaves()):
                self.utils.command(f"exec {APP_GROUPS[key]['command']}")
        else:
            self.utils.command(f"workspace {key}")

    def launch_dolphin(self, key):
        dolphin_ws = "E"
        self.utils.command(f"workspace {dolphin_ws}")
        if key in COMMON_DIRECTORIES:
            if key == dolphin_ws:
                focused = self.utils.get_focused_window_object()
                ws = focused.workspace() if focused else None
                if ws and not ws.leaves():
                    self.utils.command("exec XDG_CURRENT_DESKTOP=KDE dolphin")
            else:
                directory = COMMON_DIRECTORIES[key]
                self.utils.command(f"exec XDG_CURRENT_DESKTOP=KDE dolphin --select {directory}/.directory")

    def toggle_application(self, class_name, cmd):
        mark = f"sc_{class_name}"
        tree = self.utils.get_tree()
        windows = tree.find_marked(mark)
        if windows:
            self.utils.command(f"[con_mark={mark}] scratchpad show")
        else:
            self.scratchpad_flag = True
            self.utils.command(f"exec {cmd}")
            def on_window(i3, event):
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
                    self.utils.command(",".join(cmds))
                    self.i3.off(on_window)
            self.i3.on("window::new", on_window)
