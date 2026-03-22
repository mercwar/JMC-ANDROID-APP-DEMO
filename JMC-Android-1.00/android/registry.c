// ycyborg_reg.h
// Small registry used by YCYBORG system (header-only).

#ifndef YCYBORG_REG_H
#define YCYBORG_REG_H

#include <android/log.h>
#include <string.h>

#define YCY_TAG "YCYBORG_REG"
#define YCY_I(...) __android_log_print(ANDROID_LOG_INFO, YCY_TAG, __VA_ARGS__)
#define YCY_E(...) __android_log_print(ANDROID_LOG_ERROR, YCY_TAG, __VA_ARGS__)

#define YCY_MAX_ENTRIES 64
#define YCY_NAME_MAX 64

typedef struct {
    char name[YCY_NAME_MAX];
    int refcount;
    int used;
} YcyEntry;

typedef struct {
    YcyEntry entries[YCY_MAX_ENTRIES];
    volatile int lock;
} YcyRegistry;

static inline void ycy_lock(YcyRegistry* r) { while(__sync_lock_test_and_set(&r->lock,1)){} }
static inline void ycy_unlock(YcyRegistry* r) { __sync_lock_release(&r->lock); }

static inline void ycy_init(YcyRegistry* r) {
    if (!r) return;
    memset(r,0,sizeof(*r));
    YCY_I("YCYBORG registry initialized");
}

static inline int ycy_register(YcyRegistry* r, const char* name) {
    if (!r || !name) return -1;
    ycy_lock(r);
    for (int i=0;i<YCY_MAX_ENTRIES;i++) {
        if (r->entries[i].used && strncmp(r->entries[i].name, name, YCY_NAME_MAX) == 0) {
            YCY_I("register: %s already present (ref=%d)", name, r->entries[i].refcount);
            ycy_unlock(r);
            return 0;
        }
    }
    for (int i=0;i<YCY_MAX_ENTRIES;i++) {
        if (!r->entries[i].used) {
            r->entries[i].used = 1;
            strncpy(r->entries[i].name, name, YCY_NAME_MAX-1);
            r->entries[i].name[YCY_NAME_MAX-1] = '\0';
            r->entries[i].refcount = 0;
            YCY_I("Registered: %s", name);
            ycy_unlock(r);
            return 0;
        }
    }
    YCY_E("register failed: registry full");
    ycy_unlock(r);
    return -1;
}

static inline int ycy_checkout(YcyRegistry* r, const char* name) {
    if (!r || !name) return 0;
    ycy_lock(r);
    for (int i=0;i<YCY_MAX_ENTRIES;i++) {
        if (r->entries[i].used && strncmp(r->entries[i].name, name, YCY_NAME_MAX) == 0) {
            r->entries[i].refcount++;
            YCY_I("Checked out %s (ref=%d)", name, r->entries[i].refcount);
            ycy_unlock(r);
            return 1;
        }
    }
    YCY_E("Checkout failed: %s not found", name);
    ycy_unlock(r);
    return 0;
}

static inline int ycy_checkin(YcyRegistry* r, const char* name, int remove_when_zero) {
    if (!r || !name) return 0;
    ycy_lock(r);
    for (int i=0;i<YCY_MAX_ENTRIES;i++) {
        if (r->entries[i].used && strncmp(r->entries[i].name, name, YCY_NAME_MAX) == 0) {
            if (r->entries[i].refcount > 0) r->entries[i].refcount--;
            YCY_I("Checked in %s (ref=%d)", name, r->entries[i].refcount);
            if (remove_when_zero && r->entries[i].refcount == 0) {
                YCY_I("Unregistering %s (ref==0)", name);
                r->entries[i].used = 0;
                r->entries[i].name[0] = '\0';
                r->entries[i].refcount = 0;
            }
            ycy_unlock(r);
            return 1;
        }
    }
    YCY_E("Checkin failed: %s not found", name);
    ycy_unlock(r);
    return 0;
}

static inline void ycy_notify(const char* name, const char* msg) {
    if (!name || !msg) return;
    YCY_I("NOTIFY %s: %s", name, msg);
}

#endif // YCYBORG_REG_H
