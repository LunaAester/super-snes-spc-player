"""Encode the supplied Windows chord as one shared 8 kHz mono BRR sample."""
from pathlib import Path
import subprocess
import wave
import struct
import json
import numpy as np
import argparse
from brr_codec import encode
B=Path(__file__).resolve().parent
parser=argparse.ArgumentParser()
parser.add_argument('source',type=Path)
parser.add_argument('--ffmpeg',default='ffmpeg')
args=parser.parse_args()
source=args.source
ffmpeg=args.ffmpeg
subprocess.run([ffmpeg,'-y','-v','error','-i',str(source),'-ar','8000','-ac','1','-acodec','pcm_s16le',str(B/'ERROR_PCM.wav')],check=True)
with wave.open(str(B/'ERROR_PCM.wav'),'rb') as w:
    samples=np.frombuffer(w.readframes(w.getnframes()),'<i2').astype(np.int32)
brr,decoded=encode(samples)
(B/'ERROR.BRR').write_bytes(brr)
(B/'ERROR_directory.bin').write_bytes(struct.pack('<4H',*[0x1000]*4))
(B/'effect_error.asm').write_text('.DEFINE EFXPITCH 4\n.include "effect_apu.asm"\n')
(B/'effect_error.link').write_text('[objects]\neffect_error.o\n')
with wave.open(str(B/'ERROR_preview.wav'),'wb') as w:
    w.setnchannels(1);w.setsampwidth(2);w.setframerate(8000);w.writeframes(decoded.tobytes())
report=dict(source='CHORD.WAV',source_bytes=source.stat().st_size,rate=8000,channels=1,
            seconds=len(samples)/8000,BRR_bytes=len(brr),duplicated_sample=False,
            BRR_SNR_dB=float(10*np.log10(np.mean(samples.astype(float)**2)/np.mean((decoded.astype(float)-samples)**2))))
(B/'error_audio.json').write_text(json.dumps(report,indent=2))
print(report)

