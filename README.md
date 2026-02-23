# Ghost

**A weird little bash daemon that lives in RAM.**

Ghost runs in your terminal, keeps a diary, switches personalities, dreams,
reflects on itself, and shows you a live colorful HUD of its "mind state".

No cloud. No API keys. Just you, [Ollama](https://ollama.com), and a slightly
unhinged shell script that refuses to be boring.

---

## Quick Start

```bash
git clone https://github.com/vanj900/Ghost.git
cd Ghost

# Install dependencies
sudo apt install jq sqlite3 bc curl -y          # Ubuntu / Debian
# brew install jq sqlite bc curl bash           # macOS (bash ≥ 4 required)

# Install Ollama and pull the model
curl -fsSL https://ollama.com/install.sh | sh
ollama pull llama3.2

chmod +x *.sh
./ghostbrain.sh
```

Ghost wakes up, initialises its RAM diary, and starts ticking every 5 seconds.
The HUD refreshes every 10 seconds.

---

## Talking to Ghost

While Ghost is running, pipe a message to it:

```bash
echo "how are you feeling?" > /tmp/ghost.pipe
echo "what are you dreaming about?" > /tmp/ghost.pipe
echo "switch to judge mode" > /tmp/ghost.pipe
```

Ghost responds in the terminal and logs everything to its in-memory diary.
Press **Ctrl-C** to suspend it (diary is wiped — ephemeral by design).

---

## What It Does

| Feature | Description |
|---|---|
| **5-second pulse** | Main loop ticks every 5 s; HUD refreshes every 10 s |
| **Reflect** (every ~25 s) | Updates confidence, threat level, mood |
| **Dream** (every ~50 s) | Sends a weird hypothetical to Ollama; logs the vision |
| **Adapt** (every ~75 s) | Calculates 4 metrics, evolves stage, rotates personality mask |
| **Masks** | Healer (green) · Judge (red) · Courier (yellow) — changes LLM tone |
| **Memory diary** | SQLite in `/dev/shm` (pure RAM); vanishes on exit |
| **Live HUD** | Colored bars: consistency, adaptability, proactivity, curiosity, confidence, threat |
| **Named pipe** | `/tmp/ghost.pipe` — talk to it live from any terminal |

---

## Metrics Explained

- **Consistency** — how often the same emotion dominates memory
- **Adaptability** — variety of emotional states experienced
- **Proactivity** — ratio of self-initiated events vs user input
- **Curiosity** — how many dream cycles have run

Stage progression: `dormant` → `emerging` (5 cycles) → `aware` (20) → `evolved` (50)

---

## Files

| File | Role |
|---|---|
| `ghostbrain.sh` | Main loop — sources everything, manages pipe, orchestrates cycles |
| `ghoststate.sh` | Live terminal HUD with colored progress bars |
| `ghostllm.sh` | Ollama bridge (`localhost:11434`) |
| `ghostmemory.sh` | SQLite diary helper (RAM-backed) |
| `ghostdream.sh` | Dream cycle — LLM scenario simulation |
| `ghostreflect.sh` | Introspection — confidence, threat, mood |
| `ghostadapt.sh` | Evolution — 4 metrics, stage, self-model JSON, mask selection |

---

## Configuration

Set these before launching:

```bash
GHOST_PULSE=5           # seconds per cycle (default: 5)
GHOST_LLM_MODEL=llama3.2  # any model you have pulled
GHOST_PIPE=/tmp/ghost.pipe  # input pipe path
./ghostbrain.sh
```

---

*Ghost does not persist. It adapts, reflects, dreams, and fades.*  
*Run it long enough and watch the metrics change.*
