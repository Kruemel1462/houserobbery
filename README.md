# 🏠 House Robbery Script für FiveM

Ein performantes FiveM Script zum Ausrauben von Häusern mit ox_lib Integration.

## ✨ Features

- **Performante ox_lib Zonen** - Optimierte Bereiche um Häuser
- **Interaktive Context Menus** - Elegante Loot-Auswahl mit ox_lib
- **Framework Support** - ESX, QB-Core und Standalone
- **Cooldown System** - Verhindert Spam-Raubüberfälle
- **Polizei Requirement** - Mindestanzahl Polizisten erforderlich
- **Customizable Loot** - Konfigurierbare Gegenstände mit Wahrscheinlichkeiten
- **Admin Commands** - Einfache Verwaltung für Admins
- **Discord Integration** - Optional Webhook Benachrichtigungen

## 🚀 Installation

1. **Dependencies installieren:**
   - [ox_lib](https://github.com/overextended/ox_lib) (erforderlich)
   - ESX oder QB-Core (optional)

2. **Script hinzufügen:**
   ```
   Kopiere den houserobbery Ordner in dein resources Verzeichnis
   ```

3. **Server.cfg konfigurieren:**
   ```cfg
   ensure ox_lib
   ensure houserobbery
   ```

4. **Permissions hinzufügen (optional):**
   ```cfg
   add_ace group.admin houserobbery.admin allow
   ```

## ⚙️ Konfiguration

### Häuser hinzufügen/bearbeiten
Bearbeite `config.lua` um neue Häuser hinzuzufügen oder bestehende zu ändern:

```lua
{
    id = 'house_4',
    name = 'Dein Hausname',
    coords = vector3(x, y, z),
    size = vector3(2.0, 2.0, 2.0),
    rotation = 0.0,
    robbable = true,
    robbed = false,
    lastRobbed = 0,
    loot = {
        {item = 'money', amount = {min = 100, max = 500}, chance = 80},
        {item = 'phone', amount = {min = 1, max = 1}, chance = 30}
    }
}
```

### Loot Items
Neue Items in `Config.LootItems` hinzufügen:

```lua
new_item = {name = 'Item Name', description = 'Item Beschreibung'}
```

### Discord Webhook
In `config.lua` den Webhook URL eintragen:

```lua
Config.DiscordWebhook = "https://discord.com/api/webhooks/YOUR_WEBHOOK_URL"
```

## 🎮 Verwendung

### Für Spieler:
1. Gehe zu einem markierten Haus (Blip auf der Karte)
2. Betrete die Zone um das Haus
3. Drücke **[E]** um den Raub zu starten
4. Warte bis der Progress Bar abgeschlossen ist
5. Wähle deine Beute aus dem Context Menu

### Admin Commands:
- `/resethouse <house_id>` - Setzt ein bestimmtes Haus zurück
- `/resetallhouses` - Setzt alle Häuser zurück

## 🔧 Technische Details

### Performance
- Optimierte ox_lib Zonen reduzieren Server Load
- Effiziente Event Handling
- Minimale Client-Server Kommunikation

### Security
- Server-side Validierung aller Aktionen
- Cooldown System verhindert Exploits
- Item Requirements überprüft

### Kompatibilität
- **ESX** - Vollständig unterstützt
- **QB-Core** - Vollständig unterstützt  
- **Standalone** - Grundfunktionen verfügbar

## 📝 Events

### Client Events:
- `houserobbery:updateRobbedHouses` - Update ausgeraubte Häuser
- `houserobbery:houseReset` - Haus zurückgesetzt

### Server Events:
- `houserobbery:completeRobbery` - Raub abschließen
- `houserobbery:giveLoot` - Loot an Spieler geben
- `houserobbery:removeItem` - Item von Spieler entfernen

## 🛠️ Anpassungen

### Animationen ändern
In `client/main.lua` die Animation anpassen:

```lua
anim = {
    dict = 'dein_animation_dict',
    clip = 'deine_animation'
}
```

### Progress Bar anpassen
Dauer und Style in der `lib.progressBar()` Funktion ändern.

### Context Menu Style
Das Aussehen der Context Menus kann über ox_lib Optionen angepasst werden.

## 🐛 Troubleshooting

### Häufige Probleme:

1. **Zone funktioniert nicht:**
   - Überprüfe ob ox_lib korrekt geladen ist
   - Setze `debug = true` in der Zone

2. **Items werden nicht gegeben:**
   - Überprüfe Framework Detection
   - Stelle sicher dass Items im Inventory existieren

3. **Cooldown funktioniert nicht:**
   - Server Logs auf Fehler überprüfen
   - Admin Commands zum Reset verwenden

## 📞 Support

Bei Problemen oder Fragen:
- Überprüfe die Console auf Fehlermeldungen
- Stelle sicher dass alle Dependencies installiert sind
- Teste mit Standalone Mode ohne Framework

---

**Erstellt mit ❤️ für die FiveM Community**