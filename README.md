#EmuELEC
Retro emulação para dispositivos Amlogic.
Baseado em [CoreELEC](https://github.com/CoreELEC/CoreELEC) e [Lakka](https://github.com/libretro/Lakka-LibreELEC) com petiscos de [Batocera](https://github. com/batocera-linux/batocera.linux). Acabei de combiná-los com [Batocera-Emulationstation](https://github.com/batocera-linux/batocera-emulationstation) e alguns emuladores autônomos ([Advancemame](https://github.com/amadvance/advancemame), [ PPSSPP](https://github.com/hrydgard/ppsspp), [Reicast](https://github.com/reicast/reicast-emulator), [Amiberry](https://github.com/midwan/amiberry ) e outros).

---
[![GitHub Release](https://img.shields.io/github/release/EmuELEC/EmuELEC.svg)](https://github.com/EmuELEC/EmuELEC/releases/latest)
[![GPL-2.0 licenciado](https://shields.io/badge/license-GPL2-blue)](https://github.com/EmuELEC/EmuELEC/blob/master/licenses/GPL2.txt)
[![Discord](https://img.shields.io/badge/chat-on%20discord-7289da.svg?logo=discord)](https://discord.gg/cbgtJTu)

### ⚠️**IMPORTANTE**⚠️
#### EmuELEC agora é APENAS aarch64, compilar e usar a versão ARM após a versão 3.9 não é mais suportada. Por favor, dê uma olhada no branch master_32bit se você quiser construir a versão de 32 bits.

---
## Desenvolvimento

### Pré-requisitos de construção

Estas instruções são apenas para sistemas baseados em Debian/Ubuntu.

```
$ apt install gcc make git unzip wget xz-utils libsdl2-dev libsdl2-mixer-dev libfreeimage-dev libfreetype6-dev libcurl4-openssl-dev rapidjson-dev libasound2-dev libgl1-mesa-dev build-essential libboost-all-dev cmake fonts-droid-fallback libvlc-dev libvlccore-dev vlc-bin texinfo premake4 golang libssl-dev curl patchelf xmlstarlet default-jre xsltproc
```

### Construindo EmuELEC
Para construir o EmuELEC localmente, faça o seguinte:

```
$ git clone https://github.com/EmuELEC/EmuELEC.git
$ cd EmuELEC
$ git checkout dev
$ PROJECT=Amlogic-ce DEVICE=Amlogic-ng ARCH=aarch64 DISTRO=EmuELEC make image
```
Nota: Em alguns casos, você também pode precisar instalar os pacotes tzdata, xfonts-utils e/ou lzop.
```
$ apt install tzdata xfonts-utils lzop
```

Para o Odroid GO Advance/Super:
```
$ PROJECT=Rockchip DEVICE=OdroidGoAdvance ARCH=aarch64 DISTRO=EmuELEC make image
```




**Lembre-se de usar o DTB adequado para o seu dispositivo!**

### Enviando patches
Por favor, crie um pull request com as mudanças que você fez no ramo dev e certifique-se de incluir uma breve descrição do que você mudou e por que você fez isso.

## Entrar em contato
Se você tiver alguma dúvida, sugestões para novos recursos ou precisar de ajuda para configurar ou instalar o EmuELEC, visite [nosso fórum](https://emuelec.discourse.group/). Você também pode visitar nosso [wiki](https://github.com/EmuELEC/EmuELEC/wiki) ou se juntar ao nosso [Discord](https://discord.gg/cbgtJTu).

**EmuELEC NÃO INCLUI KODI**

Observe que este é principalmente um projeto pessoal, não posso garantir que funcionará com sua caixa. Passei muitas horas ajustando muitas coisas e garantindo que tudo funcionasse, mas não posso testar tudo e algumas coisas podem não funcionar ainda. Além disso, esteja ciente das limitações de hardware e não espere que tudo funcione a 60FPS (especialmente N64, PSP e Reicast). Não posso garantir que as alterações serão incorporadas para atender às suas necessidades específicas, mas aceito pull requests, ajuda a testar outras caixas e corrigir problemas em geral.
Estou trabalhando neste projeto em meu tempo livre, não estou ganhando dinheiro com isso, então vou demorar um pouco para testar todas as mudanças corretamente, mas farei o possível para ajudá-lo a corrigir quaisquer problemas que você poderia ter em outras caixas, em meu tempo livre.

## Licença

O EmuELEC é baseado no CoreELEC, que por sua vez é licenciado sob a GPLv2 (e GPLv2 ou posterior). Todos os arquivos originais criados pela equipe EmuELEC são licenciados como GPLv2 ou posterior e marcados como tal.

No entanto, a distro contém muitos emuladores/bibliotecas/núcleos/binários não comerciais e, portanto, **não pode ser vendido, agrupado, oferecido, incluído em produtos/aplicativos comerciais ou qualquer coisa semelhante, incluindo, entre outros, dispositivos Android, smart TVs, TV caixas, dispositivos portáteis, computadores, SBCs ou qualquer outra coisa que possa executar o EmuELEC** com os emuladores/bibliotecas/núcleos/binários incluídos.

Observe também a seção de licença do README da equipe CoreELEC, que foi adaptada para EmuELEC:

Como o EmuELEC inclui código de muitos projetos upstream, ele inclui muitos proprietários de direitos autorais. A EmuELEC NÃO reivindica direitos autorais sobre qualquer código upstream. Patches para código upstream têm a mesma licença que o projeto upstream, a menos que especificado de outra forma. Para obter uma lista completa de direitos autorais, verifique o código-fonte para examinar os cabeçalhos de licença. A menos que expressamente declarado de outra forma, todo o código enviado ao projeto EmuELEC (em qualquer forma) é licenciado sob GPLv2 ou posterior. Você é absolutamente livre para reter os direitos autorais. Para manter os direitos autorais, basta adicionar um cabeçalho de direitos autorais a cada página de código enviada. Se você enviar um código que não seja de sua autoria, é sua responsabilidade colocar um cabeçalho declarando os direitos autorais.

### Marca

Todos os logotipos, vídeos, imagens e branding relacionados à EmuELEC i
