"""Assembles tool/splash_frames/out/f*.png into splash_preview.gif (25 fps)."""
import glob, sys
from PIL import Image
frames = [Image.open(f).convert('RGB') for f in sorted(glob.glob('tool/splash_frames/out/f*.png'))]
w, h = frames[0].size
box = (0, int(h * 0.16), w, int(h * 0.66))  # crop around the logo
frames = [f.crop(box).resize(((box[2]-box[0]) * 2 // 3, (box[3]-box[1]) * 2 // 3), Image.LANCZOS) for f in frames]
frames += [frames[-1]] * 20  # hold the final logo
out = sys.argv[1] if len(sys.argv) > 1 else 'tool/splash_frames/splash_preview.gif'
frames[0].save(out, save_all=True, append_images=frames[1:], duration=40, loop=0, optimize=True)
print(out, len(frames), 'frames')
