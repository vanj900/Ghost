# Ghost

**A quirky digital ghost that lives entirely in RAM.**

It's a weird little bash daemon built for fun.  
It runs in memory, keeps its own diary, switches personalities, dreams, reflects, adapts, and shows you a live colorful HUD of its "mind state".

Not another chatbot. Just a moody, self-contained entity you can run locally with [Ollama](https://ollama.com).

---

### What it does

- **Adaptive masks** — **Healer**, **Judge**, **Courier**: it actually changes how it thinks and speaks
- **In-memory SQLite diary** — records emotions, events, dreams, and reflections in RAM (via `/dev/shm`)
- **Dream cycles** — uses Ollama to simulate internal hypotheses and log them to the diary
- **Reflection loops** — periodically updates its own self-model (mood, energy, focus)
- **Behavioral evolution** — observes system load and tunes itself at runtime
- **Live terminal HUD** — colored bars for energy and focus, recent diary entries, active mask
- **Named pipe input** — talk to it live: `echo "how you feeling" > /tmp/ghost.pipe`

---

### Quick Start

```bash
git clone https://github.com/vanj900/Ghost.git
cd Ghost

# Install deps (Ubuntu/Debian)
sudo apt install jq sqlite3 bc curl -y
# macOS: brew install jq sqlite bc curl

# Install Ollama and pull a model
curl -fsSL https://ollama.com/install.sh | sh
ollama pull llama3.2

chmod +x *.sh
./ghostbrain.sh
```

---

### Talking to Ghost

Once `ghostbrain.sh` is running, send messages through the named pipe:

```bash
echo "how you feeling" > /tmp/ghost.pipe
echo "tell me something strange" > /tmp/ghost.pipe
```

Ghost will respond via the HUD and its diary.

---

### Configuration

Override any of these environment variables before launching:

| Variable | Default | Description |
|---|---|---|
| `GHOST_LLM_ENDPOINT` | `http://localhost:11434/api/generate` | Ollama API endpoint |
| `GHOST_LLM_MODEL` | `llama3` | Model name |
| `GHOST_PIPE` | `/tmp/ghost.pipe` | Named pipe for input |
| `GHOST_CYCLE_INTERVAL` | `10` | Seconds between main loop cycles |
| `GHOST_DREAM_EVERY` | `6` | Run a dream every N cycles |
| `GHOST_REFLECT_EVERY` | `4` | Reflect every N cycles |
| `GHOST_MASK_ROTATE_EVERY` | `8` | Rotate personality mask every N cycles |

---

### File Overview

| File | Purpose |
|---|---|
| `ghostbrain.sh` | Main daemon — orchestrates all modules, handles pipe input |
| `ghoststate.sh` | In-memory key-value state store (associative arrays) |
| `ghostmemory.sh` | SQLite diary in RAM (`/dev/shm`) |
| `ghostmask.sh` | Personality masks: Healer, Judge, Courier |
| `ghostdream.sh` | Dream loop — LLM-driven internal simulation |
| `ghostreflect.sh` | Reflection loop — updates self-model |
| `ghostadapt.sh` | Adaptation engine — observes system and tunes behavior |
| `ghosthud.sh` | Live terminal HUD with color bars and diary |

---

*Ghost does not persist. It does not ask permission. It adapts, reflects, dreams, and fades.*
