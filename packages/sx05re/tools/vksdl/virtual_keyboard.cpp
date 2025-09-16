// ------------------------------------------------ //  
// SPDX-License-Identifier: GPL-2.0-or-later       //
//     Copyright (C) 2025-present BY DIEGROSAN    //
// --------------------------------------------- //

#include <SDL2/SDL.h>
#include <SDL2/SDL_ttf.h>
#include <vector>
#include <map>
#include <string>
#include <linux/uinput.h>
#include <linux/input.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <cstring>
#include <cmath>
#include <algorithm>

// Variáveis globais para resolução (serão definidas dinamicamente)
int WINDOW_WIDTH = 1200;
int WINDOW_HEIGHT = 500;
int DISPLAY_WIDTH = 0;
int DISPLAY_HEIGHT = 0;
int DISPLAY_OFFSET = 2;

// Configurações que dependem da resolução
int KEY_SIZE = 45;
int KEY_SPACING = 4;
int SPECIAL_KEY_WIDTH = 80;
int ROW_SPACING = 8;

constexpr int DEAD_ZONE = 8000;
constexpr float MOVE_THRESHOLD = 0.5f, ANALOG_SENSITIVITY = 1.5f;
constexpr Uint32 REPEAT_DELAY = 150, ANALOG_REPEAT_DELAY = 200;

// Cores
constexpr SDL_Color COLORS[] = {
    {50, 50, 50, 255},      // KEY_COLOR
    {80, 120, 255, 255},    // KEY_PRESSED_COLOR  
    {100, 150, 255, 255},   // KEY_SELECTED_COLOR
    {255, 100, 60, 255},    // KEY_SHIFT_ACTIVE
    {255, 255, 255, 255},   // TEXT_COLOR
    {120, 120, 120, 255},   // BORDER_COLOR
    {255, 255, 255, 255},   // SELECTED_BORDER_COLOR
    {30, 30, 30, 255}       // PREVIEW_BACKGROUND
};

// Mapeamento de teclas
const std::map<char, int> keymap = {
    {'a', KEY_A}, {'b', KEY_B}, {'c', KEY_C}, {'d', KEY_D}, {'e', KEY_E},
    {'f', KEY_F}, {'g', KEY_G}, {'h', KEY_H}, {'i', KEY_I}, {'j', KEY_J},
    {'k', KEY_K}, {'l', KEY_L}, {'m', KEY_M}, {'n', KEY_N}, {'o', KEY_O},
    {'p', KEY_P}, {'q', KEY_Q}, {'r', KEY_R}, {'s', KEY_S}, {'t', KEY_T},
    {'u', KEY_U}, {'v', KEY_V}, {'w', KEY_W}, {'x', KEY_X}, {'y', KEY_Y},
    {'z', KEY_Z}, {'1', KEY_1}, {'2', KEY_2}, {'3', KEY_3}, {'4', KEY_4},
    {'5', KEY_5}, {'6', KEY_6}, {'7', KEY_7}, {'8', KEY_8}, {'9', KEY_9},
    {'0', KEY_0}, {' ', KEY_SPACE}, {'\b', KEY_BACKSPACE}, {'-', KEY_MINUS},
    {'=', KEY_EQUAL}, {'[', KEY_LEFTBRACE}, {']', KEY_RIGHTBRACE},
    {'\\', KEY_BACKSLASH}, {';', KEY_SEMICOLON}, {'\'', KEY_APOSTROPHE},
    {'`', KEY_GRAVE}, {',', KEY_COMMA}, {'.', KEY_DOT}, {'/', KEY_SLASH},
    {'\n', KEY_ENTER}, {'\t', KEY_TAB},
    {'!', KEY_1}, {'@', KEY_2}, {'#', KEY_3}, {'$', KEY_4}, {'%', KEY_5},
    {'^', KEY_6}, {'&', KEY_7}, {'*', KEY_8}, {'(', KEY_9}, {')', KEY_0},
    {'_', KEY_MINUS}, {'+', KEY_EQUAL},
    {'{', KEY_LEFTBRACE}, {'}', KEY_RIGHTBRACE},
    {'|', KEY_BACKSLASH}, {':', KEY_SEMICOLON},
    {'"', KEY_APOSTROPHE}, {'~', KEY_GRAVE},
    {'<', KEY_COMMA}, {'>', KEY_DOT}, {'?', KEY_SLASH}
};

struct Key {
    SDL_Rect rect;
    char primary, secondary;
    int keycode;
    int physical_keycode;
    bool pressed = false, selected = false, is_special = false, is_shift_key = false;
    std::string display_text;
    
    Key(int x, int y, int w, int h, char p, char s, int kc, int pkc, const std::string& text, 
        bool special = false, bool shift_key = false)
        : rect{x, y, w, h}, primary(p), secondary(s), keycode(kc), physical_keycode(pkc),
          is_special(special), is_shift_key(shift_key), display_text(text) {}
};

// Variáveis globais
SDL_Window* window = nullptr;
SDL_Renderer* renderer = nullptr;
TTF_Font* font = nullptr;
SDL_GameController* controller = nullptr;
std::vector<Key> keys;
std::string input_text;
bool shift_pressed = true, close_requested = false, keyboard_visible = false;
int selected_key_index = 0, uinput_fd = -1;
Uint32 last_button_time = 0, last_analog_move_time = 0;
float last_axis_x = 0.0f, last_axis_y = 0.0f;
bool analog_moved = false;
bool l1_pressed = false;  // Track L1 button state

// Layout do teclado
const char* keyboard_rows[] = {"1234567890-=", "!@#$%^&*()_+", "qwertyuiop[]", "asdfghjkl;'", "zxcvbnm,./"};

// Função para detectar resolução e ajustar tamanhos
void detect_resolution_and_scale() {
    // Inicializa SDL temporariamente apenas para detectar resolução
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        printf("Erro ao inicializar SDL para detecção de resolução: %s\n", SDL_GetError());
        return;
    }
    
    SDL_DisplayMode display_mode;
    if (SDL_GetCurrentDisplayMode(0, &display_mode) == 0) {
        DISPLAY_WIDTH = display_mode.w;
        DISPLAY_HEIGHT = display_mode.h;
        
        printf("Resolução detectada: %dx%d\n", DISPLAY_WIDTH, DISPLAY_HEIGHT);
        
        // Ajusta tamanhos baseado na resolução
        if (DISPLAY_WIDTH <= 800) {
            // Telas pequenas (ex: 800x600)
            WINDOW_WIDTH = DISPLAY_WIDTH - 50;
            WINDOW_HEIGHT = std::min(400 / DISPLAY_OFFSET, DISPLAY_HEIGHT - 100);
            KEY_SIZE = 35;
            KEY_SPACING = 3;
            SPECIAL_KEY_WIDTH = 60;
            ROW_SPACING = 6;
        } else if (DISPLAY_WIDTH <= 1024) {
            // Telas médias (ex: 1024x768)
            WINDOW_WIDTH = DISPLAY_WIDTH - 100;
            WINDOW_HEIGHT = std::min(450 / DISPLAY_OFFSET, DISPLAY_HEIGHT - 100);
            KEY_SIZE = 40;
            KEY_SPACING = 4;
            SPECIAL_KEY_WIDTH = 70;
            ROW_SPACING = 7;
        } else if (DISPLAY_WIDTH <= 1366) {
            // Telas comuns (ex: 1366x768)
            WINDOW_WIDTH = std::min(1200 / DISPLAY_OFFSET, DISPLAY_WIDTH - 100);
            WINDOW_HEIGHT = std::min(500, DISPLAY_HEIGHT - 100);
            KEY_SIZE = 45;
            KEY_SPACING = 4;
            SPECIAL_KEY_WIDTH = 80;
            ROW_SPACING = 8;
        } else if (DISPLAY_WIDTH <= 1920) {
            // Full HD
            WINDOW_WIDTH = std::min(1400 / DISPLAY_OFFSET, DISPLAY_WIDTH - 400);
            WINDOW_HEIGHT = std::min(600, DISPLAY_HEIGHT - 150);
            KEY_SIZE = 50;
            KEY_SPACING = 5;
            SPECIAL_KEY_WIDTH = 90;
            ROW_SPACING = 10;
        } else {
            // 4K e superiores
            WINDOW_WIDTH = std::min(1800 / DISPLAY_OFFSET, DISPLAY_WIDTH - 300);
            WINDOW_HEIGHT = std::min(800, DISPLAY_HEIGHT - 200);
            KEY_SIZE = 60;
            KEY_SPACING = 6;
            SPECIAL_KEY_WIDTH = 110;
            ROW_SPACING = 12;
        }
        
        printf("Janela ajustada para: %dx%d\n", WINDOW_WIDTH, WINDOW_HEIGHT);
        printf("Tamanho das teclas: %d pixels\n", KEY_SIZE);
        
    } else {
        printf("Não foi possível detectar resolução, usando valores padrão\n");
        DISPLAY_WIDTH = 800 / DISPLAY_OFFSET;
        DISPLAY_HEIGHT = 500;
    }
    
    SDL_Quit(); // Finaliza SDL temporária
}

int setup_uinput() {
    uinput_fd = open("/dev/uinput", O_WRONLY | O_NONBLOCK);
    if (uinput_fd < 0) uinput_fd = open("/dev/input/uinput", O_WRONLY | O_NONBLOCK);
    if (uinput_fd < 0) return -1;
    
    ioctl(uinput_fd, UI_SET_EVBIT, EV_KEY);
    ioctl(uinput_fd, UI_SET_EVBIT, EV_SYN);

    for (const auto& k : keymap) ioctl(uinput_fd, UI_SET_KEYBIT, k.second);
    
    int special_keys[] = {KEY_LEFTSHIFT, KEY_RIGHTSHIFT, KEY_LEFTCTRL, KEY_LEFTALT, KEY_ESC, KEY_TAB};
    for (int key : special_keys) ioctl(uinput_fd, UI_SET_KEYBIT, key);
    
    struct uinput_user_dev uidev = {};
    snprintf(uidev.name, UINPUT_MAX_NAME_SIZE, "Teclado Virtual Gamepad");
    uidev.id = {BUS_USB, 0x6264, 0x5678, 100};
    
    if (write(uinput_fd, &uidev, sizeof(uidev)) < 0 || ioctl(uinput_fd, UI_DEV_CREATE) < 0) {
        close(uinput_fd);
        return -1;
    }
    
    usleep(100000);
    return 0;
}

void send_key_event(int keycode, bool pressed) {
    if (uinput_fd < 0) return;
    struct input_event ev = {};
    gettimeofday(&ev.time, nullptr);
    ev.type = EV_KEY;
    ev.code = keycode;
    ev.value = pressed ? 1 : 0;
    write(uinput_fd, &ev, sizeof(ev));
    ev.type = EV_SYN;
    ev.code = SYN_REPORT;
    ev.value = 0;
    write(uinput_fd, &ev, sizeof(ev));
}

void update_preview() {
    if (!keys.empty()) {
        keys[0].display_text = input_text.empty() ? "Preview..." : input_text;
    }
}

void create_keyboard_layout() {
    keys.clear();
    input_text.clear();
    
    // Área de preview - ajustada proporcionalmente
    int preview_width = (WINDOW_WIDTH - 100) * 2 / 3;
    
    keys.emplace_back((WINDOW_WIDTH - preview_width) / 2, 20, preview_width, KEY_SIZE + 15, '\0', '\0', 0, 0, "Preview...", true);
    
    int y = 20 + KEY_SIZE + 35; // Ajustado baseado no preview
    
    // Teclas especiais
    struct {int w; char c; int k; const char* t; bool shift;} special_keys[] = {
        {SPECIAL_KEY_WIDTH, 'X', KEY_ESC, "CLOSE", false},
        {SPECIAL_KEY_WIDTH, '\t', KEY_TAB, "TAB", false},
        {SPECIAL_KEY_WIDTH, '^', KEY_LEFTSHIFT, "SHIFT", true},
        {SPECIAL_KEY_WIDTH, '\b', KEY_BACKSPACE, "DEL", false}
    };
    
    int special_total_width = 4 * SPECIAL_KEY_WIDTH + 3 * KEY_SPACING;
    int special_start_x = (WINDOW_WIDTH - special_total_width) / 2;
    
    for (int i = 0; i < 4; i++) {
        auto& sk = special_keys[i];
        keys.emplace_back(special_start_x + i * (SPECIAL_KEY_WIDTH + KEY_SPACING), y, 
                         sk.w, KEY_SIZE, sk.c, sk.c, sk.k, sk.k, sk.t, true, sk.shift);
    }
    y += KEY_SIZE + ROW_SPACING;
    
    // Linhas do teclado
    for (int row = 0; row < 5; row++) {
        const char* row_chars = keyboard_rows[row];
        int key_count = strlen(row_chars);
        int row_width = key_count * KEY_SIZE + (key_count - 1) * KEY_SPACING;
        int row_start_x = (WINDOW_WIDTH - row_width) / 2;
        
        for (int i = 0; i < key_count; i++) {
            char primary = row_chars[i];
            auto it = keymap.find(primary);
            if (it != keymap.end()) {
                int kc = it->second;
                keys.emplace_back(row_start_x + i * (KEY_SIZE + KEY_SPACING), y, KEY_SIZE, KEY_SIZE,
                                primary, primary, kc, kc, std::string(1, primary));
            }
        }
        y += KEY_SIZE + ROW_SPACING;
    }
    
    // Barra de espaço e Enter
    int space_width = KEY_SIZE * 6;
    int space_x = (WINDOW_WIDTH - space_width - KEY_SPACING - SPECIAL_KEY_WIDTH) / 2;
    keys.emplace_back(space_x, y, space_width, KEY_SIZE, ' ', ' ', KEY_SPACE, KEY_SPACE, "ESPACE", true);
    keys.emplace_back(space_x + space_width + KEY_SPACING, y, SPECIAL_KEY_WIDTH, KEY_SIZE, 
                     '\n', '\n', KEY_ENTER, KEY_ENTER, "ENTER", true);
    
    if (!keys.empty()) {
        selected_key_index = 2;
        keys[selected_key_index].selected = true;
    }
}

void update_key_display() {
    for (auto& key : keys) {
        if (!key.is_special && key.display_text.length() == 1) {
            char original_char = key.primary;
            
            // Para letras (a-z), converta para maiúscula quando shift pressionado
            if (original_char >= 'a' && original_char <= 'z') {
                key.display_text = shift_pressed ? std::string(1, original_char - 'a' + 'A') : std::string(1, original_char);
            }
            // Para números, símbolos e outros caracteres, manter fixos
            else {
                key.display_text = std::string(1, original_char);
            }
        }
    }
    update_preview();
}

void render_key(const Key& key) {
    if (&key == &keys[0]) {
        // Área de preview
        SDL_SetRenderDrawColor(renderer, COLORS[7].r, COLORS[7].g, COLORS[7].b, COLORS[7].a);
        SDL_RenderFillRect(renderer, &key.rect);
        
        SDL_SetRenderDrawColor(renderer, COLORS[5].r, COLORS[5].g, COLORS[5].b, COLORS[5].a);
        SDL_RenderDrawRect(renderer, &key.rect);
        
        if (font) {
            SDL_Surface* surface = TTF_RenderUTF8_Blended(font, key.display_text.c_str(), COLORS[4]);
            if (surface) {
                SDL_Texture* texture = SDL_CreateTextureFromSurface(renderer, surface);
                if (texture) {
                    SDL_Rect text_rect = {key.rect.x + 10, key.rect.y + (key.rect.h - surface->h) / 2,
                                         surface->w, surface->h};
                    SDL_RenderCopy(renderer, texture, nullptr, &text_rect);
                    SDL_DestroyTexture(texture);
                }
                SDL_FreeSurface(surface);
            }
        }
        return;
    }
    
    SDL_Color color = COLORS[key.is_shift_key && shift_pressed ? 3 : 
                            key.pressed ? 1 : key.selected ? 2 : 0];
    
    SDL_SetRenderDrawColor(renderer, color.r, color.g, color.b, color.a);
    SDL_RenderFillRect(renderer, &key.rect);
    
    SDL_SetRenderDrawColor(renderer, COLORS[5].r, COLORS[5].g, COLORS[5].b, COLORS[5].a);
    SDL_RenderDrawRect(renderer, &key.rect);
    
    if (key.selected) {
        SDL_Rect border = {key.rect.x - 2, key.rect.y - 2, key.rect.w + 4, key.rect.h + 4};
        SDL_SetRenderDrawColor(renderer, COLORS[6].r, COLORS[6].g, COLORS[6].b, COLORS[6].a);
        SDL_RenderDrawRect(renderer, &border);
        border = {key.rect.x - 1, key.rect.y - 1, key.rect.w + 2, key.rect.h + 2};
        SDL_RenderDrawRect(renderer, &border);
    }
    
    if (!font || key.display_text.empty()) return;
    
    SDL_Surface* surface = TTF_RenderUTF8_Blended(font, key.display_text.c_str(), COLORS[4]);
    if (!surface) return;
    
    SDL_Texture* texture = SDL_CreateTextureFromSurface(renderer, surface);
    if (texture) {
        SDL_Rect text_rect = {key.rect.x + (key.rect.w - surface->w) / 2,
                             key.rect.y + (key.rect.h - surface->h) / 2,
                             surface->w, surface->h};
        SDL_RenderCopy(renderer, texture, nullptr, &text_rect);
        SDL_DestroyTexture(texture);
    }
    SDL_FreeSurface(surface);
}

void handle_key_action(int index, bool press) {
    if (index < 0 || index >= (int)keys.size()) return;
    
    Key& key = keys[index];
    key.pressed = press;
    
    if (press) {
        if (key.display_text == "CLOSE") {
            close_requested = true;
        } else if (key.is_shift_key) {
            shift_pressed = !shift_pressed;
            update_key_display();
        } else if (key.display_text == "DEL" && !input_text.empty()) {
            input_text.pop_back();
            update_preview();
            send_key_event(KEY_BACKSPACE, true);
        } else if (key.display_text == "ESPACE") {
            input_text += ' ';
            update_preview();
            send_key_event(KEY_SPACE, true);
        } else if (key.display_text == "ENTER") {
            input_text += '\n';
            update_preview();
            send_key_event(KEY_ENTER, true);
        } else if (key.display_text == "TAB") {
            input_text += '\t';
            update_preview();
            send_key_event(KEY_TAB, true);
        } else if (key.primary != '\0') {
            char to_add;
            
            // Para letras, use maiúscula/minúscula baseado no shift
            if (key.primary >= 'a' && key.primary <= 'z') {
                to_add = shift_pressed ? (key.primary - 'a' + 'A') : key.primary;
            }
            // Para números, símbolos e outros caracteres, manter o original
            else {
                to_add = key.primary;
            }
            
            input_text += to_add;
            update_preview();
            
            // Enviar evento do teclado
            bool needs_shift = false;
            int keycode_to_send = key.physical_keycode;
            
            // Verificar se precisa do shift para letras maiúsculas
            if (shift_pressed && key.primary >= 'a' && key.primary <= 'z') {
                needs_shift = true;
            }
            
            if (needs_shift) {
                send_key_event(KEY_LEFTSHIFT, true);
            }
            send_key_event(keycode_to_send, true);
        }
    } else {
        if (key.display_text == "DEL") {
            send_key_event(KEY_BACKSPACE, false);
        } else if (key.display_text == "ESPACE") {
            send_key_event(KEY_SPACE, false);
        } else if (key.display_text == "ENTER") {
            send_key_event(KEY_ENTER, false);
        } else if (key.display_text == "TAB") {
            send_key_event(KEY_TAB, false);
        } else if (key.primary != '\0' && key.display_text != "CLOSE") {
            bool needs_shift = false;
            
            // Verificar se precisa do shift para letras maiúsculas
            if (shift_pressed && key.primary >= 'a' && key.primary <= 'z') {
                needs_shift = true;
            }
            
            send_key_event(key.physical_keycode, false);
            if (needs_shift) {
                send_key_event(KEY_LEFTSHIFT, false);
            }
        }
    }
}

void navigate_keys(int dir) {
    if (keys.empty() || !keyboard_visible) return;
    
    keys[selected_key_index].selected = false;
    const SDL_Rect& curr = keys[selected_key_index].rect;
    int best = selected_key_index;
    float best_score = 999999.0f;
    
    for (size_t i = 0; i < keys.size(); i++) {
        if (i == (size_t)selected_key_index) continue;
        
        const SDL_Rect& tgt = keys[i].rect;
        int dx = tgt.x + tgt.w/2 - (curr.x + curr.w/2);
        int dy = tgt.y + tgt.h/2 - (curr.y + curr.h/2);
        
        bool valid = false;
        float score = 0;
        
        switch (dir) {
            case 0: if (dy < -5) { valid = true; score = -dy + abs(dx) * 0.5f; } break; // Up
            case 1: if (dy > 5) { valid = true; score = dy + abs(dx) * 0.5f; } break;   // Down
            case 2: if (dx < -5) { valid = true; score = -dx + abs(dy) * 0.5f; } break; // Left
            case 3: if (dx > 5) { valid = true; score = dx + abs(dy) * 0.5f; } break;   // Right
        }
        
        if (valid && score < best_score) {
            best_score = score;
            best = i;
        }
    }
    
    selected_key_index = best;
    keys[selected_key_index].selected = true;
}

void handle_analog_movement(float x, float y) {
    if (!keyboard_visible) return;
    
    Uint32 now = SDL_GetTicks();
    
    if (fabs(x) < MOVE_THRESHOLD && fabs(y) < MOVE_THRESHOLD) {
        analog_moved = false;
        return;
    }
    
    if (analog_moved && (now - last_analog_move_time < ANALOG_REPEAT_DELAY)) return;
    
    int dir = (fabs(x) > fabs(y)) ? (x > MOVE_THRESHOLD ? 3 : 2) : (y > MOVE_THRESHOLD ? 1 : 0);
    navigate_keys(dir);
    
    analog_moved = true;
    last_analog_move_time = now;
}

bool load_font() {
    const char* font_paths[] = {
        "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf",
        "/usr/share/fonts/liberation/LiberationSans-Bold.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
        "/usr/share/fonts/TTF/DejaVuSans-Bold.ttf",
        "/storage/.config/emuelec/configs/Font.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
        "arial.ttf"
    };

    // Ajusta tamanho da fonte baseado na resolução
    int font_size = 16;
    if (DISPLAY_WIDTH <= 800) font_size = 12;
    else if (DISPLAY_WIDTH <= 1024) font_size = 14;
    else if (DISPLAY_WIDTH >= 1920) font_size = 18;

    for (const char* path : font_paths) {
        font = TTF_OpenFont(path, font_size);
        if (font) return true;
    }
    return false;
}

bool init_system() {
    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_GAMECONTROLLER) < 0 || TTF_Init() == -1) return false;
    
    for (int i = 0; i < SDL_NumJoysticks(); i++) {
        if (SDL_IsGameController(i) && (controller = SDL_GameControllerOpen(i))) break;
    }
    
    SDL_SetHint(SDL_HINT_FRAMEBUFFER_ACCELERATION, "1");
    SDL_SetHint(SDL_HINT_RENDER_DRIVER, "opengles");
    
    SDL_Rect display;
    SDL_GetDisplayBounds(0, &display);
    
    window = SDL_CreateWindow("Teclado Virtual", 
                             display.x + (display.w - WINDOW_WIDTH) / 2, 0,
                             WINDOW_WIDTH, WINDOW_HEIGHT,
                             SDL_WINDOW_OPENGL | SDL_WINDOW_BORDERLESS);
    
    if (!window) return false;
    
    renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
    if (!renderer) return false;
    
    SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND);
    return load_font();
}

void cleanup() {
    if (controller) SDL_GameControllerClose(controller);
    if (renderer) SDL_DestroyRenderer(renderer);
    if (window) SDL_DestroyWindow(window);
    if (font) TTF_CloseFont(font);
    TTF_Quit();
    SDL_Quit();
    
    if (uinput_fd >= 0) {
        ioctl(uinput_fd, UI_DEV_DESTROY);
        close(uinput_fd);
    }
}

int main() {
    // Detecta resolução antes de inicializar sistema
    detect_resolution_and_scale();
    
    if (!init_system()) return 1;
    
    if (setup_uinput() < 0) printf("Executando sem uinput (apenas local)\n");
    
    create_keyboard_layout();
    update_key_display();
    
    printf("By DiegroSan Teclado virtual iniciado!\n");
    printf("Resolução: %dx%d | Janela: %dx%d | Teclas: %dpx\n", 
           DISPLAY_WIDTH, DISPLAY_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, KEY_SIZE);
    printf("Controles: Analógico/Setas=navegar, A/Enter=tecla, R3/L3=mostrar/ocultar, L1+Up=mostrar/ocultar\n");
    
    SDL_Event event;
    while (!close_requested) {
        Uint32 now = SDL_GetTicks();
        
        while (SDL_PollEvent(&event)) {
            switch (event.type) {
                case SDL_QUIT: 
                    close_requested = true;
                    break;
                    
                case SDL_KEYDOWN:
                    if (!keyboard_visible) break;
                    if (now - last_button_time <= REPEAT_DELAY) break;
                    switch (event.key.keysym.sym) {
                        case SDLK_UP: navigate_keys(0); break;
                        case SDLK_DOWN: navigate_keys(1); break;
                        case SDLK_LEFT: navigate_keys(2); break;
                        case SDLK_RIGHT: navigate_keys(3); break;
                        case SDLK_RETURN: 
                            handle_key_action(selected_key_index, true);
                            break;
                        case SDLK_ESCAPE: close_requested = true; break;
                    }
                    last_button_time = now;
                    break;
                    
                case SDL_KEYUP:
                    if (!keyboard_visible) break;
                    if (event.key.keysym.sym == SDLK_RETURN) {
                        handle_key_action(selected_key_index, false);
                    }
                    break;  
                case SDL_CONTROLLERBUTTONUP:
                    if (event.cbutton.button == SDL_CONTROLLER_BUTTON_A && keyboard_visible) {
                        handle_key_action(selected_key_index, false);
                    } else if (event.cbutton.button == SDL_CONTROLLER_BUTTON_LEFTSHOULDER) {
                        l1_pressed = false;  // Track L1 release
                    }
                    break;
                    
                case SDL_CONTROLLERAXISMOTION:
                    if (event.caxis.axis == SDL_CONTROLLER_AXIS_LEFTX || 
                        event.caxis.axis == SDL_CONTROLLER_AXIS_LEFTY) {
                        float val = event.caxis.value / 32768.0f;
                        if (fabs(val) < DEAD_ZONE / 32768.0f) val = 0.0f;
                        else val = (val - (DEAD_ZONE / 32768.0f * (val > 0 ? 1 : -1))) / (1.0f - DEAD_ZONE / 32768.0f);
                        
                        if (event.caxis.axis == SDL_CONTROLLER_AXIS_LEFTX) last_axis_x = val * ANALOG_SENSITIVITY;
                        else last_axis_y = val * ANALOG_SENSITIVITY;
                        
                        handle_analog_movement(last_axis_x, last_axis_y);
                    }
                    break;

                case SDL_CONTROLLERBUTTONDOWN:
                    if (now - last_button_time <= REPEAT_DELAY) break;
                    if (event.cbutton.button == SDL_CONTROLLER_BUTTON_A) {
                        if (keyboard_visible) {
                            handle_key_action(selected_key_index, true);
                        }
                    } else if (event.cbutton.button == SDL_CONTROLLER_BUTTON_LEFTSHOULDER) {
                        l1_pressed = true;  // Track L1 press
                    } else if (event.cbutton.button == SDL_CONTROLLER_BUTTON_RIGHTSTICK ||
                              event.cbutton.button == SDL_CONTROLLER_BUTTON_LEFTSTICK) {
                        keyboard_visible = !keyboard_visible;
                        printf("Teclado %s\n", keyboard_visible ? "visível" : "oculto");
                    } else if (l1_pressed) {
                        // Tratar combinação L1 + D-pad
                        if (event.cbutton.button == SDL_CONTROLLER_BUTTON_DPAD_UP) {
                            keyboard_visible = !keyboard_visible;
                            printf("Teclado %s (L1+D-pad Up)\n", keyboard_visible ? "visível" : "oculto");
                            l1_pressed = false; // Reset para evitar toggles rápidos
                        }
                    }
                    last_button_time = now;
                    break;
            }
        }
        
        // Renderização
        SDL_SetRenderDrawColor(renderer, 0, 0, 0, 0);
        SDL_RenderClear(renderer);
        
        if (keyboard_visible) {
            for (const auto& key : keys) render_key(key);
        }
        
        SDL_RenderPresent(renderer);
        SDL_Delay(16);
    }
    
    cleanup();
    return 0;
}
