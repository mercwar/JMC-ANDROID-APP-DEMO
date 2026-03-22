// drawmod.c
#include "drawmod.h"
#include <GLES2/gl2.h>
#include <math.h>

static int g_w = 0, g_h = 0;

void draw_init(int width, int height) {
    g_w = width; g_h = height;
    glViewport(0, 0, g_w, g_h);
}

static void draw_rect_scissor(int x, int y, int w, int h, float r, float g, float b, float a) {
    if (w <= 0 || h <= 0) return;
    glEnable(GL_SCISSOR_TEST);
    glScissor(x, y, w, h);
    glClearColor(r, g, b, a);
    glClear(GL_COLOR_BUFFER_BIT);
    glDisable(GL_SCISSOR_TEST);
}

void draw_paint(float r, float g, float b, float a) {
    glViewport(0, 0, g_w, g_h);
    glClearColor(r, g, b, a);
    glClear(GL_COLOR_BUFFER_BIT);
}

void draw_line(int x1, int y1, int x2, int y2, float r, float g, float b, int thickness) {
    // draw a thin rectangle approximating a line
    int dx = x2 - x1;
    int dy = y2 - y1;
    if (dx == 0 && dy == 0) {
        draw_rect_scissor(x1 - thickness/2, y1 - thickness/2, thickness, thickness, r, g, b, 1.0f);
        return;
    }
    float len = sqrtf((float)dx*dx + (float)dy*dy);
    float nx = -dy / len;
    float ny = dx / len;
    // compute bounding box of rotated rectangle
    float hx = (thickness/2.0f) * fabsf(nx);
    float hy = (thickness/2.0f) * fabsf(ny);
    int minx = (int)fminf(x1, x2) - (int)ceilf(hx) - 1;
    int miny = (int)fminf(y1, y2) - (int)ceilf(hy) - 1;
    int maxx = (int)fmaxf(x1, x2) + (int)ceilf(hx) + 1;
    int maxy = (int)fmaxf(y1, y2) + (int)ceilf(hy) + 1;
    draw_rect_scissor(minx, miny, maxx - minx, maxy - miny, r, g, b, 1.0f);
}

void draw_box(int x, int y, int w, int h, float r, float g, float b) {
    draw_rect_scissor(x, y, w, h, r, g, b, 1.0f);
}

void draw_border(int x, int y, int w, int h, int thickness, float r, float g, float b) {
    // top
    draw_rect_scissor(x, y + h - thickness, w, thickness, r, g, b, 1.0f);
    // bottom
    draw_rect_scissor(x, y, w, thickness, r, g, b, 1.0f);
    // left
    draw_rect_scissor(x, y, thickness, h, r, g, b, 1.0f);
    // right
    draw_rect_scissor(x + w - thickness, y, thickness, h, r, g, b, 1.0f);
}
