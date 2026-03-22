// index.c
// Main entry: wires YCYBORG registry, avis connectors, draw modules and UI.
// Save to /c/Apache24/htdocs/android/index.c

#include <android_native_app_glue.h>
#include <EGL/egl.h>
#include <GLES2/gl2.h>
#include <android/log.h>
#include <stdlib.h>
#include <string.h>

#include "ycyborg_reg.h"
#include "yc_log.h"
#include "drawmod.h"
#include "avis.h"

#define TAG "YCYBORG_APP"

static YcyRegistry g_reg;
static struct android_app* g_app_state = NULL;
static int g_width = 0, g_height = 0;
static EGLDisplay g_display = EGL_NO_DISPLAY;
static EGLSurface g_surface = EGL_NO_SURFACE;
static EGLContext g_context = EGL_NO_CONTEXT;

static const char* RENDERER = "ycy:renderer";

static int init_egl(ANativeWindow* window) {
    const EGLint cfg_attribs[] = {
        EGL_RENDERABLE_TYPE, EGL_OPENGL_ES2_BIT,
        EGL_SURFACE_TYPE, EGL_WINDOW_BIT,
        EGL_RED_SIZE,8, EGL_GREEN_SIZE,8, EGL_BLUE_SIZE,8, EGL_ALPHA_SIZE,8,
        EGL_NONE
    };
    EGLint numConfigs;
    EGLConfig config;
    g_display = eglGetDisplay(EGL_DEFAULT_DISPLAY);
    if (g_display == EGL_NO_DISPLAY) return -1;
    if (!eglInitialize(g_display, NULL, NULL)) return -1;
    if (!eglChooseConfig(g_display, cfg_attribs, &config, 1, &numConfigs) || numConfigs == 0) return -1;
    EGLint ctx_attribs[] = { EGL_CONTEXT_CLIENT_VERSION, 2, EGL_NONE };
    g_context = eglCreateContext(g_display, config, EGL_NO_CONTEXT, ctx_attribs);
    g_surface = eglCreateWindowSurface(g_display, config, window, NULL);
    if (!eglMakeCurrent(g_display, g_surface, g_surface, g_context)) return -1;
    eglQuerySurface(g_display, g_surface, EGL_WIDTH, &g_width);
    eglQuerySurface(g_display, g_surface, EGL_HEIGHT, &g_height);
    draw_init(g_width, g_height);
    yc_log_write(TAG, "EGL initialized %dx%d", g_width, g_height);
    return 0;
}

static void term_egl() {
    if (g_display == EGL_NO_DISPLAY) return;
    eglMakeCurrent(g_display, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
    if (g_context != EGL_NO_CONTEXT) eglDestroyContext(g_display, g_context);
    if (g_surface != EGL_NO_SURFACE) eglDestroySurface(g_display, g_surface);
    eglTerminate(g_display);
    g_display = EGL_NO_DISPLAY; g_surface = EGL_NO_SURFACE; g_context = EGL_NO_CONTEXT;
    yc_log_write(TAG, "EGL terminated");
}

static void render_demo() {
    // background
    drawpaint(0.0f, 1.0f, 0.0f, 1.0f);

    // window frame
    int win_w = g_width * 80 / 100;
    int win_h = g_height * 60 / 100;
    int win_x = (g_width - win_w) / 2;
    int win_y = (g_height - win_h) / 2;
    cbord(win_x, win_y, win_w, win_h, 6, 0.12f, 0.12f, 0.12f);
    drawbox(win_x + 6, win_y + 6, win_w - 12, win_h - 12, 0.95f, 0.95f, 0.95f);

    // demo line and box
    drawline(win_x + 20, win_y + 20, win_x + win_w - 20, win_y + win_h - 20, 0.0f, 0.2f, 0.6f, 4);
    drawbox(win_x + 40, win_y + 40, 120, 80, 0.2f, 0.6f, 0.2f);

    // EXIT button
    int btn_w = 140, btn_h = 56;
    int btn_x = win_x + win_w - btn_w - 24;
    int btn_y = win_y + win_h - btn_h - 24;
    drawbox(btn_x, btn_y, btn_w, btn_h, 0.85f, 0.12f, 0.12f);
    // simple label blocks
    drawbox(btn_x + 18, btn_y + 12, 22, 30, 1.0f, 1.0f, 1.0f);
    drawbox(btn_x + 46, btn_y + 12, 22, 30, 1.0f, 1.0f, 1.0f);
    drawbox(btn_x + 74, btn_y + 12, 22, 30, 1.0f, 1.0f, 1.0f);

    eglSwapBuffers(g_display, g_surface);
}

/* simple event queue */
typedef enum { EVT_NONE=0, EVT_TOUCH, EVT_EXIT } EVT;
typedef struct { EVT type; int x,y; char msg[128]; } Event;
#define QSZ 128
static Event q[QSZ];
static int qh=0, qt=0;
static volatile int qlock=0;
static inline void qlock_acq(void){ while(__sync_lock_test_and_set(&qlock,1)){} }
static inline void qlock_rel(void){ __sync_lock_release(&qlock); }

static int qpush(const Event* e) {
    qlock_acq();
    int next = (qt + 1) % QSZ;
    if (next == qh) { qlock_rel(); return -1; }
    q[qt] = *e;
    qt = next;
    qlock_rel();
    return 0;
}
static int qpop(Event* out) {
    qlock_acq();
    if (qh == qt) { qlock_rel(); return 0; }
    *out = q[qh];
    qh = (qh + 1) % QSZ;
    qlock_rel();
    return 1;
}

static int32_t on_input(struct android_app* app, AInputEvent* event) {
    if (AInputEvent_getType(event) == AINPUT_EVENT_TYPE_MOTION) {
        float fx = AMotionEvent_getX(event, 0);
        float fy = AMotionEvent_getY(event, 0);
        Event e;
        int win_w = g_width * 80 / 100;
        int win_h = g_height * 60 / 100;
        int win_x = (g_width - win_w) / 2;
        int win_y = (g_height - win_h) / 2;
        int btn_w = 140, btn_h = 56;
        int btn_x = win_x + win_w - btn_w - 24;
        int btn_y = win_y + win_h - btn_h - 24;
        if ((int)fx >= btn_x && (int)fx <= btn_x + btn_w && (int)fy >= btn_y && (int)fy <= btn_y + btn_h) {
            e.type = EVT_EXIT;
            snprintf(e.msg, sizeof(e.msg), "Exit pressed at %d,%d", (int)fx, (int)fy);
        } else {
            e.type = EVT_TOUCH;
            e.x = (int)fx; e.y = (int)fy;
            snprintf(e.msg, sizeof(e.msg), "Touch at %d,%d", e.x, e.y);
        }
        if (qpush(&e) != 0) {
            yc_log_write(TAG, "Event queue full");
        }
        return 1;
    }
    return 0;
}

static void process_queue(void) {
    Event e;
    while (qpop(&e)) {
        if (e.type == EVT_TOUCH) {
            if (ycy_checkout(&g_reg, RENDERER)) {
                ycy_notify(RENDERER, e.msg);
                ycy_checkin(&g_reg, RENDERER, 0);
            } else {
                yc_log_write(TAG, "Renderer not available");
            }
        } else if (e.type == EVT_EXIT) {
            ycy_notify("ycy:ui", e.msg);
            yc_log_write(TAG, "Exit requested");
            if (g_app_state && g_app_state->activity) {
                ANativeActivity_finish(g_app_state->activity);
            }
        }
    }
}

static void handle_cmd(struct android_app* app, int32_t cmd) {
    switch (cmd) {
        case APP_CMD_INIT_WINDOW:
            if (app->window) {
                if (init_egl(app->window) == 0) {
                    render_demo();
                } else {
                    yc_log_write(TAG, "init_egl failed");
                }
            }
            break;
        case APP_CMD_TERM_WINDOW:
            term_egl();
            break;
        default:
            break;
    }
}

void android_main(struct android_app* state) {
    app_dummy();
    g_app_state = state;

    yc_log_init();
    ycy_init(&g_reg);
    avis_connect(&g_reg); // registers ycy:log and ycy:draw

    state->onAppCmd = handle_cmd;
    state->onInputEvent = on_input;

    if (ycy_checkout(&g_reg, RENDERER)) {
        ycy_notify(RENDERER, "Renderer checked out for startup");
        ycy_checkin(&g_reg, RENDERER, 0);
    }

    int events;
    struct android_poll_source* source;
    const int FRAME_MS = 16;

    while (1) {
        while (ALooper_pollOnce(FRAME_MS, NULL, &events, (void**)&source) >= 0) {
            if (source) source->process(state, source);
            if (state->destroyRequested) { term_egl(); return; }
            process_queue();
        }
        render_demo();
    }
}
