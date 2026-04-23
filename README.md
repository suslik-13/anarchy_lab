# ANARCHY lab - Minetest/Luanti Server

## Description

**ANARCHY lab** is a hardcore PvP anarchy server for Minetest (Luanti) with no rules or restrictions. Random spawn, clan system, and complete freedom of action!

### Server Features:
- 🔥 **Anarchy mode** — no rules, do whatever you want
- ⚔️ **Hardcore PvP** — fight with other players
- 🎲 **Random spawn** — new location every time
- 👥 **Clan system** — create alliances or fight against everyone
- 🌍 **Open world** — explore, build, destroy

**Discord community:** https://discord.gg/JUFdNDWAcu

## Server Launch

### Requirements
- Docker
- Docker Compose

### Launch Commands

To start the server use:

```bash
sudo docker compose up
```

To start in background mode:

```bash
sudo docker compose up -d
```

To stop the server:

```bash
sudo docker compose down
```

### Fixing Permission Issues

If you encounter errors related to file configuration or log access permissions during startup, such as:

```
ERROR[Main]: Failed to open "/home/minetest/.minetest/debug.txt": Permission denied
ERROR[Main]: Could not read configuration from "/home/minetest/.minetest/minetest.conf"
```

Run the following command to fix access permissions:

```bash
sudo chmod -R 777 ./luanti_files
```

This command sets full access permissions (read/write/execute) to all files and directories inside `luanti_files`, allowing the Docker container to work freely with configuration, worlds, and mods.

## Project Structure

```
.
├── docker-compose.yml          # Docker Compose configuration
├── luanti_files/               # Server data (mounted in container)
│   ├── minetest.conf          # Main server config
│   ├── games/                 # Game mods and resources
│   │   └── minetest_game/    # Main game with mods
│   ├── mod_data/              # Mod data
│   └── worlds/                # Saved worlds
│       └── anarchy_lab/      # ANARCHY lab server world
└── README.md                  # This file
```

## Network Ports

The server uses the following ports:
- **30013/udp** — main game port
- **30013/tcp** — additional TCP port

Make sure these ports are open in your firewall if you want players to connect from outside.

## Configuration

The main configuration file is located at `./luanti_files/minetest.conf`. You can edit server settings by modifying this file.

After changing the configuration, restart the server:

```bash
sudo docker compose restart
```

## Mods

The server uses many mods, including:
- **3d_armor** — armor and protection
- **mobs_monster, mobs_animal** — mobs and creatures
- **farming, cannabis** — agriculture
- **technic, hopper** — technical mods
- **serverfactions** — clan system
- **stamina** — stamina system
- **awards** — achievements
- And many more...

Full list of mods can be found in the `./luanti_files/games/minetest_game/mods/` directory.

### Discord relay (discordmt)

⚠️ **Important:** The **discordmt** mod has been removed from this build as it was modified and contained bugs.

If you need a Discord relay to connect in-game chat with a Discord channel:

1. Download the official version of the **discordmt** mod from ContentDB: https://content.luanti.org/packages/archfan7411/discordmt/
2. Extract the mod to `./luanti_files/games/minetest_game/mods/discordmt/`
3. Configure the mod according to its documentation
4. In the `docker-compose.yml` file, uncomment the `discordmt` section (container for Discord bot):
   ```yaml
   discordmt:
     image: python:3.11-slim
     container_name: discordmt
     # ... rest of the configuration
   ```
5. Also uncomment the `depends_on: - discordmt` line in the `luanti` section
6. Restart the server: `sudo docker compose up -d`

The official version of the mod is stable and does not contain the known bugs of the modified version.

## Support

If you have problems or questions, join our Discord server: https://discord.gg/JUFdNDWAcu

---

**Welcome to the world of anarchy! There are no rules here!** 🔥
