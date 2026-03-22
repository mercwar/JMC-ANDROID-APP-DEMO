// avis.h
// Thin connector API exposing the function names you requested.

#ifndef AVIS_H
#define AVIS_H

#include "ycyborg_reg.h"

/* initialization wrappers */
void logini(void);
void drawini(int width, int height);

/* drawing wrappers */
void drawpaint(float r, float g, float b, float a);
void drawline(int x1, int y1, int x2, int y2, float r, float g, float b, int thickness);
void drawbox(int x, int y, int w, int h, float r, float g, float b);
void cbord(int x, int y, int w, int h, int thickness, float r, float g, float b);

/* connect modules to registry */
int avis_connect(YcyRegistry* reg);

#endif // AVIS_H
