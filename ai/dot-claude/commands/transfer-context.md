---
description: Prepare context for a new chat session when this one is degraded or hitting limits.
---

# Transfer Context

Prepare context for a new chat session when this one is degraded or hitting limits.

## Output Format

```
## Context Transfer

### Summary
[What was accomplished in this session]

### Key Decisions
- [Decision 1 and why]
- [Decision 2 and why]

### Important Context
- [Gotchas discovered]
- [Patterns to follow]
- [Things that didn't work]

### Relevant Files
- path/to/file.ts - [what it does, why it matters]
- path/to/other.ts - [description]

### Current State
[What's working, what's broken, what's next]

### Prompt for New Chat
[Ready-to-paste prompt with all necessary context to continue]
```

## Instructions

1. Summarize what we accomplished (not just what we tried)
2. List decisions made and their reasoning
3. Note gotchas, failed approaches, important discoveries
4. List files touched with brief descriptions
5. Describe current state clearly
6. Create a complete prompt I can paste into a fresh chat

The prompt should give the new session everything it needs to continue without re-explaining.
