// drawmod.h
// Public drawing API used by index.c and other modules.

#ifndef DRAWMOD_H
#define DRAWMOD_H

#include <GLES2/gl2.h>

void draw_init(int width, int height);
void draw_paint(float r, float g, float b, float a);
void draw_line(int x1, int y1, int x2, int y2, float r, float g, float b, int thickness);
void draw_box(int x, int y, int w, int h, float r, float g, float b);
void draw_border(int x, int y, int w, int h, int thickness, float r, float g, float b);

#endif // DRAWMOD_H
