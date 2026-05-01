#include <stdio.h>

extern const char* message_from_ipc();

int main() {
    printf("C IPC watcher started!\n");
    printf("Message from IPC: %s!\n", message_from_ipc());

    return 0;
}
