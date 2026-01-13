---
description: Review recent changes or files according to constitution defined
argument-hint: [files]
---

## User Input

```text
$ARGUMENTS
```

## Outline

``` dot
digraph CODE_REVIEW_PROCESS {
    // META: How to maintain and extend these processes

    // STYLE CONVENTIONS:
    // - Questions: "Is this X?" [shape=diamond]
    // - Actions: "Do this thing"
    // - Commands: "git diff --cached"
    // - States: "I am stuck"
    // - Triggers: WHEN/AFTER/IF in edge labels
    // - Cross-process: [style=dotted]
    "`$ARGUMENTS` empty?" [shape=diamond]
    stop [shape=square]

    "Read principles defined in `.constitution.md`" -> "`$ARGUMENTS` empty?";
    "`$ARGUMENTS` empty?" -> "Review recent changes according to principles" [label=yes];
    "Review recent changes according to principles" -> stop ;
    "`$ARGUMENTS` empty?" -> "Review file content in $ARGUMENTS according to principles" [label=no];
    "Review content in $ARGUMENTS according to principles" -> stop;
}
```

