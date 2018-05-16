alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ?"

smbL = int(input())
smbH = int(input())
text = input().upper()

output = []
for i in range(smbH):
  line = input()
  res = ''
  for ch in text:
    if ch not in alphabet:
      ch = '?'
      
    pos = alphabet.find(ch)
    res += line[pos*smbL:(pos+1)*smbL]
    
  output.append(res)
  
print('\n'.join(output))
