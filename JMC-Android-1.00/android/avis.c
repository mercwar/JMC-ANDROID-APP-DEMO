// avis.c
// Implements the thin wrappers and connects modules to the registry.

#include "avis.h"
#include "yc_log.h"
#include "drawmod.h"

#include <android/log.h>

static YcyRegistry* g_reg = NULL;

void logini(void) {
    yc_log_init();
    yc_log_write("YCYBORG_INIT", "logini called");
}

void drawini(int width, int height) {
    draw_init(width, height);
    yc_log_write("YCYBORG_INIT", "drawini called: %dx%d", width, height);
}

void drawpaint(float r, float g, float b, float a) {
    draw_paint(r,g,b,a);
}

void drawline(int x1, int y1, int x2, int y2, float r, float g, float b, int thickness) {
    draw_line(x1,y1,x2,y2,r,g,b,thickness);
}

void drawbox(int x, int y, int w, int h, float r, float g, float b) {
    draw_box(x,y,w,h,r,g,b);
}

void cbord(int x, int y, int w, int h, int thickness, float r, float g, float b) {
    draw_border(x,y,w,h,thickness,r,g,b);
}

int avis_connect(YcyRegistry* reg) {
    if (!reg) return -1;
    g_reg = reg;
    // register common components
    ycy_register(g_reg, "ycy:log");
    ycy_register(g_reg, "ycy:draw");
    yc_log_write("YCYBORG_INIT", "avis_connect: modules registered");
    return 0;
}
