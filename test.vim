let asm= vital#of('vital').import('Regexp.Assemble').new()

echo asm.__path
call asm.add('public')
echo asm.__path
call asm.add('protected')
echo asm.__path
call asm.add('private')
echo asm.__path
echo asm.re()
