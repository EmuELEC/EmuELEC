#include <SDL2/SDL.h>
#include <SDL2/SDL_vulkan.h>
#include <vulkan/vulkan.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[]) {
    printf("=== SDL2 + Vulkan Display Test ===\n\n");

    // Initialize SDL
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        printf("ERROR: SDL_Init failed: %s\n", SDL_GetError());
        return 1;
    }
    printf("SDL initialized successfully\n");

    // Create window with Vulkan flag
    SDL_Window *window = SDL_CreateWindow(
        "Vulkan Test",
        SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
        1920, 1080,
        SDL_WINDOW_VULKAN | SDL_WINDOW_FULLSCREEN
    );
    
    if (!window) {
        printf("ERROR: SDL_CreateWindow failed: %s\n", SDL_GetError());
        SDL_Quit();
        return 1;
    }
    printf("SDL window created successfully\n");

    // Get required Vulkan extensions from SDL
    unsigned int extensionCount = 0;
    if (!SDL_Vulkan_GetInstanceExtensions(window, &extensionCount, NULL)) {
        printf("ERROR: SDL_Vulkan_GetInstanceExtensions failed: %s\n", SDL_GetError());
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 1;
    }
    
    const char **extensionNames = malloc(sizeof(char*) * extensionCount);
    SDL_Vulkan_GetInstanceExtensions(window, &extensionCount, extensionNames);
    
    printf("SDL requires %d Vulkan extensions:\n", extensionCount);
    for (unsigned int i = 0; i < extensionCount; i++) {
        printf("  - %s\n", extensionNames[i]);
    }

    // Create Vulkan instance
    VkApplicationInfo appInfo = {
        .sType = VK_STRUCTURE_TYPE_APPLICATION_INFO,
        .pApplicationName = "Vulkan Test",
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
    printf("Vulkan instance created successfully\n");

    // Create surface through SDL
    VkSurfaceKHR surface;
    if (!SDL_Vulkan_CreateSurface(window, instance, &surface)) {
        printf("ERROR: SDL_Vulkan_CreateSurface failed: %s\n", SDL_GetError());
        vkDestroyInstance(instance, NULL);
        free(extensionNames);
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 1;
    }
    printf("Vulkan surface created successfully through SDL\n");

    // Get physical device
    uint32_t deviceCount = 0;
    vkEnumeratePhysicalDevices(instance, &deviceCount, NULL);
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
    vkEnumeratePhysicalDevices(instance, &deviceCount, devices);
    VkPhysicalDevice physicalDevice = devices[0];

    VkPhysicalDeviceProperties props;
    vkGetPhysicalDeviceProperties(physicalDevice, &props);
    printf("Using device: %s\n", props.deviceName);

    // Find graphics queue family
    uint32_t queueFamilyCount = 0;
    vkGetPhysicalDeviceQueueFamilyProperties(physicalDevice, &queueFamilyCount, NULL);
    VkQueueFamilyProperties *queueFamilies = malloc(sizeof(VkQueueFamilyProperties) * queueFamilyCount);
    vkGetPhysicalDeviceQueueFamilyProperties(physicalDevice, &queueFamilyCount, queueFamilies);

    uint32_t graphicsFamily = UINT32_MAX;
    for (uint32_t i = 0; i < queueFamilyCount; i++) {
        if (queueFamilies[i].queueFlags & VK_QUEUE_GRAPHICS_BIT) {
            graphicsFamily = i;
            break;
        }
    }
    printf("Graphics queue family: %d\n", graphicsFamily);

    // Create logical device
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
    printf("Vulkan device created successfully\n");

    VkQueue graphicsQueue;
    vkGetDeviceQueue(device, graphicsFamily, 0, &graphicsQueue);

    // Get surface capabilities
    VkSurfaceCapabilitiesKHR surfaceCaps;
    vkGetPhysicalDeviceSurfaceCapabilitiesKHR(physicalDevice, surface, &surfaceCaps);
    printf("Surface capabilities: min=%dx%d max=%dx%d current=%dx%d\n",
           surfaceCaps.minImageExtent.width, surfaceCaps.minImageExtent.height,
           surfaceCaps.maxImageExtent.width, surfaceCaps.maxImageExtent.height,
           surfaceCaps.currentExtent.width, surfaceCaps.currentExtent.height);

    // Get surface formats
    uint32_t formatCount;
    vkGetPhysicalDeviceSurfaceFormatsKHR(physicalDevice, surface, &formatCount, NULL);
    VkSurfaceFormatKHR *formats = malloc(sizeof(VkSurfaceFormatKHR) * formatCount);
    vkGetPhysicalDeviceSurfaceFormatsKHR(physicalDevice, surface, &formatCount, formats);
    printf("Surface format: %d (colorspace: %d)\n", formats[0].format, formats[0].colorSpace);

    // Create swapchain
    VkSwapchainCreateInfoKHR swapchainInfo = {
        .sType = VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR,
        .surface = surface,
        .minImageCount = surfaceCaps.minImageCount + 1,
        .imageFormat = formats[0].format,
        .imageColorSpace = formats[0].colorSpace,
        .imageExtent = surfaceCaps.currentExtent,
        .imageArrayLayers = 1,
        .imageUsage = VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT,
        .imageSharingMode = VK_SHARING_MODE_EXCLUSIVE,
        .preTransform = surfaceCaps.currentTransform,
        .compositeAlpha = VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR,
        .presentMode = VK_PRESENT_MODE_FIFO_KHR,
        .clipped = VK_TRUE
    };

    VkSwapchainKHR swapchain;
    result = vkCreateSwapchainKHR(device, &swapchainInfo, NULL, &swapchain);
    if (result != VK_SUCCESS) {
        printf("ERROR: vkCreateSwapchainKHR failed: %d\n", result);
        // cleanup...
        return 1;
    }
    printf("Swapchain created successfully!\n");

    // Get swapchain images
    uint32_t imageCount;
    vkGetSwapchainImagesKHR(device, swapchain, &imageCount, NULL);
    VkImage *swapchainImages = malloc(sizeof(VkImage) * imageCount);
    vkGetSwapchainImagesKHR(device, swapchain, &imageCount, swapchainImages);
    printf("Got %d swapchain images\n", imageCount);

    // Create command pool
    VkCommandPoolCreateInfo poolInfo = {
        .sType = VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO,
        .queueFamilyIndex = graphicsFamily,
        .flags = VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT
    };
    VkCommandPool commandPool;
    vkCreateCommandPool(device, &poolInfo, NULL, &commandPool);

    // Allocate command buffer
    VkCommandBufferAllocateInfo allocInfo = {
        .sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO,
        .commandPool = commandPool,
        .level = VK_COMMAND_BUFFER_LEVEL_PRIMARY,
        .commandBufferCount = 1
    };
    VkCommandBuffer commandBuffer;
    vkAllocateCommandBuffers(device, &allocInfo, &commandBuffer);

    // Create semaphores
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

    printf("\n=== Starting render loop (5 seconds) ===\n");
    printf("You should see alternating RED and BLUE frames\n\n");

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
        if (result != VK_SUCCESS) {
            printf("vkAcquireNextImageKHR failed: %d\n", result);
            break;
        }

        // Record command buffer - clear to alternating colors
        vkResetCommandBuffer(commandBuffer, 0);
        VkCommandBufferBeginInfo beginInfo = {
            .sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO
        };
        vkBeginCommandBuffer(commandBuffer, &beginInfo);

        // Transition image to transfer dst
        VkImageMemoryBarrier barrier = {
            .sType = VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER,
            .oldLayout = VK_IMAGE_LAYOUT_UNDEFINED,
            .newLayout = VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
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
            .dstAccessMask = VK_ACCESS_TRANSFER_WRITE_BIT
        };
        vkCmdPipelineBarrier(commandBuffer, 
            VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT, VK_PIPELINE_STAGE_TRANSFER_BIT,
            0, 0, NULL, 0, NULL, 1, &barrier);

        // Clear to color (alternate red/blue every 30 frames)
        VkClearColorValue clearColor;
        if ((frameCount / 30) % 2 == 0) {
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
            VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, &clearColor, 1, &range);

        // Transition to present
        barrier.oldLayout = VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL;
        barrier.newLayout = VK_IMAGE_LAYOUT_PRESENT_SRC_KHR;
        barrier.srcAccessMask = VK_ACCESS_TRANSFER_WRITE_BIT;
        barrier.dstAccessMask = 0;
        vkCmdPipelineBarrier(commandBuffer,
            VK_PIPELINE_STAGE_TRANSFER_BIT, VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT,
            0, 0, NULL, 0, NULL, 1, &barrier);

        vkEndCommandBuffer(commandBuffer);

        // Submit
        VkPipelineStageFlags waitStage = VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT;
        VkSubmitInfo submitInfo = {
            .sType = VK_STRUCTURE_TYPE_SUBMIT_INFO,
            .waitSemaphoreCount = 1,
            .pWaitSemaphores = &imageAvailable,
            .pWaitDstStageMask = &waitStage,
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
        if (result != VK_SUCCESS) {
            printf("vkQueuePresentKHR failed: %d\n", result);
        }

        frameCount++;
        if (frameCount % 60 == 0) {
            printf("Frame %d rendered\n", frameCount);
        }
    }

    printf("\nRendered %d frames in 5 seconds\n", frameCount);
    printf("Test complete!\n");

    // Cleanup
    vkDeviceWaitIdle(device);
    vkDestroyFence(device, inFlightFence, NULL);
    vkDestroySemaphore(device, renderFinished, NULL);
    vkDestroySemaphore(device, imageAvailable, NULL);
    vkDestroyCommandPool(device, commandPool, NULL);
    free(swapchainImages);
    vkDestroySwapchainKHR(device, swapchain, NULL);
    free(formats);
    free(queueFamilies);
    free(devices);
    vkDestroySurfaceKHR(instance, surface, NULL);
    vkDestroyInstance(instance, NULL);
    free(extensionNames);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;
}
