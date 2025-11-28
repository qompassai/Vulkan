#!/usr/bin/env bash
# quickstart.sh
# Qompass AI Vulkan Quickstart
set -euo pipefail
TARGET="${1:-}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
XDG_BIN_HOME="${XDG_BIN_HOME:-$HOME/.local/bin}"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
detect_shell() {
	shell_name=$(basename "$SHELL")
	case "$shell_name" in
	bash) echo "bash" ;;
	zsh) echo "zsh" ;;
	fish) echo "fish" ;;
	*) echo "unknown" ;;
	esac
}
add_path_hint() {
	shell_type="$1"
	case "$shell_type" in
	bash)
		echo "Add this to your ~/.bashrc:"
		echo "export PATH=\"\$XDG_BIN_HOME:\$PATH\""
		;;
	zsh)
		echo "Add this to your ~/.zshrc:"
		echo "export PATH=\"\$XDG_BIN_HOME:\$PATH\""
		;;
	fish)
		echo "For fish shell, run:"
		echo "set -U fish_user_paths \$XDG_BIN_HOME \$fish_user_paths"
		;;
	*)
		echo "Unknown shell. Add \$XDG_BIN_HOME to your PATH manually."
		;;
	esac
}
install_vulkan_sdk() {
	OS="$(uname -s)"
	ARCH="$(uname -m)"
	if [ "$OS" = "Linux" ]; then
		if [ "$ARCH" = "x86_64" ]; then
			PLATFORM="linux"
			VERSION_URL="https://vulkan.lunarg.com/sdk/latest/linux.txt"
			EXT="tar.xz"
			SDK_SUFFIX="linux-x86_64"
		else
			echo "Unsupported Linux architecture: $ARCH"
			exit 1
		fi
	elif [ "$OS" = "Darwin" ]; then
		PLATFORM="mac"
		VERSION_URL="https://vulkan.lunarg.com/sdk/latest/mac.txt"
		EXT="zip"
		SDK_SUFFIX="macos"
	else
		echo "Unsupported OS: $OS. For Windows, use PowerShell."
		exit 1
	fi

	INSTALL_DIR="$XDG_DATA_HOME/vulkan-sdk"
	echo "Detected OS: $OS, Architecture: $ARCH, Shell: $(detect_shell)"
	echo "Querying latest Vulkan SDK version..."
	LATEST_VERSION=$(curl -s "$VERSION_URL")
	if [ -z "$LATEST_VERSION" ]; then
		echo "Could not retrieve latest Vulkan SDK version."
		exit 1
	fi
	DOWNLOAD_URL="https://sdk.lunarg.com/sdk/download/$LATEST_VERSION/$PLATFORM/vulkansdk-$SDK_SUFFIX-$LATEST_VERSION.$EXT"
	echo "Latest Vulkan SDK: version $LATEST_VERSION"
	echo "Download URL: $DOWNLOAD_URL"

	mkdir -p "$INSTALL_DIR"
	OLD_DIR="$PWD"
	cd "$INSTALL_DIR"

	echo "Downloading and extracting..."
	if [ "$EXT" = "zip" ]; then
		curl -L -o vulkansdk.zip "$DOWNLOAD_URL"
		unzip -o vulkansdk.zip
		rm vulkansdk.zip
	elif [ "$EXT" = "tar.xz" ]; then
		curl -L -o vulkansdk.tar.xz "$DOWNLOAD_URL"
		tar -xf vulkansdk.tar.xz --strip-components=1
		rm vulkansdk.tar.xz
	fi
	PHMAP_REPO="$HOME/parallel-hashmap"
	PHMAP_SRC="$PHMAP_REPO/parallel_hashmap"
	SDK_INCLUDE="$INSTALL_DIR/include"
	if [ ! -d "$PHMAP_SRC" ]; then
		echo "parallel_hashmap not found at $PHMAP_SRC. Cloning from GitHub..."
		git clone --depth 1 https://github.com/greg7mdp/parallel-hashmap.git "$PHMAP_REPO"
	fi
	if [ -d "$PHMAP_SRC" ]; then
		mkdir -p "$SDK_INCLUDE"
		cp -r "$PHMAP_SRC" "$SDK_INCLUDE/"
		echo "parallel_hashmap added to Vulkan SDK include dir: $SDK_INCLUDE"
	else
		echo "Failed to set up parallel_hashmap. You may need to check your network or repo path."
	fi

	CONFIG_JSON_URL="https://sdk.lunarg.com/sdk/download/$LATEST_VERSION/$PLATFORM/config.json"
	SDK_SOURCE="$INSTALL_DIR/source"
	mkdir -p "$SDK_SOURCE"
	echo "Fetching Vulkan SDK config.json manifest for $LATEST_VERSION ..."
	if curl -fsSL -o "$SDK_SOURCE/config.json" "$CONFIG_JSON_URL"; then
		echo "config.json placed at $SDK_SOURCE/config.json"
	else
		echo "Warning: Could not download config.json from $CONFIG_JSON_URL"
	fi

	if [ -f "setup-env.sh" ]; then
		chmod +x "setup-env.sh"
		source "./setup-env.sh"
	fi

	SDK_BIN=$(find . -type d -name 'bin' | head -n 1)
	if [ -d "$SDK_BIN" ]; then
		mkdir -p "$XDG_BIN_HOME"
		for exe in "$SDK_BIN"/*; do
			[ -f "$exe" ] && [ -x "$exe" ] && ln -sf "$PWD/$exe" "$XDG_BIN_HOME/"
		done
		echo "SDK binaries symlinked into $XDG_BIN_HOME"
		if [ -x "$XDG_BIN_HOME/vulkansdk" ]; then
			echo "Running vulkansdk all from $XDG_BIN_HOME ..."
			"$XDG_BIN_HOME/vulkansdk" all
		else
			echo "No vulkansdk script found in $XDG_BIN_HOME, skipping build."
		fi
	else
		echo "SDK bin directory not found; check the installation."
	fi

	echo ""
	add_path_hint "$(detect_shell)"
	echo ""
	echo "Vulkan SDK downloaded to $INSTALL_DIR."
	cd "$OLD_DIR"
}
install_android_ndk() {
	NDK_PAGE=$(curl -s "https://developer.android.com/ndk/downloads")
	LATEST_NDK_ZIP=$(echo "$NDK_PAGE" | grep -oE "android-ndk-r[0-9]+[a-z]?(-linux\.zip)?" | head -1)
	NDK_VERSION=$(echo "$LATEST_NDK_ZIP" | sed 's/-linux\.zip//')
	if [ -z "$NDK_VERSION" ]; then
		echo "Could not determine the latest NDK version."
		exit 1
	fi
	NDK_URL="https://dl.google.com/android/repository/$LATEST_NDK_ZIP"
	DEST="$XDG_DATA_HOME/android-ndk"
	echo "Downloading latest Android NDK: $NDK_URL"
	curl -O "$NDK_URL"
	unzip "${LATEST_NDK_ZIP}" -d "$DEST"
	echo "Latest Android NDK ($NDK_VERSION) installed at $DEST"
}

case "$TARGET" in
droid | android)
	install_android_ndk
	;;
*)
	install_vulkan_sdk
	;;
esac
