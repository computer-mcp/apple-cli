#include <stdio.h>
#include <unistd.h>

int main(int argc, char **argv) {
    if (argc != 2) return 1;
    pid_t child = fork();
    if (child < 0) return 2;
    if (child == 0) {
        if (setsid() < 0) return 3;
        FILE *pid_file = fopen(argv[1], "w");
        if (!pid_file) return 4;
        fprintf(pid_file, "%d", getpid());
        fclose(pid_file);
        sleep(10);
    }
    return 0;
}
