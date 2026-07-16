#include "my_application.h"
#include <stdlib.h>

int main(int argc, char** argv) {
  // Desabilita o IBUS para evitar o bug de digitação no Flutter Desktop Linux
  setenv("GTK_IM_MODULE", "", 1);
  setenv("XMODIFIERS", "", 1);
  setenv("QT_IM_MODULE", "", 1);
  
  g_autoptr(MyApplication) app = my_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}
