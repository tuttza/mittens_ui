#include "mittens_ui.h"

VALUE rb_mMittensUi;

void
Init_mittens_ui(void)
{
  rb_mMittensUi = rb_define_module("MittensUi");
}
