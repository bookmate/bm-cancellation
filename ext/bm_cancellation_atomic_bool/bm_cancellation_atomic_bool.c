#include <stdbool.h>
#include <stdatomic.h>

#include "ruby.h"
#include "extconf.h"


#define MUST_RUBY_BOOL(val)                                           \
  if (val != Qtrue && val != Qfalse) {                                \
    rb_raise(rb_eTypeError, "wrong argument type boolean expected");  \
  }

#define TO_C_BOOL(val) val == Qtrue ? true : false
#define TO_RUBY_BOOL(val) val ? Qtrue : Qfalse

struct bm_cancellation_atomic_bool {
  atomic_bool value;
};

static VALUE
bm_cancellation_atomic_bool_alloc(VALUE klass) {
  struct bm_cancellation_atomic_bool *ptr;

  return Data_Make_Struct(klass, struct bm_cancellation_atomic_bool, NULL, free, ptr);
}

static VALUE
bm_cancellation_atomic_bool_init(VALUE self, VALUE initial_value) {
  struct bm_cancellation_atomic_bool *ptr;

  MUST_RUBY_BOOL(initial_value);

  Data_Get_Struct(self, struct bm_cancellation_atomic_bool, ptr);
  atomic_init(&ptr->value, TO_C_BOOL(initial_value));

  return self;
}

static VALUE
bm_cancellation_atomic_bool_fetch(VALUE self) {
  struct bm_cancellation_atomic_bool *ptr;

  Data_Get_Struct(self, struct bm_cancellation_atomic_bool, ptr);
  bool value = atomic_load_explicit(&ptr->value, memory_order_acquire);

  return TO_RUBY_BOOL(value);
}

static VALUE
bm_cancellation_atomic_bool_value(VALUE self) {
  struct bm_cancellation_atomic_bool *ptr;

  Data_Get_Struct(self, struct bm_cancellation_atomic_bool, ptr);

  return TO_RUBY_BOOL(ptr->value);
}

static VALUE
bm_cancellation_atomic_bool_swap(VALUE self, VALUE expected, VALUE desired) {
  struct bm_cancellation_atomic_bool *ptr;

  MUST_RUBY_BOOL(expected);
  MUST_RUBY_BOOL(desired);

  Data_Get_Struct(self, struct bm_cancellation_atomic_bool, ptr);
  bool old_value = TO_C_BOOL(expected);
  bool succ = atomic_compare_exchange_strong(&ptr->value, &old_value, TO_C_BOOL(desired));

  return TO_RUBY_BOOL(succ);
}

void Init_bm_cancellation_atomic_bool() {
  VALUE cAtomicBool = rb_path2class("BM::Cancellation::AtomicBool");

  rb_define_alloc_func(cAtomicBool, bm_cancellation_atomic_bool_alloc);
  rb_define_method(cAtomicBool, "initialize", bm_cancellation_atomic_bool_init, 1);
  rb_define_method(cAtomicBool, "fetch", bm_cancellation_atomic_bool_fetch, 0);
  rb_define_method(cAtomicBool, "swap",  bm_cancellation_atomic_bool_swap,  2);
  rb_define_method(cAtomicBool, "value", bm_cancellation_atomic_bool_value, 0);
}
