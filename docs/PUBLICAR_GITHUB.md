# Publicar Super SNES SPC Player! 1.0

Esta carpeta es la raíz del repositorio preparado. Incluye el código y las dos
ROM de la edición pública 1.0. Los ZIP se entregan por separado.

## Repositorio

Nombre sugerido: `super-snes-spc-player`.

Descripción sugerida:

> A read-only microSD SPC player for SNES, with compatible C700/game drivers,
> playback controls, audio meters and DSP information pages.

Crea el repositorio vacío en tu cuenta de GitHub. Desde una terminal dentro de
esta carpeta, reemplaza la URL de ejemplo por la que corresponda a tu cuenta:

```sh
git init
git add .
git commit -m "Prepare public release 1.0"
git branch -M main
git remote add origin https://github.com/TU_USUARIO/super-snes-spc-player.git
git push -u origin main
```

El paquete no tiene una cuenta, URL remota ni credenciales configuradas. Usa la
carpeta extraída como raíz; no subas la carpeta de trabajo histórica de Codex.

## Release

- Tag: `1.0`.
- Título: `Super SNES SPC Player! 1.0`.
- Texto: copia el contenido de `RELEASE_NOTES.md`.
- Adjunto para jugadores: `Super_SNES_SPC_Player_1_0_ROMs.zip`.
- Adjunto opcional con fuentes: `Super_SNES_SPC_Player_1_0_GitHub.zip`.

`VERSION`, el README, el HUD y los títulos internos de las ROM usan 1.0. El
archivo `manifest.json` identifica los binarios mediante SHA-256. La compatibilidad
es parcial y se documenta por archivo en `docs/compatibility.csv`.

## Licencia

No se ha elegido una licencia general para este proyecto. `CREDITS.md` conserva
la atribución de los recursos suministrados; no asigna una nueva licencia a esos
recursos. La selección de una licencia para el código original queda a cargo de
Luna.
