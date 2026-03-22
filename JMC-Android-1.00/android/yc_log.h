// yc_log.h
// Simple logging helper: Android log + append to /sdcard/yc_log.txt

#ifndef YC_LOG_H
#define YC_LOG_H

void yc_log_init(void);
void yc_log_write(const char* tag, const char* fmt, ...);

#endif // YC_LOG_H
