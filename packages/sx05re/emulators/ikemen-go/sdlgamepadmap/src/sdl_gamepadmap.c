#include <SDL2/SDL.h>
#include <SDL2/SDL_ttf.h>
#include <json-c/json.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

const char *button_names[] = {
    "Up", "Down", "Left", "Right",
    "A", "B", "C", "X", "Y", "Z",
    "Start", "L", "R", "Menu"
};

#define NUM_BUTTONS (sizeof(button_names) / sizeof(button_names[0]))

#define COLOR_BG_R 15
#define COLOR_BG_G 23
#define COLOR_BG_B 42
#define COLOR_PRIMARY_R 59
#define COLOR_PRIMARY_G 130
#define COLOR_PRIMARY_B 246
#define COLOR_SUCCESS_R 16
#define COLOR_SUCCESS_G 185
#define COLOR_SUCCESS_B 129
#define COLOR_TEXT_R 255
#define COLOR_TEXT_G 255
#define COLOR_TEXT_B 255
#define COLOR_ARROW_R 59
#define COLOR_ARROW_G 130
#define COLOR_ARROW_B 246

typedef struct {
    SDL_Renderer *ren;
    TTF_Font *font_large;
    TTF_Font *font_medium;
    TTF_Font *font_small;
    int screen_w;
    int screen_h;
} UI_Context;

void drawText(UI_Context *ui, const char *text, int x, int y, TTF_Font *font, SDL_Color color) {
    SDL_Surface *surf = TTF_RenderUTF8_Blended(font, text, color);
    if (!surf) return;
    SDL_Texture *tex = SDL_CreateTextureFromSurface(ui->ren, surf);
    SDL_Rect dest = {x, y, surf->w, surf->h};
    SDL_RenderCopy(ui->ren, tex, NULL, &dest);
    SDL_FreeSurface(surf);
    SDL_DestroyTexture(tex);
}

void drawTextCentered(UI_Context *ui, const char *text, int y, TTF_Font *font, SDL_Color color) {
    SDL_Surface *surf = TTF_RenderUTF8_Blended(font, text, color);
    if (!surf) return;
    SDL_Texture *tex = SDL_CreateTextureFromSurface(ui->ren, surf);
    int x = (ui->screen_w - surf->w) / 2;
    SDL_Rect dest = {x, y, surf->w, surf->h};
    SDL_RenderCopy(ui->ren, tex, NULL, &dest);
    SDL_FreeSurface(surf);
    SDL_DestroyTexture(tex);
}

void drawRoundedRect(SDL_Renderer *ren, int x, int y, int w, int h, int r, int g, int b, int a) {
    SDL_SetRenderDrawColor(ren, r, g, b, a);
    SDL_Rect rect = {x + 4, y, w - 8, h};
    SDL_RenderFillRect(ren, &rect);
    rect = (SDL_Rect){x, y + 4, w, h - 8};
    SDL_RenderFillRect(ren, &rect);
    for (int i = 0; i < 4; i++) {
        SDL_Rect corner = {x + i, y + i, w - i * 2, h - i * 2};
        SDL_RenderDrawRect(ren, &corner);
    }
}

void drawArrow(SDL_Renderer *ren, int x, int y, int size, int direction) {
    SDL_SetRenderDrawColor(ren, COLOR_ARROW_R, COLOR_ARROW_G, COLOR_ARROW_B, 255);
    SDL_Point points[4];
    switch (direction) {
        case 0:
            points[0] = (SDL_Point){x, y - size / 2};
            points[1] = (SDL_Point){x - size / 2, y + size / 2};
            points[2] = (SDL_Point){x, y + size / 4};
            points[3] = (SDL_Point){x + size / 2, y + size / 2};
            break;
        case 1:
            points[0] = (SDL_Point){x, y + size / 2};
            points[1] = (SDL_Point){x - size / 2, y - size / 2};
            points[2] = (SDL_Point){x, y - size / 4};
            points[3] = (SDL_Point){x + size / 2, y - size / 2};
            break;
        case 2:
            points[0] = (SDL_Point){x - size / 2, y};
            points[1] = (SDL_Point){x + size / 2, y - size / 2};
            points[2] = (SDL_Point){x + size / 4, y};
            points[3] = (SDL_Point){x + size / 2, y + size / 2};
            break;
        case 3:
            points[0] = (SDL_Point){x + size / 2, y};
            points[1] = (SDL_Point){x - size / 2, y - size / 2};
            points[2] = (SDL_Point){x - size / 4, y};
            points[3] = (SDL_Point){x - size / 2, y + size / 2};
            break;
    }
    for (int i = 0; i < 4; i++) {
        SDL_RenderDrawLine(ren, points[i].x, points[i].y, points[(i + 1) % 4].x, points[(i + 1) % 4].y);
    }
    SDL_RenderDrawLines(ren, points, 4);
}

void drawButton(UI_Context *ui, const char *name, int x, int y, int pressed, int is_arrow, int arrow_dir) {
    int w = 100, h = 100;
    drawRoundedRect(ui->ren, x + 4, y + 4, w, h, 0, 0, 0, 80);
    if (pressed) {
        drawRoundedRect(ui->ren, x, y, w, h, COLOR_SUCCESS_R, COLOR_SUCCESS_G, COLOR_SUCCESS_B, 255);
    } else {
        drawRoundedRect(ui->ren, x, y, w, h, 50, 50, 60, 255);
    }
    SDL_SetRenderDrawColor(ui->ren, COLOR_PRIMARY_R, COLOR_PRIMARY_G, COLOR_PRIMARY_B, 255);
    for (int i = 0; i < 3; i++) {
        SDL_Rect border = {x + i, y + i, w - i * 2, h - i * 2};
        SDL_RenderDrawRect(ui->ren, &border);
    }
    if (is_arrow) {
        drawArrow(ui->ren, x + w / 2, y + h / 2, 40, arrow_dir);
    } else {
        SDL_Color color = {COLOR_TEXT_R, COLOR_TEXT_G, COLOR_TEXT_B, 255};
        SDL_Surface *surf = TTF_RenderUTF8_Blended(ui->font_medium, name, color);
        if (surf) {
            SDL_Texture *tex = SDL_CreateTextureFromSurface(ui->ren, surf);
            int tx = x + (w - surf->w) / 2;
            int ty = y + (h - surf->h) / 2;
            SDL_Rect dest = {tx, ty, surf->w, surf->h};
            SDL_RenderCopy(ui->ren, tex, NULL, &dest);
            SDL_FreeSurface(surf);
            SDL_DestroyTexture(tex);
        }
    }
}
void drawGamepadLayout(UI_Context *ui, int current_button, int pressed_buttons[NUM_BUTTONS]) {
    int cx = ui->screen_w / 2;
    int cy = ui->screen_h / 2 + 80;
    int spacing = 120;
    int dpad_x = cx - 350;
    int dpad_y = cy - 60;

    drawButton(ui, "Up", dpad_x, dpad_y - spacing, pressed_buttons[0], 1, 0);
    drawButton(ui, "Down", dpad_x, dpad_y + spacing, pressed_buttons[1], 1, 1);
    drawButton(ui, "Left", dpad_x - spacing, dpad_y, pressed_buttons[2], 1, 2);
    drawButton(ui, "Right", dpad_x + spacing, dpad_y, pressed_buttons[3], 1, 3);

    int action_x = cx + 350;
    int action_y = cy - 60;
    drawButton(ui, "X", action_x, action_y - spacing, pressed_buttons[7], 0, 0);
    drawButton(ui, "Y", action_x - spacing, action_y, pressed_buttons[8], 0, 0);
    drawButton(ui, "A", action_x, action_y + spacing, pressed_buttons[4], 0, 0);
    drawButton(ui, "B", action_x + spacing, action_y, pressed_buttons[5], 0, 0);

    drawButton(ui, "L", cx - 250, cy - 250, pressed_buttons[11], 0, 0);
    drawButton(ui, "R", cx + 150, cy - 250, pressed_buttons[12], 0, 0);

    drawButton(ui, "Select", cx - 130, cy + 200, pressed_buttons[13], 0, 0);
    drawButton(ui, "Start", cx + 30, cy + 200, pressed_buttons[10], 0, 0);

    drawButton(ui, "C", cx - 110, cy - 60, pressed_buttons[6], 0, 0);
    drawButton(ui, "Z", cx + 110, cy - 60, pressed_buttons[9], 0, 0);
}

void saveMapping(const char *path, int js_id, char button_values[NUM_BUTTONS][8]) {
    struct json_object *root = json_object_from_file(path);
    if (!root) root = json_object_new_object();

    struct json_object *jarr = json_object_object_get(root, "JoystickConfig");
    if (!jarr) {
        jarr = json_object_new_array();
        json_object_object_add(root, "JoystickConfig", jarr);
    }

    struct json_object *entry = json_object_new_object();
    json_object_object_add(entry, "Joystick", json_object_new_int(js_id));

    struct json_object *btns = json_object_new_array();
    for (int i = 0; i < NUM_BUTTONS; i++) {
        json_object_array_add(btns, json_object_new_string(button_values[i]));
    }
    json_object_object_add(entry, "Buttons", btns);

    while (json_object_array_length(jarr) <= js_id)
        json_object_array_add(jarr, json_object_new_object());

    json_object_array_put_idx(jarr, js_id, entry);
    json_object_to_file_ext(path, root, JSON_C_TO_STRING_PRETTY);
    json_object_put(root);
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Usage: %s <path_to_config.json>\n", argv[0]);
        return 1;
    }

    const char *CONFIG_PATH = argv[1];

    if (SDL_Init(SDL_INIT_JOYSTICK | SDL_INIT_VIDEO) < 0) {
        printf("Error initializing SDL: %s\n", SDL_GetError());
        return 1;
    }

    if (TTF_Init() < 0) {
        printf("Error initializing TTF: %s\n", TTF_GetError());
        return 1;
    }

    SDL_DisplayMode dm;
    SDL_GetCurrentDisplayMode(0, &dm);
    int screen_w = dm.w * 0.8;
    int screen_h = dm.h * 0.8;

    SDL_Window *win = SDL_CreateWindow("Gamepad Mapper Pro",
        SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
        screen_w, screen_h, SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE);
    SDL_Renderer *ren = SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);

    UI_Context ui = {
        .ren = ren,
        .font_large = TTF_OpenFont("/usr/share/fonts/liberation/LiberationSans-Bold.ttf", 48),
        .font_medium = TTF_OpenFont("/usr/share/fonts/liberation/LiberationSans-Regular.ttf", 28),
        .font_small = TTF_OpenFont("/usr/share/fonts/liberation/LiberationSans-Regular.ttf", 20),
        .screen_w = screen_w,
        .screen_h = screen_h
    };

    if (!ui.font_large || !ui.font_medium || !ui.font_small) {
        printf("Error loading fonts. Make sure Liberation Sans is installed.\n");
        return 1;
    }

    int num_joysticks = SDL_NumJoysticks();
    if (num_joysticks < 1) {
        printf("No joystick detected!\n");
        return 0;
    }

    SDL_Joystick *joysticks[4] = {NULL};
    int device_index[4] = {-1, -1, -1, -1};

    for (int i = 0; i < num_joysticks && i < 4; i++) {
        joysticks[i] = SDL_JoystickOpen(i);
        if (joysticks[i]) {
            SDL_JoystickID instance_id = SDL_JoystickInstanceID(joysticks[i]);
            device_index[instance_id] = i;
            printf("Joystick %d opened - Instance ID: %d - Name: %s\n",
                   i, instance_id, SDL_JoystickName(joysticks[i]));
        }
    }

    int js_id = -1;
    int device_id = -1;
    Uint32 first_press_time = 0;
    int detecting_instance_id = -1;

    while (js_id == -1) {
        SDL_Event e;
        while (SDL_PollEvent(&e)) {
            if (e.type == SDL_JOYBUTTONDOWN ||
                (e.type == SDL_JOYAXISMOTION && abs(e.jaxis.value) > 16000)) {

                int current_instance_id = (e.type == SDL_JOYBUTTONDOWN) ? e.jbutton.which : e.jaxis.which;

                if (detecting_instance_id == -1) {
                    detecting_instance_id = current_instance_id;
                    first_press_time = SDL_GetTicks();
                } else if (detecting_instance_id == current_instance_id) {
                    if (SDL_GetTicks() - first_press_time >= 5000) {
                        js_id = current_instance_id;
                        device_id = device_index[current_instance_id];
                        break;
                    }
                } else {
                    detecting_instance_id = current_instance_id;
                    first_press_time = SDL_GetTicks();
                }
            } else if (e.type == SDL_QUIT) {
                for (int i = 0; i < 4; i++) {
                    if (joysticks[i]) SDL_JoystickClose(joysticks[i]);
                }
                SDL_Quit();
                return 0;
            }
        }

        SDL_SetRenderDrawColor(ren, COLOR_BG_R, COLOR_BG_G, COLOR_BG_B, 255);
        SDL_RenderClear(ren);

        SDL_Color white = {255, 255, 255, 255};
        SDL_Color yellow = {255, 230, 100, 255};

        drawTextCentered(&ui, "Press any button", screen_h / 2 - 100, ui.font_large, white);
        drawTextCentered(&ui, "on the controller to map", screen_h / 2 - 40, ui.font_medium, white);

        if (detecting_instance_id != -1) {
            Uint32 elapsed = SDL_GetTicks() - first_press_time;
            float progress = (float)elapsed / 5000.0f;
            if (progress > 1.0f) progress = 1.0f;

            int detecting_device = device_index[detecting_instance_id];
            char msg[64];
            snprintf(msg, sizeof(msg), "Detecting Joystick %d (/dev/input/js%d)",
                     detecting_device, detecting_device);
            drawTextCentered(&ui, msg, screen_h / 2 + 40, ui.font_medium, yellow);

            int bar_w = 400;
            int bar_h = 30;
            int bar_x = (screen_w - bar_w) / 2;
            int bar_y = screen_h / 2 + 100;

            drawRoundedRect(ren, bar_x, bar_y, bar_w, bar_h, 40, 40, 50, 255);

            int fill_w = (int)(bar_w * progress);
            if (fill_w > 0) {
                drawRoundedRect(ren, bar_x, bar_y, fill_w, bar_h,
                    COLOR_SUCCESS_R, COLOR_SUCCESS_G, COLOR_SUCCESS_B, 255);
            }

            float remaining = 5.0f - (elapsed / 1000.0f);
            if (remaining < 0) remaining = 0;
            snprintf(msg, sizeof(msg), "%.1f seconds", remaining);
            drawTextCentered(&ui, msg, bar_y + bar_h + 20, ui.font_small, white);
        } else {
            drawTextCentered(&ui, "Hold for 5 seconds",
                screen_h / 2 + 40, ui.font_small, white);
        }

        SDL_RenderPresent(ren);
        SDL_Delay(16);
    }

    SDL_Joystick *target = joysticks[device_id];
    printf("\n✓ Selected controller: Joystick %d (/dev/input/js%d)\n", device_id, device_id);
    printf("  Name: %s\n\n", SDL_JoystickName(target));

    for (int i = 0; i < 4; i++) {
        if (joysticks[i] && i != device_id) SDL_JoystickClose(joysticks[i]);
    }

    char button_values[NUM_BUTTONS][8];
    int pressed_buttons[NUM_BUTTONS] = {0};
    memset(button_values, 0, sizeof(button_values));

    for (int i = 0; i < NUM_BUTTONS; i++) {
        int mapped = 0;
        while (!mapped) {
            SDL_Event e;
            while (SDL_PollEvent(&e)) {
                if (e.type == SDL_JOYBUTTONDOWN) {
                    snprintf(button_values[i], sizeof(button_values[i]), "%d", e.jbutton.button);
                    pressed_buttons[i] = 1;
                    mapped = 1;
                } else if (e.type == SDL_JOYAXISMOTION && abs(e.jaxis.value) > 16000) {
                    snprintf(button_values[i], sizeof(button_values[i]), "%s%d",
                             (e.jaxis.value < 0 ? "-" : ""), e.jaxis.axis);
                    pressed_buttons[i] = 1;
                    mapped = 1;
                } else if (e.type == SDL_QUIT) {
                    SDL_Quit();
                    return 0;
                }
            }

            SDL_SetRenderDrawColor(ren, COLOR_BG_R, COLOR_BG_G, COLOR_BG_B, 255);
            SDL_RenderClear(ren);

            SDL_Color white = {255, 255, 255, 255};
            SDL_Color yellow = {255, 230, 100, 255};

            char instruction[64];
            snprintf(instruction, sizeof(instruction), "Press: %s", button_names[i]);
            drawTextCentered(&ui, instruction, 50, ui.font_large, yellow);

            char progress[32];
            snprintf(progress, sizeof(progress), "Button %d of %d", i + 1, NUM_BUTTONS);
            drawTextCentered(&ui, progress, 120, ui.font_small, white);

            drawGamepadLayout(&ui, i, pressed_buttons);

            SDL_RenderPresent(ren);
            SDL_Delay(16);
        }
        SDL_Delay(200);
    }

    saveMapping(CONFIG_PATH, device_id, button_values);

    SDL_SetRenderDrawColor(ren, COLOR_BG_R, COLOR_BG_G, COLOR_BG_B, 255);
    SDL_RenderClear(ren);
    SDL_Color green = {COLOR_SUCCESS_R, COLOR_SUCCESS_G, COLOR_SUCCESS_B, 255};

    char success_msg[128];
    snprintf(success_msg, sizeof(success_msg), "✓ Configuration Saved! (Joystick %d)", device_id);
    drawTextCentered(&ui, success_msg, screen_h / 2, ui.font_large, green);

    SDL_RenderPresent(ren);
    SDL_Delay(2500);

    printf("✓ Mapping saved successfully at: %s\n", CONFIG_PATH);
    printf("  Joystick ID: %d (/dev/input/js%d)\n", device_id, device_id);

    TTF_CloseFont(ui.font_large);
    TTF_CloseFont(ui.font_medium);
    TTF_CloseFont(ui.font_small);
    SDL_JoystickClose(target);
    SDL_DestroyRenderer(ren);
    SDL_DestroyWindow(win);
    TTF_Quit();
    SDL_Quit();
    return 0;
}

