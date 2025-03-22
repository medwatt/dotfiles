import time
import subprocess
import functools

def debounce(wait):
    def decorator(fn):
        last_call = 0
        @functools.wraps(fn)
        def wrapper(*args, **kwargs):
            nonlocal last_call
            now = time.time()
            if now - last_call < wait:
                return
            last_call = now
            return fn(*args, **kwargs)
        return wrapper
    return decorator

class DisplayManager:
    def __init__(self):
        self.allow_set_display_mode = True
        self.is_display_mode_extended = True
        self.monitors = []

    def initialize(self):
        self.set_display_mode(None, None)

    @debounce(1)
    def set_display_mode(self, i3, event):
        self.get_connected_monitors()
        if self.allow_set_display_mode:
            if len(self.monitors) == 1:
                self.run_xrandr("xrandr --auto")
            else:
                self.extend_displays()
        else:
            self.allow_set_display_mode = True
        self.set_wallpaper()
        self.launch_polybar()

    def get_connected_monitors(self):
        proc = subprocess.Popen("xrandr", stdout=subprocess.PIPE, shell=True)
        output = proc.communicate()[0].decode().splitlines()
        self.monitors = [line.split()[0] for line in output if " connected" in line]

    def choose_display_mode(self):
        self.allow_set_display_mode = False
        menu = "Clone displays\nExtend displays\nSet primary display"
        choice = self.run_rofi(menu)
        if choice == "Clone displays":
            self.clone_displays()
        elif choice == "Extend displays":
            self.extend_displays()
        elif choice == "Set primary display":
            self.set_primary_display()
        else:
            self.show_notification("No valid option chosen. Defaulting to extend mode.")
            self.extend_displays()

    def clone_displays(self):
        self.is_display_mode_extended = False
        primary = self.monitors[0]
        cmd = f"xrandr --output {primary} --auto --primary"
        for display in self.monitors[1:]:
            cmd += f" --output {display} --auto --same-as {primary}"
        self.run_xrandr(cmd)

    def extend_displays(self):
        primary = self.monitors[0]
        cmd = f"xrandr --output {primary} --auto --primary"
        for display in self.monitors[1:]:
            cmd += f" --output {display} --auto --right-of {primary}"
        self.run_xrandr(cmd)

    def set_primary_display(self):
        options = "\n".join(self.monitors)
        choice = self.run_rofi(options)
        if choice in self.monitors:
            primary = choice
            cmd = f"xrandr --output {primary} --auto --primary"
            for display in self.monitors:
                if display != primary:
                    cmd += f" --output {display} --auto --right-of {primary}"
            self.run_xrandr(cmd)
        else:
            self.show_notification("Invalid input. No changes made.")

    def run_xrandr(self, cmd):
        proc = subprocess.Popen(cmd, shell=True)
        proc.wait()

    def run_rofi(self, options):
        result = subprocess.run(
            f"echo -e '{options}' | rofi -dmenu -p 'Choose display mode:'",
            shell=True,
            stdout=subprocess.PIPE
        )
        return result.stdout.decode().strip()

    def show_notification(self, message):
        subprocess.Popen(f"notify-send 'Display Setup' '{message}'", shell=True)

    def set_wallpaper(self):
        wallpaper = "/home/medwatt/Pictures/astro.jpg"
        cmd = f"feh --bg-fill {wallpaper}"
        subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, shell=True)

    def launch_polybar(self):
        subprocess.run(["killall", "-q", "polybar"])
        monitors = [self.monitors[0]] if not self.is_display_mode_extended else self.monitors
        for m in monitors:
            cmd = f"MONITOR={m} polybar --reload top"
            subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, shell=True)
        self.is_display_mode_extended = True
