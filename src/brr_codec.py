"""Integer BRR encoder used for the supplied audio assets."""
import numpy as np

def predict(f,p1,p2):
 p2=p2>>1
 if f==1:return (p1>>1)+((-p1)>>5)
 if f==2:return p1-p2+(p2>>4)+((p1*-3)>>6)
 if f==3:return p1-p2+((p1*-13)>>7)+((p2*3)>>4)
 return 0
def encode(samples):
 out=bytearray();decoded=[];hist=(0,0)
 count=(len(samples)+15)//16
 for block in range(count):
  values=[int(v) for v in samples[block*16:block*16+16]];values += [0]*(16-len(values));best=None
  for f in range(4 if block else 1):
   for shift in range(13):
    p1,p2=hist;error=0;nibbles=[];recon=[];step=1<<shift
    for sample in values:
     pr=predict(f,p1,p2)
     # Choose the closest signed nibble; evaluate neighbours for integer rounding.
     q=max(-8,min(7,round((sample/2-pr)*2/step)))
     options=[]
     for n in {max(-8,q-1),q,min(7,q+1)}:
      s=((n<<shift)>>1)+pr;s=max(-32768,min(32767,s));s=((s*2+32768)&65535)-32768
      options.append(((s-sample)**2,n,s))
     err,n,s=min(options);error+=err;nibbles.append(n&15);recon.append(s);p2,p1=p1,s
    if best is None or error<best[0]:best=(error,f,shift,nibbles,recon,(p1,p2))
  _,f,shift,nibs,recon,hist=best
  out.append((shift<<4)|(f<<2)|(1 if block==count-1 else 0))
  out+=bytes((nibs[i]<<4)|nibs[i+1] for i in range(0,16,2));decoded+=recon
 return bytes(out),np.array(decoded[:len(samples)],dtype=np.int16)
