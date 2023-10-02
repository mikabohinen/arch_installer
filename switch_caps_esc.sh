#!/bin/bash

# Function to check if a command is available
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Ensure dialog is installed
if ! command_exists dialog; then
    sudo pacman -S dialog --noconfirm
fi

# Welcome message
dialog --title "CapsLock to Escape/Control Remapper" \
    --msgbox "This script will install and configure caps2esc to remap \
    Caps Lock to Escape when pressed alone and to Control when pressed \
    with other keys. Press OK to continue." 10 60

# Install caps2esc
dialog --title "Installing caps2esc" --infobox "Installing..." 3 20
sudo pacman -S interception-caps2esc --noconfirm

# Create udevmon.yaml configuration file
udevmon_config="- JOB: \"intercept -g \$DEVNODE | caps2esc | uinput -d \$DEVNODE\"
  DEVICE:
    EVENTS:
      EV_KEY: [KEY_CAPSLOCK, KEY_ESC]"

echo "$udevmon_config" | sudo tee /etc/udevmon.yaml

# Create systemd service unit file for udevmon
udevmon_service="[Unit]
Description=udevmon
Wants=systemd-udev-settle.service
After=systemd-udev-settle.service

[Service]
ExecStart=/usr/bin/nice -n -20 /usr/bin/udevmon -c /etc/udevmon.yaml

[Install]
WantedBy=multi-user.target"

echo "$udevmon_service" | sudo tee /etc/systemd/system/udevmon.service

# Enable and start the udevmon service
dialog --title "Enabling and starting udevmon service" --infobox "Configuring..." 3 30
sudo systemctl enable --now udevmon.service

# Completion message
dialog --title "Installation Complete" \
    --msgbox "The caps2esc utility has been installed and configured. \
    Caps Lock will now act as Escape when pressed alone and as Control \
    when pressed with other keys." 10 60
