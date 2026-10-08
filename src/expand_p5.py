from pathlib import Path
import re
B=Path(__file__).resolve().parent
inverse={'bcc':'bcs','bcs':'bcc','beq':'bne','bne':'beq','bmi':'bpl','bpl':'bmi','bvc':'bvs','bvs':'bvc'}
for name in ('main.asm','ui.asm','hud_meters.asm','controls.asm','auto_drivers.asm','fat.asm','game_apu.asm','intro.asm','loading_progress.asm','ui_sounds.asm','titles.asm','v13.asm','apu_recovery.asm','credits.asm'):
 p=B/name;s=p.read_text();counter=0;lines=[]
 for line in s.splitlines():
  m=re.fullmatch(r'(\s*)(bcc|bcs|beq|bne|bmi|bpl|bvc|bvs|bra) ([A-Za-z_]\w*)',line)
  if not m or m[3].startswith(('LongBranch_','P5Long_')):lines.append(line);continue
  pre,op,target=m.groups()
  if op=='bra':lines.append(f'{pre}jmp {target}');continue
  label=f'P5Long_{p.stem}_{counter}'
  while label+':' in s:counter+=1;label=f'P5Long_{p.stem}_{counter}'
  counter+=1;lines.extend([f'{pre}{inverse[op]} {label}',f'{pre}jmp {target}',label+':'])
 p.write_text('\n'.join(lines)+'\n')
