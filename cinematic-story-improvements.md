# Cinematic Story & Dialogue Improvements Plan

## Overview
Improve story delivery across all cinematics and upgrade the dialogue format from `\n` escape characters to arrays of lines for better readability and editing.

---

## Part 1: Dialogue Format Upgrade

### Current Format (with \n)
```json
"dialogues": [
  "Walton: line 1\nCollins: line 2\nWalton: line 3"
]
```

### New Format (array of lines)
```json
"dialogues": [
  ["Walton: line 1", "Collins: line 2", "Walton: line 3"],
  ["Single line dialogue"],
  ["Line 1", "Line 2", "Line 3"]
]
```

### Benefits
- Easier to read and edit in any text editor
- Each line is a separate element (no escape character issues)
- Can still have multiple speakers per dialogue entry
- Cleaner git diffs when editing

### Code Changes Required
**File: [Core/Cinematics/CinematicLoader.gd](Core/Cinematics/CinematicLoader.gd)**

Update dialogue parsing to handle both formats:
```gdscript
# In _load_config_from_json() where dialogues are processed:
for dialogue in raw_dialogues:
    if dialogue is Array:
        # New format: array of lines - join with newlines
        result.append("\n".join(dialogue))
    else:
        # Legacy format: string (may contain \n)
        result.append(str(dialogue))
```

This maintains **backwards compatibility** - old configs still work.

---

## Part 2: Story Summary

### Characters
- **Dr. Geoffrey Collins**: Humanitarian doctor giving free medicine in Zalimbwe
- **Anabelle**: Collins' nurse partner - secretly Sharaka's wife, planted the diamonds
- **Aluminum Pharma**: Private medical corporation, antagonist (Collins hurts their profits)
- **Julia Mellinguer**: INTERPAX officer, Walton's partner, admires Collins, love interest
- **Thomas Walton**: INTERPAX officer, orchestrates the rescue
- **Mbeki Sharaka**: Prison workshop boss - manipulated by Aluminum Pharma into believing Collins is having an affair with his wife Anabelle
- **Benjamin Kaluga**: Prison block boss, professional boxer, final boss
- **Amir Rahiri**: Friendly inmate from Madagascar, delivers intel

### International Police Organization: **INTERPAX**
**Full name:** International Police Action Exchange

### Key Plot Points
1. **The Frame-up**: Aluminum Pharma wants Collins gone (free medicine = lost profits)
2. **The Manipulation**: Aluminum Pharma tells Sharaka his wife is cheating with Collins
3. **The Betrayal**: Anabelle (Sharaka's wife, Collins' nurse) plants diamonds
4. **The Revelation**: After defeating Sharaka, Collins learns the truth about Anabelle

---

## Part 3: Chapter-by-Chapter Story Fixes

### INTRO - Needs improvement
**Current issues:**
- "Agente internacional" is vague - should specify INTERPAX
- Doesn't show WHY Collins was framed (Aluminum Pharma motivation)
- Should introduce Anabelle as Collins' trusted nurse partner

**Proposed dialogue flow:**
1. Setting: Zalimbwe, Collins giving free vaccinations with nurse Anabelle
2. Collins dialogue with patient (show his compassion)
3. Introduce Mellinguer as INTERPAX officer observing
4. Hint at Aluminum Pharma losing profits due to Collins' free medicine
5. Inspection scene - diamonds "found" (Anabelle planted them)
6. Collins arrested, Mellinguer shocked
7. Mellinguer wants to resign, Walton proposes rescue plan

### CHAPTER 1 - Minor tweaks
- Clarify Walton/Mellinguer are INTERPAX partners
- Hint that a corporation is behind the framing

### CHAPTER 3 - Good as is
- Rahiri delivers tactical info
- Warns about Sharaka and Kaluga

### CHAPTER 4 - Good as is
- Confrontation with Sharaka before fight
- Philosophical clash about the system

### CHAPTER 5 - ADD REVELATION!
**After defeating Sharaka, Collins discovers the truth:**
- Sharaka, defeated, mentions his wife betrayed HIM too
- Reveals Aluminum Pharma told him Collins was having an affair with Anabelle
- Collins realizes Anabelle planted the diamonds - she was manipulated/paid
- Emotional moment: both men were pawns in Aluminum Pharma's scheme
- Possible moment of understanding between Collins and Sharaka

### CHAPTER 6 - Kaluga confrontation (exists, is fine)
- Brief tense exchange before boss fight

### CHAPTER 7 - Needs full dialogue
**Current placeholders:** Hermana, Charla, Abrazo, Despedida, Viaje, Cadena, Beso, Trío

**Proposed dialogue flow:**
1. Walton: "Relájate, todo ha terminado."
2. Collins reunites with parents (emotional)
3. Collins meets his sister
4. Family conversation/catching up
5. Emotional family embrace
6. Family says goodbye as Collins leaves with Mellinguer
7. Journey scene (Collins and Mellinguer traveling)
8. Romantic moment (chains as symbol of freedom?)
9. Collins and Mellinguer kiss
10. Final shot: Collins and Mellinguer together (happiness after ordeal)

---

## Part 4: Implementation Steps

### Step 1: Update CinematicLoader.gd
Add array-of-lines support while keeping backwards compatibility.

### Step 2: Update INTRO config.json
Rewrite dialogues to:
- Set location as Zalimbwe
- Introduce Anabelle as Collins' nurse partner
- Clarify Mellinguer works for INTERPAX
- Mention Aluminum Pharma as the threat

### Step 3: Update CHAPTER 5 config.json
Add the revelation after Sharaka is defeated:
- Sharaka reveals Aluminum Pharma's manipulation
- Collins learns Anabelle (Sharaka's wife) planted the diamonds
- Both men realize they were pawns

### Step 4: Update CHAPTER 7 config.json
Replace placeholder text with full emotional dialogues for:
- Family reunion (parents + sister)
- Romantic conclusion with Mellinguer

### Step 5: Convert all configs to new array format
Update all chapter configs to use `[["line1", "line2"], ...]` format.

---

## Files to Modify

1. **[Core/Cinematics/CinematicLoader.gd](Core/Cinematics/CinematicLoader.gd)** - Parse array dialogues
2. **[Cinematics/intro/config.json](Cinematics/intro/config.json)** - Story improvements + Anabelle intro
3. **[Cinematics/chapter5/config.json](Cinematics/chapter5/config.json)** - Add revelation scene
4. **[Cinematics/chapter7/config.json](Cinematics/chapter7/config.json)** - Full dialogue content
5. **All other config.json files** - Convert to array format (chapter1, chapter3, chapter4, chapter6)

---

## Verification
1. Test CinematicLoader with both old and new dialogue formats
2. Play through intro cinematic - verify Anabelle and INTERPAX are introduced
3. Play through chapter 5 - verify revelation scene has emotional impact
4. Play through chapter 7 - verify family reunion and romance scenes work
5. Test all cinematics end-to-end (skip through with Space)
