#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <getopt.h>
#include <Ivy/ivy.h>
#include <Ivy/ivyloop.h>
#include <Ivy/timer.h>
#include <Ivy/version.h>
#include <caml/mlvalues.h>
#include <caml/fail.h>
#include <caml/callback.h>
#include <caml/memory.h>
#include <caml/alloc.h>

value ivy_mainLoop(value unit)
{
  CAMLparam1 (unit);
#if IVYMINOR_VERSION == 8
  IvyMainLoop (NULL,NULL);
#else
  IvyMainLoop ();
#endif
  CAMLreturn(Val_unit);;
}

void timer_cb(TimerId id, void *data, unsigned long delta)
{
  value closure = *(value*)data;
  callback(closure, Val_long(id));
}

value ivy_timerRepeatafter(value nb_ticks, value delay, value closure_name)
{
  CAMLparam3 (nb_ticks, delay, closure_name);
  value * closure = caml_named_value(String_val(closure_name));
  TimerId id = TimerRepeatAfter(Int_val(nb_ticks), Int_val(delay), timer_cb, (void*)closure);
  CAMLreturn (Val_int(id));
}

/* Data associated to Channel callbacks is the couple of delete and
read closures */

extern void cb_delete_channel(void *delete_read);
extern void cb_read_channel(Channel ch, IVY_HANDLE fd, void *closure);
extern void cb_write_channel(Channel ch, IVY_HANDLE fd, void *closure);


value ivy_channelSetUp(value fd, value closure_name)
{
  CAMLparam2 (fd, closure_name);
  Channel c;
  value * closure = caml_named_value(String_val(closure_name));

#if IVYMINOR_VERSION == 8
  c = IvyChannelAdd((IVY_HANDLE)Int_val(fd), (void*)closure, cb_delete_channel, cb_read_channel);
#else
  c = IvyChannelAdd((IVY_HANDLE)Int_val(fd), (void*)closure, cb_delete_channel, cb_read_channel, cb_write_channel);
#endif
  CAMLreturn (Val_int(c));
}

value ivy_timerRemove(value t)
{
  CAMLparam1 (t);
  TimerRemove((TimerId)Long_val(t));
  CAMLreturn (Val_unit);;
}


value ivy_channelClose(value ch)
{
  CAMLparam1 (ch);
  IvyChannelRemove((Channel)Long_val(ch));
  CAMLreturn (Val_unit);;
}
