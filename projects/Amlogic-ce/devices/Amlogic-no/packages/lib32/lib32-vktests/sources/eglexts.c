#include <stdio.h>
#include <EGL/egl.h>
#include <EGL/eglext.h>

int main() {
    const char *client_extensions = eglQueryString(EGL_NO_DISPLAY, EGL_EXTENSIONS);
    printf("EGL Client Extensions:\n%s\n\n", client_extensions ? client_extensions : "NONE");
    return 0;
}
