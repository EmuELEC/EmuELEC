// Vulkan Cube Test - Debug Version
// Compile: gcc vulkan_cube_debug.c -o vulkan_cube_debug -lSDL2 -lvulkan -lm

#include <SDL2/SDL.h>
#include <SDL2/SDL_vulkan.h>
#include <vulkan/vulkan.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define DEBUG(fmt, ...) do { printf("DEBUG [%d]: " fmt "\n", __LINE__, ##__VA_ARGS__); fflush(stdout); } while(0)

int main(int argc, char *argv[]) {
    printf("=== SDL2 + Vulkan 3D Cube Test (Debug) ===\n\n");
    fflush(stdout);

    // Initialize SDL
    DEBUG("Calling SDL_Init");
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        printf("ERROR: SDL_Init failed: %s\n", SDL_GetError());
        return 1;
    }
    DEBUG("SDL_Init succeeded");

    // Create window with Vulkan flag
    DEBUG("Creating SDL window with SDL_WINDOW_VULKAN flag");
    SDL_Window *window = SDL_CreateWindow(
        "Vulkan Cube",
        SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
        800, 600,
        SDL_WINDOW_VULKAN | SDL_WINDOW_SHOWN
    );
    if (!window) {
        printf("ERROR: SDL_CreateWindow failed: %s\n", SDL_GetError());
        SDL_Quit();
        return 1;
    }
    DEBUG("SDL window created: %p", (void*)window);

    // Get required Vulkan extensions from SDL
    DEBUG("Getting required Vulkan extensions from SDL");
    unsigned int extensionCount = 0;
    if (!SDL_Vulkan_GetInstanceExtensions(window, &extensionCount, NULL)) {
        printf("ERROR: SDL_Vulkan_GetInstanceExtensions (count) failed: %s\n", SDL_GetError());
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 1;
    }
    DEBUG("SDL requires %u instance extensions", extensionCount);

    const char **extensionNames = malloc(sizeof(char*) * extensionCount);
    if (!extensionNames) {
        printf("ERROR: malloc failed for extension names\n");
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 1;
    }

    if (!SDL_Vulkan_GetInstanceExtensions(window, &extensionCount, extensionNames)) {
        printf("ERROR: SDL_Vulkan_GetInstanceExtensions (names) failed: %s\n", SDL_GetError());
        free(extensionNames);
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 1;
    }

    DEBUG("Required extensions:");
    for (unsigned int i = 0; i < extensionCount; i++) {
        DEBUG("  [%u] %s", i, extensionNames[i]);
    }

    // Create Vulkan instance
    DEBUG("Creating Vulkan instance");
    VkApplicationInfo appInfo = {
        .sType = VK_STRUCTURE_TYPE_APPLICATION_INFO,
        .pApplicationName = "Vulkan Cube Test",
        .applicationVersion = VK_MAKE_VERSION(1, 0, 0),
        .pEngineName = "No Engine",
        .engineVersion = VK_MAKE_VERSION(1, 0, 0),
        .apiVersion = VK_API_VERSION_1_0
    };

    VkInstanceCreateInfo createInfo = {
        .sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
        .pApplicationInfo = &appInfo,
        .enabledExtensionCount = extensionCount,
        .ppEnabledExtensionNames = extensionNames
    };

    VkInstance instance;
    VkResult result = vkCreateInstance(&createInfo, NULL, &instance);
    if (result != VK_SUCCESS) {
        printf("ERROR: vkCreateInstance failed: %d\n", result);
        free(extensionNames);
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 1;
    }
    DEBUG("Vulkan instance created: %p", (void*)instance);

    // Create surface through SDL
    DEBUG("Creating Vulkan surface via SDL_Vulkan_CreateSurface");
    VkSurfaceKHR surface;
    if (!SDL_Vulkan_CreateSurface(window, instance, &surface)) {
        printf("ERROR: SDL_Vulkan_CreateSurface failed: %s\n", SDL_GetError());
        vkDestroyInstance(instance, NULL);
        free(extensionNames);
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 1;
    }
    DEBUG("Vulkan surface created: %p", (void*)surface);

    // Get physical device
    DEBUG("Enumerating physical devices");
    uint32_t deviceCount = 0;
    vkEnumeratePhysicalDevices(instance, &deviceCount, NULL);
    DEBUG("Found %u physical device(s)", deviceCount);
    
    if (deviceCount == 0) {
        printf("ERROR: No Vulkan devices found\n");
        vkDestroySurfaceKHR(instance, surface, NULL);
        vkDestroyInstance(instance, NULL);
        free(extensionNames);
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 1;
    }

    VkPhysicalDevice *devices = malloc(sizeof(VkPhysicalDevice) * deviceCount);
    if (!devices) {
        printf("ERROR: malloc failed for devices\n");
        vkDestroySurfaceKHR(instance, surface, NULL);
        vkDestroyInstance(instance, NULL);
        free(extensionNames);
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 1;
    }
    
    vkEnumeratePhysicalDevices(instance, &deviceCount, devices);
    VkPhysicalDevice physicalDevice = devices[0];
    DEBUG("Selected physical device: %p", (void*)physicalDevice);

    VkPhysicalDeviceProperties props;
    vkGetPhysicalDeviceProperties(physicalDevice, &props);
    printf("\nUsing device: %s\n", props.deviceName);
    DEBUG("Device API version: %u.%u.%u", 
          VK_VERSION_MAJOR(props.apiVersion),
          VK_VERSION_MINOR(props.apiVersion),
          VK_VERSION_PATCH(props.apiVersion));

    // Find graphics queue family with present support
    DEBUG("Getting queue family properties");
    uint32_t queueFamilyCount = 0;
    vkGetPhysicalDeviceQueueFamilyProperties(physicalDevice, &queueFamilyCount, NULL);
    DEBUG("Found %u queue families", queueFamilyCount);

    VkQueueFamilyProperties *queueFamilies = malloc(sizeof(VkQueueFamilyProperties) * queueFamilyCount);
    if (!queueFamilies) {
        printf("ERROR: malloc failed for queue families\n");
        free(devices);
        vkDestroySurfaceKHR(instance, surface, NULL);
        vkDestroyInstance(instance, NULL);
        free(extensionNames);
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 1;
    }
    vkGetPhysicalDeviceQueueFamilyProperties(physicalDevice, &queueFamilyCount, queueFamilies);

    uint32_t graphicsFamily = UINT32_MAX;
    for (uint32_t i = 0; i < queueFamilyCount; i++) {
        DEBUG("Queue family %u: flags=0x%x, count=%u", 
              i, queueFamilies[i].queueFlags, queueFamilies[i].queueCount);
        
        if (queueFamilies[i].queueFlags & VK_QUEUE_GRAPHICS_BIT) {
            // Check present support
            VkBool32 presentSupport = VK_FALSE;
            vkGetPhysicalDeviceSurfaceSupportKHR(physicalDevice, i, surface, &presentSupport);
            DEBUG("  Graphics capable, present support: %s", presentSupport ? "YES" : "NO");
            
            if (presentSupport && graphicsFamily == UINT32_MAX) {
                graphicsFamily = i;
            }
        }
    }

    if (graphicsFamily == UINT32_MAX) {
        printf("ERROR: No suitable queue family found\n");
        free(queueFamilies);
        free(devices);
        vkDestroySurfaceKHR(instance, surface, NULL);
        vkDestroyInstance(instance, NULL);
        free(extensionNames);
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 1;
    }
    DEBUG("Using queue family %u for graphics and present", graphicsFamily);

    // Create logical device
    DEBUG("Creating logical device");
    float queuePriority = 1.0f;
    VkDeviceQueueCreateInfo queueCreateInfo = {
        .sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO,
        .queueFamilyIndex = graphicsFamily,
        .queueCount = 1,
        .pQueuePriorities = &queuePriority
    };

    const char *deviceExtensions[] = { VK_KHR_SWAPCHAIN_EXTENSION_NAME };
    VkDeviceCreateInfo deviceCreateInfo = {
        .sType = VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO,
        .queueCreateInfoCount = 1,
        .pQueueCreateInfos = &queueCreateInfo,
        .enabledExtensionCount = 1,
        .ppEnabledExtensionNames = deviceExtensions
    };

    VkDevice device;
    result = vkCreateDevice(physicalDevice, &deviceCreateInfo, NULL, &device);
    if (result != VK_SUCCESS) {
        printf("ERROR: vkCreateDevice failed: %d\n", result);
        free(queueFamilies);
        free(devices);
        vkDestroySurfaceKHR(instance, surface, NULL);
        vkDestroyInstance(instance, NULL);
        free(extensionNames);
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 1;
    }
    DEBUG("Logical device created: %p", (void*)device);

    VkQueue graphicsQueue;
    vkGetDeviceQueue(device, graphicsFamily, 0, &graphicsQueue);
    DEBUG("Graphics queue obtained: %p", (void*)graphicsQueue);

    // Get surface capabilities
    DEBUG("Getting surface capabilities");
    VkSurfaceCapabilitiesKHR surfaceCaps;
    result = vkGetPhysicalDeviceSurfaceCapabilitiesKHR(physicalDevice, surface, &surfaceCaps);
    if (result != VK_SUCCESS) {
        printf("ERROR: vkGetPhysicalDeviceSurfaceCapabilitiesKHR failed: %d\n", result);
        vkDestroyDevice(device, NULL);
        free(queueFamilies);
        free(devices);
        vkDestroySurfaceKHR(instance, surface, NULL);
        vkDestroyInstance(instance, NULL);
        free(extensionNames);
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 1;
    }
    
    printf("Surface capabilities:\n");
    printf("  Image count: min=%u, max=%u\n", surfaceCaps.minImageCount, surfaceCaps.maxImageCount);
    printf("  Extent: min=%ux%u, max=%ux%u, current=%ux%u\n",
           surfaceCaps.minImageExtent.width, surfaceCaps.minImageExtent.height,
           surfaceCaps.maxImageExtent.width, surfaceCaps.maxImageExtent.height,
           surfaceCaps.currentExtent.width, surfaceCaps.currentExtent.height);

    // Get surface formats
    DEBUG("Getting surface formats");
    uint32_t formatCount;
    vkGetPhysicalDeviceSurfaceFormatsKHR(physicalDevice, surface, &formatCount, NULL);
    DEBUG("Found %u surface formats", formatCount);
    
    if (formatCount == 0) {
        printf("ERROR: No surface formats available\n");
        vkDestroyDevice(device, NULL);
        free(queueFamilies);
        free(devices);
        vkDestroySurfaceKHR(instance, surface, NULL);
        vkDestroyInstance(instance, NULL);
        free(extensionNames);
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 1;
    }

    VkSurfaceFormatKHR *formats = malloc(sizeof(VkSurfaceFormatKHR) * formatCount);
    vkGetPhysicalDeviceSurfaceFormatsKHR(physicalDevice, surface, &formatCount, formats);
    DEBUG("Using format: %d, colorspace: %d", formats[0].format, formats[0].colorSpace);

    // Get present modes
    DEBUG("Getting present modes");
    uint32_t presentModeCount;
    vkGetPhysicalDeviceSurfacePresentModesKHR(physicalDevice, surface, &presentModeCount, NULL);
    DEBUG("Found %u present modes", presentModeCount);

    // Determine swapchain extent
    VkExtent2D swapExtent;
    if (surfaceCaps.currentExtent.width != UINT32_MAX) {
        swapExtent = surfaceCaps.currentExtent;
    } else {
        swapExtent.width = 800;
        swapExtent.height = 600;
        if (swapExtent.width < surfaceCaps.minImageExtent.width)
            swapExtent.width = surfaceCaps.minImageExtent.width;
        if (swapExtent.width > surfaceCaps.maxImageExtent.width)
            swapExtent.width = surfaceCaps.maxImageExtent.width;
        if (swapExtent.height < surfaceCaps.minImageExtent.height)
            swapExtent.height = surfaceCaps.minImageExtent.height;
        if (swapExtent.height > surfaceCaps.maxImageExtent.height)
            swapExtent.height = surfaceCaps.maxImageExtent.height;
    }
    DEBUG("Swapchain extent: %ux%u", swapExtent.width, swapExtent.height);

    // Create swapchain
    DEBUG("Creating swapchain");
    uint32_t imageCount = surfaceCaps.minImageCount + 1;
    if (surfaceCaps.maxImageCount > 0 && imageCount > surfaceCaps.maxImageCount) {
        imageCount = surfaceCaps.maxImageCount;
    }
    DEBUG("Requesting %u swapchain images", imageCount);

    VkSwapchainCreateInfoKHR swapchainInfo = {
        .sType = VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR,
        .surface = surface,
        .minImageCount = imageCount,
        .imageFormat = formats[0].format,
        .imageColorSpace = formats[0].colorSpace,
        .imageExtent = swapExtent,
        .imageArrayLayers = 1,
        .imageUsage = VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT,
        .imageSharingMode = VK_SHARING_MODE_EXCLUSIVE,
        .preTransform = surfaceCaps.currentTransform,
        .compositeAlpha = VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR,
        .presentMode = VK_PRESENT_MODE_FIFO_KHR,
        .clipped = VK_TRUE,
        .oldSwapchain = VK_NULL_HANDLE
    };

    VkSwapchainKHR swapchain;
    result = vkCreateSwapchainKHR(device, &swapchainInfo, NULL, &swapchain);
    if (result != VK_SUCCESS) {
        printf("ERROR: vkCreateSwapchainKHR failed: %d\n", result);
        free(formats);
        vkDestroyDevice(device, NULL);
        free(queueFamilies);
        free(devices);
        vkDestroySurfaceKHR(instance, surface, NULL);
        vkDestroyInstance(instance, NULL);
        free(extensionNames);
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 1;
    }
    DEBUG("Swapchain created: %p", (void*)swapchain);

    // Get swapchain images
    DEBUG("Getting swapchain images");
    vkGetSwapchainImagesKHR(device, swapchain, &imageCount, NULL);
    VkImage *swapchainImages = malloc(sizeof(VkImage) * imageCount);
    vkGetSwapchainImagesKHR(device, swapchain, &imageCount, swapchainImages);
    DEBUG("Got %u swapchain images", imageCount);

    // Create command pool
    DEBUG("Creating command pool");
    VkCommandPoolCreateInfo poolInfo = {
        .sType = VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO,
        .queueFamilyIndex = graphicsFamily,
        .flags = VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT
    };
    VkCommandPool commandPool;
    result = vkCreateCommandPool(device, &poolInfo, NULL, &commandPool);
    if (result != VK_SUCCESS) {
        printf("ERROR: vkCreateCommandPool failed: %d\n", result);
        // cleanup...
        return 1;
    }
    DEBUG("Command pool created");

    // Allocate command buffer
    DEBUG("Allocating command buffer");
    VkCommandBufferAllocateInfo allocInfo = {
        .sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO,
        .commandPool = commandPool,
        .level = VK_COMMAND_BUFFER_LEVEL_PRIMARY,
        .commandBufferCount = 1
    };
    VkCommandBuffer commandBuffer;
    vkAllocateCommandBuffers(device, &allocInfo, &commandBuffer);
    DEBUG("Command buffer allocated");

    // Create semaphores and fence
    DEBUG("Creating synchronization objects");
    VkSemaphoreCreateInfo semInfo = { .sType = VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO };
    VkSemaphore imageAvailable, renderFinished;
    vkCreateSemaphore(device, &semInfo, NULL, &imageAvailable);
    vkCreateSemaphore(device, &semInfo, NULL, &renderFinished);

    VkFenceCreateInfo fenceInfo = { 
        .sType = VK_STRUCTURE_TYPE_FENCE_CREATE_INFO,
        .flags = VK_FENCE_CREATE_SIGNALED_BIT
    };
    VkFence inFlightFence;
    vkCreateFence(device, &fenceInfo, NULL, &inFlightFence);
    DEBUG("Sync objects created");

    printf("\n=== Starting render loop (5 seconds) ===\n");
    printf("You should see alternating RED and BLUE frames\n\n");
    fflush(stdout);

    int frameCount = 0;
    Uint32 startTime = SDL_GetTicks();
    int running = 1;
    
    while (running && (SDL_GetTicks() - startTime) < 5000) {
        SDL_Event event;
        while (SDL_PollEvent(&event)) {
            if (event.type == SDL_QUIT || 
                (event.type == SDL_KEYDOWN && event.key.keysym.sym == SDLK_ESCAPE)) {
                running = 0;
            }
        }

        // Wait for previous frame
        vkWaitForFences(device, 1, &inFlightFence, VK_TRUE, UINT64_MAX);
        vkResetFences(device, 1, &inFlightFence);

        // Acquire image
        uint32_t imageIndex;
        result = vkAcquireNextImageKHR(device, swapchain, UINT64_MAX, imageAvailable, VK_NULL_HANDLE, &imageIndex);
        if (result != VK_SUCCESS && result != VK_SUBOPTIMAL_KHR) {
            printf("vkAcquireNextImageKHR failed: %d\n", result);
            break;
        }

        // Record command buffer
        vkResetCommandBuffer(commandBuffer, 0);
        
        VkCommandBufferBeginInfo beginInfo = {
            .sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO
        };
        vkBeginCommandBuffer(commandBuffer, &beginInfo);

        // Transition image to COLOR_ATTACHMENT_OPTIMAL
        VkImageMemoryBarrier barrier = {
            .sType = VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER,
            .oldLayout = VK_IMAGE_LAYOUT_UNDEFINED,
            .newLayout = VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,
            .srcQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED,
            .dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED,
            .image = swapchainImages[imageIndex],
            .subresourceRange = {
                .aspectMask = VK_IMAGE_ASPECT_COLOR_BIT,
                .baseMipLevel = 0,
                .levelCount = 1,
                .baseArrayLayer = 0,
                .layerCount = 1
            },
            .srcAccessMask = 0,
            .dstAccessMask = VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT
        };
        vkCmdPipelineBarrier(commandBuffer,
            VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT,
            VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
            0, 0, NULL, 0, NULL, 1, &barrier);

        // Clear with alternating colors
        VkClearColorValue clearColor;
        if (frameCount % 2 == 0) {
            clearColor = (VkClearColorValue){{1.0f, 0.0f, 0.0f, 1.0f}}; // Red
        } else {
            clearColor = (VkClearColorValue){{0.0f, 0.0f, 1.0f, 1.0f}}; // Blue
        }

        VkImageSubresourceRange range = {
            .aspectMask = VK_IMAGE_ASPECT_COLOR_BIT,
            .baseMipLevel = 0,
            .levelCount = 1,
            .baseArrayLayer = 0,
            .layerCount = 1
        };
        vkCmdClearColorImage(commandBuffer, swapchainImages[imageIndex],
            VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL, &clearColor, 1, &range);

        // Transition to PRESENT
        barrier.oldLayout = VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL;
        barrier.newLayout = VK_IMAGE_LAYOUT_PRESENT_SRC_KHR;
        barrier.srcAccessMask = VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT;
        barrier.dstAccessMask = 0;
        vkCmdPipelineBarrier(commandBuffer,
            VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
            VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT,
            0, 0, NULL, 0, NULL, 1, &barrier);

        vkEndCommandBuffer(commandBuffer);

        // Submit
        VkPipelineStageFlags waitStages[] = { VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT };
        VkSubmitInfo submitInfo = {
            .sType = VK_STRUCTURE_TYPE_SUBMIT_INFO,
            .waitSemaphoreCount = 1,
            .pWaitSemaphores = &imageAvailable,
            .pWaitDstStageMask = waitStages,
            .commandBufferCount = 1,
            .pCommandBuffers = &commandBuffer,
            .signalSemaphoreCount = 1,
            .pSignalSemaphores = &renderFinished
        };
        vkQueueSubmit(graphicsQueue, 1, &submitInfo, inFlightFence);

        // Present
        VkPresentInfoKHR presentInfo = {
            .sType = VK_STRUCTURE_TYPE_PRESENT_INFO_KHR,
            .waitSemaphoreCount = 1,
            .pWaitSemaphores = &renderFinished,
            .swapchainCount = 1,
            .pSwapchains = &swapchain,
            .pImageIndices = &imageIndex
        };
        result = vkQueuePresentKHR(graphicsQueue, &presentInfo);
        if (result != VK_SUCCESS && result != VK_SUBOPTIMAL_KHR) {
            printf("vkQueuePresentKHR failed: %d\n", result);
            break;
        }

        frameCount++;
    }

    vkDeviceWaitIdle(device);

    float elapsed = (SDL_GetTicks() - startTime) / 1000.0f;
    printf("\n=== Test Complete ===\n");
    printf("Rendered %d frames in %.2f seconds (%.1f FPS)\n", 
           frameCount, elapsed, frameCount / elapsed);

    // Cleanup
    DEBUG("Starting cleanup");
    vkDestroyFence(device, inFlightFence, NULL);
    vkDestroySemaphore(device, renderFinished, NULL);
    vkDestroySemaphore(device, imageAvailable, NULL);
    vkDestroyCommandPool(device, commandPool, NULL);
    free(swapchainImages);
    vkDestroySwapchainKHR(device, swapchain, NULL);
    free(formats);
    vkDestroyDevice(device, NULL);
    free(queueFamilies);
    free(devices);
    vkDestroySurfaceKHR(instance, surface, NULL);
    vkDestroyInstance(instance, NULL);
    free(extensionNames);
    SDL_DestroyWindow(window);
    SDL_Quit();
    DEBUG("Cleanup complete");

    return 0;
}
