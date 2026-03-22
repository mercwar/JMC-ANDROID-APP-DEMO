// yc_log.c
// Fixed logging helper: Android log + append to /sdcard/yc_log.txt

#include "yc_log.h"
#include <android/log.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <stdarg.h>

#define LOG_PATH "/sdcard/yc_log.txt"
#define LOG_TAG "YCYBORG_LOG"

static FILE* yc_log_file = NULL;

void yc_log_init(void) {
    if (yc_log_file) return;
    yc_log_file = fopen(LOG_PATH, "a");
    if (!yc_log_file) {
        __android_log_print(ANDROID_LOG_WARN, LOG_TAG, "Could not open %s for append", LOG_PATH);
    } else {
        time_t t = time(NULL);
        char buf[64];
        strftime(buf, sizeof(buf), "%Y-%m-%d %H:%M:%S", localtime(&t));
        fprintf(yc_log_file, "=== YCYBORG LOG START %s ===\n", buf);
        fflush(yc_log_file);
    }
}

void yc_log_write(const char* tag, const char* fmt, ...) {
    va_list ap;
    va_start(ap, fmt);

    // Log to Android logcat using the provided tag and format
    __android_log_vprint(ANDROID_LOG_INFO, tag, fmt, ap);

    // Also write to the file if available (use a copy of va_list)
    if (yc_log_file) {
        va_list ap2;
        va_copy(ap2, ap);
        char line[512];
        vsnprintf(line, sizeof(line), fmt, ap2);
        fprintf(yc_log_file, "%s: %s\n", tag, line);
        fflush(yc_log_file);
        va_end(ap2);
    }

    va_end(ap);
}
