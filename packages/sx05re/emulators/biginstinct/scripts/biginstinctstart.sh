#!/bin/bash
# Create libOpenGL.so.0 symlink in /tmp (filesystem is read-only)
if [ ! -f /tmp/libOpenGL.so.0 ]; then
  ln -sf /usr/lib/libGL.so.1 /tmp/libOpenGL.so.0
fi

# Add /tmp first so libOpenGL.so.0 symlink is found before other paths
export LD_LIBRARY_PATH=/tmp:/usr/lib:/emuelec/lib:$LD_LIBRARY_PATH
# Fix GL rendering issues on Mali GPU
export LIBGL_NOTEST=1
# Change to biginstinct directory
cd /usr/bin/biginstinct
# Launch biginstinct with all arguments
./biginstinct "$@"