// ui_mod.c
#include "ui_mod.h"
#include "drawmod.h"

void ui_draw_window_frame(int x, int y, int w, int h) {
    // outer border
    draw_border(x, y, w, h, 6, 0.12f, 0.12f, 0.12f);
    // inner background
    draw_box(x + 6, y + 6, w - 12, h - 12, 0.95f, 0.95f, 0.95f);
}

void ui_draw_exit_button(int x, int y, int w, int h) {
    draw_box(x, y, w, h, 0.85f, 0.12f, 0.12f);
    // simple label as three blocks
    int ex = x + 18;
    int ey = y + 12;
    draw_box(ex, ey, 22, 30, 1.0f, 1.0f, 1.0f);
    draw_box(ex + 28, ey, 22, 30, 1.0f, 1.0f, 1.0f);
    draw_box(ex + 56, ey, 22, 30, 1.0f, 1.0f, 1.0f);
}
