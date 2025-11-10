# $ZDOTDIR/.zshenv
# Used for setting user's environment variables;
# it should not contain commands that produce output or assume the shell is attached to a TTY.
# When this file exists it will always be read.
. "$HOME/.cargo/env"

# Setup android sdk environment
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator"

