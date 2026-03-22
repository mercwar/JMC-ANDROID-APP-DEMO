// registry.h
#pragma once
#include <stdbool.h>

typedef struct Registry Registry;

/* Initialize / shutdown */
Registry* registry_create(void);
void registry_destroy(Registry* r);

/* Register a named source (id string). Returns 0 on success, -1 on error */
int registry_register(Registry* r, const char* name);

/* Checkout increments refcount and returns true if available */
bool registry_checkout(Registry* r, const char* name);

/* Checkin decrements refcount; if remove_when_zero true, unregister when 0 */
bool registry_checkin(Registry* r, const char* name, bool remove_when_zero);

/* Query refcount (0 if not present) */
int registry_refcount(Registry* r, const char* name);

/* Send a textual notification to terminal/log */
void registry_notify(Registry* r, const char* name, const char* msg);
