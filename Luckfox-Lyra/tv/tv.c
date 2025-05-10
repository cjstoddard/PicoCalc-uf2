/* textreader.c
Code by Chris Stoddard */

#include <ncurses.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <libgen.h>
#include <limits.h>

#define MAX_LINES 10000
#define MAX_LINE_LEN 1024
#define SCREEN_ROWS 38    // Text lines
#define SCREEN_COLS 40    // Characters per row
#define STATUS_ROW 38     // Last row is status bar (row 0-indexed)

char *lines[MAX_LINES];
int total_lines = 0;
char state_file_path[PATH_MAX];

void init_state_file_path(const char *filepath) {
    char path_copy[PATH_MAX];
    if (!realpath(filepath, path_copy)) {
        perror("realpath");
        exit(1);
    }
    snprintf(state_file_path, sizeof(state_file_path), "%s/.textreader.state", dirname(path_copy));
}

int load_last_position(const char *filepath) {
    init_state_file_path(filepath);
    char abspath[PATH_MAX];
    if (!realpath(filepath, abspath)) return 0;

    FILE *fp = fopen(state_file_path, "r");
    if (!fp) return 0;

    char file_entry[PATH_MAX];
    int pos = 0;
    while (fscanf(fp, "%s %d", file_entry, &pos) == 2) {
        if (strcmp(file_entry, abspath) == 0) {
            fclose(fp);
            return pos;
        }
    }

    fclose(fp);
    return 0;
}

void save_position(const char *filepath, int pos) {
    init_state_file_path(filepath);
    char abspath[PATH_MAX];
    if (!realpath(filepath, abspath)) return;

    FILE *fp = fopen(state_file_path, "r");
    FILE *tmp = tmpfile();
    char buffer[PATH_MAX + 16];
    int updated = 0;

    if (fp) {
        while (fgets(buffer, sizeof(buffer), fp)) {
            char file_entry[PATH_MAX];
            int old_pos;
            if (sscanf(buffer, "%s %d", file_entry, &old_pos) == 2) {
                if (strcmp(file_entry, abspath) == 0) {
                    fprintf(tmp, "%s %d\n", abspath, pos);
                    updated = 1;
                } else {
                    fputs(buffer, tmp);
                }
            }
        }
        fclose(fp);
    }

    if (!updated) {
        fprintf(tmp, "%s %d\n", abspath, pos);
    }

    FILE *out = fopen(state_file_path, "w");
    if (!out) return;
    rewind(tmp);
    while (fgets(buffer, sizeof(buffer), tmp)) fputs(buffer, out);
    fclose(out);
    fclose(tmp);
}

void load_file(const char *filename) {
    FILE *fp = fopen(filename, "r");
    if (!fp) { perror("fopen"); exit(1); }

    char buffer[MAX_LINE_LEN];
    while (fgets(buffer, sizeof(buffer), fp) && total_lines < MAX_LINES) {
        lines[total_lines++] = strdup(buffer);
    }

    fclose(fp);
}

void free_lines() {
    for (int i = 0; i < total_lines; i++) {
        free(lines[i]);
    }
}

void draw_screen(int start_line) {
    clear();

    int row = 0;
    for (int i = start_line; i < total_lines && row < SCREEN_ROWS; i++) {
        int len = strlen(lines[i]);
        for (int j = 0; j < len && row < SCREEN_ROWS; j += SCREEN_COLS) {
            char segment[SCREEN_COLS + 1];
            strncpy(segment, lines[i] + j, SCREEN_COLS);
            segment[SCREEN_COLS] = '\0';
            mvprintw(row++, 0, "%s", segment);
        }
    }

    // Status bar on last row
    mvprintw(STATUS_ROW, 0, "[q] Quit  Line %d / %d", start_line + 1, total_lines);
    clrtoeol();

    refresh();
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <textfile>\n", argv[0]);
        return 1;
    }

    load_file(argv[1]);

    initscr();
    cbreak();
    noecho();
    keypad(stdscr, TRUE);

    int ch;
    int start_line = load_last_position(argv[1]);

    draw_screen(start_line);

    while ((ch = getch()) != 'q') {
        switch (ch) {
            case KEY_DOWN:
                if (start_line + 1 < total_lines)
                    start_line++;
                break;
            case KEY_UP:
                if (start_line > 0)
                    start_line--;
                break;
            case ' ':
                start_line += SCREEN_ROWS;
                if (start_line > total_lines - 1)
                    start_line = total_lines - 1;
                break;
        }

        draw_screen(start_line);
    }

    endwin();
    save_position(argv[1], start_line);
    free_lines();
    return 0;
}

