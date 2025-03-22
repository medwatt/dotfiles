#!/usr/bin/python3

from i3ipc import Connection, Event

from workspace_manager import WorkspaceManager
from app_manager import AppManager
from display_manager import DisplayManager
from utils import Utils


class I3Controller:
    def run(self):
        self.i3 = Connection()
        self.utils = Utils(self.i3)
        self.initalize_display_manager()
        self.initalize_workspace_manager()
        self.app_mgr = AppManager(self.i3, self.utils)
        self.i3.on(Event.BINDING, self.on_binding)
        self.i3.main()

    def initalize_display_manager(self):
        self.display_mgr = DisplayManager()
        self.display_mgr.initialize()
        self.i3.on(Event.OUTPUT, self.display_mgr.set_display_mode)

    def initalize_workspace_manager(self):
        self.workspace_mgr = WorkspaceManager(self.i3, self.utils)
        self.workspace_mgr.initialize()
        # self.i3.on(Event.WORKSPACE_FOCUS, self.workspace_mgr.track_workspace)
        self.i3.on(Event.WINDOW_NEW, self.workspace_mgr.on_window_new)
        self.i3.on(Event.WINDOW_CLOSE, self.workspace_mgr.on_window_close)
        self.i3.on(Event.WINDOW_MOVE, self.workspace_mgr.on_window_move)

    def on_binding(self, i3, event):
        parts = event.binding.command.split()
        sym = event.binding.symbol.upper()
        if parts[0] != "nop":
            return
        cmd = parts[1]
        if cmd == "mode_launch_app_in_named_workspace":
            self.app_mgr.launch_in_named_workspace(sym)
        elif cmd == "mode_launch_app":
            self.app_mgr.launch_app(parts[2])
        elif cmd == "mode_workspace_back_and_forth":
            self.workspace_mgr.go_to_previous_workspace()
        elif cmd == "mode_close_all_windows_in_worksapce":
            self.workspace_mgr.close_all_windows_in_workspace()
        elif cmd == "mode_go_to_empty_workspace":
            self.workspace_mgr.go_to_empty_workspace()
        elif cmd == "mode_toggle_scratchpad":
            self.app_mgr.toggle_application(parts[2], " ".join(parts[3:]))
        elif cmd.startswith("mode_launch_dolphin"):
            self.app_mgr.launch_dolphin(sym)
        elif cmd == "mode_choose_display_mode":
            self.display_mgr.choose_display_mode()

if __name__ == "__main__":
    controller = I3Controller()
    controller.run()
