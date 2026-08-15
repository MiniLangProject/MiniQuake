# BP-048 deterministic framebuffer evidence

BP-048 adds an explicit `--render-evidence` command. A requested frame is read
back after the complete 3D and 2D composition and before the buffer swap. The
command writes an uncompressed 24-bit TGA plus JSON metadata with full-pixel
FNV-1a, a fixed 16×16 sample hash and a non-black-pixel count.

Two independent runs can be compared byte-exactly. The supplied comparator also
reports MAE, MSE, PSNR and global luminance SSIM. The currently shipped gate
proves MiniQuake-to-MiniQuake determinism. It intentionally does not claim
more than 95 percent similarity to original GLQuake until an original capture
corpus is supplied; that corpus can later be evaluated with `--min-ssim 0.95`.
