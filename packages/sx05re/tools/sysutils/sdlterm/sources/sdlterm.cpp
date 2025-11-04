#include <SDL2/SDL.h>
#include <SDL2/SDL_ttf.h>

#include <fstream>
#include <iostream>
#include <thread>
#include <mutex>
#include <vector>
#include <string>
#include <cstdlib>
#include <cstdio>
#include <cmath>

std::vector<std::string> output_lines;
std::mutex output_mutex;
bool running = true;

void read_script_output(const std::string& cmd) {
    FILE* pipe = popen(cmd.c_str(), "r");
    if (!pipe) {
        std::lock_guard<std::mutex> lock(output_mutex);
        output_lines.push_back("Failed to run script.");
        running = false;
        return;
    }

    std::ofstream logfile("/emuelec/logs/sdlterm.log", std::ios::out | std::ios::trunc);
    if (!logfile) {
        std::cerr << "[ERROR] Could not open log file /emuelec/logs/sdlterm.log\n";
    } else {
        logfile << "Output for: " << cmd << "\n\n";
    }

    char buffer[256];
    while (fgets(buffer, sizeof(buffer), pipe)) {
        std::string line(buffer);

        // Strip trailing newline/carriage return
        while (!line.empty() && (line.back() == '\n' || line.back() == '\r')) {
            line.pop_back();
        }

        {
            std::lock_guard<std::mutex> lock(output_mutex);
            output_lines.push_back(line);
        }

        if (logfile) {
            logfile << line << std::endl;
        }
    }

    if (logfile) {
        logfile << "All finished.\n";
    }

    pclose(pipe);
    running = false;
}

void draw_filled_circle(SDL_Renderer* renderer, int cx, int cy, int radius) {
    for (int dy = -radius; dy <= radius; ++dy) {
        int width = static_cast<int>(sqrt(radius * radius - dy * dy));
        SDL_RenderDrawLine(renderer, cx - width, cy + dy, cx + width, cy + dy);
    }
}

int main(int argc, char* argv[]) {
    std::string title = "EmuELEC";
    std::string run_cmd;
    std::string run_args;
    bool wait_after_finish = false;

    // Parse arguments
    for (int i = 1; i < argc; ++i) {
        std::string arg = argv[i];
        if (arg == "--title" && i + 1 < argc) {
            title = std::string("EmuELEC - ") + argv[++i];
        } else if (arg == "--run" && i + 1 < argc) {
            run_cmd = argv[++i];
        } else if ((arg == "--runargs" || arg == "--args") && i + 1 < argc) {
            run_args = argv[++i];
        } else if (arg == "--wait") {
            wait_after_finish = true;
        } else {
            std::cerr << "Unknown argument: " << arg << std::endl;
            std::cerr << "Usage: --title <title> --run <script> [--runargs <args>] [--wait]" << std::endl;
            return 1;
        }
    }

    if (run_cmd.empty()) {
        std::cerr << "Usage: --title <title> --run <script> [--runargs <args>] [--wait]" << std::endl;
        return 1;
    }

    std::string full_cmd = "bash -c '" + run_cmd + " " + run_args + "'";
    std::cout << "[DEBUG] Full command: " << full_cmd << std::endl;

    // Initialize SDL
    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_GAMECONTROLLER) != 0) {
        std::cerr << "SDL_Init error: " << SDL_GetError() << std::endl;
        return 1;
    }

    if (TTF_Init() == -1) {
        std::cerr << "TTF_Init error: " << TTF_GetError() << std::endl;
        SDL_Quit();
        return 1;
    }

    // Load controller mappings
    const char* mapping_file = std::getenv("SDL_GAMECONTROLLERCONFIG_FILE");
    if (mapping_file) {
        if (SDL_GameControllerAddMappingsFromFile(mapping_file) == -1) {
            std::cerr << "Warning: Could not load mappings: " << SDL_GetError() << std::endl;
        } else {
            std::cout << "[DEBUG] Loaded controller mappings from: " << mapping_file << std::endl;
        }
    }

    // Open first available game controller
    SDL_GameController* controller = nullptr;
    for (int i = 0; i < SDL_NumJoysticks(); ++i) {
        if (SDL_IsGameController(i)) {
            controller = SDL_GameControllerOpen(i);
            if (controller) {
                std::cout << "Game controller connected: " << SDL_GameControllerName(controller) << std::endl;
                break;
            }
        }
    }

    // Create fullscreen window
    SDL_DisplayMode dm;
    if (SDL_GetCurrentDisplayMode(0, &dm) != 0) {
        std::cerr << "SDL_GetCurrentDisplayMode error: " << SDL_GetError() << std::endl;
        TTF_Quit();
        SDL_Quit();
        return 1;
    }

    SDL_Window* window = SDL_CreateWindow(title.c_str(),
                                          SDL_WINDOWPOS_CENTERED,
                                          SDL_WINDOWPOS_CENTERED,
                                          dm.w, dm.h,
                                          SDL_WINDOW_FULLSCREEN_DESKTOP | SDL_WINDOW_SHOWN);
    if (!window) {
        std::cerr << "SDL_CreateWindow error: " << SDL_GetError() << std::endl;
        if (controller) SDL_GameControllerClose(controller);
        TTF_Quit();
        SDL_Quit();
        return 1;
    }

    SDL_Renderer* renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
    if (!renderer) {
        std::cerr << "SDL_CreateRenderer error: " << SDL_GetError() << std::endl;
        SDL_DestroyWindow(window);
        if (controller) SDL_GameControllerClose(controller);
        TTF_Quit();
        SDL_Quit();
        return 1;
    }

    TTF_Font* font = TTF_OpenFont("/usr/share/retroarch-assets/ozone/regular.ttf", 18);
    if (!font) {
        std::cerr << "TTF_OpenFont error: " << TTF_GetError() << std::endl;
        SDL_DestroyRenderer(renderer);
        SDL_DestroyWindow(window);
        if (controller) SDL_GameControllerClose(controller);
        TTF_Quit();
        SDL_Quit();
        return 1;
    }

    SDL_Color white = {255, 255, 255, 255};
    SDL_Color gray = {50, 50, 50, 255};

    // Start script thread
    std::thread script_thread(read_script_output, full_cmd);

    bool quit = false;
    SDL_Event e;
    float angle = 0.0f;

    const int line_height = 20;
    const int output_start_y = 50;
    const int visible_lines = (dm.h - output_start_y) / line_height;

    while (!quit) {
        while (SDL_PollEvent(&e)) {
            if (e.type == SDL_QUIT) {
                quit = true;
            }
            
            if (!running && wait_after_finish) {
                if (e.type == SDL_KEYDOWN || e.type == SDL_CONTROLLERBUTTONDOWN) {
                    quit = true;
                }
            }
        }

        if (!running && !wait_after_finish) {
            quit = true;
        }

        // Clear screen
        SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        SDL_RenderClear(renderer);

        // Draw title bar
        SDL_Rect title_bar = {0, 0, dm.w, 40};
        SDL_SetRenderDrawColor(renderer, gray.r, gray.g, gray.b, gray.a);
        SDL_RenderFillRect(renderer, &title_bar);

        SDL_Surface* title_surface = TTF_RenderText_Blended(font, title.c_str(), white);
        if (title_surface) {
            SDL_Texture* title_texture = SDL_CreateTextureFromSurface(renderer, title_surface);
            if (title_texture) {
                SDL_Rect title_rect = {10, 10, title_surface->w, title_surface->h};
                SDL_RenderCopy(renderer, title_texture, nullptr, &title_rect);
                SDL_DestroyTexture(title_texture);
            }
            SDL_FreeSurface(title_surface);
        }

        // Draw output lines
        {
            std::lock_guard<std::mutex> lock(output_mutex);
            int total_lines = static_cast<int>(output_lines.size());
            int scroll_offset = 0;

            if (running) {
                scroll_offset = std::max(0, total_lines - visible_lines);
            } else {
                scroll_offset = std::max(0, total_lines - static_cast<int>(visible_lines / 1.2));
            }

            int lines_to_draw = std::min(visible_lines, total_lines - scroll_offset);
            for (int i = 0; i < lines_to_draw; ++i) {
                const std::string& line = output_lines[scroll_offset + i];
                if (line.empty()) continue;
                
                SDL_Surface* text_surface = TTF_RenderText_Blended(font, line.c_str(), white);
                if (!text_surface) {
                    std::cerr << "[WARN] Failed to render line: " << line << " - " << TTF_GetError() << std::endl;
                    continue;
                }
                
                SDL_Texture* text_texture = SDL_CreateTextureFromSurface(renderer, text_surface);
                if (!text_texture) {
                    SDL_FreeSurface(text_surface);
                    continue;
                }
                
                SDL_Rect dst = {10, output_start_y + i * line_height, text_surface->w, text_surface->h};
                SDL_RenderCopy(renderer, text_texture, nullptr, &dst);
                SDL_FreeSurface(text_surface);
                SDL_DestroyTexture(text_texture);
            }
        }

        // Draw status indicator
        const int circle_radius = 15;
        const int circle_x = dm.w - 40;
        const int circle_y = 25;

        if (running) {
            angle += 0.05f;
            if (angle > 2 * M_PI) angle -= 2 * M_PI;

            int pulse_radius = circle_radius - static_cast<int>(3 * (1 + sin(angle * 4)));
            SDL_SetRenderDrawColor(renderer, 0, 255, 0, 255);
            draw_filled_circle(renderer, circle_x, circle_y, pulse_radius);
        } else {
            SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255);
            draw_filled_circle(renderer, circle_x, circle_y, circle_radius);

            const char* done_msg = wait_after_finish 
                ? "Script finished! Press any key or gamepad button to exit."
                : "Script finished! Exiting...";
            
            SDL_Surface* done_surface = TTF_RenderText_Blended(font, done_msg, white);
            if (done_surface) {
                SDL_Texture* done_texture = SDL_CreateTextureFromSurface(renderer, done_surface);
                if (done_texture) {
                    SDL_Rect done_rect = {10, dm.h - 40, done_surface->w, done_surface->h};
                    SDL_RenderCopy(renderer, done_texture, nullptr, &done_rect);
                    SDL_DestroyTexture(done_texture);
                }
                SDL_FreeSurface(done_surface);
            }
        }

        SDL_RenderPresent(renderer);
        SDL_Delay(16);
    }

    if (script_thread.joinable()) script_thread.join();

    if (controller) SDL_GameControllerClose(controller);
    TTF_CloseFont(font);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    TTF_Quit();
    SDL_Quit();

    return 0;
}
