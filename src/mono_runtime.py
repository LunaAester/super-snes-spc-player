"""Resident, reversible DSP panning, installed only in checked unused ARAM.
Shadow volumes contain the intended DSP values AFTER global volume scaling.
Default stereo/unity restores the source's original DSP writer instructions.
"""
import struct
class Code:
 def __init__(self):self.c=bytearray();self.labels={};self.fix=[]
 def e(self,*v):self.c.extend(v)
 def label(self,s):self.labels[s]=len(self.c)
 def br(self,op,s):self.e(op,0);self.fix.append((len(self.c)-1,s,1))
 def abs(self,op,s,offset=0):self.e(op,0,0);self.fix.append((len(self.c)-2,s,2,offset))
 def mov(self,dp,value):self.e(0x8f,value,dp)
 def finish(self,addresses):
  for f in self.fix:
   at,s,width=f[:3]
   if width==1:
    d=self.labels[s]-at-1
    assert -128<=d<128,(s,d)
    self.c[at]=d&255
   else:struct.pack_into('<H',self.c,at,addresses[s]+f[3])
  return self.c

def build(allocate,sites,modified,relocated,volume_wrapper,pcall_short=True):
 blocks={};addr={};patches=[]
 # Shadow's last byte is scratch: FIR7 is not a volume register.
 addr['shadow']=allocate(128);addr['half']=addr['shadow']+127
 raw=Code();blocks['raw']=raw
 raw.e(0x0d,0x2d,0x4d,0x6d,0x20,0xfd,0xe8);raw.label('mode');raw.e(0)
 raw.br(0xf0,'pass');raw.e(0xe4,0xf2,0x28,0x4f,0x68,0x0c);raw.br(0xf0,'master')
 raw.e(0xe4,0xf2,0x28,0x0e);raw.br(0xd0,'pass')
 raw.e(0xe8,1);raw.br(0x2f,'mask')
 raw.label('master');raw.e(0xe8,16)
 raw.label('mask');raw.abs(0xc5,'mask_operand');raw.e(0xe4,0xf2,0x28,0x7f,0x5d,0xdd)
 raw.abs(0xd5,'shadow');raw.e(0x7d,0x48);raw.label('mask_operand');raw.e(1,0x5d)
 raw.abs(0xf5,'shadow');raw.e(0x68,0x80,0x7c);raw.abs(0xc5,'half')
 raw.e(0xdd,0x68,0x80,0x7c,0x60);raw.abs(0x85,'half');raw.e(0xfd,0xe4,0xf2,0x48)
 raw.label('mask2');raw.e(1,0xc4,0xf2,0xdd,0xc4,0xf3,0xe4,0xf2,0x48)
 raw.label('mask3');raw.e(1,0xc4,0xf2)
 raw.label('pass');raw.e(0xdd,0xc4,0xf3,0xee,0xce,0xae,0x8e,0x6f)
 # Patch all three XOR operands together via a tiny callable selector.
 # The first store above is replaced with CALL; two additional stores reside here.
 selector=Code();blocks['selector']=selector
 for name in ('mask_operand','mask2','mask3'):selector.abs(0xc5,name)
 selector.e(0x6f)
 # C5 originally stored the mask; change the operation to CALL selector.
 maskfix=next(f for f in raw.fix if f[1]=='mask_operand');raw.c[maskfix[0]-1]=0x3f
 raw.fix[raw.fix.index(maskfix)]=(maskfix[0],'selector',2,0)
 volume,gain=volume_wrapper();vol=Code();vol.c=volume[:-1] # remove RTS
 # Existing function has restored registers. Re-enter raw without changing input.
 # This would lose the scaled value; replace its DSP store with CALL raw instead.
 write=vol.c.index(b'\xc4\xf3',30)
 vol.c[write:write+2]=b'\x3f\0\0';vol.fix.append((write+1,'raw',2,0));vol.e(0x6f)
 blocks['volume']=vol
 for name,code in blocks.items():addr[name]=allocate(len(code.c))
 addr['mode']=addr['raw']+raw.labels['mode'];addr['gain']=addr['volume']+gain
 for name in ('mask_operand','mask2','mask3'):addr[name]=addr['raw']+raw.labels[name]
 # Change output mode using a full snapshot, then restore only volume registers.
 mode=Code();blocks['toggle']=mode
 mode.e(0x28,1);mode.abs(0x65,'mode');mode.br(0xf0,'done');mode.e(0x68,0);mode.br(0xf0,'stereo')
 mode.e(0xcd,0)
 mode.label('snapshot');mode.e(0xd8,0xf2,0xe4,0xf3);mode.abs(0xd5,'shadow');mode.e(0x3d,0xc8,128);mode.br(0xd0,'snapshot')
 mode.e(0xe8,1);mode.abs(0xc5,'mode');mode.e(0xcd,0);mode.br(0x2f,'scan')
 mode.label('stereo');mode.e(0xe8,0);mode.abs(0xc5,'mode');mode.e(0xcd,0)
 mode.label('scan');mode.e(0x7d,0x28,0x4f,0x68,0x0c);mode.br(0xf0,'volume')
 mode.e(0x7d,0x28,0x0e);mode.br(0xd0,'next')
 mode.label('volume');mode.e(0xd8,0xf2);mode.abs(0xf5,'shadow');mode.abs(0x3f,'raw')
 mode.label('next');mode.e(0x3d,0xc8,128);mode.br(0xd0,'scan')
 mode.abs(0xe5,'mode');mode.br(0xf0,'done');mode.abs(0x3f,'clear_echo')
 mode.label('done');mode.e(0x6f);addr['toggle']=allocate(len(mode.c))
 echo=Code();blocks['clear_echo']=echo
 # FLG bit 5 disables echo writes, not echo reads. Old stereo history remains
 # audible when writes are disabled; clear the checked echo area in either case.
 echo.mov(0xf2,0x6d);echo.e(0xe4,0xf3);echo.abs(0xc5,'clear_destination',1)
 echo.e(0xe8,0);echo.abs(0xc5,'clear_limit')
 echo.mov(0xf2,0x7d);echo.e(0xe4,0xf3,0x28,15);echo.br(0xf0,'tiny')
 echo.e(0x1c,0x1c,0x1c,0xfd);echo.br(0x2f,'page')
 echo.label('tiny');echo.e(0x8d,1,0xe8,4);echo.abs(0xc5,'clear_limit')
 echo.label('page');echo.e(0xcd,0)
 echo.label('byte');echo.abs(0xe5,'clear_destination',1);echo.br(0xd0,'write')
 echo.e(0xc8,0xf0);echo.br(0xb0,'next_page') # skip hardware I/O on wrapping page 0
 echo.label('write');echo.e(0xe8,0,0xd5);echo.label('clear_destination');echo.e(0,0)
 echo.e(0x3d,0xc8);echo.label('clear_limit');echo.e(0);echo.br(0xd0,'byte')
 echo.label('next_page');echo.abs(0xac,'clear_destination',1);echo.e(0xdc);echo.br(0xd0,'page')
 echo.label('done');echo.e(0x6f);addr['clear_echo']=allocate(len(echo.c));addr['clear_destination']=addr['clear_echo']+echo.labels['clear_destination'];addr['clear_limit']=addr['clear_echo']+echo.labels['clear_limit']
 # Preserve branches entering an instruction immediately after a DSP store.
 bridges={};pcall={}
 for at,amount,writerlen,prefix in sites:
  original=bytes(modified[at+prefix:at+prefix+writerlen]);target=addr['volume']
  if writerlen==2 and pcall_short:
   # PCALL occupies exactly two bytes. Shared branches can still enter the
   # original next instruction; the checked trampoline is below the IPL ROM.
   if original not in pcall:
    if original==b'\xc4\xf3':body=b'\x3f'+struct.pack('<H',target)+b'\x6f'
    else:
     load=b'\x7d' if original[0]==0xd8 else b'\xdd'
     body=b'\x0d\x2d'+load+b'\x3f'+struct.pack('<H',target)+b'\xae\x8e\x6f'
    key='pcall'+str(len(pcall));c=Code();c.c=bytearray(body);blocks[key]=c;addr[key]=allocate(len(body),ff_only=True);pcall[original]=addr[key]
   patches.append((at,original,bytes((0x4f,pcall[original]&255))))
   continue
  if original not in (b'\xc4\xf3',b'\xc5\xf3\0'):
   if original not in bridges:
    load=bytes((0xe4,original[1])) if original[0]==0xfa else bytes((0xe8,original[1])) if original[0]==0x8f else b'\x7d' if original[0] in (0xd8,0xc9) else b'\xdd'
    body=b'\x0d\x2d'+load+b'\x3f'+struct.pack('<H',addr['volume'])+b'\xae\x8e\x6f'
    key='bridge'+str(len(bridges));c=Code();c.c=bytearray(body);blocks[key]=c;addr[key]=allocate(len(body));bridges[original]=addr[key]
   target=bridges[original]
  body=b'\x3f'+struct.pack('<H',target)+relocated(modified,at+prefix+writerlen,amount-prefix-writerlen)
  if prefix:
   dest=(at+prefix+int.from_bytes(modified[at+prefix-1:at+prefix],'little',signed=True))&65535
   body=bytes(modified[at:at+prefix-1])+bytes([len(body)])+body+b'\x5f'+struct.pack('<H',dest)
  key='writer'+str(len(patches));c=Code();c.c=bytearray(body);blocks[key]=c;addr[key]=allocate(len(body))
  patches.append((at,bytes(modified[at:at+amount]),(b'\x5f'+struct.pack('<H',addr[key])).ljust(amount,b'\0')))
 flat=[(dest+i,old,new) for dest,olds,news in patches for i,(old,new) in enumerate(zip(olds,news))]
 chunks=[flat[i:i+60] for i in range(0,len(flat),60)];tables=[]
 for i,chunk in enumerate(chunks):
  values=b''.join(struct.pack('<HBB',dest,old,new) for dest,old,new in chunk);where=allocate(len(values),True)
  key='table'+str(i);addr[key]=where;c=Code();c.c=bytearray(values);blocks[key]=c;tables.append(key)
 switches=[]
 for i,chunk in enumerate(chunks):
  c=Code();key='switch'+str(i);blocks[key]=c;switches.append(key)
  c.e(0xcd,0);c.abs(0xe5,'gain');c.br(0xd0,'enabled');c.abs(0xe5,'mode');c.br(0xd0,'enabled');c.e(0xe8,2);c.br(0x2f,'column')
  c.label('enabled');c.e(0xe8,3)
  c.label('column');c.e(0x60,0x88,0);lowop=len(c.c)-1
  c.abs(0xc5,key+'_read_operand');c.label('loop')
  c.abs(0xf5,tables[i]);c.abs(0xc5,key+'_write_operand')
  c.abs(0xf5,tables[i],1);c.abs(0xc5,key+'_write_operand',1)
  c.e(0xf5);c.label('read_operand');c.e(0,0)
  c.e(0xc5);c.label('write_operand');c.e(0,0,0x7d,0x60,0x88,4,0x5d,0xc8,len(chunk)*4);c.br(0xd0,'loop')
  if i+1<len(chunks):c.abs(0x5f,'switch'+str(i+1))
  else:c.e(0x6f)
  addr[key]=allocate(len(c.c));addr[key+'_read_operand']=addr[key]+c.labels['read_operand'];addr[key+'_write_operand']=addr[key]+c.labels['write_operand'];c.c[lowop]=addr[tables[i]]&255
  struct.pack_into('<H',c.c,c.labels['read_operand'],addr[tables[i]]+2)
 dispatch=Code();blocks['dispatch']=dispatch
 dispatch.e(0x6d,0xfd,0xe4,0xf7,0x68,0x6b);dispatch.br(0xf0,'mono')
 dispatch.e(0xdd);dispatch.abs(0xc5,'gain');dispatch.br(0x2f,'patch')
 dispatch.label('mono');dispatch.e(0xdd);dispatch.abs(0x3f,'toggle')
 dispatch.label('patch');dispatch.abs(0x3f,switches[0]);dispatch.e(0xee,0x6f);addr['dispatch']=allocate(len(dispatch.c))
 segments=[(addr['shadow'],bytes(128))]+[(addr[key],bytes(c.finish(addr))) for key,c in blocks.items()]
 global LAST_MAP
 LAST_MAP={key:(addr[key],len(c.c)) for key,c in blocks.items()}
 return segments,patches,addr['dispatch'],addr['gain'],addr['raw'],addr['mode']
