#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <getopt.h>
#include <Ivy/ivy.h>
#include <Ivy/ivyloop.h>
#include <Ivy/timer.h>
#include <caml/mlvalues.h>
#include <caml/fail.h>
#include <caml/callback.h>
#include <caml/memory.h>
#include <caml/alloc.h>

value ivy_sendMsg(value msg)
{
  CAMLparam1 (msg);
  IvySendMsg("%s", String_val(msg));
  CAMLreturn (Val_unit);;
}

value ivy_stop(value unit)
{
  CAMLparam1 (unit);
  IvyStop();
  CAMLreturn (Val_unit);;
}


void app_cb(IvyClientPtr app, void *user_data, IvyApplicationEvent event )
{
  value closure = *(value*)user_data;
  callback2(closure, Val_int(app), Val_int(event));
}

value ivy_init(value vappName, value vready, value closure_name)
{
  CAMLparam3 (vappName, vready, closure_name);
  value * closure = caml_named_value(String_val(closure_name));
  char * appName = malloc(strlen(String_val(vappName))+1); /* Memory leak */
  strcpy(appName, String_val(vappName));
  char * ready = malloc(strlen(String_val(vready))+1); /* Memory leak */
  strcpy(ready, String_val(vready));
  IvyInit(appName, ready, app_cb, (void*)closure, 0, 0); /* When the "die callback" is called ??? */
  CAMLreturn (Val_unit);;
}

value ivy_start(value bus)
{
  CAMLparam1 (bus);
  IvyStart(String_val(bus));
  CAMLreturn (Val_unit);;
}

void ClosureCallback(IvyClientPtr app, void *closure, int argc, char **argv)
{
  CAMLparam0 ();
  CAMLlocal1 (data);
  char* t[argc+1];
  int i;
  /* Copie de argv dans t avec ajout d'un pointeur nul a la fin */
  for(i=0; i < argc; i++) t[i] = argv[i];
  t[argc] = (char*)0L;
  data = copy_string_array((char const **)t);
  callback2(*(value*)closure, Val_long(app), data);
  CAMLreturn0;
}

value ivy_bindMsg(value cb_name, value regexp)
{
  CAMLparam2 (cb_name, regexp);
  value * closure = caml_named_value(String_val(cb_name));
  MsgRcvPtr id = IvyBindMsg(ClosureCallback, (void*)closure, "%s", String_val(regexp));
  CAMLreturn (Val_long(id));
}

value ivy_unbindMsg(value id)
{
  CAMLparam1 (id);
  IvyUnbindMsg((MsgRcvPtr)Long_val(id));
  CAMLreturn (Val_unit);
}

value ivy_name_of_client(value c)
{
  CAMLparam1 (c);
  CAMLlocal1 (name);
  name = copy_string(IvyGetApplicationName((IvyClientPtr)Long_val(c)));
  CAMLreturn (name);
}
value ivy_host_of_client(value c)
{
  CAMLparam1 (c);
  CAMLlocal1 (host);
  host = copy_string(IvyGetApplicationHost((IvyClientPtr)Long_val(c)));
  CAMLreturn (host);
}

void cb_delete_channel(void *delete_read)
{
}

void cb_write_channel(Channel ch, IVY_HANDLE fd, void *closure)
{
}

void cb_read_channel(Channel ch, IVY_HANDLE fd, void *closure)
{
  callback(*(value*)closure, Val_int(ch));
}
