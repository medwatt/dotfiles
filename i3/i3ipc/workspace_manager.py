import math
from config import NO_DYNAMIC_TILING_WORKSPACES

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
    def __init__(self, i3, utils):
        self.i3 = i3
        self.utils = utils
        self.history = {}
        self.num_columns = 1

    def initialize(self):
        self.focused_monitor = self.utils.get_focused_monitor()
        focused_workspace = self.utils.get_focused_workspace_object()
        if self.focused_monitor and focused_workspace:
            self.history[self.focused_monitor] = VisitedWorkspaces(focused_workspace, focused_workspace)

    def track_workspace(self, i3, event):
        mon = self.utils.get_focused_monitor()

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

    def go_to_previous_workspace(self):
        if self.focused_monitor in self.history:
            prev = self.history[self.focused_monitor].previous.name
            self.utils.command(f"workspace {prev}")

    def setup_new_workspace(self, ws):
        windows = [w for w in ws.leaves() if w.window and w.floating not in ["user_on", "auto_on"]]
        if not windows:
            return
        if len(windows) == 1:
            ws.command("split h")
        elif len(windows) == 2:
            for window in windows:
                window.command("split v")
            self.num_columns = 2

    def fix_workspace_on_removing_window(self, focus_win, focus_ws, windows):
        if not windows:
            return
        self.num_columns = math.floor(focus_ws.rect.width / focus_win.rect.width)
        if len(windows) == 1:
            windows[0].command("split h")
        elif len(windows) > 1:
            container = windows[0].parent
            if container.layout == "splitv" and container.leaves()[-1] == windows[-1]:
                windows[0].command("move left")
                windows[0].command("split v")

    def on_window_new(self, i3, event):
        focus_ws = self.utils.get_focused_workspace_object()
        if focus_ws and focus_ws.name not in NO_DYNAMIC_TILING_WORKSPACES:
            self.setup_new_workspace(focus_ws)

    def on_window_close(self, i3, event):
        focus_win, focus_ws = self.utils.get_focused_window_and_workspace_objects()
        if focus_ws and focus_ws.name not in NO_DYNAMIC_TILING_WORKSPACES:
            windows = [w for w in focus_ws.leaves() if w.window and w.floating not in ["user_on", "auto_on"]]
            self.fix_workspace_on_removing_window(focus_win, focus_ws, windows)

    def on_window_move(self, i3, event):
        if event.container.scratchpad_state == "changed":
            return
        focus_win, focus_ws = self.utils.get_focused_window_and_workspace_objects()
        if focus_ws and focus_ws.name not in NO_DYNAMIC_TILING_WORKSPACES and focus_win.floating == "auto_off":
            new_cols = math.floor(focus_ws.rect.width / focus_win.rect.width)
            if event.container and event.container.layout == "splith" and new_cols > self.num_columns:
                event.container.command("splitv")
            self.num_columns = new_cols
            tree = self.utils.get_tree()
            dest_ws = tree.find_by_id(event.container.id).workspace()
            self.setup_new_workspace(dest_ws)
            if new_cols == 1 and focus_ws.descendants():
                focus_ws.descendants()[-1].command("splith")

    # Useful methods <<<
    def close_all_windows_in_workspace(self):
        ws = self.utils.get_focused_workspace_object()
        for window in ws.leaves():
            if window.window:
                window.command("kill")

    def go_to_empty_workspace(self):
        tree = self.utils.get_tree()
        used = set(ws.name.split(":")[0].strip() for ws in tree.workspaces())
        for num in range(1, 10):
            if str(num) not in used:
                self.utils.command(f"workspace {num}")
                return
        # self.utils.command('exec i3-nagbar -m "No unused numbered workspace"')
    # >>>
