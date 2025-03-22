import functools
import time

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

    def command(self, cmd):
        return self.i3.command(cmd)

    def get_tree(self):
        return self.i3.get_tree()

    def get_focused_window_object(self):
        tree = self.get_tree()
        if tree:
            return tree.find_focused()
        return None

    def get_focused_workspace_object(self):
        focused = self.get_focused_window_object()
        if focused:
            return focused.workspace()
        return None

    def get_focused_window_and_workspace_objects(self):
        focused = self.get_focused_window_object()
        if focused:
            return focused, focused.workspace()
        return None, None

    def get_focused_monitor(self):
        node = self.get_focused_window_object()
        if node:
            while node.type != 'output' and node.parent:
                node = node.parent
            if node.type == 'output':
                return node.name
        return None
