mkdir -p ~/.local/share/pocl/cuda
mkdir -p ~/.local/share/vulkan/explicit_layer.d
mkdir -p ~/.local/share/vulkan/icd.d
mkdir -p ~/.local/share/vulkan/implicit_layer.d
mkdir -p ~/.local/share/vulkan/registry
ln -sf /usr/share/vulkan/explicit_layer.d/VkLayer_khronos_validation.json ~/.local/share/vulkan/explicit_layer.d/
ln -sf /usr/share/vulkan/explicit_layer.d/VkLayer_api_dump.json ~/.local/share/vulkan/explicit_layer.d/
ln -sf /usr/share/vulkan/explicit_layer.d/VkLayer_MESA_overlay.json ~/.local/share/vulkan/explicit_layer.d/
ln -sf /usr/share/vulkan/explicit_layer.d/VkLayer_MESA_screenshot.json ~/.local/share/vulkan/explicit_layer.d/
ln -s /usr/share/vulkan/icd.d/nvidia_icd.json ~/.local/share/vulkan/icd.d/
ln -s /usr/share/vulkan/icd.d/intel_icd.x86_64.json ~/.local/share/vulkan/icd.d/
ln -s /usr/share/vulkan/icd.d/intel_icd.i686.json ~/.local/share/vulkan/icd.d/
ln -sf /usr/share/vulkan/implicit_layer.d/MangoHud.x86_64.json ~/.local/share/vulkan/implicit_layer.d/
ln -sf /usr/share/vulkan/implicit_layer.d/VkLayer_MESA_device_select.json ~/.local/share/vulkan/implicit_layer.d/
ln -sf /usr/share/vulkan/implicit_layer.d/obs_vkcapture_64.json ~/.local/share/vulkan/implicit_layer.d/
ln -s /usr/share/registry/vk.xml ~/.local/share/vulkan/registry/
ln -s /usr/share/pocl/kernel-x86_64-pc-linux-gnu-avx2.bc ~/.local/share/pocl/
ln -s /usr/share/pocl/cuda/builtins.cl ~/.local/share/pocl/cuda/
ln -s /usr/share/pocl/cuda/builtins_sm50.ptx ~/.local/share/pocl/cuda/
