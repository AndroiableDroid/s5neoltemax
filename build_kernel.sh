
export ARCH=arm64
export CROSS_COMPILE=/home/wilmans2m/toolchains/google/bin/aarch64-linux-android-

make exynos7580-s5neolte_defconfig
make -j2
